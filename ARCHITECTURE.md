# Workflow Architecture & Design

## Overview

The Backend Development Automation Workflow is modeled as a **12-state machine**: the 8 pipeline stages, plus 4 control states that manage entry, retries, escalation, and completion. Every pipeline stage is followed by a human checkpoint — the workflow does not advance until the checkpoint is explicitly passed.

## The 12 States

| # | State | Type | Description |
|---|-------|------|-------------|
| 0 | **START** | Control | Entry point. Operator provides a problem statement and (optionally) codebase context. |
| 1 | **Spike Document** | Stage | Clarify the problem, identify module scope, document technical concerns. |
| 2 | **Task Breakdown** | Stage | Decompose the spike into granular, dependency-ordered tasks. |
| 3 | **Codebase Analyzer** | Stage | Analyze relevant modules for patterns, conventions, and technical debt. |
| 4 | **Prompt Generator** | Stage | Generate execution-ready prompts per task, informed by the analysis. |
| 5 | **Code Executor** | Stage | Execute prompts to produce code changes. |
| 6 | **Test Runner** | Stage | Generate and run tests against the new code. |
| 7 | **Self-Verifier** | Stage | Check architecture, performance, and trade-offs; auto-fix safe issues. |
| 8 | **Business Logic Reviewer** | Stage | Final human review of correctness against the original problem. May approve, approve conditionally (fixes routed back to Stage 5), or reject (back to Stage 2). |
| 9 | **RETRY_LOOP** | Control | Re-enters Stage 5/6 with failure context when tests fail. |
| 10 | **ESCALATE_TO_HUMAN** | Control | Reached when retries are exhausted or a checkpoint is rejected without a clear fix. |
| 11 | **COMPLETE** | Control | Terminal state. All checkpoints passed, code approved for deployment. |

## State Machine Diagram

```text
                                   ┌────────────────────┐
                                   │       START         │
                                   │ (problem statement)  │
                                   └──────────┬───────────┘
                                              │
                                              ▼
                                  ┌───────────────────────┐
                                  │ 1. Spike Document      │
                                  └──────────┬─────────────┘
                                    approve  │  revise (loop)
                                              ▼
                                  ┌───────────────────────┐
                                  │ 2. Task Breakdown      │
                                  └──────────┬─────────────┘
                                    approve  │  revise (loop)
                                              ▼
                                  ┌───────────────────────┐
                                  │ 3. Codebase Analyzer   │
                                  └──────────┬─────────────┘
                                    approve  │  revise (loop)
                                              ▼
                                  ┌───────────────────────┐
                                  │ 4. Prompt Generator    │
                                  └──────────┬─────────────┘
                                    approve  │  revise (loop)
                                              ▼
                                  ┌───────────────────────┐
                          ┌──────►│ 5. Code Executor       │
                          │       └──────────┬─────────────┘
                          │                  ▼
                          │       ┌───────────────────────┐
                          │       │ 6. Test Runner         │
                          │       └──────────┬─────────────┘
                          │            pass  │  fail
                          │                  │
                          │      ┌───────────┴────────────┐
                          │      ▼                         ▼
                          │  (continue)          ┌──────────────────┐
                          │                       │ 9. RETRY_LOOP     │
                          │                       │ (attempt < max)   │
                          │                       └─────────┬─────────┘
                          │                  retry available │  max retries reached
                          └─────────────────────────────────┤
                                                              ▼
                                                  ┌───────────────────────┐
                                                  │ 10. ESCALATE_TO_HUMAN  │
                                                  └────────────┬───────────┘
                                                               │ human resolves
                                                               ▼
                                  ┌───────────────────────┐
                                  │ 7. Self-Verifier       │◄──────────────┐
                                  └──────────┬─────────────┘                │
                                    approve  │  issues found ────────────────┘
                                              ▼
                                  ┌───────────────────────┐
                                  │ 8. Business Logic      │◄──────────────┐
                                  │    Reviewer            │                │
                                  └──────────┬─────────────┘                │
                                    approve   │  conditional (fixes) ────────┘
                                              │  reject (back to Stage 2)
                                              ▼
                                  ┌───────────────────────┐
                                  │ 11. COMPLETE           │
                                  └───────────────────────┘
```

Note: the "conditional" outcome from Stage 8 re-enters Stages 5→6→7 with the required fixes as the new task input, then returns to Stage 8 for final sign-off (the loop-back arrow above). This differs from "reject", which returns to Stage 2 because the *requirement* was misunderstood, not just the implementation.

## Stage Dependencies

| Stage | Input | Output | Depends On |
|-------|-------|--------|------------|
| 1. Spike Document | Problem statement | Spike document (module scope, concerns) | START |
| 2. Task Breakdown | Spike document | Task list with dependencies | Stage 1 |
| 3. Codebase Analyzer | Task list + module scope | Analysis report (patterns, debt) | Stage 2 |
| 4. Prompt Generator | Tasks + analysis | Execution prompts | Stages 2, 3 |
| 5. Code Executor | Execution prompts | Generated code | Stage 4 |
| 6. Test Runner | Generated code + analysis patterns | Test results | Stages 3, 5 |
| 7. Self-Verifier | Code + test results | Verification report | Stages 5, 6 |
| 8. Business Logic Reviewer | All prior outputs | Approval / rejection | All stages |

