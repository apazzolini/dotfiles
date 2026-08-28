import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.registerCommand("id", {
    description: "Copy the current session ID to the clipboard",
    handler: async (_args, ctx) => {
      const sessionId = ctx.sessionManager.getSessionId();
      const result = await pi.exec("/bin/sh", [
        "-c",
        'printf %s "$1" | pbcopy',
        "copy-session-id",
        sessionId,
      ]);

      if (result.code !== 0) {
        const error = result.stderr.trim() || `pbcopy exited with code ${result.code}`;
        ctx.ui.notify(`Could not copy session ID: ${error}`, "error");
        return;
      }

      ctx.ui.notify(`Copied session ID: ${sessionId}`, "info");
    },
  });
}
