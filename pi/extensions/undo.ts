import type { ExtensionAPI, ExtensionCommandContext } from "@mariozechner/pi-coding-agent";

type SessionEntry = {
  type: string;
  id: string;
  message?: {
    role?: string;
    content?: unknown;
  };
};

function getLastUserEntry(ctx: ExtensionCommandContext): SessionEntry | undefined {
  const branch = ctx.sessionManager.getBranch() as readonly SessionEntry[];

  for (let i = branch.length - 1; i >= 0; i--) {
    const entry = branch[i];
    if (entry?.type === "message" && entry.message?.role === "user") {
      return entry;
    }
  }

  return undefined;
}

export default function (pi: ExtensionAPI) {
  pi.registerCommand("undo", {
    description: "Return to the last user message without a branch summary",
    handler: async (_args, ctx) => {
      await ctx.waitForIdle();

      const lastUserEntry = getLastUserEntry(ctx);
      if (!lastUserEntry) {
        ctx.ui.notify("No user message found to undo to", "warning");
        return;
      }

      const result = await ctx.navigateTree(lastUserEntry.id, { summarize: false });
      if (result.cancelled) {
        ctx.ui.notify("Undo cancelled", "warning");
      }
    },
  });
}
