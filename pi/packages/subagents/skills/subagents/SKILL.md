---
name: subagents
description: Delegate scouting, implementation, review, review loops, cleanup, and advisor consensus to focused interactive Pi child sessions. Use when independent context, parallel review, adversarial validation, or a worker-review cycle would materially improve the result.
---

# Subagents

The parent Pi session is the orchestrator and final decision-maker. Children run as full interactive Pi sessions in tmux windows, where the user may watch or steer them directly.

## Choose a role

- `scout`: fast codebase reconnaissance and compressed context.
- `worker`: the only mutation-capable implementation thread for normal workflows.
- `reviewer`: fresh-context, evidence-backed review. Review-only unless explicitly asked to edit.
- `oracle`: forked-context challenge of plans, assumptions, and decision drift.
- `delegate`: lightweight general delegation.
- `council-opus` and `council-sol`: read-only advisors for bounded consensus work.

## Operating rules

- Delegate only when independent context, parallel evidence, or focused execution materially helps.
- Keep the parent in control of sequencing, synthesis, accepted fixes, and user-facing conclusions.
- Give each child a concrete task: objective, target/cwd, authority boundary, relevant evidence, success criteria, validation, expected report, and stop conditions.
- Use fresh context for independent reviewers. Use forked context when a worker or oracle needs the parent conversation's decisions.
- Launch independent read-only calls together so Pi runs them in parallel.
- Never automatically create a worktree. Never run concurrent writers in the same working tree. If the user explicitly prepares separate worktrees, target them with separate `cwd` values.
- Children do not launch subagents. The parent owns orchestration.
- Treat child reports as evidence, not authority. Verify disputed or speculative findings before acting.
- The user can type directly into a running child's tmux window. Do not add a second mediated steering protocol.

## Workflow references

- Read [references/review-workflows.md](references/review-workflows.md) for parallel review, review/fix loops, and cleanup passes.
- Read [references/consensus.md](references/consensus.md) for bounded advisor councils.

Use the packaged `/review`, `/parallel-review`, `/review-loop`, `/parallel-cleanup`, `/gather-context-and-clarify`, and `/council` prompts for repeatable workflows.
