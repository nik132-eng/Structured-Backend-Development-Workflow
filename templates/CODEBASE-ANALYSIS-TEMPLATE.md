# Codebase Analysis: [Feature/Epic Name]

> Source: [feature]-tasks.md, module scope from [feature]-spike.md

## Executive Summary

[1-2 sentences: what was analyzed, overall state of the codebase, and whether it's ready for this feature — including any timeline impact from pre-build tasks]

## Module Structure

| Module | Files/Directories Reviewed | Dependencies | Tasks Touching This Module |
|--------|------------------------------|---------------|------------------------------|
| [Module] | [paths] | [other modules it depends on / is depended on by] | [Task IDs] |

## Patterns & Conventions

**Naming Conventions:**
[file names, function/method names, variable casing, route naming]

**Error Handling:**
[how errors are raised, caught, formatted, returned]

**Structure:**
[architectural pattern — MVC, layered, hexagonal, etc. — and how strictly followed]

**Validation:**
[where/how input validation happens]

**Data Access:**
[ORM/query builder, transaction patterns, migration conventions]

**Testing:**
[framework, file location/naming, fixture/mocking conventions — cross-reference config/test-frameworks.json]

## Technical Concerns

| # | Issue | Module(s) | Impact | Recommendation | Effort | Priority | Blocking? |
|---|-------|-----------|--------|-----------------|--------|----------|-----------|
| 1 | [Issue] | [Module] | [Impact] | [Recommendation] | [Quick fix / Medium refactor / Major overhaul] | [High/Medium/Low] | Y/N |

## Tech Debt

- [Existing tech debt relevant to this feature's modules]

## Refactoring Opportunities

| What Exists | Improvement | Benefit |
|-------------|-------------|---------|
| [Existing code/pattern] | [Improvement] | [Benefit] |

## Pre-Build Tasks

[Any blocking concerns from "Technical Concerns" above, to be added to the Stage 2 task list before Stage 4 proceeds. If none, state "None — no blocking concerns identified."]

- [Task description] — [Effort] — blocks [Task IDs]

## Patterns Summary (Critical for Prompt Generation)

```
Naming Conventions:
- [Controllers/handlers]: ...
- [Services]: ...
- [Data access]: ...
- [Models/Validation]: ...

Code Structure:
- Framework: [...]
- Dependency wiring: [...]
- Error Handling: [...]
- Validation: [...]

Database:
- ORM: [...]
- Table/column naming: [...]
- Migrations: [...]

Testing:
- Framework: [...]
- Location: [...]
- Mocking: [...]
- Coverage target: [...]

Response/Error Format:
[example shape]
```

## Recommendations

- [Recommendation for Stage 4 prompt generation, e.g., "all new endpoints should follow the controller pattern in src/controllers/orderController.js"]

## Readiness Assessment

- **Ready to build now:** Yes / No
- **Blockers:** [list, or "None"]
- **Risk level:** Low / Medium / High

## Assumptions & Notes

- [Anything inferred without direct codebase access, caveats, incomplete information]

---

**Status:** Draft / Under Review / Approved
**Approved By:** [Name/Role]
**Date:** [YYYY-MM-DD]
