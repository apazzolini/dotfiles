/*
 * Derived from OpenAI Codex apply_patch.
 * Copyright 2025 OpenAI
 * Modified for pi-gpt-enhance.
 * SPDX-License-Identifier: Apache-2.0
 */

import {
  truncateHead,
  type AgentToolUpdateCallback,
  type ExtensionAPI,
  type ExtensionContext,
  type SourceInfo,
  type ToolDefinition,
  type ToolInfo,
} from "@earendil-works/pi-coding-agent";
import { Type, type Static } from "typebox";
import { applyPatch } from "./apply-patch.js";
import { compactionLifecycle } from "./lifecycle.js";

export const APPLY_PATCH_DESCRIPTION =
  "The `apply_patch` tool can be used to edit files. This is a FREEFORM tool, so do not wrap the patch in JSON.";

/** The no-environment-ID grammar used by Codex's OpenAI custom tool. */
export const APPLY_PATCH_LARK_GRAMMAR = `start: begin_patch hunk+ end_patch
begin_patch: "*** Begin Patch" LF
end_patch: "*** End Patch" LF?

hunk: add_hunk | delete_hunk | update_hunk
add_hunk: "*** Add File: " filename LF add_line+
delete_hunk: "*** Delete File: " filename LF
update_hunk: "*** Update File: " filename LF change_move? change?

filename: /(.+)/
add_line: "+" /(.*)/ LF -> line

change_move: "*** Move to: " filename LF
change: (change_context | change_line)+ eof_line?
change_context: ("@@" | "@@ " /(.+)/) LF
change_line: ("+" | "-" | " ") /(.*)/ LF
eof_line: "*** End of File" LF

%import common.LF
`;

const APPLY_PATCH_PARAMETERS = Type.Object(
  { input: Type.String() },
  { additionalProperties: false },
);

type ApplyPatchParameters = Static<typeof APPLY_PATCH_PARAMETERS>;

export type ApplyPatchToolDetails = {
  summary: string;
  truncated: boolean;
  totalLines: number;
  totalBytes: number;
};

export function createApplyPatchTool(): ToolDefinition<
  typeof APPLY_PATCH_PARAMETERS,
  ApplyPatchToolDetails
> {
  return {
    name: "apply_patch",
    label: "Apply Patch",
    description: APPLY_PATCH_DESCRIPTION,
    parameters: APPLY_PATCH_PARAMETERS,
    constrainedSampling: {
      type: "grammar",
      variants: { openai_lark: APPLY_PATCH_LARK_GRAMMAR },
    },
    executionMode: "sequential",
    async execute(
      _toolCallId: string,
      params: ApplyPatchParameters,
      signal: AbortSignal | undefined,
      _onUpdate: AgentToolUpdateCallback<ApplyPatchToolDetails> | undefined,
      ctx: ExtensionContext,
    ) {
      const summary = await applyPatch(params.input, ctx.cwd, signal);
      const truncation = truncateHead(summary);
      const output = truncation.truncated
        ? `${truncation.content}\n\n[Summary truncated: showing ${truncation.outputLines} of ${truncation.totalLines} lines.]`
        : summary;
      return {
        content: [{ type: "text", text: output }],
        details: {
          summary: output,
          truncated: truncation.truncated,
          totalLines: truncation.totalLines,
          totalBytes: truncation.totalBytes,
        },
      };
    },
  };
}

const APPLY_PATCH_NAME = "apply_patch";

type Ownership = { kind: "unknown" } | { kind: "foreign" } | { kind: "owned"; sourceKey: string };

export type ApplyPatchSupportState = "off" | "inactive" | "active" | "external";
export type ApplyPatchSupport = {
  state: () => ApplyPatchSupportState;
};

function sourceInfoKey(sourceInfo: SourceInfo | undefined): string | undefined {
  if (!sourceInfo) return undefined;
  return JSON.stringify([
    sourceInfo.path,
    sourceInfo.source,
    sourceInfo.scope,
    sourceInfo.origin,
    sourceInfo.baseDir ?? "",
  ]);
}

function visibleApplyPatch(pi: ExtensionAPI): ToolInfo | undefined {
  return pi.getAllTools().find((tool) => tool.name === APPLY_PATCH_NAME);
}

function sameNames(left: string[], right: string[]): boolean {
  return left.length === right.length && left.every((name, index) => name === right[index]);
}

/**
 * Install the optional tool and reconcile its active state at model/lifecycle boundaries.
 * A foreign same-name tool always wins and is never modified by this extension.
 */
export function registerApplyPatchSupport(
  pi: ExtensionAPI,
  options: { enabled: boolean },
): ApplyPatchSupport {
  if (!options.enabled) return { state: () => "off" };

  let ownership: Ownership = { kind: "unknown" };

  const sync = (model: unknown): void => {
    if (ownership.kind === "foreign") return;

    const eligible = compactionLifecycle.isEligible(model);
    let visible = visibleApplyPatch(pi);
    if (ownership.kind === "unknown") {
      if (visible) {
        ownership = { kind: "foreign" };
        return;
      }
      if (!eligible) return;
      try {
        pi.registerTool(createApplyPatchTool());
      } catch (error) {
        visible = visibleApplyPatch(pi);
        if (visible) {
          ownership = { kind: "foreign" };
          return;
        }
        throw error;
      }
      visible = visibleApplyPatch(pi);
      const sourceKey = sourceInfoKey(visible?.sourceInfo);
      if (!visible || sourceKey === undefined) {
        ownership = { kind: "foreign" };
        return;
      }
      ownership = { kind: "owned", sourceKey };
    }

    if (ownership.kind !== "owned") return;
    visible = visibleApplyPatch(pi);
    if (sourceInfoKey(visible?.sourceInfo) !== ownership.sourceKey) {
      ownership = { kind: "foreign" };
      return;
    }

    const active = pi.getActiveTools();
    const next = eligible
      ? active.includes(APPLY_PATCH_NAME)
        ? active
        : [...active, APPLY_PATCH_NAME]
      : active.filter((name) => name !== APPLY_PATCH_NAME);
    if (!sameNames(active, next)) pi.setActiveTools(next);
  };

  const state = (): ApplyPatchSupportState => {
    if (ownership.kind === "foreign") return "external";
    const visible = visibleApplyPatch(pi);
    if (ownership.kind === "unknown") return visible ? "external" : "inactive";
    if (sourceInfoKey(visible?.sourceInfo) !== ownership.sourceKey) {
      ownership = { kind: "foreign" };
      return "external";
    }
    return pi.getActiveTools().includes(APPLY_PATCH_NAME) ? "active" : "inactive";
  };

  pi.on("session_start", (_event, ctx) => sync(ctx.model));
  pi.on("model_select", (event) => sync(event.model));
  pi.on("before_agent_start", (_event, ctx) => sync(ctx.model));
  return { state };
}

export const applyPatchToolName = (): string => APPLY_PATCH_NAME;
