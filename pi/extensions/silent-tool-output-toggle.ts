import {
  InteractiveMode,
  ToolExecutionComponent,
  type ExtensionAPI,
} from "@earendil-works/pi-coding-agent";
import { truncateToWidth } from "@earendil-works/pi-tui";

const GRAY2_FG = "\x1b[38;5;245m";
const GREEN_FG = "\x1b[32m";
const RED_FG = "\x1b[31m";
const BOLD = "\x1b[1m";
const RESET_BOLD = "\x1b[22m";
const RESET_FG = "\x1b[39m";

type InteractiveModeInternals = {
  showStatus(message: string): void;
};

type ToolResult = {
  content: Array<{ type: string; text?: string }>;
  isError: boolean;
};

type ToolExecutionInternals = {
  args: unknown;
  expanded: boolean;
  isPartial: boolean;
  result?: ToolResult;
  toolCallId: string;
  toolName: string;
  ui: {
    requestRender(): void;
  };
};

type SessionSummarySource = {
  getBranch(): readonly unknown[];
  getLeafId(): string | null;
};

type ToolCallSummary = {
  elapsedMs: number;
  ownerToolCallId: string;
  toolCalls: number;
  turns: number;
};

function asRecord(value: unknown): Record<string, unknown> | undefined {
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    return undefined;
  }

  return value as Record<string, unknown>;
}

function buildToolCallSummaries(entries: readonly unknown[]): Map<string, ToolCallSummary> {
  const summaries = new Map<string, ToolCallSummary>();
  let completedAt: number | undefined;
  let hasUserMessage = false;
  let startedAt: number | undefined;
  let toolCallIds: string[] = [];
  let turns = 0;

  const finishGroup = () => {
    const ownerToolCallId = toolCallIds.at(-1);
    if (ownerToolCallId) {
      const elapsedMs = startedAt !== undefined && completedAt !== undefined
        ? Math.max(0, completedAt - startedAt)
        : 0;
      const summary = {
        elapsedMs,
        ownerToolCallId,
        toolCalls: toolCallIds.length,
        turns,
      };
      for (const toolCallId of toolCallIds) {
        summaries.set(toolCallId, summary);
      }
    }

    completedAt = undefined;
    startedAt = undefined;
    toolCallIds = [];
    turns = 0;
  };

  for (const entry of entries) {
    const entryRecord = asRecord(entry);
    if (entryRecord?.type !== "message") {
      continue;
    }

    const message = asRecord(entryRecord.message);
    if (message?.role === "user") {
      finishGroup();
      hasUserMessage = true;
      continue;
    }

    if (!hasUserMessage || message?.role !== "assistant") {
      continue;
    }

    turns++;
    const messageTimestamp = typeof message.timestamp === "number" ? message.timestamp : undefined;
    startedAt ??= messageTimestamp;
    completedAt = messageTimestamp ?? completedAt;
    if (typeof entryRecord.timestamp === "string") {
      const entryTimestamp = Date.parse(entryRecord.timestamp);
      if (Number.isFinite(entryTimestamp)) {
        completedAt = entryTimestamp;
      }
    }

    const content = Array.isArray(message.content) ? message.content : [];
    for (const part of content) {
      const contentPart = asRecord(part);
      if (contentPart?.type === "toolCall" && typeof contentPart.id === "string") {
        toolCallIds.push(contentPart.id);
      }
    }
  }

  finishGroup();
  return summaries;
}

function formatDoneSummary(summary: ToolCallSummary): string {
  const turns = `${summary.turns} turn${summary.turns === 1 ? "" : "s"}`;
  const toolCalls = `${summary.toolCalls} tool call${summary.toolCalls === 1 ? "" : "s"}`;
  const elapsedSeconds = Math.floor(summary.elapsedMs / 1000);
  const elapsed = `${Math.floor(elapsedSeconds / 60)}:${String(elapsedSeconds % 60).padStart(2, "0")}`;
  return `Done (${turns}, ${toolCalls}, ${elapsed})`;
}

function clean(value: unknown): string | undefined {
  if (typeof value !== "string") {
    return undefined;
  }

  return value.replace(/[\r\n\t]+/g, " ").replace(/\s+/g, " ").trim();
}

function countOutputLines(result: ToolResult | undefined): number {
  const text = result?.content.find((part) => part.type === "text")?.text;
  if (!text?.trim()) {
    return 0;
  }

  return text.split("\n").filter((line) => line.trim()).length;
}

function formatGenericArgs(args: Record<string, unknown> | undefined): string {
  if (!args) {
    return "";
  }

  for (const key of ["path", "query", "pattern", "action", "command", "name"]) {
    const value = clean(args[key]);
    if (value) {
      return ` ${value}`;
    }
  }

  const json = clean(JSON.stringify(args));
  if (!json || json === "{}") {
    return "";
  }

  return ` ${json}`;
}

