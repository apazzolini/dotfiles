import { spawn } from "node:child_process";
import { randomBytes } from "node:crypto";
import * as fs from "node:fs";
import * as path from "node:path";
import { fileURLToPath } from "node:url";
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
  parseFrontmatter,
  SessionManager,
  truncateHead,
  type ExtensionAPI,
  type SessionEntry,
} from "@earendil-works/pi-coding-agent";
import { Text } from "@earendil-works/pi-tui";
import { Type } from "typebox";

const REPORT_TOKEN_ENV = "PI_TMUX_SUBAGENT_TOKEN";
const REPORT_TOKEN_STATE = Symbol.for("andre-subagents.report-token-state");
const REPORT_OPTION_PREFIX = "@pi_tmux_subagent_";
const REPORT_CHANNEL_PREFIX = "pi-tmux-subagent-";
const SLASH_COMMAND_PATTERN = /^\/[A-Za-z0-9][\w:.-]*(\s|$)/;
const CHILD_ENV_EXCLUSIONS = new Set([
  "_",
  "OLDPWD",
  "PI_MODEL",
  "PI_PROVIDER",
  "PI_REASONING_LEVEL",
  "PI_SESSION_FILE",
  "PI_SESSION_ID",
  "PWD",
  "SHLVL",
  "TMUX",
  "TMUX_PANE",
  REPORT_TOKEN_ENV,
]);

interface ReportTokenState {
  claimed: boolean;
  token?: string;
}

interface SubagentReport {
  state: "running" | "settled" | "closed";
  sessionFile?: string;
  exitCode?: number;
  usage?: Usage;
}

type SubagentThinking = "off" | "minimal" | "low" | "medium" | "high" | "xhigh" | "max";

type SubagentContext = "fresh" | "fork";
type SystemPromptMode = "append" | "replace";

interface SubagentParams {
  agent: string;
  task: string;
  context?: SubagentContext;
  model?: string;
  thinking?: SubagentThinking;
  fork?: string;
  cwd?: string;
}

interface SubagentDetails {
  agent: string;
  task: string;
  windowId: string;
  windowName: string;
  sessionFile: string;
  stopReason?: string;
  forkedFrom?: string;
}

type AgentFrontmatter = {
  name?: unknown;
  aliases?: unknown;
  description?: unknown;
  tools?: unknown;
  model?: unknown;
  thinking?: unknown;
  systemPromptMode?: unknown;
  defaultContext?: unknown;
  inheritSkills?: unknown;
};

interface AgentConfig {
  name: string;
  aliases: string[];
  description: string;
  tools?: string[];
  model?: string;
  thinking?: SubagentThinking;
  systemPromptMode: SystemPromptMode;
  defaultContext: SubagentContext;
  inheritSkills: boolean;
  systemPrompt: string;
}

const THINKING_LEVELS = new Set<SubagentThinking>([
  "off",
  "minimal",
  "low",
  "medium",
  "high",
  "xhigh",
  "max",
]);

function parseStringList(value: unknown): string[] {
  const values = Array.isArray(value) ? value : typeof value === "string" ? value.split(",") : [];
  return values
    .filter((item): item is string => typeof item === "string")
    .map((item) => item.trim())
    .filter(Boolean);
}

function loadAgents(): AgentConfig[] {
  const agentsDir = fileURLToPath(new URL("./agents/", import.meta.url));
  return fs
    .readdirSync(agentsDir, { withFileTypes: true })
    .filter((entry) => entry.isFile() && entry.name.endsWith(".md"))
    .sort((left, right) => left.name.localeCompare(right.name))
    .flatMap((entry) => {
      const content = fs.readFileSync(path.join(agentsDir, entry.name), "utf8");
      const { frontmatter, body } = parseFrontmatter<AgentFrontmatter>(content);
      if (typeof frontmatter.name !== "string" || typeof frontmatter.description !== "string") {
        return [];
      }
      const thinking =
        typeof frontmatter.thinking === "string" &&
        THINKING_LEVELS.has(frontmatter.thinking as SubagentThinking)
          ? (frontmatter.thinking as SubagentThinking)
          : undefined;
      return [
        {
          name: frontmatter.name,
          aliases: parseStringList(frontmatter.aliases),
          description: frontmatter.description,
          tools: parseStringList(frontmatter.tools),
          model: typeof frontmatter.model === "string" ? frontmatter.model : undefined,
          thinking,
          systemPromptMode: frontmatter.systemPromptMode === "append" ? "append" : "replace",
          defaultContext: frontmatter.defaultContext === "fork" ? "fork" : "fresh",
          inheritSkills: frontmatter.inheritSkills !== false,
          systemPrompt: body.trim(),
        },
      ];
    });
}

