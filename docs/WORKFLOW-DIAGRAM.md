# Workflow State Diagram

This is the full 12-state machine referenced in `ARCHITECTURE.md`, with additional detail on each transition.

## Full Diagram

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
                                  │ 2. Task Breakdown      │◄────────────────┐
                                  └──────────┬─────────────┘                  │
                                    approve  │  revise (loop)                 │
                                              ▼                                │
                                  ┌───────────────────────┐                  │
                                  │ 3. Codebase Analyzer   │                  │
                                  └──────────┬─────────────┘                  │
                                    approve  │  revise (loop)                 │
                                              ▼                                │
                                  ┌───────────────────────┐                  │
                                  │ 4. Prompt Generator    │                  │
                                  └──────────┬─────────────┘                  │
                                    approve  │  revise (loop)                 │
                                              ▼                                │
                                  ┌───────────────────────┐                  │
                          ┌──────►│ 5. Code Executor       │                  │
                          │       └──────────┬─────────────┘                  │
                          │                  ▼                                │
                          │       ┌───────────────────────┐                  │
                          │       │ 6. Test Runner         │                  │
                          │       └──────────┬─────────────┘                  │
                          │            pass  │  fail                          │
                          │                  │                                │
                          │      ┌───────────┴────────────┐                  │
                          │      ▼                         ▼                  │
                          │  (continue)          ┌──────────────────┐         │
                          │                       │ 9. RETRY_LOOP     │         │
                          │                       │ (attempt < max)   │         │
                          │                       └─────────┬─────────┘         │
                          │                  retry available │  max retries reached
                          └─────────────────────────────────┤                  │
                                                              ▼                  │
                                                  ┌───────────────────────┐     │
                                                  │ 10. ESCALATE_TO_HUMAN  │     │
                                                  └────────────┬───────────┘     │
                                                               │ human resolves   │
                                                               ▼                  │
                                  ┌───────────────────────┐                     │
                                  │ 7. Self-Verifier       │◄──────────────┐     │
                                  └──────────┬─────────────┘                │     │
                                    approve  │  issues found ────────────────┘     │
                                              ▼                                     │
                                  ┌───────────────────────┐                       │
                                  │ 8. Business Logic      │                       │
                                  │    Reviewer            │                       │
                                  └──────────┬─────────────┘                       │
                                  approve     │  reject ─────────────────────────────┘
                                              ▼
                                  ┌───────────────────────┐
                                  │ 11. COMPLETE           │
                                  └───────────────────────┘
```

## Transition Reference

| From | To | Trigger | Notes |
|------|----|---------|-------|
| START | Stage 1 | Operator provides problem statement | |
| Stage 1 | Stage 1 | "revise" | Checkpoint not approved; feedback folded into re-run |
| Stage 1 | Stage 2 | "approve" | Spike document becomes Stage 2 input |
| Stage 2 | Stage 2 | "revise" | |
| Stage 2 | Stage 3 | "approve" | Task list + module scope become Stage 3 input |
| Stage 3 | Stage 3 | "revise" | |
| Stage 3 | Stage 4 | "approve" | Analysis + task list become Stage 4 input |
| Stage 4 | Stage 4 | "revise" | |
| Stage 4 | Stage 5 | "approve" | First prompt dispatched |
| Stage 5 | Stage 6 | Code generated | Automatic, no checkpoint |
| Stage 6 | Stage 7 | All tests pass | Automatic |
| Stage 6 | State 9 (RETRY_LOOP) | One or more tests fail, retries remain | Automatic |
| State 9 | Stage 5 | Retry context built | Re-enters Code Executor with failure context |
| State 9 | State 10 (ESCALATE_TO_HUMAN) | Retries exhausted (`test_failure_max_retries`) | |
| State 10 | Stage 7 | Human resolves escalation | Resumes pipeline at Self-Verifier once code is fixed |
| Stage 7 | Stage 7 | Auto-fix applied, re-test needed | Internal loop, capped by `self_verification_retries` |
| Stage 7 | Stage 8 | Verification complete (issues resolved or flagged) | |
| Stage 8 | State 11 (COMPLETE) | Approved, no tasks remain | Terminal |
| Stage 8 | Stage 5 | Approved, tasks remain | Next task's prompt (from Stage 4's ordered list) dispatched |
| Stage 8 | Stage 2 | Rejected (business logic mismatch) | Treated as scoping issue, not a code bug |

## Worked Example: Test Failure -> Retry -> Resolution

See `examples/ecommerce-cart-example/07-TEST-RESULTS.md` for a concrete walkthrough of Stage 6 -> State 9 (RETRY_LOOP) -> Stage 5 -> Stage 6 (pass) -> Stage 7, where:

1. Stage 6 (first run) fails 1 of 11 tests.
2. State 9 builds a retry context with a root-cause hypothesis.
3. The fix (in this case, to the test mock rather than the implementation) is applied.
4. Stage 6 (second run) passes all 11 tests, proceeding to Stage 7.

This illustrates that the "fix" during a retry isn't always a production code change — Stage 5/9 may determine the test itself was wrong, and the retry context should reflect that honestly rather than forcing a production code change to satisfy an incorrect test.
