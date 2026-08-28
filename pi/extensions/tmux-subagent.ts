import { spawn } from "node:child_process";
import { randomBytes } from "node:crypto";
import * as fs from "node:fs";
import * as path from "node:path";
import {
  StringEnum,
  type AssistantMessage,
  type TextContent,
  type Usage,
} from "@earendil-works/pi-ai";
import {
  DEFAULT_MAX_BYTES,
  DEFAULT_MAX_LINES,
  formatSize,
  SessionManager,
  truncateHead,
  type ExtensionAPI,
  type SessionEntry,
} from "@earendil-works/pi-coding-agent";
import { Text } from "@earendil-works/pi-tui";
import { Type } from "typebox";

const REPORT_TOKEN_ENV = "PI_TMUX_SUBAGENT_TOKEN";
const REPORT_OPTION_PREFIX = "@pi_tmux_subagent_";
const REPORT_CHANNEL_PREFIX = "pi-tmux-subagent-";
const SLASH_COMMAND_PATTERN = /^\/[A-Za-z0-9][\w:.-]*(\s|$)/;

interface SubagentReport {
  state: "running" | "settled" | "closed";
  sessionFile?: string;
  exitCode?: number;
  usage?: Usage;
}

type SubagentThinking = "off" | "minimal" | "low" | "medium" | "high" | "xhigh" | "max";

interface SubagentParams {
  task: string;
  model?: string;
  thinking?: SubagentThinking;
  fork?: string;
}

interface SubagentDetails {
  task: string;
  windowId: string;
  windowName: string;
  sessionFile: string;
  stopReason?: string;
  forkedFrom?: string;
}

function getPiInvocation(args: string[]): { command: string; args: string[] } {
  const currentScript = process.argv[1];
  const isBunVirtualScript = currentScript?.startsWith("/$bunfs/root/");
  if (currentScript && !isBunVirtualScript && fs.existsSync(currentScript)) {
    return { command: process.execPath, args: [currentScript, ...args] };
  }

  const execName = path.basename(process.execPath).toLowerCase();
  const isGenericRuntime = /^(node|bun)(\.exe)?$/.test(execName);
  if (!isGenericRuntime) return { command: process.execPath, args };
  return { command: "pi", args };
}

function getAssistantText(message: AssistantMessage): string {
  return message.content
    .filter((part): part is TextContent => part.type === "text")
    .map((part) => part.text)
    .join("\n")
    .trim();
}

function getUsage(entries: SessionEntry[]): Usage | undefined {
  const total: Usage = {
    input: 0,
    output: 0,
    cacheRead: 0,
    cacheWrite: 0,
    totalTokens: 0,
    cost: {
      input: 0,
      output: 0,
      cacheRead: 0,
      cacheWrite: 0,
      total: 0,
    },
  };
  let hasUsage = false;

  for (const entry of entries) {
    let usage: Usage | undefined;
    if (
      entry.type === "message" &&
      (entry.message.role === "assistant" || entry.message.role === "toolResult")
    ) {
      usage = entry.message.usage;
    } else if (entry.type === "branch_summary" || entry.type === "compaction") {
      usage = entry.usage;
    }
    if (!usage) continue;

    hasUsage = true;
    total.input += usage.input;
    total.output += usage.output;
    total.cacheRead += usage.cacheRead;
    total.cacheWrite += usage.cacheWrite;
    total.totalTokens += usage.totalTokens;
    total.cost.input += usage.cost.input;
    total.cost.output += usage.cost.output;
    total.cost.cacheRead += usage.cost.cacheRead;
    total.cost.cacheWrite += usage.cost.cacheWrite;
    total.cost.total += usage.cost.total;
    if (usage.cacheWrite1h !== undefined) {
      total.cacheWrite1h = (total.cacheWrite1h ?? 0) + usage.cacheWrite1h;
    }
    if (usage.reasoning !== undefined) {
      total.reasoning = (total.reasoning ?? 0) + usage.reasoning;
    }
  }

  return hasUsage ? total : undefined;
}

