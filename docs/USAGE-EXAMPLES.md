# Usage Examples

Copy-paste prompts for every agent and skill in this setup, with the best use case for each. All of these work in any repo where the setup is installed (project `.cursor/` or global `~/.cursor/`).

## The 30-second version

For 90% of tasks you only need three prompts:

```text
/intake  <paste your ticket, bug report, or one-line idea>
loop
/ship
```

Intake turns the request into a brief with acceptance criteria and asks any blocking questions once. "loop" makes the agent branch, plan, and iterate until the criteria pass. `/ship` produces verification evidence and a PR summary, then stops for your approval.

---

## Everyday workflows

### Small fix (no ceremony)

Just describe it. The triage rule skips all documentation for trivial one-file changes:

```text
Fix the typo in the signup validation message — it says "emial".
```

### Feature from a ticket

```text
/intake
Ticket PAY-142: Clinic admins need to export appointment reminders as CSV.
Filters: date range + provider. Must exclude patient phone numbers from
the export (PHI). Deadline: this sprint.
```

The agent writes `00-problem-brief.md` with machine-verifiable acceptance criteria and states its assumptions so you can veto them. Review, then say `loop`.

### Bug you can't reproduce

```text
loop — Users report the checkout webhook fires twice on slow connections.
Acceptance: a failing test reproducing the double-fire, then the fix making it pass.
```

Best use case for the loop: the `qa` agent must reproduce the bug as a failing test *before* any fix counts as done, so "fixed" means proven.

### "Did I break anything?"

```text
/ship
```

or just: `did this break anything?` — runs the regression-check skill: targeted tests first, then lint, then broader suites, recorded in `04-test-evidence.md`.

---

## The subagents — when and how to invoke each

You rarely invoke these directly — the orchestrator and `project-manager` dispatch them. But you can call any of them by name when you want that specific job done.

### `project-manager` — multi-workstream features

Best use case: a feature spanning backend + tests + UI that can run as parallel workstreams.

```text
Use the project-manager to build the appointment-reminder settings page:
API endpoint (NestJS), unit tests, and the React settings form.
Plan first, then parallelize what doesn't overlap.
```

### `planner` — think before touching code

Best use case: ambiguous or architectural work where the approach matters more than the typing.

```text
Have the planner produce a spike and implementation plan for migrating
our session storage from Redis to Postgres. No code yet — I want to
review the plan first.
```

### `codebase-explorer` — cheap answers about the code

Best use case: "where does X happen?" questions in a repo you don't know. Keeps noisy search output out of your main context.

```text
Ask the codebase-explorer: where do we validate webhook signatures,
and which modules call that validation?
```

### `engineer` — one scoped subtask

Best use case: you already know exactly what to change and how to verify it.

```text
Dispatch the engineer: add a `deleted_at` column migration for the
appointments table, batched for >1M rows. Verify with: npm run test:unit -- migrations
```

### `qa` — test evidence

Best use case: after implementation, or when you suspect thin coverage.

```text
Run the qa agent on the export feature — I want red-green evidence
for the PHI-exclusion behavior and the date-range filter edge cases.
```

### `verifier` — independent "is it done?"

Best use case: before you trust a big change. The verifier didn't write the code, sees only the artifact and the plan, and gives a PR-ready verdict or the specific gaps.

```text
Have the verifier judge the current branch against the plan. Verdict only.
```

### `uiux-reviewer` — pixels, not promises

Best use case: any frontend change. It screenshots the real screens and compares against the goal and design system.

```text
uiux-reviewer: check the new settings form — default, error, and mobile
states — against the brief and our design tokens.
```

### `security-auditor` — touched-scope audit

Best use case: anything brushing auth, input handling, storage, network, uploads, or PHI. Fires automatically in the loop; invoke directly for a standalone check.

```text
Run the security-auditor on the diff — this PR touches the auth middleware
and adds a file upload endpoint.
```

---

## Long-horizon and autonomous runs

### `ralph-loop` — big tasks, fresh context per iteration

Best use case: 8+ subtask plans or overnight work that outlives one context window. Each iteration is a fresh subagent that reads the plan from disk, does one subtask, verifies, and writes state back.

```text
ralph — work through the implementation plan in docs/agent-tasks/2026-07-13_csv-export/.
Per-iteration commits are pre-approved. Stop on any blocked subtask.
```

### `/clarify` — stress-test the request before work starts

Best use case: you have a vague idea and want the agent to find the decisions instead of guessing.

```text
/clarify I want some kind of audit trail for who viewed patient records.
```

### `/status` — where are we?

```text
/status
```

Reads the plan and progress log; reports done/in-progress/blocked with evidence. No code changes.

---

## Maintenance prompts

### `/agents-md` — write a context file that helps instead of hurts

```text
/agents-md — draft an AGENTS.md for this repo. Toolchain First: exact
commands, non-obvious invariants, files never to touch. Under 40 lines.
```

### Graph the codebase (token saver)

```text
Build the code graph for this repo, then answer from it:
how does a reminder go from cron trigger to SMS send?
```

Free (AST-only) in code repos; the agent uses `graphify query/explain/path` for structural questions afterward instead of re-reading files.

### Find a skill for an unfamiliar task

Best use case: the task involves a framework, vendor API, or workflow pattern the agent would otherwise improvise. Discovery is automatic during task setup, but you can force it:

```text
Find a skill for Remotion video rendering best practices before we start —
vet it and tell me source + installs before installing anything.
```

The agent searches skills.sh (`npx skills find`), reads the candidate's SKILL.md for red flags, and proposes it with source and install count. Installs always wait for your yes; for one-off needs it prefers `npx skills use <owner/repo>@<skill>` which applies the skill without installing.

### Teach the system something permanent

```text
That TLS workaround cost us an hour twice now — write it into STATE.md
as a general rule, and update the ci-triage skill's known failure modes.
```

The learning loop does this automatically after failures, but you can force a distillation any time.

---

## Model routing cheat sheet

You don't pick models per task — the routing rule does. What it optimizes:

| Work | Tier | Why |
| --- | --- | --- |
| Planning, hard diagnosis | deep reasoning | judgment is the bottleneck |
| Implementation, tests | balanced | quality per token |
| Search, lint, scaffolding | fast | volume work, fan out in parallel |
| Verification verdicts | cheapest capable (vision for UI) | independent + cheap |

Two invariants: the maker never grades its own work, and a subtask escalates one tier only after failing twice.

---

## Anti-patterns (don't do these)

- **Don't paste 500-line logs into chat** — point the agent at the file; it summarizes.
- **Don't ask for "make it better"** — subjective goals break the loop. Say what observable behavior counts as done, or let `/clarify` extract it.
- **Don't skip `/intake` on multi-day work** — no acceptance criteria means the loop can't know when to stop.
- **Don't approve UI work from a text description** — that's what `uiux-reviewer` exists for.
- **Don't let one session's lesson die in chat** — if it'll matter next month, it belongs in STATE.md or a skill.
