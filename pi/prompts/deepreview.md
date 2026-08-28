---
description: Review current changes with two independent reviewer subagents, then consolidate
argument-hint: "[scope or instructions]"
---

# Deep Review

Run two independent reviews in parallel, then consolidate them into a single review.

## Scope

- Extra scope/instructions, which may be empty: $ARGUMENTS

## Delegation

- Issue both `tmux_subagent` calls in the same tool block so they run in parallel.
- Opus: `model` = `anthropic/claude-opus-5`, `thinking` = `high`.
- Sol: `model` = `openai/gpt-5.6-sol`, `thinking` = `high`.
- For both subagents, `task` must be the literal slash command and nothing else:
    - `/review` when the scope above is empty.
    - `/review <scope>` when the scope above is non-empty, with the scope text copied verbatim.
- Never restate, paraphrase, summarize, expand, or extend the `/review` prompt. The subagents run that command themselves; your job is only to forward it.
- Do not add a preamble, framing, format reminder, or any other instruction to `task`.
- Spawn exactly these two subagents. Do not run your own review pass, and do not inspect the diff before both subagents return.
- If a subagent fails or returns nothing usable, say so in one line and consolidate whatever did come back.

## Consolidation

- Merge both reports into one ordered list of findings.
- Refer to the reviewers by name: `Opus` for the `claude-opus-5` subagent and `Sol` for the `gpt-5.6-sol` subagent. Never call them reviewer A, reviewer B, subagent A, subagent B, or the first/second reviewer.
- Deduplicate: when both report the same defect at the same location, emit one finding, keep the clearest explanation, and note in its description that both Opus and Sol raised it.
- Keep a finding reported by only one of them if it holds up, and attribute it, for example "Sol found this" or "Opus found this".
- When the reviewers disagree, or a finding looks speculative, read the cited code before deciding. Drop findings the code contradicts and briefly list them under a "Discarded" note at the end with the reason.
- Reconcile severities yourself based on the evidence rather than averaging the two labels.
- Re-number the merged list from 1 and re-sort by severity (blocker, high, medium, low).
- Do not add findings of your own beyond what verification requires.

## Findings

Report findings before summaries. Number the findings starting with 1 and order them by severity (blocker, high, medium, low). Format every finding as a proper Markdown ordered-list item. Render the one-line heading in bold white using Markdown bold, then indent each continuation paragraph by three spaces so wrapped lines remain aligned:

1. **[<SEVERITY>] <one-line description>**
   <file and line references>

   <longer description including what can go wrong, where it is introduced, what user-visible, persisted, security, or maintenance impact it has, what evidence supports the claim, and attribution to Opus, Sol, or both>

   **■ Fix:** <the suggested fix>

If there are no findings, say so directly and mention any meaningful test gap or residual risk that Opus or Sol flagged.

Put unrelated cleanup in follow-up notes.
