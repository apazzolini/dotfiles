import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

type Message = {
  content: Array<{
    type: string;
    thinking?: string;
    [key: string]: unknown;
  }>;
  [key: string]: unknown;
};

type UpdateContent = (message: Message, isStreaming?: boolean) => void;

type AssistantMessageComponent = {
  updateContent: UpdateContent;
};

type AssistantMessageComponentClass = {
  prototype: AssistantMessageComponent;
};

export default function (pi: ExtensionAPI) {
  let componentPrototype: AssistantMessageComponent | undefined;
  let originalUpdateContent: UpdateContent | undefined;
  let replacementUpdateContent: UpdateContent | undefined;

  pi.on("session_start", async (_event, ctx) => {
    if (ctx.mode !== "tui") {
      return;
    }

    const packageEntry = import.meta.resolve("@earendil-works/pi-coding-agent");
    const componentUrl = new URL("./modes/interactive/components/assistant-message.js", packageEntry);
    const componentModule = await import(componentUrl.href) as {
      AssistantMessageComponent: AssistantMessageComponentClass;
    };

    componentPrototype = componentModule.AssistantMessageComponent.prototype;
    originalUpdateContent = componentPrototype.updateContent;
    replacementUpdateContent = function (message, isStreaming) {
      const displayMessage = {
        ...message,
        content: message.content.map((content) => {
          if (content.type !== "thinking") {
            return content;
          }

          return { ...content, thinking: "" };
        }),
      };

      originalUpdateContent!.call(this, displayMessage, isStreaming);
    };
    componentPrototype.updateContent = replacementUpdateContent;
  });

  pi.on("session_shutdown", () => {
    if (componentPrototype && originalUpdateContent && componentPrototype.updateContent === replacementUpdateContent) {
      componentPrototype.updateContent = originalUpdateContent;
    }
  });
}
