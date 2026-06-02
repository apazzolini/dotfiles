import { complete, type AssistantMessage, type Message } from "@earendil-works/pi-ai";
import type { ExtensionAPI, ExtensionCommandContext } from "@earendil-works/pi-coding-agent";
import { withFileMutationQueue } from "@earendil-works/pi-coding-agent";
import { mkdir, readFile, writeFile } from "node:fs/promises";
import { homedir } from "node:os";
import { dirname, join } from "node:path";

type ContentBlock = {
  type?: string;
  text?: string;
};

type SessionEntry = {
  type: string;
  message?: {
    role?: string;
    content?: unknown;
  };
};

const MAX_AGENTS_CHARS = 12000;
const MAX_CONVERSATION_CHARS = 24000;

function truncateTail(text: string, maxChars: number): string {
  if (text.length <= maxChars) {
    return text;
  }

  return `[Earlier content omitted]\n${text.slice(text.length - maxChars)}`;
}

function extractTextParts(content: unknown): string[] {
  if (typeof content === "string") {
    return [content];
  }

  if (!Array.isArray(content)) {
    return [];
  }

  const textParts: string[] = [];
  for (const part of content) {
    if (!part || typeof part !== "object") {
      continue;
    }

    const block = part as ContentBlock;
    if (block.type === "text" && typeof block.text === "string") {
      textParts.push(block.text);
    }
  }

  return textParts;
}

function buildConversationText(entries: SessionEntry[]): string {
  const sections: string[] = [];

  for (const entry of entries) {
    if (entry.type !== "message" || !entry.message?.role) {
      continue;
    }

    const role = entry.message.role;
    if (role !== "user" && role !== "assistant") {
      continue;
    }

    const text = extractTextParts(entry.message.content).join("\n").trim();
    if (!text) {
      continue;
    }

    const roleLabel = role === "user" ? "User" : "Assistant";
    sections.push(`${roleLabel}: ${text}`);
  }

  return truncateTail(sections.join("\n\n"), MAX_CONVERSATION_CHARS);
}

const REWRITE_SYSTEM_PROMPT = [
  "Rewrite the user's requested memory as durable AGENTS.md guidance for future coding agents.",
  "Return only Markdown bullet guidance suitable to append to AGENTS.md.",
  "Do not include a heading, preamble, quotes, code fence, or explanation.",
].join("\n");

function buildRewritePrompt(args: string, existingAgents: string, conversationText: string): string {
  return [
    "Rewrite the user's requested memory as durable AGENTS.md guidance for future coding agents.",
    "Use the current conversation only to disambiguate intent. Do not add unrelated context.",
    "Return only Markdown bullet guidance suitable to append to AGENTS.md.",
    "Prefer one concise imperative bullet. Use sub-bullets only if needed for clarity.",
    "Match the style of the existing AGENTS.md: direct, specific, and actionable.",
    "Do not include a heading, preamble, quotes, code fence, or explanation.",
    "Do not use em dashes.",
    "",
    "<existing_agents_md>",
    truncateTail(existingAgents, MAX_AGENTS_CHARS),
    "</existing_agents_md>",
    "",
    "<current_conversation>",
    conversationText || "No prior conversation text was available.",
    "</current_conversation>",
    "",
    "<memory_request>",
    args,
    "</memory_request>",
  ].join("\n");
}

function extractAssistantText(message: { content: unknown }): string {
  return extractTextParts(message.content).join("\n").trim();
}

function getAssistantContentTypes(message: AssistantMessage): string {
  if (!message.content.length) {
    return "none";
  }

  return message.content.map((block) => block.type).join(", ");
}

function stripCodeFences(text: string): string {
  const lines = text.trim().split("\n");
  if (lines[0]?.trim().startsWith("```")) {
    lines.shift();
  }

  if (lines[lines.length - 1]?.trim().startsWith("```")) {
    lines.pop();
  }

  return lines.join("\n").trim();
}

