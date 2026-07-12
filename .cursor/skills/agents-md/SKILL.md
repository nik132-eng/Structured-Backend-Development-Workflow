---
name: agents-md
description: Author or trim AGENTS.md / CLAUDE.md repository context files using the evidence-based "Toolchain First" practice - minimal, human-quality, high-signal. Use when creating, reviewing, or updating AGENTS.md, CLAUDE.md, .cursorrules, or any repository context file for coding agents.
---

# AGENTS.md — Toolchain First

Evidence (ETH Zurich + LogicStar.ai, "Evaluating AGENTS.md", arXiv Feb 2026): LLM-generated context files **reduced** agent success in 5 of 8 settings and added 20%+ inference cost; carefully written developer files gave only ~4% gain. Bloated context files are worse than none. Write less, and write it like a human.

## What earns a line in AGENTS.md

Only content the agent would get wrong without it:

- **Exact commands**: the real test/lint/typecheck/build/run commands, including flags and working directory (e.g. `npx vitest run <file>` not "run the tests").
- **Genuinely non-obvious constraints**: invariants no linter enforces (e.g. "plaintext PHI must never reach logs or server-visible state", "all times stored UTC").
- **Files and areas never to touch**: generated code, vendored dirs, migration history.
- **Project-specific conventions that contradict defaults**: unusual branch model, commit format, module boundaries.

## What to delete on sight

- Anything a linter, formatter, tsconfig, or CI already enforces — the toolchain is the source of truth, not prose.
- Anything obvious from the README or package.json.
- Generic best practices the agent already knows ("write clean code", "add tests").
- Style guides — configure the linter instead.
- Long architecture narratives — link to the doc, don't inline it.

## Rules

- Target **under ~40 lines**. If it's longer, it's probably hurting.
- Never auto-generate and walk away. If a generator or `/init` produced a draft, review every line asking: "would the agent actually get this wrong without this line?" Delete on any hesitation.
- Monorepos: nest per-package AGENTS.md files (closest file wins); keep the root one to repo-wide invariants only.
- Re-verify commands by running them before committing the file — a wrong command is worse than no command.
- Prefer AGENTS.md (open standard, read by 20+ tools) over vendor files; keep CLAUDE.md/.cursorrules only as thin pointers if a tool requires them.
