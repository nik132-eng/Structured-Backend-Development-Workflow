# Cursor Agent Workflow

A reusable, self-improving Cursor agent setup. Drop it into any repo (or install it globally) and get a full agent team — project manager, planner, engineer, QA, UI/UX reviewer, verifier, security auditor — with autonomous loops, token-aware model routing, compounding memory, and hard safety gates.

Stack-agnostic by design: the agents detect each project's real test/lint/build commands and base branch instead of assuming one.

## Quick start

```text
/intake  <paste a ticket, bug report, or one-line idea>
   → review the brief, answer any batched questions
loop
   → the agent branches, plans, and iterates until acceptance criteria pass
/ship
   → verification evidence + PR summary; stops for your approval
```

That's the whole workflow for most tasks. Trivial one-file fixes skip all ceremony — just ask.

## What's inside

| Piece | What it gives you |
| --- | --- |
| 4 always-on rules | Triage + clarify-first protocol, git discipline, model routing, security review policy |
| 8 subagents | `project-manager` coordinating `engineer`, `qa`, `uiux-reviewer`, `codebase-explorer`, `planner`, `verifier`, `security-auditor` |
| 13 skills | `goal-loop`, `ralph-loop` (long-horizon fresh-context runs), `problem-intake`, `spike-doc`, `task-implementation-doc`, `regression-check`, `pr-prep`, `agents-md`, `skill-discovery` (auto-finds ecosystem skills when a task needs them), plus `/intake` `/clarify` `/ship` `/status` |
| Safety layer | Destructive-command hook (`rm -rf`, force push, `DROP TABLE`, …) + plain-English Auto-review permissions |
| Learning loop | `.learnings/STATE.md` five-stage memory (verified facts → general rules), skills that accumulate failure modes, memory-MCP integration |

## Documentation

- **[docs/USAGE-EXAMPLES.md](docs/USAGE-EXAMPLES.md)** — copy-paste prompts and the best use case for every agent and skill. Start here.
- **[docs/CURSOR-AGENT-SETUP.md](docs/CURSOR-AGENT-SETUP.md)** — full reference: architecture, workflow artifacts, role hierarchy, model routing, reuse instructions.

## Install

**Into one project:**

```bash
cp -R .cursor /path/to/your-repo/.cursor
```

**Globally (every project, zero per-repo setup):** see the install section in [docs/CURSOR-AGENT-SETUP.md](docs/CURSOR-AGENT-SETUP.md). Restart Cursor afterward so hooks and permissions load. Requires `jq` (`brew install jq`).

## Specializing for a domain

The setup is generic; domain knowledge plugs in via the project's own `AGENTS.md` and rules. Example: for healthcare work, [docs/HEALTHCARE-PATTERNS.md](docs/HEALTHCARE-PATTERNS.md) and [docs/HIPAA-COMPLIANCE-CHECKLIST.md](docs/HIPAA-COMPLIANCE-CHECKLIST.md) hold the PHI/HIPAA invariants — the `security-auditor` and `planner` agents read project rules automatically and treat violations as critical.

## License

MIT — see [LICENSE](LICENSE).
