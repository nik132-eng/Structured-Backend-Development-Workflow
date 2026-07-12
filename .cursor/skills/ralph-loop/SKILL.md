---
name: ralph-loop
description: Long-horizon autonomous loop for large tasks - many subtasks, overnight runs, or work too big for one context window. Runs each iteration in a fresh-context subagent that reads durable state from the task folder, completes one subtask, verifies, and updates state on disk. Use when the user says "ralph", "overnight", "long-running loop", or a plan has more than ~8 subtasks.
---

# Ralph Loop

The Ralph pattern (Geoffrey Huntley): every iteration gets a **fresh context window**; the filesystem and git history are the only memory; completion is judged by **machine-verifiable criteria only**. Conversation history is never load-bearing.

## Preconditions — refuse to start without these

1. Acceptance criteria in `00-problem-brief.md` that are all machine-checkable (a command that passes or fails: tests, lint, typecheck, build). Subjective criteria ("looks clean", "feels fast") fail this pattern — rewrite them into observable checks or push back.
2. A complete `02-implementation-plan.md` where every subtask has a concrete verify command.
3. A clean git tree on a task branch (per `goal-loop` setup).

## Durable state contract

Everything an iteration needs must live in the task folder — a fresh agent with zero chat history must be able to continue from files alone:

- `00-problem-brief.md` — goal + exit criteria (read-only during the loop)
- `02-implementation-plan.md` — subtask table with `Status` column (the queue)
- `03-progress-log.md` — append-only iteration log (the history)

## Iteration protocol

Run each iteration as a **fresh `generalPurpose` subagent** with this prompt shape:

> Read `<task-folder>/00-problem-brief.md`, `02-implementation-plan.md`, and the last 3 entries of `03-progress-log.md`. Pick the first subtask with status `todo` (or the failing one marked `doing`). Make the smallest coherent change to complete it. Run its verify command. Update the subtask Status and append one progress-log entry (target, hypothesis if retrying, files touched, verify result). If the same subtask has failed twice with the same hypothesis, mark it `blocked` with a one-line diagnosis instead of retrying. Return a one-line summary: subtask, pass/fail/blocked.

The orchestrator (you) between iterations:

- Read only the subagent's one-line result and, on failure, the newest progress-log entry — do not pull the diff into your context.
- Exit conditions: all subtasks `done` and acceptance criteria verified → Finish (per `goal-loop`: regression-check, security audit if boundaries touched, pr-prep). Any subtask `blocked`, same failure 3 consecutive iterations, or 12 iterations total → STOP and report with the progress log as evidence.
- Never re-plan mid-loop silently; if the plan is wrong, stop, revise `02-implementation-plan.md` in one explicit step, note it in the progress log, and resume.

## Guardrails

- All approval gates from the core rule still apply inside every iteration (credentials, destructive commands, PRs).
- Commits: only if the user pre-approved per-iteration commits before the loop started; otherwise leave the tree uncommitted.
- The task folder and transcripts may end up in the repo or on disk — never write secrets, tokens, or personal/patient data into them.