function normalizeRememberedText(text: string): string {
  const stripped = stripCodeFences(text);
  const lines = stripped
    .split("\n")
    .map((line) => line.trimEnd())
    .filter((line) => line.trim().length > 0);

  const normalized: string[] = [];
  for (const line of lines) {
    const leadingWhitespace = line.match(/^\s*/)?.[0]?.replace(/\t/g, "  ") ?? "";
    const indent = leadingWhitespace.length >= 2 ? leadingWhitespace : "";
    const trimmed = line.trim();
    const numbered = trimmed.match(/^\d+[.)]\s+(.*)$/);
    if (trimmed.startsWith("- ")) {
      normalized.push(`${indent}${trimmed}`);
    } else if (trimmed.startsWith("* ") || trimmed.startsWith("• ")) {
      normalized.push(`${indent}- ${trimmed.slice(2).trim()}`);
    } else if (numbered) {
      normalized.push(`${indent}- ${numbered[1]?.trim() ?? ""}`);
    } else {
      normalized.push(`- ${trimmed}`);
    }
  }

  return normalized.join("\n").trim();
}

function fallbackRememberedText(args: string): string {
  const cleaned = args.trim().replace(/\s+/g, " ");
  return `- ${cleaned}`;
}

async function readExistingAgents(path: string): Promise<string> {
  try {
    return await readFile(path, "utf8");
  } catch (error) {
    const maybeNodeError = error as { code?: string };
    if (maybeNodeError.code === "ENOENT") {
      return "";
    }

    throw error;
  }
}

async function rewriteMemory(args: string, existingAgents: string, ctx: ExtensionCommandContext): Promise<string> {
  const model = ctx.model;
  if (!model) {
    throw new Error("No active model is selected");
  }

  const auth = await ctx.modelRegistry.getApiKeyAndHeaders(model);
  if (!auth.ok) {
    throw new Error(auth.error);
  }

  if (!auth.apiKey && !auth.headers) {
    throw new Error(`No auth configured for ${model.provider}/${model.id}`);
  }

  const messages: Message[] = [
    {
      role: "user",
      content: [{ type: "text", text: buildRewritePrompt(args, existingAgents, buildConversationText(ctx.sessionManager.getBranch())) }],
      timestamp: Date.now(),
    },
  ];

  const response = await complete(
    model,
    { systemPrompt: REWRITE_SYSTEM_PROMPT, messages },
    {
      apiKey: auth.apiKey,
      headers: auth.headers,
      maxTokens: 500,
    },
  );

  if (response.stopReason === "error" || response.stopReason === "aborted") {
    throw new Error(response.errorMessage || `Rewrite response stopped with ${response.stopReason}`);
  }

  const rememberedText = normalizeRememberedText(extractAssistantText(response));
  if (!rememberedText) {
    throw new Error(
      `Rewrite response produced no text (stopReason=${response.stopReason}, content=${getAssistantContentTypes(response)})`,
    );
  }

  return rememberedText;
}

async function appendToAgents(path: string, rememberedText: string): Promise<void> {
  await withFileMutationQueue(path, async () => {
    await mkdir(dirname(path), { recursive: true });
    const existing = await readExistingAgents(path);
    const trimmedExisting = existing.trimEnd();
    let next = "";

    if (trimmedExisting) {
      next = `${trimmedExisting}\n\n${rememberedText}\n`;
    } else {
      next = `${rememberedText}\n`;
    }

    await writeFile(path, next, "utf8");
  });
}

export default function (pi: ExtensionAPI) {
  pi.registerCommand("remember", {
    description: "Add a reworded instruction to ~/.pi/agent/AGENTS.md",
    handler: async (args, ctx) => {
      const memory = args.trim();
      if (!memory) {
        ctx.ui.notify("Usage: /remember <something>", "warning");
        return;
      }

      await ctx.waitForIdle();

      const agentDir = process.env.PI_CODING_AGENT_DIR ?? join(homedir(), ".pi", "agent");
      const agentsPath = join(agentDir, "AGENTS.md");
      const existingAgents = await readExistingAgents(agentsPath);
      let rememberedText = "";

      try {
        rememberedText = await rewriteMemory(memory, existingAgents, ctx);
      } catch (error) {
        rememberedText = fallbackRememberedText(memory);
        const message = error instanceof Error ? error.message : String(error);
        ctx.ui.notify(`Remember rewrite failed, adding cleaned input instead: ${message}`, "warning");
      }

      await appendToAgents(agentsPath, rememberedText);
      ctx.ui.notify(`Added to ${agentsPath}:\n${rememberedText}`, "info");
    },
  });
}
