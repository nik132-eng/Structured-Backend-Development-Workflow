# Cursor Agent Setup

A reusable, autonomous Cursor agent configuration. Everything lives under `.cursor/` in this repo, is stack-agnostic (the agent detects each project's real test/lint/build commands and base branch instead of assuming one), and can be copied into any project or installed globally.

## What's inside `.cursor/`

| Path | What it does |
| --- | --- |
| `rules/orchestrator-core.mdc` | Always-on operating protocol: triage (trivial vs. non-trivial), clarify-first questioning, delegation, approval gates |
| `rules/git-workflow.mdc` | Branch discipline: detect base branch, never implement on it, safe git operations |
| `rules/security-review.mdc` | When and how to trigger a touched-scope security review |
| `rules/model-routing.mdc` | Token-aware routing: every delegated task goes to the cheapest model tier that does it well |
| `agents/` | Eight subagents (see the role hierarchy below) |
| `skills/` | Nine workflow skills + four slash-command skills (see below), incl. `skill-discovery` for auto-finding ecosystem skills (skills.sh) when a task needs know-how no installed skill covers — install stays behind the approval gate |
| `hooks.json` + `hooks/guard-destructive.sh` | Safety hook: flags destructive shell commands (`rm -rf`, force push, hard reset, `DROP TABLE`, `terraform destroy`, …) for explicit approval before they run |
| `permissions.json` | Plain-English Auto-review policy: auto-allow read-only/test/lint/build commands, force approval for pushes to shared branches, credential use, and data-destructive operations |

## The workflow

Non-trivial tasks run through a documented loop. Artifacts go in `docs/agent-tasks/YYYY-MM-DD_short-name/`:

```text
problem-intake  →  00-problem-brief.md      (goal + acceptance criteria + assumptions)
spike-doc       →  01-spike.md              (current behavior, root cause, approach)
task-impl-doc   →  02-implementation-plan.md (subtask table with verify commands)
goal-loop       →  03-progress-log.md        (think → implement → verify → decide, iterated)
regression-check→  04-test-evidence.md       (targeted then broader checks)
security-auditor→  05-security-review.md     (only if trust boundaries were touched)
pr-prep         →  06-pr-summary.md          (stops for your approval before any PR)
```

The `goal-loop` skill drives iteration autonomously: it diagnoses each failure before retrying, refuses to repeat the same failed hypothesis, and hard-stops after 3 identical failures or 10 iterations rather than thrashing. Acceptance criteria must be machine-verifiable — a command that passes or fails — and the task folder is the loop's durable memory: a fresh agent must be able to resume from the files alone, never from chat history.

### Long-horizon work: the Ralph loop

For tasks with many subtasks or overnight runs, the `ralph-loop` skill applies the Ralph pattern (fresh context every iteration, filesystem + git as the only memory): each iteration runs in a fresh-context subagent that reads the brief/plan/progress files, completes exactly one subtask, verifies it, updates the files, and returns a one-line result. The orchestrator only checks exit criteria between iterations. It refuses to start without machine-verifiable acceptance criteria — subjective goals fail this pattern.

### Role hierarchy and model routing

The main chat model is the orchestrator; a `project-manager` subagent coordinates role agents for multi-workstream tasks, like a PM managing a team:

```text
you → orchestrator (main chat)
        └─ project-manager (inherit) — decomposes, dispatches, tracks status
             ├─ engineer (balanced tier)      — one implementation subtask per dispatch
             ├─ qa (balanced tier)            — failing tests for bugs, red-green for features
             ├─ uiux-reviewer (vision, RO)    — screenshot vs. goal/design-system verification
             ├─ codebase-explorer (fast tier) — search fan-out, graph-first
             ├─ planner (deep tier, RO)       — spikes and plans
             ├─ verifier (inherit, RO)        — independent PR-ready verdict
             └─ security-auditor (RO)         — touched-scope audit
```

`rules/model-routing.mdc` makes this token-aware and provider-agnostic: deep-reasoning models only for planning and hard diagnosis, balanced models for implementation and tests, fast models for bulk fan-out, the cheapest capable model for grading. Two structural rules: maker ≠ grader (the model that produced work never judges it — an independent verifier sees only the artifact and the rubric), and escalate one tier only after 2 consecutive failures.

### Learning loop (self-improvement)

The system compounds run over run — the model is stateless, the environment isn't. Project memory lives in `.learnings/STATE.md` with five sections mirroring the fail → investigate → verify → distill → consult progression: Verified facts, General rules, Open failures, Lessons learned, Last session. Every non-trivial session reads it at start and writes it before ending; entries promote upward (failure → verified fact → general rule). Beyond the state file: a procedure done twice becomes a skill (and skills accumulate known failure modes and anti-patterns after real incidents), rules that apply to most tasks go to AGENTS.md, and durable cross-project facts go to a memory MCP server.

### Graph-first code understanding (token efficiency)

If the `graphify` CLI is installed, the agent answers structural questions from the project's knowledge graph (`graphify query/explain/path`, ~2k tokens) instead of re-reading files. In a code repo without a graph it bootstraps one for free with `graphify update .` (AST-only, no LLM), and refreshes it after implementation in the goal-loop finish step. Docs-only corpora need the full semantic pipeline (costs tokens), which is opt-in.

### AGENTS.md authoring

The `agents-md` skill encodes the evidence-based "Toolchain First" practice (ETH Zurich, Feb 2026: LLM-generated context files *reduced* agent success in 5 of 8 settings and added 20%+ cost): keep AGENTS.md under ~40 lines of genuinely non-obvious content — exact commands, invariants no linter enforces, files never to touch — and delete anything the toolchain or README already covers.

### Clarify-first

Before a non-trivial task, the agent checks outcome, scope, constraints, and irreversibles. Genuinely blocking questions are asked once, up front, as a single batched multiple-choice prompt. Everything else proceeds on stated assumptions you can veto in the brief.

### Slash commands

Implemented as skills with `disable-model-invocation: true` (the `.cursor/commands` mechanism is deprecated):

| Command | Effect |
| --- | --- |
| `/intake <ticket or idea>` | Produce the problem brief + acceptance criteria, then stop for review |
| `/clarify` | Interrogate the current task for ambiguity before any work starts |
| `/ship` | Regression check + independent verify + security audit + PR summary |
| `/status` | Report task progress from the plan and progress log |
| "loop" / `/goal-loop` | Run the full autonomous loop |
| "ralph" / `/ralph-loop` | Long-horizon loop with a fresh-context subagent per iteration |
| `/agents-md` | Author or trim an AGENTS.md the Toolchain First way |

## Typical session

```text
/intake  <paste ticket, bug report, or one-line idea>
   → review the brief, answer any batched questions
"loop"
   → agent branches, plans, iterates until acceptance criteria pass
/ship
   → verification evidence + PR summary; agent stops for your approval
```

## Reusing this setup

**Per project** — copy the directory:

```bash
cp -R .cursor /path/to/other-repo/.cursor
```

**Globally (all projects, no per-repo setup)** — install to your user config:

```bash
cp -R .cursor/agents ~/.cursor/agents
cp -R .cursor/skills ~/.cursor/skills
cp .cursor/rules/orchestrator-core.mdc ~/.cursor/rules/
cp .cursor/permissions.json ~/.cursor/permissions.json
mkdir -p ~/.cursor/hooks && cp .cursor/hooks/guard-destructive.sh ~/.cursor/hooks/
# User-level hooks resolve paths relative to ~/.cursor/:
# edit ~/.cursor/hooks.json to use "./hooks/guard-destructive.sh"
chmod +x ~/.cursor/hooks/guard-destructive.sh
```

Restart Cursor after installing so hooks and permissions load. Project-level config wins over global on name conflicts, so a repo can override any piece by shipping its own version.

**Requirements:** `jq` on PATH (the safety hook uses it): `brew install jq`.

## Customizing for a domain

The setup is generic by design. To specialize it for a project (e.g. the healthcare/HIPAA patterns in this repo's `docs/`):

- Add domain invariants to the project's `AGENTS.md` or a new rule in `.cursor/rules/` — the `security-auditor` and `planner` subagents read them automatically.
- Adjust `permissions.json` block-instructions for domain-specific risks (e.g. "any command touching patient data exports must go through approval").
- Add extra patterns to `hooks/guard-destructive.sh` if your stack has its own dangerous commands.
