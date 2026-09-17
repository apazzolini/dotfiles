import { randomUUID } from "node:crypto";
import { readFile, writeFile } from "node:fs/promises";
import { homedir } from "node:os";
import { join, resolve } from "node:path";
import { pathToFileURL } from "node:url";
import { stripVTControlCharacters } from "node:util";
import {
  detectSupportedImageMimeTypeFromFile,
  getMarkdownTheme,
  getPackageDir,
  InteractiveMode,
  parseSkillBlock,
  type ExtensionAPI,
  type ExtensionContext,
} from "@earendil-works/pi-coding-agent";
import { Markdown, type AutocompleteProvider } from "@earendil-works/pi-tui";

type InteractiveExportMode = {
  handleExportCommand(text: string): Promise<void>;
  createBaseAutocompleteProvider(): AutocompleteProvider;
};

export default function exportChat(pi: ExtensionAPI): void {
  const exportConversation = async (args: string, ctx: ExtensionContext): Promise<void> => {
      if (!ctx.isIdle()) {
        ctx.ui.notify("Wait for the response to finish, then run /export", "warning");
        return;
      }

      try {
        // Reuse Pi's escaping and ANSI renderer, not its full-session HTML template.
        // This helper is shipped with Pi but isn't exposed by the package entry point.
        const { ansiToHtml }: { ansiToHtml: (text: string) => string } = await import(
          pathToFileURL(join(getPackageDir(), "dist/core/export-html/ansi-to-html.js")).href
        );
        const markdownTheme = {
          ...getMarkdownTheme(),
          // Pi's HTML ANSI converter doesn't support strike styling; retain its meaning.
          strikethrough: (text: string) => `~~${text}~~`,
        };
        const width = Math.max(80, Math.min(process.stdout.columns || 120, 160));
        const messages: string[] = [];
        const clipboardImages = new Map<string, string | null>();

        // getBranch retains pre-compaction messages, unlike buildSessionContext.
        for (const entry of ctx.sessionManager.getBranch()) {
          if (entry.type !== "message") continue;
          const { message } = entry;
          if (message.role !== "user" && message.role !== "assistant") continue;

          const content = typeof message.content === "string"
            ? [{ type: "text" as const, text: message.content }]
            : message.content;
          const parts: string[] = [];
          for (const block of content) {
            if (block.type === "text" && block.text.trim()) {
              const skill = message.role === "user" ? parseSkillBlock(block.text) : null;
              // Skill instructions are collapsed UI context, not conversation prose.
              const text = skill ? [`/skill:${skill.name}`, skill.userMessage].filter(Boolean).join("\n\n") : block.text;
              const clipboardPathPattern = /(?<![\w/.:])\/tmp\/pi-clipboard-[\w-]+\.(?:png|jpe?g|gif|webp|bmp)(?![\w/])/gi;
              for (const [imagePath] of text.matchAll(clipboardPathPattern)) {
                if (clipboardImages.has(imagePath)) continue;
                try {
                  const mimeType = await detectSupportedImageMimeTypeFromFile(imagePath);
                  if (!mimeType) throw new Error("Unsupported image format");
                  const data = await readFile(imagePath);
                  clipboardImages.set(imagePath, `<img src="data:${mimeType};base64,${data.toString("base64")}" alt="Clipboard image" loading="lazy">`);
                } catch {
                  clipboardImages.set(imagePath, null);
                }
              }
              const inlineImages = new Map<string, string>();
              const textWithImages = text
                .replace(/!?\[[^\]\n]*\]\(([^\s)]+)\)/g, (link, path: string) => clipboardImages.get(path) ? path : link)
                .replace(clipboardPathPattern, (path) => {
                  const image = clipboardImages.get(path);
                  if (!image) return path;
                  // One character survives terminal wrapping and syntax highlighting intact.
                  let codePoint = 0xf0000 + inlineImages.size;
                  while (text.includes(String.fromCodePoint(codePoint)) || inlineImages.has(String.fromCodePoint(codePoint))) codePoint++;
                  const marker = String.fromCodePoint(codePoint);
                  inlineImages.set(marker, image);
                  return marker;
                });
              const markdown = new Markdown(stripVTControlCharacters(textWithImages), 0, 0, markdownTheme, undefined, {
                preserveOrderedListMarkers: message.role === "user",
                preserveBackslashEscapes: message.role === "user",
              });
              const lines = markdown.render(width).map((line) => renderLine({ line, ansiToHtml }));
              const renderedText = lines.join("\n").replace(/[\u{f0000}-\u{ffffd}]/gu, (marker) => inlineImages.get(marker) ?? marker);
              parts.push(`<pre>${renderedText}</pre>`);
            } else if (block.type === "image") {
              if (/^image\/(png|jpeg|gif|webp|bmp)$/.test(block.mimeType) && /^[A-Za-z0-9+/=\r\n]+$/.test(block.data)) {
                parts.push(`<img src="data:${block.mimeType};base64,${block.data}" alt="Attached image" loading="lazy">`);
              } else {
                parts.push("<pre>[Image attachment omitted: unsupported format]</pre>");
              }
            }
          }
          if (parts.length) {
            messages.push(`<section class="${message.role}" aria-label="${message.role}">${parts.join("\n")}</section>`);
          }
        }

        if (!messages.length) {
          ctx.ui.notify("No conversation messages to export", "warning");
          return;
        }

        const requestedPath = args.trim().replace(/^(["'])(.*)\1$/, "$2");
        const filename = requestedPath || join("/Users/andre.azzolini", `pi-chat-${Date.now()}-${randomUUID().slice(0, 8)}.html`);
        const expandedPath = filename.startsWith("~/") ? join(homedir(), filename.slice(2)) : filename;
        const outputPath = resolve(ctx.cwd, expandedPath);
        if (!/\.html?$/i.test(outputPath)) {
          ctx.ui.notify("Use a filename ending in .html", "error");
          return;
        }

        const html = `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta http-equiv="Content-Security-Policy" content="default-src 'none'; style-src 'unsafe-inline'; img-src data:; base-uri 'none'; form-action 'none'">
<meta name="referrer" content="no-referrer">
<title>Conversation</title>
<style>
:root { color-scheme: dark; }
* { box-sizing: border-box; }
body { margin: 0; background: #242431; color: #d9d7e8; font: 11.25px/1.65 ui-monospace, SFMono-Regular, Menlo, Consolas, monospace; }
main { max-width: calc(${width}ch + 4rem); margin: 0 auto; padding: 1.5rem 0; }
section { padding: 1.25rem 2rem; }
.user { background: #453c4d; }
pre { margin: 0; white-space: pre-wrap; overflow-wrap: anywhere; font: inherit; tab-size: 4; }
pre + pre, pre + img, img + pre, img + img { margin-top: 1rem; }
a { color: inherit; text-underline-offset: 3px; }
a:focus-visible { outline: 2px solid #a6c5d7; outline-offset: 3px; }
img { display: block; max-width: 100%; height: auto; border-radius: 4px; }
pre img { margin: 1rem 0; }
@media (max-width: 600px) { body { font-size: 9.75px; } main { padding: 0; } section { padding: 1rem; } }
@media print { :root { color-scheme: light; } body { background: white; color: black; font-size: 7.5pt; } .user { background: #eee; } span { color: inherit !important; background: none !important; } main { max-width: none; padding: 0; } }
</style>
</head>
<body><main>
${messages.join("\n")}
</main></body>
</html>`;

        // Exports can contain private conversation text; don't overwrite existing files.
        await writeFile(outputPath, html, { encoding: "utf8", mode: 0o600, flag: "wx" });
        ctx.ui.notify(`Exported conversation: ${outputPath}`, "info");
        const unavailableImages = [...clipboardImages].filter(([, image]) => !image).map(([path]) => path);
        if (unavailableImages.length) {
          ctx.ui.notify(`Could not embed clipboard images; paths retained: ${unavailableImages.join(", ")}`, "warning");
        }
        try {
          const result = await pi.exec("open", [outputPath], { timeout: 10000 });
          if (result.code !== 0) {
            ctx.ui.notify(`File saved, but open failed: ${result.stderr.trim() || `exit code ${result.code}`}`, "warning");
          }
        } catch (error) {
          ctx.ui.notify(`File saved, but open failed: ${error instanceof Error ? error.message : String(error)}`, "warning");
        }
      } catch (error) {
        ctx.ui.notify(`Export failed: ${error instanceof Error ? error.message : String(error)}`, "error");
      }
  };

  let exportPi: ((text: string) => Promise<void>) | undefined;
  let restoreRouting: (() => void) | undefined;

  pi.registerCommand("export-pi", {
    description: "Pi's original session export (HTML or .jsonl)",
    handler: async (args, ctx) => {
      if (!exportPi) {
        ctx.ui.notify("/export-pi is only available in Pi's interactive terminal", "warning");
        return;
      }
      await exportPi(args ? `/export ${args}` : "/export");
    },
  });

  pi.on("session_start", (event, ctx) => {
    if (ctx.mode !== "tui") return;
    restoreRouting?.();

    // Built-in commands bypass the extension registry. Keep the override local to this runtime.
    const prototype = InteractiveMode.prototype as unknown as InteractiveExportMode;
    const originalExport = prototype.handleExportCommand;
    const originalAutocomplete = prototype.createBaseAutocompleteProvider;
    if (typeof originalExport !== "function" || typeof originalAutocomplete !== "function") {
      ctx.ui.notify("Export override unavailable: Pi's interactive command hooks changed", "error");
      return;
    }

    const replacementExport = (text: string): Promise<void> =>
      exportConversation(text.slice("/export".length).trimStart(), ctx);
    const replacementAutocomplete = function (this: InteractiveExportMode): AutocompleteProvider {
      // Autocomplete is rebuilt after session binding, including /reload and /resume.
      exportPi = (text) => originalExport.call(this, text);
      const provider = originalAutocomplete.call(this);
      return {
        triggerCharacters: provider.triggerCharacters,
        async getSuggestions(lines, cursorLine, cursorCol, options) {
          const suggestions = await provider.getSuggestions(lines, cursorLine, cursorCol, options);
          if (!suggestions || !/^\/[^\s/]*$/.test(suggestions.prefix)) return suggestions;
          return {
            ...suggestions,
            items: suggestions.items.map((item) => item.value === "export"
              ? { ...item, description: "Export conversation to HTML (no tools or thinking)" }
              : item),
          };
        },
        applyCompletion: (lines, cursorLine, cursorCol, item, prefix) =>
          provider.applyCompletion(lines, cursorLine, cursorCol, item, prefix),
        shouldTriggerFileCompletion: (lines, cursorLine, cursorCol) =>
          provider.shouldTriggerFileCompletion?.(lines, cursorLine, cursorCol) ?? false,
      };
    };

    prototype.handleExportCommand = replacementExport;
    prototype.createBaseAutocompleteProvider = replacementAutocomplete;
    restoreRouting = () => {
      if (prototype.handleExportCommand === replacementExport) prototype.handleExportCommand = originalExport;
      if (prototype.createBaseAutocompleteProvider === replacementAutocomplete) prototype.createBaseAutocompleteProvider = originalAutocomplete;
      exportPi = undefined;
    };
  });

  pi.on("session_shutdown", () => {
    restoreRouting?.();
    restoreRouting = undefined;
  });
}

function renderLine({ line, ansiToHtml }: { line: string; ansiToHtml: (text: string) => string }): string {
  // Terminal palette slots aren't portable to HTML; use readable dark-theme equivalents.
  const palette: Record<string, string> = {
    "#000000": "#242431", "#800000": "#f08095", "#008000": "#b6cba5", "#808000": "#e6c384",
    "#000080": "#c7d4b2", "#800080": "#c8a9d9", "#008080": "#a6c5d7", "#c0c0c0": "#d9d7e8",
    "#808080": "#9393aa", "#ff0000": "#ff9cac", "#00ff00": "#c4dfad", "#ffff00": "#f2d99c",
    "#0000ff": "#bacceb", "#ff00ff": "#dfb9ef", "#00ffff": "#b7d8dc", "#ffffff": "#eeeafa",
  };
  // Pi uses OSC 8 for links. Convert each label separately so ANSI spans cannot cross anchors.
  const pieces: string[] = [];
  let offset = 0;
  const links = /\x1b\]8;[^;]*;([^\x07\x1b]+)(?:\x07|\x1b\\)([\s\S]*?)\x1b\]8;;(?:\x07|\x1b\\)/g;
  for (const match of line.matchAll(links)) {
    pieces.push(ansiToHtml(line.slice(offset, match.index)));
    const url = stripVTControlCharacters(match[1]);
    const label = ansiToHtml(match[2]);
    if (/^(https?:\/\/|mailto:)/i.test(url)) {
      pieces.push(`<a href="${ansiToHtml(url)}" target="_blank" rel="noopener noreferrer">${label}</a>`);
    } else {
      pieces.push(label);
    }
    offset = match.index + match[0].length;
  }
  pieces.push(ansiToHtml(line.slice(offset)));
  const html = pieces.join("").replace(/<span style="[^"]*">/g, (span) =>
    span.replace(/color:(#[0-9a-f]{6})(?=[;"])/gi, (match, color: string) => {
      const replacement = palette[color.toLowerCase()];
      return replacement ? `color:${replacement}` : match;
    }),
  );
  return stripVTControlCharacters(html).trimEnd();
}
