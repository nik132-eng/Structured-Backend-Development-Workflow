---
name: regression-check
description: Final verification pass over touched code after the goal-loop converges. Runs targeted then broader checks and records evidence. Use before PR prep, or when the user asks "did this break anything".
---

# Regression Check

Run after the loop exits green, before PR prep. Record results in `04-test-evidence.md`.

Use the project's real commands (detected during setup — from `package.json`, `Makefile`, `pyproject.toml`, CI config). Order (stop escalating when confidence is sufficient):

1. Targeted test files for every touched module
2. Lint (and style lint if styles changed)
3. Full unit suite if changes span multiple modules
4. Typecheck/build if imports, types, or config changed
5. UI changes: Browser check of the affected screens; save screenshots into the task folder; verify keyboard/focus behavior

Evidence format in `04-test-evidence.md` — one line per check:

```markdown
- `<command>` → pass|fail (<counts or short failure summary>)
```

If a check fails on something unrelated to this change, say so precisely and note the pre-existing failure; do not silently skip it.
