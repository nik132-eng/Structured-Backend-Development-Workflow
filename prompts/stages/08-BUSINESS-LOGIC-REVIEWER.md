# Stage 8: Business Logic Reviewer

**Purpose:** This is the final human checkpoint. Every prior stage has validated *how* the code was built — this stage validates *whether it solves the right problem*. This cannot be automated away.

**Input:** Verified code and verification report (Stage 7), plus full context from all prior stages (problem statement, success criteria, task list, analysis, flagged concerns)

**Output:** Approval (-> State 11 / COMPLETE) or rejection with feedback (-> back to Stage 2)

---

## Step 1: Re-state What's Being Reviewed

Before the human reviews, summarize concisely:

- The original problem statement and success criteria (from Stage 1)
- The task(s) being reviewed and what they implement
- Any concerns flagged by Stage 7 that need a judgment call

This grounds the reviewer without requiring them to re-read every prior stage's output.

---

## Step 2: Requirement Verification Matrix

Before the broader checklist, trace each of Stage 1's success criteria to where it's implemented and how it's verified:

| Success Criterion (Stage 1) | Implemented In | Verified By (Stage 6/7) | Status |
|---|---|---|---|
| [Criterion] | [File/function/endpoint] | [Test name(s)] | Met / Not Met / Partially Met |

This makes "does it solve the original problem" concrete and checkable, rather than a judgment call made from memory.

---

## Step 3: Business Logic Validation Checklist

Walk through these questions with the human reviewer:

- [ ] **Does this solve the original problem?** Cross-check against the Requirement Verification Matrix above — not just "does the code run" but "does it address why this was requested."
- [ ] **Is the business logic correct?** Check the implementation against real-world rules (pricing, permissions, limits, statuses) that may not have been fully specified in Stage 2's task descriptions but are implied by the domain.
- [ ] **Does it fit the existing architecture?** Beyond Stage 7's structural check — does this make sense from a product/domain perspective alongside related features?
- [ ] **Are Stage 7's flagged concerns acceptable?** For each flagged concern, decide using the Decision Matrix below.
- [ ] **Does Stage 1's success criteria hold?** Every row in the Requirement Verification Matrix is "Met" (or "Partially Met" with an accepted follow-up).
- [ ] **Is it ready for deployment?** Anything environment-specific (config, migrations, feature flags) accounted for?

**Decision Matrix for flagged concerns** — for each concern Stage 7 raised, pick one:

| Decision | Meaning | When to use |
|---|---|---|
| Accept as-is | No action needed | The concern is informational, or an acceptable trade-off for now |
| Accept with follow-up | Log a new task (P1/P2), doesn't block this release | The concern is real but not urgent enough to delay — e.g., a rare race condition, a minor perf issue |
| Reject (blocks) | Must be fixed before approval | The concern represents incorrect business logic, a security gap, or a broken success criterion |

---

## Step 4: Decision

### If Approved

- Mark the task(s) complete.
- If this was the last remaining task in Stage 2's task list, transition to **State 11 — COMPLETE**.
- If tasks remain, return to Stage 5 for the next prompt in Stage 4's ordered list.

### If Conditional (Approved Pending Fixes)

Use this when the business logic and success criteria are sound, but one or more flagged concerns were marked "Reject (blocks)" in the Decision Matrix — i.e., the issue is a fixable implementation detail, not a misunderstanding of the requirement:

1. List the specific required fixes (be concrete — same standard as a rejection reason).
2. Route back to **Stage 5 (Code Executor)** with these fixes as the new task input — this re-enters Stages 5→6→7 for just the affected code, not the full Stage 2 re-planning loop.
3. Once the fixes pass Stage 6/7 again, return here for a final approve/reject decision (the Requirement Verification Matrix and Decision Matrix should now show all-clear).

### If Rejected

Rejection at this stage means the *business logic* is wrong — not a bug Stage 5/6/7 could have caught, but a mismatch with what was actually needed. This is treated as a **scoping problem**:

1. Document precisely what's wrong and why (be specific — "the discount should apply to the pre-tax subtotal, not the total" is actionable; "this doesn't feel right" is not).
2. Transition back to **Stage 2 (Task Breakdown)** with this feedback.
3. Stage 2 should re-examine the affected task(s) — and possibly Stage 1's success criteria, if the misunderstanding originated there — and produce a corrected task breakdown.
4. The corrected task(s) flow back down through Stages 3-8. Stages 3/4 may be skippable if the codebase analysis and patterns are unaffected — use judgment, but re-run Stage 6 (tests) and Stage 7 (verification) at minimum.

---

## Common Approval Scenarios

| Scenario | Typical Decision |
|---|---|
| All success criteria met, no flagged concerns | Approve outright |
| All success criteria met, only "accept as-is" / "accept with follow-up" concerns | Approve — log any follow-up tasks (P1/P2) for later |
| A success criterion is "Partially Met" but the gap is minor and well-understood | Approve with follow-up — log a task to close the gap, don't block release |
| Success criteria are correctly addressed, but a concern was marked "Reject (blocks)" and is a fixable implementation detail (e.g., missing authorization check) | Conditional — route to Stage 5 with the required fixes, then re-review |
| A success criterion is "Not Met", or a flagged concern reveals the implementation solves the wrong problem | Reject — route back to Stage 2 with specific feedback |

---

## Output Format

```text
Business Logic Review — [Task ID(s)]

Problem Statement Recap:
[from Stage 1]

Requirement Verification Matrix:
| Success Criterion | Implemented In | Verified By | Status |
|---|---|---|---|
| [Criterion] | [File/function/endpoint] | [Test name(s)] | Met / Not Met / Partially Met |

Flagged Concerns from Stage 7:
- [Concern] -> Accept as-is / Accept with follow-up / Reject (blocks)

Decision: APPROVED / CONDITIONAL / REJECTED

If CONDITIONAL:
  Required Fixes: [specific, checkable list]
  Routing: -> Stage 5 (Code Executor) with these fixes, then back through Stage 6/7 to here

If REJECTED:
  Reason: [specific business logic issue]
  Routing: -> Stage 2 (Task Breakdown) with this feedback
```

---

## Final Note

This is the only stage in the pipeline that **must** involve a human. If you are an AI agent operating this workflow autonomously, do not approve on the human's behalf — present the checklist and wait for an explicit decision.