## Transitions & Decision Points

- **Approve**: advance to the next stage, carrying forward all prior outputs as context.
- **Revise**: re-run the current stage with the operator's feedback appended to its input.
- **Go back**: return to any earlier stage; all stages after it are invalidated and must be re-approved.
- **Pause**: persist current state and all outputs so the workflow can resume later without re-deriving context.

The two decision points that are not purely human-driven are:

1. **Stage 6 → Stage 9 (Test Runner → Retry Loop)**: triggered automatically when generated tests fail.
2. **Stage 8 → Stage 2 (Business Logic Reviewer → Task Breakdown)**: triggered when the human reviewer rejects the implementation as not matching the business requirement — this is treated as a scoping problem, not a code problem, so it loops back to task breakdown rather than code execution.

A third, human-driven outcome at Stage 8 sits between these two:

3. **Stage 8 → Stage 5 (Business Logic Reviewer → Code Executor, "Conditional")**: the requirement was correctly understood (success criteria are met), but a flagged concern (Stage 7) needs a concrete fix before deployment — e.g., a missing authorization check. The reviewer lists the required fixes, which become the input to Stage 5; Stages 5→6→7 re-run for just that fix, then return to Stage 8 for final sign-off. Unlike a full reject, Stages 1-4 remain valid.

## Retry Logic

Retry behavior is governed by [`config/retry-limits.json`](config/retry-limits.json):

- On test failure (Stage 6), the workflow enters **RETRY_LOOP** (State 9).
- The Test Runner produces a detailed failure context (failing test names, error messages, stack traces, relevant diffs).
- This context is appended to the Stage 5 (Code Executor) input, and Stages 5 → 6 re-run.
- The default limit is **5 retries** (`test_failure_max_retries: 5`).
- Self-verification issues (Stage 7) have a separate, smaller retry budget — default **3 retries** (`self_verification_retries: 3`) — for auto-fixable issues only.
- If either retry budget is exhausted, the workflow transitions to **ESCALATE_TO_HUMAN** (State 10), surfacing:
  - The original task and prompt
  - All retry attempts and their failures
  - The current best-effort code state
  - A recommendation (e.g. "task may need to be split" or "missing dependency in codebase")
- A human resolves the escalation by either providing a fix directly, revising the task breakdown (back to Stage 2), or providing additional codebase context (back to Stage 3).

## Checkpoint Strategy

Every pipeline stage (1–8) ends with a checkpoint defined in [`config/checkpoint-definitions.json`](config/checkpoint-definitions.json). A checkpoint is a checklist the operator (or a reviewing agent) runs through before approving. Checkpoints exist to:

- Catch ambiguity early (Stage 1) before it propagates into wasted implementation effort
- Keep task granularity consistent (Stage 2) so retries and prompts stay scoped
- Ensure generated code matches existing patterns (Stages 3, 4, 7) rather than introducing inconsistency
- Guarantee a human always signs off on business correctness (Stage 8) — this is the only checkpoint that cannot be automated

Checkpoints are intentionally lightweight (4-5 yes/no items) so they don't become a bottleneck, but mandatory so that low-quality output can't silently propagate through 8 stages of context.

## Design Rationale

**Why a linear pipeline with checkpoints, rather than a single end-to-end prompt?**

A single prompt asking an AI agent to "build feature X" tends to produce code that compiles but doesn't fit the codebase, misses edge cases, or solves the wrong problem — and by the time a human notices, a large amount of code has already been generated and is hard to unwind. Splitting the process into 8 stages means:

- Mistakes are caught at the cheapest possible point (a misunderstood requirement is a one-paragraph fix at Stage 1; the same mistake found at Stage 8 means re-doing implementation and tests).
- Each stage has a narrow, well-defined input/output contract, which makes individual stages easy to swap, retry, or run with a different model/agent.
- The codebase analysis (Stage 3) happens *before* code generation, so generated code is informed by real conventions rather than generic best practices.
- Retries are scoped to Stages 5–6 (the expensive, iterative part) rather than re-running the entire pipeline.
- The final human checkpoint (Stage 8) is cheap because everything upstream has already been validated — the reviewer is checking business logic, not re-discovering architectural problems.

**Why tool-agnostic Markdown prompts rather than a scripted pipeline?**

Backend codebases, AI agents, and team conventions vary too much to hard-code. Markdown prompts can be read by any AI coding agent, edited by any team member without touching code, and version-controlled alongside the project they're used on. Teams that want automation can still wire these prompts into scripts or CI — the `config/` directory exists specifically to make that integration straightforward.
