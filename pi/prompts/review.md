---
description: Review current changes for correctness issues
argument-hint: "[scope or instructions]"
---

# Code Review

Review the current changes for concrete defects.

## Execution

- Unless the user explicitly asks for a direct, current-session, or no-subagent review, delegate exactly one review to a fresh-context `reviewer` subagent.
- Launch the reviewer asynchronously and present its report when it completes.
- Give the reviewer a self-contained task containing the effective scope and the review criteria below. Do not assume it can see the parent conversation.
- If this session is already a subagent or the `subagent` tool is unavailable, perform the review directly instead of delegating again.

## Scope

- Additional scope or instructions, which may be empty: $ARGUMENTS
- If no scope is supplied, review changes against the branch merge base, plus staged, unstaged, and relevant untracked files.
- Inspect the diff first, then read surrounding code as needed.
- Expand beyond changed behavior only to prove a concrete correctness, security, data-loss, or regression risk.
- Prefer the smallest correct fix. Do not request unrelated architecture or cleanup work.
- Treat comments and TODOs as evidence of intent, not automatic justification for defective behavior.

## Review Criteria

Check whether the change:

- Does what it claims end to end.
- Preserves authorization, validation, persistence, ordering, and public contracts where relevant.
- Correctly uses accepted fields and applies defaults at the appropriate boundary.
- Includes tests that would fail for the reported bug or regression.
- Introduces unnecessary abstractions, compatibility paths, or scope expansion.

## Output

Report findings first, ordered by severity:

1. **[<SEVERITY>] <description>**
   `<file>:<line>`

   Explain the local cause, triggering condition, observable impact, and evidence.

   **■ Fix:** <smallest correct fix>

If there are no findings, say so and mention meaningful test gaps or residual risks. Put unrelated cleanup in follow-up notes.
