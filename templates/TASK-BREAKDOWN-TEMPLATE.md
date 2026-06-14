# Task Breakdown: [Feature/Epic Name]

> Source: [feature]-spike.md

## Overview

[Brief summary of what's being built and why, from the spike document.]

## Task List

| Task ID | Title | Description | Dependencies | Estimated Effort | Sub-tasks | Sub-Checkpoint |
|---------|-------|-------------|--------------|-------------------|-----------|------------------|
| T-[FEATURE]-001 | [Title] | [Description] | None | [N]d | None | A |
| T-[FEATURE]-002 | [Title] | [Description] | T-[FEATURE]-001 | [N]d | None | A |
| T-[FEATURE]-003 | [Title] | [Description] | T-[FEATURE]-002 | [N]d | T-[FEATURE]-003-A, T-[FEATURE]-003-B | B |

### Task Detail Template (repeat per task)

```text
Task ID: T-[FEATURE]-[NNN]
Title: [Clear, action-oriented title]
Description: [What needs to be done, in 1-2 sentences]
Acceptance Criteria:
  - [ ] Criterion 1
  - [ ] Criterion 2
  - [ ] Criterion 3
Dependencies: [Task IDs, or "None"]
Estimated Effort: [N days, 1-3 typical]
Test Requirements: [What tests must pass]
Sub-tasks: [Nested Task IDs, or "None"]
```

## Dependency Graph

```text
T-[FEATURE]-001
    |
    v
T-[FEATURE]-002 --> T-[FEATURE]-003   <- parallel where noted
                \--> T-[FEATURE]-004
    |
    v
T-[FEATURE]-005 [Checkpoint B]
```

**Critical path:** [T-[FEATURE]-001 -> T-[FEATURE]-002 -> ... ]

## Sub-Checkpoints

**Checkpoint A (after T-[FEATURE]-NNN):** [What this checkpoint verifies]
- [ ] [Verification item]
- [ ] [Verification item]

**Checkpoint B (after T-[FEATURE]-NNN):** [What this checkpoint verifies]
- [ ] [Verification item]

**Checkpoint [Final letter] (final):** [Feature-complete verification]
- [ ] All tests passing
- [ ] Documentation complete
- [ ] Ready for production

## Timeline Estimate

- **Sequential:** [X] days
- **With parallelism:** [Y] days
- **Critical path:** [List of blocking Task IDs]

## Testing Strategy (per task)

- **Unit tests:** [framework, minimum coverage %]
- **Integration tests:** [what to test]
- **Edge cases:** [common pitfalls to test across tasks]

## Notes

[Special considerations, risks, assumptions — e.g., highest-risk tasks, deferred scope.]

---

**Status:** Draft / Under Review / Approved
**Approved By:** [Name/Role]
**Date:** [YYYY-MM-DD]