function formatToolCall(tool: ToolExecutionInternals): { icon: string; label: string; detail: string } {
  const args = asRecord(tool.args);
  const normalizedName = tool.toolName.split(".").at(-1)?.toLowerCase() ?? tool.toolName.toLowerCase();
  const path = clean(args?.path) ?? clean(args?.file_path);
  const resultCount = tool.isPartial ? 0 : countOutputLines(tool.result);

  if (normalizedName === "read") {
    let range = "";
    const offset = typeof args?.offset === "number" ? args.offset : undefined;
    const limit = typeof args?.limit === "number" ? args.limit : undefined;
    if (offset !== undefined || limit !== undefined) {
      const start = offset ?? 1;
      range = limit === undefined ? `:${start}` : `:${start}-${start + limit - 1}`;
    }
    return { icon: "→", label: "Read", detail: ` ${path ?? "…"}${range}` };
  }

  if (normalizedName === "bash") {
    return { icon: "$", label: "", detail: ` ${clean(args?.command) ?? "…"}` };
  }

  if (normalizedName === "edit") {
    const edits = Array.isArray(args?.edits) ? args.edits.length : 0;
    const count = edits > 0 ? ` (${edits} replacement${edits === 1 ? "" : "s"})` : "";
    return { icon: "←", label: "Edit", detail: ` ${path ?? "…"}${count}` };
  }

  if (normalizedName === "write") {
    return { icon: "←", label: "Write", detail: ` ${path ?? "…"}` };
  }

  if (normalizedName === "grep") {
    const pattern = clean(args?.pattern) ?? "…";
    const location = path ? ` in ${path}` : "";
    const count = resultCount > 0 ? ` (${resultCount} matches)` : "";
    return { icon: "*", label: "Grep", detail: ` "${pattern}"${location}${count}` };
  }

  if (normalizedName === "find") {
    const pattern = clean(args?.pattern) ?? "…";
    const location = path ? ` in ${path}` : "";
    const count = resultCount > 0 ? ` (${resultCount} files)` : "";
    return { icon: "*", label: "Find", detail: ` ${pattern}${location}${count}` };
  }

  if (normalizedName === "ls") {
    const count = resultCount > 0 ? ` (${resultCount} entries)` : "";
    return { icon: "→", label: "List", detail: ` ${path ?? "."}${count}` };
  }

  if (normalizedName === "mcp") {
    const server = clean(args?.server);
    const remoteTool = clean(args?.tool);
    const action = clean(args?.action);
    let target = remoteTool ?? action ?? clean(args?.search) ?? "request";
    if (server && remoteTool) {
      target = `${server}.${remoteTool}`;
    }
    return { icon: "→", label: "MCP", detail: ` ${target}` };
  }

  if (normalizedName === "parallel") {
    const calls = Array.isArray(args?.tool_uses) ? args.tool_uses.length : 0;
    return { icon: "→", label: "Parallel", detail: calls > 0 ? ` ${calls} tools` : "" };
  }

  const label = tool.toolName
    .replace(/^.*[.:/]/, "")
    .replace(/[_-]+/g, " ")
    .replace(/\b\w/g, (character) => character.toUpperCase());
  return { icon: "→", label, detail: formatGenericArgs(args) };
}