function findAgent(agents: AgentConfig[], requestedName: string): AgentConfig | undefined {
  const normalizedName = requestedName.trim().toLowerCase();
  return agents.find(
    (agent) =>
      agent.name.toLowerCase() === normalizedName ||
      agent.aliases.some((alias) => alias.toLowerCase() === normalizedName),
  );
}

function claimReportToken(): string | undefined {
  const stateHost = globalThis as typeof globalThis & { [key: symbol]: unknown };
  const existingState = stateHost[REPORT_TOKEN_STATE] as ReportTokenState | undefined;
  if (existingState?.claimed) return existingState.token;

  const environmentToken = process.env[REPORT_TOKEN_ENV];
  delete process.env[REPORT_TOKEN_ENV];
  const token = environmentToken && /^[a-f0-9]{16}$/.test(environmentToken)
    ? environmentToken
    : undefined;
  stateHost[REPORT_TOKEN_STATE] = { claimed: true, token } satisfies ReportTokenState;
  return token;
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
  const reportToken = claimReportToken();
  if (reportToken) {
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

  const agents = loadAgents();
  const agentSummary = agents.map((agent) => `${agent.name}: ${agent.description}`).join("; ");

  pi.registerTool({
    name: "subagent",
    label: "Subagent",
    description: [
      "Delegate one focused task to a configured agent running as a full interactive Pi session in a new tmux window.",
      "The user can watch or steer the child directly while it runs; the parent waits for settlement and receives the final response and transcript path.",
      "Use multiple sibling tool calls for parallel work. The parent remains the workflow controller and final decision-maker.",
      "A task that is exactly a slash command, such as `/review src/api`, is sent verbatim so the child expands the packaged prompt itself.",
      "Use `context: fork` to inherit the current parent session, or `fork` with a prior child transcript to reuse a primed base without inheriting sibling work.",
      `Available agents: ${agentSummary}`,
    ].join(" "),
    promptSnippet:
      "Delegate a focused task to a role-specific interactive Pi child session in a tmux window",
    promptGuidelines: [
      "Use subagent when independent context, parallel evidence, adversarial review, or focused implementation materially improves the result.",
      "Keep the parent session in control of orchestration, synthesis, accepted fixes, and user-facing decisions. Children must not launch subagents.",
      "Use fresh-context reviewer children for independent review. Use forked context for workers or oracles that need the parent conversation's decisions.",
      "Launch independent read-only subagent calls in the same tool block so Pi runs them in parallel.",
      "Never automatically create a worktree. Never launch concurrent writers in the same working tree.",
      "When delegating repeatedly against a reusable background context, prime one child and pass its transcript path as `fork` on later calls.",
      'When the user specifies a model or thinking level, pass it to subagent. Model names may be fuzzy phrases such as "gpt sol"; normalize "med" to "medium".',
    ],
    parameters: Type.Object({
      agent: Type.String({
        description: `Configured agent name. Available: ${agents.map((agent) => agent.name).join(", ")}`,
      }),
      task: Type.String({ description: "The complete task to delegate to the child" }),
      context: Type.Optional(
        StringEnum(["fresh", "fork"] as const, {
          description:
            "Context policy. fresh starts clean; fork inherits the current parent transcript. Defaults to the selected agent's policy.",
        }),
      ),
      model: Type.Optional(
        Type.String({
          description:
            'Optional Pi model ID or fuzzy model phrase, such as "openai/gpt-5.6-sol" or "gpt sol". Overrides the agent default.',
        }),
      ),
      thinking: Type.Optional(
        StringEnum(["off", "minimal", "low", "medium", "high", "xhigh", "max"] as const, {
          description:
            'Optional thinking level. Normalize aliases such as "med" to "medium". Overrides the agent default.',
        }),
      ),
      fork: Type.Optional(
        Type.String({
          description:
            "Optional transcript path from a previous child. Starts from a copy of that session so the base remains reusable.",
        }),
      ),
      cwd: Type.Optional(
        Type.String({ description: "Optional working directory for the child. Defaults to the parent cwd." }),
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
        throw new Error("subagent requires Pi to be running inside tmux");
      }
      const agent = findAgent(agents, params.agent);
      if (!agent) {
        throw new Error(
          `Unknown subagent '${params.agent}'. Available agents: ${agents.map((candidate) => candidate.name).join(", ")}`,
        );
      }
      const childCwd = params.cwd?.trim() || ctx.cwd;
      if (!fs.existsSync(childCwd) || !fs.statSync(childCwd).isDirectory()) {
        throw new Error(`Subagent cwd is not a directory: ${childCwd}`);
      }
      const inheritedEnvironmentArgs = Object.entries(process.env).flatMap(([name, value]) =>
        value === undefined || CHILD_ENV_EXCLUSIONS.has(name) ? [] : ["-e", `${name}=${value}`],
      );

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
      const taskPreview = params.task.replace(/\s+/g, " ").trim().slice(0, 28);
      const windowName = taskPreview
        ? `${agent.name}: ${taskPreview}`
        : `${agent.name}: ${token.slice(0, 6)}`;
      const trimmedTask = params.task.trim();
      const prompt = SLASH_COMMAND_PATTERN.test(trimmedTask)
        ? trimmedTask
        : [
            `Work independently as the ${agent.name} subagent. Complete the task below, then give the parent agent a concise final report.`,
            "The user may steer you interactively in this tmux window.",
            "Do not launch or propose additional subagents; the parent session owns orchestration.",
            "",
            params.task,
          ].join("\n");
      const context = params.context ?? agent.defaultContext;
      const requestedForkSource = params.fork?.trim();
      const explicitForkSource = requestedForkSource
        ? path.resolve(ctx.cwd, requestedForkSource)
        : undefined;
      let sessionSource = explicitForkSource;
      let forkedFrom = explicitForkSource;
      let usePreparedParentFork = false;
      if (!sessionSource && context === "fork") {
        const parentSessionFile = ctx.sessionManager.getSessionFile();
        const currentLeaf = ctx.sessionManager.getLeafEntry();
        if (!parentSessionFile) {
          throw new Error("Cannot fork the parent context because this Pi session is not persisted");
        }
        if (
          currentLeaf?.type !== "message" ||
          currentLeaf.message.role !== "assistant" ||
          !currentLeaf.parentId
        ) {
          throw new Error("Cannot identify a safe parent context before the current subagent call");
        }
        const forkManager = SessionManager.open(parentSessionFile, undefined, childCwd);
        sessionSource = forkManager.createBranchedSession(currentLeaf.parentId);
        if (!sessionSource) throw new Error("Could not prepare the parent context for the subagent");
        forkManager.appendCustomEntry("subagent-fork-base", { parentSessionFile });
        if (!fs.existsSync(sessionSource)) {
          const header = forkManager.getHeader();
          if (!header) throw new Error("Prepared parent context is missing its session header");
          const serializedSession = [header, ...forkManager.getEntries()]
            .map((entry) => JSON.stringify(entry))
            .join("\n");
          fs.writeFileSync(sessionSource, `${serializedSession}\n`, { flag: "wx", mode: 0o600 });
        }
        forkedFrom = parentSessionFile;
        usePreparedParentFork = true;
      }
      if (sessionSource && !fs.existsSync(sessionSource)) {
        throw new Error(`Cannot fork subagent session; transcript not found: ${sessionSource}`);
      }
      const childArgs = sessionSource
        ? [usePreparedParentFork ? "--session" : "--fork", sessionSource, "--name", windowName]
        : ["--name", windowName];
      if (agent.systemPrompt) {
        childArgs.push(
          agent.systemPromptMode === "append" ? "--append-system-prompt" : "--system-prompt",
          agent.systemPrompt,
        );
      }
      if (agent.tools && agent.tools.length > 0) childArgs.push("--tools", agent.tools.join(","));
      if (!agent.inheritSkills) childArgs.push("--no-skills");
      let childModel = params.model ?? agent.model;
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
      } else if (ctx.model && !sessionSource) {
        childModel = `${ctx.model.provider}/${ctx.model.id}`;
      }
      if (childModel) childArgs.push("--model", childModel);
      const childThinking = params.thinking ?? agent.thinking ?? (sessionSource ? undefined : ctx.thinkingLevel);
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
          childCwd,
          "-n",
          windowName,
          ...inheritedEnvironmentArgs,
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
        details: { agent: agent.name, task: params.task, windowId, windowName },
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
          agent: agent.name,
          task: params.task,
          windowId,
          windowName,
          sessionFile: report.sessionFile,
          stopReason: finalMessage.stopReason,
          forkedFrom,
        } satisfies SubagentDetails,
        usage: subagentUsage,
      };
    },

    renderCall(args, theme) {
      const preview = args.task.replace(/\s+/g, " ").trim();
      const context = args.fork || args.context === "fork" ? " (fork)" : "";
      const title = `${args.agent}${context} `;
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
