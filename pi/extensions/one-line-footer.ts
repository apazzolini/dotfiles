import { isAbsolute, relative, resolve, sep } from "node:path";
import { VERSION, type ExtensionAPI, type ExtensionContext } from "@earendil-works/pi-coding-agent";
import { stripTerminalSequences, truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

type Usage = {
  input?: number;
  output?: number;
  cacheRead?: number;
  cacheWrite?: number;
  cost?: {
    total?: number;
  };
};

type AssistantMessageLike = {
  role?: string;
  usage?: Usage;
};

function sanitizeStatusText(text: string): string {
  return text
    .replace(/[\r\n\t]/g, " ")
    .replace(/ +/g, " ")
    .trim();
}

function normalizeStatusText(text: string): string {
  const sanitized = sanitizeStatusText(text);
  const plain = stripTerminalSequences(sanitized);
  const mcpServers = /^MCP:\s*(\d+)\/\d+\s+servers?\b/.exec(plain);

  if (!mcpServers) {
    return sanitized;
  }

  const activeServerCount = Number(mcpServers[1]);
  if (activeServerCount > 0) {
    return sanitized;
  }

  return plain;
}

function formatTokens(count: number): string {
  if (count < 1000) {
    return count.toString();
  }

  if (count < 10000) {
    return `${(count / 1000).toFixed(1)}k`;
  }

  if (count < 1000000) {
    return `${Math.round(count / 1000)}k`;
  }

  if (count < 10000000) {
    return `${(count / 1000000).toFixed(1)}M`;
  }

  return `${Math.round(count / 1000000)}M`;
}

function getPwd(ctx: ExtensionContext, branch: string | null): string {
  let pwd = ctx.sessionManager.getCwd();
  const home = process.env.HOME || process.env.USERPROFILE;

  if (home) {
    const relativeToHome = relative(resolve(home), resolve(pwd));
    const isInsideHome =
      relativeToHome === "" ||
      (relativeToHome !== ".." &&
        !relativeToHome.startsWith(`..${sep}`) &&
        !isAbsolute(relativeToHome));

    if (isInsideHome) {
      pwd = relativeToHome === "" ? "~" : `~${sep}${relativeToHome}`;
    }
  }

  if (branch) {
    pwd = `${pwd} (${branch})`;
  }

  const sessionName = ctx.sessionManager.getSessionName();
  if (sessionName) {
    pwd = `${pwd} • ${sessionName}`;
  }

  return pwd;
}

export default function (pi: ExtensionAPI) {
  pi.on("session_start", (_event, ctx) => {
    if (!ctx.hasUI) {
      return;
    }

    ctx.ui.setFooter((tui, theme, footerData) => {
      const unsubscribe = footerData.onBranchChange(() => tui.requestRender());

      return {
        dispose: unsubscribe,
        invalidate() {},
        render(width: number): string[] {
          let totalCost = 0;

          for (const entry of ctx.sessionManager.getEntries()) {
            if (entry.type === "message") {
              const message = entry.message as AssistantMessageLike;
              if (message.role === "assistant" || message.role === "toolResult") {
                totalCost += message.usage?.cost?.total ?? 0;
              }
              continue;
            }

            if (entry.type === "branch_summary" || entry.type === "compaction") {
              totalCost += entry.usage?.cost.total ?? 0;
            }
          }

          const statsParts: string[] = [];
          const usingSubscription = ctx.model ? ctx.modelRegistry.isUsingOAuth(ctx.model) : false;
          if (totalCost || usingSubscription) {
            statsParts.push(`$${totalCost.toFixed(3)}`);
          }

          const contextUsage = ctx.getContextUsage();
          const contextWindow = contextUsage?.contextWindow ?? ctx.model?.contextWindow ?? 0;
          const contextPercent = contextUsage?.percent;
          const contextPercentDisplay = contextPercent === null || contextPercent === undefined
            ? `?/${formatTokens(contextWindow)}`
            : `${contextPercent.toFixed(1)}%/${formatTokens(contextWindow)}`;
          statsParts.push(contextPercentDisplay);

          const compactionCount = ctx.sessionManager
            .getBranch()
            .filter(
              (entry) =>
                entry.type === "custom" &&
                entry.customType === "gpt-enhance-stateless-compaction",
            ).length;
          const statuses = Array.from(footerData.getExtensionStatuses().entries())
            .sort(([a], [b]) => a.localeCompare(b))
            .map(([key, text]) => {
              const normalized = normalizeStatusText(text);
              if (key !== "gpt-enhance.compression") {
                return normalized;
              }

              const compressionStatus = stripTerminalSequences(normalized);
              return compressionStatus === "COMPACT:ON"
                ? `${compressionStatus} (${compactionCount})`
                : compressionStatus;
            })
            .filter(Boolean);

          const separator = theme.fg("dim", " • ");
          const leftParts = [
            getPwd(ctx, footerData.getGitBranch()),
            ...statsParts,
            ...statuses,
          ].filter(Boolean);
          const left = leftParts.join(" • ");
          const styledLeft = leftParts.map((part) => theme.fg("dim", part)).join(separator);

          const modelName = ctx.model?.id || "no-model";
          const isLargeContext =
            modelName === "gpt-5.6-sol" &&
            contextUsage?.tokens !== null &&
            contextUsage?.tokens !== undefined &&
            contextUsage.tokens > 272000;
          const largeContextIndicator = isLargeContext
            ? ` ${theme.fg("error", "[large-context]")}`
            : "";
          const thinkingLevel = ctx.model?.reasoning ? pi.getThinkingLevel() : undefined;
          let thinkingSuffix = "";
          if (thinkingLevel === "off") {
            thinkingSuffix = " • thinking off";
          } else if (thinkingLevel !== undefined) {
            thinkingSuffix = ` • ${thinkingLevel}`;
          }
          const providerPrefix = footerData.getAvailableProviderCount() > 1 && ctx.model
            ? `(${ctx.model.provider}) `
            : "";
          const modelPrefix = `${providerPrefix}${modelName}`;
          const modelSuffix = `${thinkingSuffix} • pi v${VERSION}`;
          const model = `${modelPrefix}${largeContextIndicator}${modelSuffix}`;
          const styledModel =
            theme.fg("dim", modelPrefix) +
            largeContextIndicator +
            theme.fg("dim", modelSuffix);

          const minPadding = 2;
          const modelWidth = visibleWidth(model);
          const leftWidth = visibleWidth(left);

          if (leftWidth + minPadding + modelWidth <= width) {
            const padding = theme.fg("dim", " ".repeat(width - leftWidth - modelWidth));
            return [styledLeft + padding + styledModel];
          }

          const availableForLeft = width - modelWidth - minPadding;
          if (availableForLeft > 10) {
            const truncatedLeft = truncateToWidth(styledLeft, availableForLeft, theme.fg("dim", "..."));
            const padding = theme.fg("dim", " ".repeat(Math.max(minPadding, width - visibleWidth(truncatedLeft) - modelWidth)));
            return [truncatedLeft + padding + styledModel];
          }

          return [truncateToWidth(`${styledLeft}${theme.fg("dim", "  ")}${styledModel}`, width, theme.fg("dim", "..."))];
        },
      };
    });
  });
}