export default function (pi: ExtensionAPI) {
  const interactivePrototype = InteractiveMode.prototype as unknown as InteractiveModeInternals;
  const originalShowStatus = interactivePrototype.showStatus;
  const toolPrototype = ToolExecutionComponent.prototype;
  const originalRender = toolPrototype.render;
  let activeAgent = false;
  let activeAgentStartedAt: number | undefined;
  const activeToolCallIds = new Set<string>();
  let latestActiveToolCallId: string | undefined;
  let aggregateActiveToolCalls = false;
  let renderUi: ToolExecutionInternals["ui"] | undefined;
  let sessionSummarySource: SessionSummarySource | undefined;
  let summaryCacheKey: string | undefined;
  let summaryCache = new Map<string, ToolCallSummary>();

  const replacementShowStatus = function (this: InteractiveModeInternals, message: string) {
    if (message.startsWith("Tool output:")) {
      return;
    }

    originalShowStatus.call(this, message);
  };
  const replacementRender = function (this: ToolExecutionComponent, width: number): string[] {
    const tool = this as unknown as ToolExecutionInternals;
    renderUi = tool.ui;

    if (tool.expanded) {
      return originalRender.call(this, width);
    }

    if (
      (aggregateActiveToolCalls || !activeAgent || !activeToolCallIds.has(tool.toolCallId))
      && sessionSummarySource
    ) {
      const branch = sessionSummarySource.getBranch();
      const cacheKey = `${sessionSummarySource.getLeafId() ?? "none"}:${branch.length}`;
      if (cacheKey !== summaryCacheKey) {
        summaryCache = buildToolCallSummaries(branch);
        summaryCacheKey = cacheKey;
      }

      const summary = summaryCache.get(tool.toolCallId);
      if (summary) {
        if (summary.ownerToolCallId !== tool.toolCallId) {
          return [];
        }

        let displayedSummary = summary;
        if (aggregateActiveToolCalls && activeToolCallIds.has(tool.toolCallId)) {
          displayedSummary = {
            ...summary,
            elapsedMs: activeAgentStartedAt === undefined
              ? summary.elapsedMs
              : Math.max(0, Date.now() - activeAgentStartedAt),
            turns: summary.turns + 1,
          };
        }
        const line = `${GREEN_FG}${BOLD} ${formatDoneSummary(displayedSummary)}${RESET_BOLD}${RESET_FG}`;
        return ["", truncateToWidth(line, width, "…")];
      }
    }

    if (activeAgent && tool.toolCallId === latestActiveToolCallId) {
      return originalRender.call(this, width);
    }

    const { icon, label, detail } = formatToolCall(tool);
    const foregroundColor = tool.result?.isError ? RED_FG : GRAY2_FG;
    let line = `${foregroundColor}${icon}`;
    if (label) {
      line += ` ${BOLD}${label}${RESET_BOLD}`;
    }
    line += detail;
    if (tool.isPartial) {
      line += " …";
    }
    line += RESET_FG;
    const renderedLine = truncateToWidth(line, width, "…");
    const firstActiveToolCallId = activeToolCallIds.values().next().value;
    if (activeAgent && tool.toolCallId === firstActiveToolCallId) {
      return ["", renderedLine];
    }

    return [renderedLine];
  };
  interactivePrototype.showStatus = replacementShowStatus;
  toolPrototype.render = replacementRender;

  pi.on("before_agent_start", () => {
    activeAgent = true;
    activeAgentStartedAt = undefined;
    activeToolCallIds.clear();
    latestActiveToolCallId = undefined;
    aggregateActiveToolCalls = false;
  });

  pi.on("turn_start", (event) => {
    activeAgentStartedAt ??= event.timestamp;
  });

  pi.on("message_update", (event) => {
    const message = asRecord(event.message);
    const content = Array.isArray(message?.content) ? message.content : [];
    let hasText = false;
    let hasToolCall = false;

    for (const part of content) {
      const contentPart = asRecord(part);
      if (contentPart?.type === "text" && clean(contentPart.text)) {
        hasText = true;
      }
      if (contentPart?.type === "toolCall" && typeof contentPart.id === "string") {
        hasToolCall = true;
        activeToolCallIds.add(contentPart.id);
        latestActiveToolCallId = contentPart.id;
      }
    }

    if (hasToolCall) {
      aggregateActiveToolCalls = false;
      return;
    }

    if (hasText && activeToolCallIds.size > 0 && !aggregateActiveToolCalls) {
      aggregateActiveToolCalls = true;
      summaryCacheKey = undefined;
      renderUi?.requestRender();
    }
  });

  pi.on("tool_execution_start", (event) => {
    activeToolCallIds.add(event.toolCallId);
    latestActiveToolCallId = event.toolCallId;
    aggregateActiveToolCalls = false;
  });

  pi.on("agent_settled", () => {
    activeAgent = false;
    activeAgentStartedAt = undefined;
    activeToolCallIds.clear();
    latestActiveToolCallId = undefined;
    aggregateActiveToolCalls = false;
    summaryCacheKey = undefined;
    renderUi?.requestRender();
  });

  pi.on("session_start", (_event, ctx) => {
    activeAgent = false;
    activeAgentStartedAt = undefined;
    activeToolCallIds.clear();
    latestActiveToolCallId = undefined;
    aggregateActiveToolCalls = false;
    sessionSummarySource = ctx.sessionManager;
    summaryCacheKey = undefined;
  });

  pi.on("session_shutdown", () => {
    activeAgent = false;
    activeAgentStartedAt = undefined;
    activeToolCallIds.clear();
    latestActiveToolCallId = undefined;
    aggregateActiveToolCalls = false;
    renderUi = undefined;
    sessionSummarySource = undefined;
    if (interactivePrototype.showStatus === replacementShowStatus) {
      interactivePrototype.showStatus = originalShowStatus;
    }
    if (toolPrototype.render === replacementRender) {
      toolPrototype.render = originalRender;
    }
  });
}
