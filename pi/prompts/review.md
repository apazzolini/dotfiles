---
description: Review current changes for correctness issues
argument-hint: "[scope or instructions]"
---

# Code Review Guide

Use this guide to find defects without expanding scope. The best review usually asks: what will break, and what is the smallest correction?

## Scope

- If arguments are provided, use them as the review scope/instructions: $ARGUMENTS
    - Otherwise, review the changes in this branch, both committed and uncommitted
- Perform the review in the current session. Do not spawn or delegate to subagents.
- Inspect the diff first, then read surrounding code as needed. Stay inside the changed behavior.
- Expand only to prove a concrete correctness, security, or data-loss risk.
- Do not ask for architecture work when a local fix would be correct.
- Treat `AGENTS.md` as background guidance, not a checklist.
- Check TODO comments added or changed in the diff before reporting a nearby issue. If a TODO already acknowledges and intentionally defers the exact limitation or risk, treat it as addressed context rather than a finding; report only a separate unacknowledged defect or a contradiction in the comment’s assumptions.

## Findings

Report findings before summaries. Number the findings starting with 1 and order them by severity (blocker, high, medium, low). Format every finding as a proper Markdown ordered-list item. Render the one-line heading in bold white using Markdown bold, then indent each continuation paragraph by three spaces so wrapped lines remain aligned:

1. **[<SEVERITY>] <one-line description>**
   <file and line references>

   <longer description including what can go wrong, where it is introduced, what user-visible, persisted, security, or maintenance impact it has, and what evidence supports the claim>

   **■ Fix:** <the suggested fix>

If there are no findings, say so directly and mention any meaningful test gap or residual risk.

## Check

- Does the change do what it claims to do?
- Are authorization, validation, query filters, ordering, pagination, and persistence correct at the layer that enforces them?
- Are changed route, command, event, and database fields implemented end to end?
- Are accepted fields actually used?
- Are defaults applied once at the boundary instead of hidden behind optional internal fields?
- Do tests assert outcomes that would fail for the bug or regression?

## Simplicity Red Flags

Flag these when they are not required for the current change:

- New descriptor tables, registries, coordinators, managers, generators, state machines, or dependency injection.
- New packages or cross-package contract moves.
- Compatibility adapters that keep old and new paths alive together.
- Generic helpers, options, config flags, or abstractions with one real caller.
- Broad migrations or backfills bundled with a local behavior change.
- File splits that increase the number of places a reader must visit without deleting an older path.

## Clarity and Causality

- State the local defect before explaining downstream mechanics.
- Name the exact field, condition, argument, return value, or behavior that is wrong, missing, or inconsistent.
- Cite the primary changed location first. Use downstream locations only as supporting evidence.
- Make the heading and first sentence sufficient for the author to understand what needs changing.
- Distinguish clearly between code that is defective and nearby code that merely exposes the defect.
- Trace findings in this order: local cause → triggering condition → observable impact → smallest fix.
- Prefer concrete statements such as “`toastDescriptions` omits `failure`” over indirect statements such as “the fallback interpolates untranslated fragments.”
- Before reporting a finding, verify that a reader could identify the exact edit from the heading and first paragraph without reconstructing the reviewer’s reasoning.


Put unrelated cleanup in follow-up notes.

