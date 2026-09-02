# Subagents

A local Pi package for role-based delegation into full interactive Pi sessions in tmux windows.

## Tool

`subagent` runs one configured agent and waits for it to settle. Independent sibling calls can be issued together for parallel work.

Fields:

- `agent`: `scout`, `worker`, `reviewer`, `oracle`, `delegate`, `council-opus`, or `council-sol`
- `task`: complete child task; literal slash commands are expanded by the child
- `context`: `fresh` or `fork`; defaults by agent
- `fork`: optional prior child transcript to reuse as a base
- `model`, `thinking`, `cwd`: optional overrides

Children are ordinary Pi TUIs. The user may watch or steer them directly in tmux. The parent remains the orchestrator and receives the final response and transcript path.

## Resources

- `skills/subagents`: role selection and orchestration guidance
- `prompts/review.md`: one fresh review
- `prompts/parallel-review.md`: distinct parallel review angles
- `prompts/review-loop.md`: parent-controlled worker/reviewer loop
- `prompts/parallel-cleanup.md`: cleanup review fanout
- `prompts/gather-context-and-clarify.md`: scout before clarification
- `prompts/council.md`: bounded advisor consensus

The package never creates worktrees. Run only one writer per working tree unless the user explicitly supplies separate worktree paths.
