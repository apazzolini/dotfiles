import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { VERSION } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  // return

  pi.on("session_start", (_event, ctx) => {
    if (!ctx.hasUI) {
      return;
    }

    ctx.ui.setHeader((_tui, theme) => {
      return {
        render(_width: number): string[] {
          return [`${theme.bold(theme.fg("mdHeading", "Hello"))}`];
          // return [` ${theme.bold(theme.fg("mdHeading", "pi"))}${theme.fg("dim", ` v${VERSION}`)}`];
        },
        invalidate() {},
      };
    });
  });
}