export default function tmuxSubagent(pi: ExtensionAPI) {
  const reportToken = process.env[REPORT_TOKEN_ENV];
  if (reportToken) {
    if (!/^[a-f0-9]{16}$/.test(reportToken)) return;

    const optionName = `${REPORT_OPTION_PREFIX}${reportToken}`;
    const channelName = `${REPORT_CHANNEL_PREFIX}${reportToken}`;
    let sessionFile: string | undefined;
    let terminalReportSent = false;

    const report = async (state: SubagentReport["state"], entries?: SessionEntry[]) => {
      if (state !== "running") {
        if (terminalReportSent) return;
        terminalReportSent = true;
      }

      const value = JSON.stringify({
        state,
        sessionFile,
        usage: entries ? getUsage(entries) : undefined,
      } satisfies SubagentReport);
      await pi.exec("tmux", ["set-option", "-gq", optionName, value]);
      if (state !== "running") {
        await pi.exec("tmux", ["wait-for", "-S", channelName]);
      }
    };

    pi.on("session_start", async (_event, ctx) => {
      sessionFile = ctx.sessionManager.getSessionFile();
      await report("running");
    });
    pi.on("agent_settled", async (_event, ctx) => {
      await report("settled", ctx.sessionManager.getEntries());
    });
    pi.on("session_shutdown", async (_event, ctx) => {
      await report("closed", ctx.sessionManager.getEntries());
    });
    return;
  }

  pi.registerTool({
    name: "tmux_subagent",
    label: "Tmux Subagent",
    description:
      "Run a delegated task in a fresh interactive pi session in a new window of the current tmux session. The user can watch or steer the subagent while it runs, and the window closes when it finishes. Optionally accepts model and thinking-level overrides. Waits for the subagent to settle, then returns its final response from the pi session transcript. A task that is exactly a slash command, such as `/review src/api`, is sent verbatim as the subagent's first message so the subagent expands that prompt template itself. Pass `fork` with the transcript path of a previously primed subagent to start from a copy of that session, so the new subagent inherits its context without seeing anything that happened in other forks.",
    promptSnippet:
      "Run a delegated task with optional model and thinking overrides in an interactive pi session in a new tmux window",
    promptGuidelines: [
      'Use tmux_subagent when the user asks to do work "in a subagent", "using a subagent", or with equivalent delegation language.',
      "When you delegate repeatedly against the same background context, prime one subagent with that context and then pass its transcript path as `fork` on later calls, so each subagent inherits the primed context without inheriting the other forks' work.",
      'When the user specifies a subagent model or thinking level, pass them to tmux_subagent. Model names may be fuzzy phrases such as "gpt sol". Normalize colloquial thinking levels, such as "med", to the corresponding thinking value, such as "medium".',
    ],
    parameters: Type.Object({
      task: Type.String({ description: "The complete task to delegate to the subagent" }),
      model: Type.Optional(
        Type.String({
          description:
            'Optional pi model ID or fuzzy model phrase, such as "openai/gpt-5.6-sol" or "gpt sol". Inherits the parent model when omitted.',
        }),
      ),
      thinking: Type.Optional(
        StringEnum(["off", "minimal", "low", "medium", "high", "xhigh", "max"] as const, {
          description:
            'Optional thinking level. Normalize aliases such as "med" to "medium". Inherits the parent thinking level when omitted.',
        }),
      ),
      fork: Type.Optional(
        Type.String({
          description:
            "Optional transcript path reported by a previous tmux_subagent call. When set, the subagent starts from a fork of that session: it inherits everything that session had absorbed, writes to a new transcript so the base stays reusable, and keeps that session's model and thinking unless you override them explicitly.",
        }),
      ),
    }),
    prepareArguments(args): SubagentParams {
      if (!args || typeof args !== "object") return args as SubagentParams;
      const input = args as SubagentParams;
      if (typeof input.thinking === "string" && input.thinking.toLowerCase() === "med") {
        return { ...input, thinking: "medium" };
      }
      return input;
    },

    async execute(_toolCallId, params, signal, onUpdate, ctx) {
      const tmuxPane = process.env.TMUX_PANE;
      if (!process.env.TMUX || !tmuxPane) {
        throw new Error("tmux_subagent requires pi to be running inside tmux");
      }

      const sessionResult = await pi.exec(
        "tmux",
        ["display-message", "-p", "-t", tmuxPane, "#{session_name}"],
        { signal },
      );
      if (sessionResult.code !== 0) {
        throw new Error(
          sessionResult.stderr.trim() || "Could not identify the current tmux session",
        );
      }
      const tmuxSession = sessionResult.stdout.trim();

      const token = randomBytes(8).toString("hex");
      const optionName = `${REPORT_OPTION_PREFIX}${token}`;
      const channelName = `${REPORT_CHANNEL_PREFIX}${token}`;
      const taskPreview = params.task.replace(/\s+/g, " ").trim().slice(0, 32);
      const windowName = taskPreview
        ? `subagent: ${taskPreview}`
        : `subagent: ${token.slice(0, 6)}`;
      const trimmedTask = params.task.trim();
      const prompt = SLASH_COMMAND_PATTERN.test(trimmedTask)
        ? trimmedTask
        : [
            "Work independently as a subagent. Complete the task below, then give the parent agent a concise final report.",
            "The user may steer you interactively in this tmux window.",
            "",
            params.task,
          ].join("\n");
      const forkSource = params.fork?.trim();
      if (forkSource && !fs.existsSync(forkSource)) {
        throw new Error(`Cannot fork subagent session; transcript not found: ${forkSource}`);
      }
      const childArgs = forkSource
        ? ["--fork", forkSource, "--name", windowName]
        : ["--name", windowName];
      let childModel = params.model;
      if (childModel) {
        let availableModels = ctx.modelRegistry.getAvailable();
        if (ctx.scopedModels.length > 0) {
          availableModels = ctx.scopedModels.map((entry) => entry.model);
        }

        const normalizedModel = childModel.trim().toLowerCase();
        const exactMatches = availableModels.filter(
          (model) =>
            model.id.toLowerCase() === normalizedModel ||
            `${model.provider}/${model.id}`.toLowerCase() === normalizedModel,
        );
        let resolvedModel = exactMatches.length === 1 ? exactMatches[0] : undefined;
        if (!resolvedModel && ctx.model) {
          const currentProviderExactMatches = exactMatches.filter(
            (model) => model.provider === ctx.model?.provider,
          );
          if (currentProviderExactMatches.length === 1) {
            resolvedModel = currentProviderExactMatches[0];
          }
        }

        if (!resolvedModel) {
          const terms = normalizedModel.split(/[^a-z0-9]+/).filter(Boolean);
          const matches = availableModels.filter((model) => {
            const text = `${model.provider} ${model.id} ${model.name ?? ""}`.toLowerCase();
            return terms.every((term) => text.includes(term));
          });
          resolvedModel = matches.length === 1 ? matches[0] : undefined;
          if (!resolvedModel && ctx.model) {
            const currentProviderMatches = matches.filter(
              (model) => model.provider === ctx.model?.provider,
            );
            if (currentProviderMatches.length === 1) {
              resolvedModel = currentProviderMatches[0];
            }
          }
        }

        if (resolvedModel) childModel = `${resolvedModel.provider}/${resolvedModel.id}`;
      } else if (ctx.model && !forkSource) {
        childModel = `${ctx.model.provider}/${ctx.model.id}`;
      }
      if (childModel) childArgs.push("--model", childModel);
      const childThinking = forkSource ? params.thinking : (params.thinking ?? ctx.thinkingLevel);
      if (childThinking) childArgs.push("--thinking", childThinking);
      childArgs.push(prompt);
      const invocation = getPiInvocation(childArgs);
      const runnerScript = [
        "channel=$1",
        "option=$2",
        "shift 2",
        '"$@"',
        "status=$?",
        'if [ -z "$(tmux show-options -gqv "$option")" ]; then',
        '  tmux set-option -gq "$option" "{\\"state\\":\\"closed\\",\\"exitCode\\":$status}"',
        "fi",
        'tmux wait-for -S "$channel"',
        'exit "$status"',
      ].join("\n");

      const waiter = spawn("tmux", ["wait-for", channelName], {
        stdio: ["ignore", "ignore", "pipe"],
      });
      let waiterStderr = "";
      waiter.stderr.on("data", (data) => {
        waiterStderr += data.toString();
      });

      const launchResult = await pi.exec(
        "tmux",
        [
          "new-window",
          "-d",
          "-P",
          "-F",
          "#{window_id}",
          "-t",
          `${tmuxSession}:`,
          "-c",
          ctx.cwd,
          "-n",
          windowName,
          "-e",
          `${REPORT_TOKEN_ENV}=${token}`,
          "/bin/sh",
          "-c",
          runnerScript,
          "tmux-subagent-runner",
          channelName,
          optionName,
          invocation.command,
          ...invocation.args,
        ],
        { signal },
      );
      if (launchResult.code !== 0) {
        waiter.kill();
        throw new Error(launchResult.stderr.trim() || "Could not create the tmux subagent window");
      }
      const windowId = launchResult.stdout.trim();
      onUpdate?.({
        content: [
          { type: "text", text: `Subagent is running in tmux window ${windowId} (${windowName})` },
        ],
        details: { task: params.task, windowId, windowName },
      });

      await new Promise<void>((resolve, reject) => {
        const abort = () => {
          waiter.kill();
          void pi.exec("tmux", ["kill-window", "-t", windowId]);
          reject(new Error(`Subagent wait aborted; tmux window ${windowId} was closed`));
        };
        if (signal?.aborted) {
          abort();
          return;
        }
        signal?.addEventListener("abort", abort, { once: true });
        waiter.once("error", (error) => {
          signal?.removeEventListener("abort", abort);
          reject(error);
        });
        waiter.once("close", (code) => {
          signal?.removeEventListener("abort", abort);
          if (code === 0) resolve();
          else reject(new Error(waiterStderr.trim() || `tmux wait-for exited with code ${code}`));
        });
      });

      const reportResult = await pi.exec("tmux", ["show-options", "-gqv", optionName]);
      await pi.exec("tmux", ["kill-window", "-t", windowId]);
      void pi.exec("tmux", ["set-option", "-gu", optionName]);
      if (reportResult.code !== 0 || !reportResult.stdout.trim()) {
        throw new Error(
          `Subagent finished without reporting a session transcript; window: ${windowId}`,
        );
      }

      let report: SubagentReport;
      try {
        report = JSON.parse(reportResult.stdout.trim()) as SubagentReport;
      } catch {
        throw new Error(`Subagent returned an invalid completion report; window: ${windowId}`);
      }
      if (!report.sessionFile) {
        const exitCode = report.exitCode === undefined ? "" : `; exit code: ${report.exitCode}`;
        throw new Error(
          `Subagent exited before creating a persistent session transcript${exitCode}; window: ${windowId}`,
        );
      }

      const sessionManager = SessionManager.open(report.sessionFile);
      const branch = sessionManager.getBranch();
      let finalMessage: AssistantMessage | undefined;
      for (let i = branch.length - 1; i >= 0; i--) {
        const entry = branch[i];
        if (entry.type === "message" && entry.message.role === "assistant") {
          finalMessage = entry.message;
          break;
        }
      }
      if (!finalMessage) {
        throw new Error(
          `Subagent produced no assistant response; transcript: ${report.sessionFile}`,
        );
      }
      if (finalMessage.stopReason === "error" || finalMessage.stopReason === "aborted") {
        throw new Error(
          finalMessage.errorMessage ||
            `Subagent stopped with reason ${finalMessage.stopReason}; transcript: ${report.sessionFile}`,
        );
      }

      const subagentUsage = report.usage ?? getUsage(sessionManager.getEntries());
      const finalText =
        getAssistantText(finalMessage) || "(Subagent completed without a final text response.)";
      const truncated = truncateHead(finalText, {
        maxLines: DEFAULT_MAX_LINES,
        maxBytes: DEFAULT_MAX_BYTES,
      });
      let response = truncated.content;
      if (truncated.truncated) {
        response += `\n\n[Response truncated to ${formatSize(truncated.outputBytes)}. Full response is in ${report.sessionFile}.]`;
      }

      return {
        content: [
          {
            type: "text",
            text: `Subagent completed in tmux window ${windowId} (${windowName}), which is now closed.\nTranscript: ${report.sessionFile}\n\n${response}`,
          },
        ],
        details: {
          task: params.task,
          windowId,
          windowName,
          sessionFile: report.sessionFile,
          stopReason: finalMessage.stopReason,
          forkedFrom: forkSource,
        } satisfies SubagentDetails,
        usage: subagentUsage,
      };
    },

    renderCall(args, theme) {
      const preview = args.task.replace(/\s+/g, " ").trim();
      const title = args.fork ? "tmux subagent (fork) " : "tmux subagent ";
      return new Text(theme.fg("toolTitle", theme.bold(title)) + theme.fg("muted", preview), 0, 0);
    },

    renderResult(result, { isPartial }, theme) {
      const details = result.details as Partial<SubagentDetails> | undefined;
      if (isPartial) {
        const location = details?.windowId ? ` in ${details.windowId}` : "";
        return new Text(theme.fg("warning", `Running${location}...`), 0, 0);
      }
      if (details?.windowId) {
        return new Text(
          theme.fg("success", "✓ ") +
            theme.fg("accent", details.windowName || details.windowId) +
            theme.fg("muted", ` (${details.windowId})`),
          0,
          0,
        );
      }
      const content = result.content[0];
      return new Text(content?.type === "text" ? content.text : "Subagent failed", 0, 0);
    },
  });
}
