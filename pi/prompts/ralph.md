---
description: Implement a goal, then loop implement/review with forked reviewer subagents until the review comes back clean
argument-hint: "<goal> [--model <phrase>] [--thinking <level>]"
---

# Ralph

Goal and flags: $ARGUMENTS

Implement the goal in this session, then loop with independent reviewer subagents until a review comes back clean. Do all of this autonomously; do not stop to ask permission between rounds.

## Flags

- `--model <phrase>` and `--thinking <level>` may appear anywhere in the arguments. Strip them out; everything else is the goal.
- Pass them to the priming subagent in step 2 only. Later forks inherit that subagent's model and thinking automatically, so never repeat the flags on a fork call.
- When the flags are absent, the reviewers inherit this session's model and thinking.

## Step 1 — Write the brief

Write a self-contained brief for someone who has never seen this session. Include:

- The goal, verbatim, plus the intent behind it as you understand it from this session's context.
- The files, directories, modules, and entry points that matter, with paths.
- Constraints, conventions, and decisions already settled in this session.
- What "achieves the goal" means concretely, and how a reviewer should judge it.
- Relevant branch context: what this branch is doing, what the base branch is.

The brief must not describe or contain the changes that satisfy the goal. Not a diff, not a patch, not a file-by-file plan of edits, not "I will change X to Y". The reviewers must reach the diff on their own.

## Step 2 — Prime the base session

Call `tmux_subagent` once, with no `fork`, passing `--model`/`--thinking` from step 1 if present. The task must:

- Contain the brief.
- Instruct the subagent to build deep context: inspect the branch's commits against the base branch (`git log`, `git show`), read the code the brief points at and the code around it, read the relevant tests, and learn the local conventions.
- Allow committed history freely: `git log`, `git show <sha>`, `git diff <base-branch>...HEAD`, and reading tracked files.
- Forbid every view of uncommitted state: no `git diff`, no `git diff --cached`/`--staged`, no `git status`, no `git stash list`, no reading untracked files. If it notices uncommitted changes anyway, it must ignore them and say nothing about them.
- If the working tree is already dirty when it starts, tell it to read the committed version of any dirty file (`git show HEAD:<path>`) instead of the working copy.
- Forbid edits, commits, and running `/review`.
- Ask it to finish by restating the goal in its own words and how it would judge whether the goal is achieved.

Record the `Transcript:` path from the result. That path is the **base**. Every review round forks it. Never overwrite it, never fork a round's transcript, and never resume it.

## Step 3 — Implement

Implement the goal yourself in this session. Do not delegate implementation. Leave everything uncommitted; the reviewers read the branch commits plus the working tree.

## Step 4 — Review round

Call `tmux_subagent` with `fork` set to the base transcript. The task must:

- Tell it to actually run the `/review` command, by name, rather than reviewing ad hoc.
- Name the goal and ask whether the current uncommitted changes achieve it.
- State that uncommitted scope includes new untracked files, so it must pick them up (`git status --porcelain`, or `git add -N` style discovery) instead of relying on `git diff` alone.

For example: `Use /review to review the current uncommitted changes, including any new untracked files, then judge whether they achieve this goal: <goal>`.

Do not include the diff, a summary of what you changed, a list of touched files, the findings from earlier rounds, or a restatement of the `/review` format. Each round must be a naive review of the current working tree. The only exception is a pushback note carried per the rules below.

Each round forks the same base, so each reviewer knows the goal and the codebase but nothing about earlier rounds.

## Step 5 — Act on the findings

For each finding, either fix it or reject it.

- Fix it in this session, keeping the change as small as the finding requires.
- Reject it only when you have read the cited code and it contradicts the finding, or the finding is out of scope for the goal. Then add one short pushback note to the next round's task: what a previous reviewer claimed, and why you believe it is wrong. Keep it to a couple of sentences and drop it once a later round stops raising it.
- Findings that are real but unrelated to the goal go in the final report as follow-ups, not into the code.

Then run another review round. Repeat step 4 and step 5.

## Stopping

- Stop when a round reports no findings.
- Stop when the same finding shows up in two rounds despite your fix or your pushback. Report the deadlock instead of trying a third time.
- There is no iteration cap otherwise. Keep looping.

## Final report

- The goal, and whether it is achieved.
- How many review rounds ran.
- What you changed, at a level that maps to files.
- Findings you rejected, with your reasoning.
- Anything unresolved, including a deadlocked finding, plus follow-ups.

Leave the work uncommitted.
