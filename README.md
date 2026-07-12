# Agent Workflow

A reusable, self-improving AI agent system. Drop it into any repo (or install it globally) and get a full agent team — project manager, planner, engineer, QA, UI/UX reviewer, verifier, security auditor — with autonomous loops, token-aware model routing, compounding memory, and hard safety gates.

**Runs on Cursor today. Built to run everywhere.** The current implementation targets Cursor's rules/skills/subagents/hooks surface, but the workflow itself is written against open standards ([AGENTS.md](https://agents.md), [agentskills.io](https://agentskills.io) SKILL.md) — the roadmap below takes it to every agent, every IDE, and no IDE at all.

Stack-agnostic by design: the agents detect each project's real test/lint/build commands and base branch instead of assuming one. Model-agnostic by design: routing works on tiers (deep / balanced / fast / grader), not on any one vendor's models.

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

## Roadmap — beyond Cursor

This is the Cursor edition of something bigger: one workflow, portable across the whole agent ecosystem, the way packs like `addyosmani/agent-skills` install into 70+ agents from one repo.

| Phase | Target | How |
| --- | --- | --- |
| **Now** | Cursor (IDE + CLI) | Native `.cursor/` rules, skills, subagents, hooks, permissions — this repo |
| **Next** | Any skills-capable agent (Claude Code, Codex, Copilot, Windsurf, Gemini CLI, OpenCode, …) | Publish the 13 skills as an installable pack on the open skills ecosystem: `npx skills add <this-repo>` — SKILL.md is already the cross-agent standard; compatibility dirs (`.claude/`, `.codex/`, `.agents/`) ship in the same repo |
| **Then** | Any IDE-less / headless environment | The same loops driven programmatically: CI pipelines and schedulers running intake → loop → ship via agent SDKs and CLIs, with the task folder + `STATE.md` as the only state — no editor required |
| **Later** | Distribution | Package rules + skills + agents + hooks as a single plugin with per-agent adapters, so one install command sets up the whole team anywhere |

What makes this portable by construction: the workflow's state lives in plain files (task folders, `STATE.md`, AGENTS.md), not in any tool's session — any agent that can read files and run shell commands can pick up where another left off.

## Specializing for a domain

The setup is generic; domain knowledge plugs in via the project's own `AGENTS.md` and rules. Example: for healthcare work, [docs/HEALTHCARE-PATTERNS.md](docs/HEALTHCARE-PATTERNS.md) and [docs/HIPAA-COMPLIANCE-CHECKLIST.md](docs/HIPAA-COMPLIANCE-CHECKLIST.md) hold the PHI/HIPAA invariants — the `security-auditor` and `planner` agents read project rules automatically and treat violations as critical.

## License

MIT — see [LICENSE](LICENSE).
