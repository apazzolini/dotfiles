import { readFile } from "node:fs/promises";
import { homedir } from "node:os";
import { join } from "node:path";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { loadConfig } from "./config.js";
import {
  clearStatusBar,
  isFastEnabled,
  toggleFast,
  updateCompressionStatus,
  updateFastStatus,
} from "./fast-mode.js";
import { registerApplyPatchSupport } from "./apply-patch-tool.js";
import { compactionLifecycle } from "./lifecycle.js";
import { effectiveBranchMessages, manualCompaction } from "./manual-compaction.js";
import { isEligibleGptModelId } from "./model-eligibility.js";
import { streamGptEnhancedResponses } from "./stream.js";

type JsonRecord = Record<string, unknown>;
type ConfiguredModel = string | JsonRecord;

type ConfiguredProvider = JsonRecord & {
  api?: unknown;
  models?: ConfiguredModel[];
};

type CommandTone = "accent" | "dim" | "error" | "success" | "text" | "warning";
type CommandTheme = {
  fg?: (color: CommandTone, text: string) => string;
  bold?: (text: string) => string;
};
type CommandUi = {
  theme?: CommandTheme;
  notify: (message: string, type?: "info" | "warning" | "error") => void;
};
type CommandRow = {
  label: string;
  value: string;
  tone?: CommandTone;
};

const STATE_ENTRY_TYPE = "gpt-enhance-stateless-compaction";

const GPT_ENHANCE_SUBCOMMANDS = [
  { value: "status", label: "status", description: "Show enhancement status" },
  { value: "fast", label: "fast", description: "Toggle Fast mode" },
  { value: "update", label: "update", description: "Clear the compaction capability cache" },
  { value: "compact", label: "compact", description: "Compact the server response chain" },
];

function commandCompletions(prefix: string) {
  const candidate = prefix.trimStart().toLowerCase();
  if (/\s/.test(candidate)) return null;
  const matches = GPT_ENHANCE_SUBCOMMANDS.filter(({ value }) => value.startsWith(candidate));
  return matches.length > 0 ? matches : null;
}

function themed(theme: CommandTheme | undefined, tone: CommandTone, text: string): string {
  return typeof theme?.fg === "function" ? theme.fg(tone, text) : text;
}

function formatCommandPanel(
  theme: CommandTheme | undefined,
  title: string,
  rows: readonly CommandRow[],
): string {
  const heading = typeof theme?.bold === "function" ? theme.bold(title) : title;
  const labelWidth = Math.max(0, ...rows.map(({ label }) => label.length)) + 2;
  return [
    themed(theme, "accent", heading),
    ...rows.flatMap(({ label, value, tone = "text" }) =>
      value
        .split(/\r?\n/)
        .map((line, index) =>
          index === 0
            ? `  ${themed(theme, "dim", label.padEnd(labelWidth))}${themed(theme, tone, line)}`
            : `${" ".repeat(labelWidth + 2)}${themed(theme, tone, line)}`,
        ),
    ),
  ].join("\n");
}

function notifyCommand(
  ui: CommandUi,
  title: string,
  rows: readonly CommandRow[],
  type: "info" | "warning" | "error" = "info",
): void {
  ui.notify(formatCommandPanel(ui.theme, title, rows), type);
}

function modelLabel(model: unknown): string {
  if (!isRecord(model)) return "none";
  const provider = typeof model.provider === "string" ? model.provider : "unknown";
  const id = typeof model.id === "string" ? model.id : "unknown";
  return `${provider}/${id}`;
}

