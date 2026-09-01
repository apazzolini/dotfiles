import {
  AssistantMessageComponent as PiAssistantMessageComponent,
  type ExtensionAPI,
} from "@earendil-works/pi-coding-agent";

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

export default function (pi: ExtensionAPI) {
  let componentPrototype: AssistantMessageComponent | undefined;
  let originalUpdateContent: UpdateContent | undefined;
  let replacementUpdateContent: UpdateContent | undefined;

  pi.on("session_start", (_event, ctx) => {
    if (ctx.mode !== "tui") {
      return;
    }

    componentPrototype = PiAssistantMessageComponent.prototype as AssistantMessageComponent;
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
