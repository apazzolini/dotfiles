---
description: Run a parent-controlled implementation and review loop until clean
argument-hint: "[task, target, or max rounds]"
---

Run a parent-controlled review/fix loop for the requested work. Read the `subagents` skill's review workflow reference first.

- The parent owns the loop, synthesis, accepted fixes, and final decision.
- Default to at most three review rounds unless the user specifies another cap.
- Never create a worktree automatically.
- Use only one writer in the active working tree.

If implementation is needed, launch one `worker` with forked parent context and a narrow, approved task. Wait for it to settle.

For each review round, launch fresh-context `reviewer` calls together with distinct angles chosen from the actual change. Reviewers inspect the current repository and diff directly and do not edit. Ask for evidence-backed P0/P1/P2 findings and a merge verdict.

Synthesize each round into:

- blockers or unapproved product/scope/architecture decisions requiring the user;
- fixes worth doing now;
- optional or deferred notes;
- feedback rejected as unsupported or out of scope.

When fixes are authorized, launch one forked `worker` to apply only the accepted fixes and run focused validation. Review again only after material changes. Stop when no concrete blocker or fix worth doing now remains, only optional feedback remains, a user decision is needed, or the round cap is reached.

On completion, inspect the final diff and summarize rounds, fixes, validation, deferred items, and the stop reason.

Requested work or scope:

$@