function isRecord(value: unknown): value is JsonRecord {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function restoreCompactionContext(ctx: ExtensionContext, model: unknown): void {
  const checkpoints = ctx.sessionManager
    .getBranch()
    .flatMap((entry) =>
      entry.type === "custom" && entry.customType === STATE_ENTRY_TYPE ? [entry.data] : [],
    );
  compactionLifecycle.restoreContext(model, effectiveBranchMessages(ctx), checkpoints);
}

async function loadModelsConfig(): Promise<Record<string, ConfiguredProvider>> {
  try {
    const raw = await readFile(join(homedir(), ".pi", "agent", "models.json"), "utf8");
    const parsed: unknown = JSON.parse(raw);
    if (!isRecord(parsed) || !isRecord(parsed.providers)) return {};
    return Object.fromEntries(
      Object.entries(parsed.providers).filter((entry): entry is [string, ConfiguredProvider] =>
        isRecord(entry[1]),
      ),
    );
  } catch {
    return {};
  }
}

function configuredModelId(model: ConfiguredModel): string | undefined {
  return typeof model === "string" ? model : typeof model.id === "string" ? model.id : undefined;
}

function providerFields(provider: ConfiguredProvider | undefined): JsonRecord {
  if (!provider) return {};
  const { models: _models, ...fields } = provider;
  return fields;
}

async function registerResponsesProviders(pi: ExtensionAPI): Promise<void> {
  const configuredProviders = await loadModelsConfig();
  const configuredOpenAI = configuredProviders.openai;
  if (!configuredOpenAI || configuredOpenAI.api === "openai-responses") {
    pi.registerProvider("openai", {
      ...providerFields(configuredOpenAI),
      api: "openai-responses",
      streamSimple: streamGptEnhancedResponses,
    });
  }

  for (const [providerName, provider] of Object.entries(configuredProviders)) {
    if (
      providerName === "openai" ||
      provider.api !== "openai-responses" ||
      !provider.models?.some((model) => isEligibleGptModelId(configuredModelId(model)))
    ) {
      continue;
    }

    pi.registerProvider(providerName, {
      ...providerFields(provider),
      api: "openai-responses",
      streamSimple: streamGptEnhancedResponses,
    });
  }
}

export default async function gptEnhance(pi: ExtensionAPI): Promise<void> {
  const config = loadConfig();
  if (!config.enabled) return;

  await registerResponsesProviders(pi);
  const applyPatchSupport = registerApplyPatchSupport(pi, { enabled: config.applyPatch });
  let durableCompactionPending = false;
  let durableCompactionInProgress = false;
  const refreshStatusBar = (
    ctx: Parameters<typeof updateFastStatus>[0],
    model = ctx?.model,
  ): void => {
    updateCompressionStatus(ctx, compactionLifecycle.capability(model), {
      statusBar: config.statusBar,
      compression: config.compression,
      eligible: compactionLifecycle.isEligible(model),
    });
    updateFastStatus(ctx, model, config.statusBar);
  };

  pi.on("session_start", (_event, ctx) => {
    durableCompactionPending = false;
    durableCompactionInProgress = false;
    restoreCompactionContext(ctx, ctx.model);
    refreshStatusBar(ctx);
  });

  pi.on("model_select", (event, ctx) => {
    restoreCompactionContext(ctx, event.model);
    refreshStatusBar(ctx, event.model);
  });

  pi.on("message_end", async (event, ctx) => {
    const outcome = await compactionLifecycle.finishMessage(event.message, ctx.model);
    refreshStatusBar(ctx);
    if (outcome.kind !== "server-compacted") return;

    durableCompactionPending = true;
    if (outcome.checkpoint) pi.appendEntry(STATE_ENTRY_TYPE, outcome.checkpoint);
    if (config.notify && ctx.hasUI) {
      ctx.ui.notify(
        `OpenAI server compaction completed for ${outcome.provider}/${outcome.modelId}.`,
        "warning",
      );
    }
  });

  pi.on("agent_settled", (_event, ctx) => {
    if (!durableCompactionPending || durableCompactionInProgress || !ctx.isIdle()) return;

    durableCompactionPending = false;
    durableCompactionInProgress = true;
    ctx.compact({
      onComplete: () => {
        durableCompactionInProgress = false;
      },
      onError: (error) => {
        durableCompactionInProgress = false;
        durableCompactionPending = true;
        if (config.notify && ctx.hasUI) {
          ctx.ui.notify(`Pi durable compaction failed: ${error.message}`, "error");
        }
      },
    });
  });

  pi.on("session_compact", () => {
    durableCompactionPending = false;
    durableCompactionInProgress = false;
  });

  pi.on("session_before_switch", () => compactionLifecycle.clearContext());
  pi.on("session_before_fork", () => compactionLifecycle.clearContext());
  pi.on("session_before_tree", () => compactionLifecycle.clearContext());
  pi.on("session_tree", (_event, ctx) => {
    restoreCompactionContext(ctx, ctx.model);
  });
  pi.on("session_shutdown", (_event, ctx) => {
    durableCompactionPending = false;
    durableCompactionInProgress = false;
    clearStatusBar(ctx);
    compactionLifecycle.reset();
  });

  pi.registerCommand("gpt-enhance", {
    description:
      "Show GPT enhancement status, toggle Fast mode, refresh capabilities, or compact the server response chain",
    getArgumentCompletions: commandCompletions,
    handler: async (args, ctx) => {
      const subcommand = args.trim().toLowerCase() || "status";
      const model = ctx.model;
      const modelName = modelLabel(model);
      const eligible = compactionLifecycle.isEligible(model);

      if (subcommand === "status") {
        if (!eligible) {
          notifyCommand(
            ctx.ui,
            "gpt-enhance",
            [
              { label: "model", value: modelName },
              { label: "compatibility", value: "unavailable", tone: "warning" },
              { label: "requires", value: "openai-responses + gpt-*", tone: "dim" },
            ],
            "warning",
          );
          refreshStatusBar(ctx, model);
          return;
        }

        const capability = compactionLifecycle.capability(model);
        const fastEnabled = isFastEnabled(model);
        const applyPatchSupportState = applyPatchSupport.state();
        const applyPatchState =
          applyPatchSupportState === "active"
            ? ({ value: "active", tone: "success" } as const)
            : applyPatchSupportState === "external"
              ? ({ value: "external", tone: "dim" } as const)
              : applyPatchSupportState === "inactive"
                ? ({ value: "inactive", tone: "warning" } as const)
                : ({ value: "off", tone: "dim" } as const);
        const capabilityState = !config.compression
          ? ({ value: "disabled", tone: "dim" } as const)
          : capability === "supported"
            ? ({ value: "supported", tone: "success" } as const)
            : capability === "unsupported"
              ? ({ value: "unsupported", tone: "warning" } as const)
              : ({ value: "not probed", tone: "dim" } as const);

        notifyCommand(
          ctx.ui,
          "gpt-enhance",
          [
            { label: "model", value: modelName },
            { label: "server compact", ...capabilityState },
            {
              label: "continuation",
              value: config.store ? "server (store:true)" : "client (store:false)",
              tone: config.store ? "warning" : "success",
            },
            {
              label: "fast mode",
              value: fastEnabled ? "on (priority)" : "off",
              tone: fastEnabled ? "success" : "dim",
            },
            {
              label: "instructions",
              value: config.promoteSystemPromptToInstructions ? "on" : "off",
              tone: config.promoteSystemPromptToInstructions ? "success" : "dim",
            },
            { label: "apply_patch", ...applyPatchState },
            {
              label: "status bar",
              value: config.statusBar ? "on" : "off",
              tone: config.statusBar ? "success" : "dim",
            },
          ],
          "info",
        );
        refreshStatusBar(ctx, model);
        return;
      }

      if (!eligible) {
        refreshStatusBar(ctx, model);
        notifyCommand(
          ctx.ui,
          `gpt-enhance / ${subcommand}`,
          [
            { label: "model", value: modelName },
            { label: "state", value: "unavailable", tone: "warning" },
            { label: "requires", value: "openai-responses + gpt-*", tone: "dim" },
          ],
          "warning",
        );
        return;
      }

      if (subcommand === "fast") {
        try {
          const enabled = await toggleFast(model);
          refreshStatusBar(ctx, model);
          notifyCommand(ctx.ui, "gpt-enhance / fast", [
            { label: "model", value: modelName },
            {
              label: "state",
              value: enabled ? "on (priority)" : "off",
              tone: enabled ? "success" : "dim",
            },
          ]);
        } catch (error) {
          const message = error instanceof Error ? error.message : String(error);
          notifyCommand(
            ctx.ui,
            "gpt-enhance / fast",
            [
              { label: "state", value: "failed", tone: "error" },
              { label: "reason", value: message },
            ],
            "error",
          );
        }
        return;
      }

      if (subcommand === "update") {
        await compactionLifecycle.refreshCapabilities(model);
        refreshStatusBar(ctx, model);
        notifyCommand(ctx.ui, "gpt-enhance / update", [
          { label: "model", value: modelName },
          { label: "cache", value: "cleared", tone: "success" },
          { label: "next request", value: "will probe support", tone: "dim" },
        ]);
        return;
      }

      if (subcommand !== "compact") {
        notifyCommand(
          ctx.ui,
          "gpt-enhance / command",
          [
            { label: "unknown", value: subcommand, tone: "warning" },
            { label: "usage", value: "status | fast | update | compact", tone: "dim" },
          ],
          "warning",
        );
        return;
      }

      if (!ctx.isIdle()) {
        notifyCommand(
          ctx.ui,
          "gpt-enhance / compact",
          [
            { label: "state", value: "blocked", tone: "warning" },
            { label: "reason", value: "session is busy" },
          ],
          "warning",
        );
        return;
      }

      const auth = await ctx.modelRegistry.getApiKeyAndHeaders(model);
      if (!auth.ok) {
        notifyCommand(
          ctx.ui,
          "gpt-enhance / compact",
          [
            { label: "state", value: "failed", tone: "error" },
            { label: "reason", value: auth.error },
          ],
          "error",
        );
        return;
      }
      try {
        const result = await manualCompaction.compact(model, auth, ctx, {
          promoteSystemPromptToInstructions: config.promoteSystemPromptToInstructions,
        });
        if (result.checkpoint) pi.appendEntry(STATE_ENTRY_TYPE, result.checkpoint);
        notifyCommand(ctx.ui, "gpt-enhance / compact", [
          { label: "model", value: modelName },
          { label: "state", value: "completed", tone: "success" },
          { label: "response", value: result.responseId },
        ]);
      } catch (error) {
        const message = error instanceof Error ? error.message : String(error);
        notifyCommand(
          ctx.ui,
          "gpt-enhance / compact",
          [
            { label: "state", value: "failed", tone: "error" },
            { label: "reason", value: message },
            { label: "local fallback", value: "not run", tone: "dim" },
          ],
          "error",
        );
      }
    },
  });
}
