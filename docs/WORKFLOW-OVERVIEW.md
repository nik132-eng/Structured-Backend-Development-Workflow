# Workflow Overview

This document explains each of the 8 stages in detail, why checkpoints matter, when to use the master workflow vs. individual stages, and how to troubleshoot common problems.

## Stage-by-Stage

### Stage 1: Spike Document Generator

Turns a (possibly vague) problem statement into a refined problem statement, module scope, and list of technical concerns. This is the cheapest place to catch a misunderstanding — a wrong assumption here costs a few minutes of conversation; the same wrong assumption caught at Stage 8 costs a full re-implementation.

**Spend time here if**: the problem statement is one or two sentences, or you're not sure which parts of the codebase this touches.

### Stage 2: Task Breakdown

Decomposes the spike document's technical approach into atomic, independently testable tasks with dependencies mapped. Good task breakdown is what makes retries (Stage 9) cheap — a retry only re-runs one task's Stage 5/6, not the whole feature.

**Spend time here if**: any task feels like it touches "everything" — that's a sign it needs splitting.

### Stage 3: Codebase Analyzer

Looks at the actual code in the modules identified in Stage 1, for the tasks identified in Stage 2, and extracts real patterns (naming, error handling, structure, testing conventions). This is what makes Stage 4's prompts produce code that *fits* rather than code that's merely "correct in isolation."

**Spend time here if**: the codebase has inconsistent patterns across modules — call this out explicitly so Stage 4 knows which pattern to follow for this feature.

### Stage 4: Prompt Generator

Combines Stage 2's tasks with Stage 3's patterns into execution-ready prompts — one per task (or sub-task). A good Stage 4 prompt is one Stage 5 can execute without asking a single clarifying question.

**Spend time here if**: a task's "Edge Cases to Consider" feels generic — generic edge cases produce generic (missing) tests in Stage 6.

### Stage 5: Code Executor

Executes one prompt, producing code. Deliberately the "dumbest" stage — no validation, no judgment calls beyond following the prompt and its constraints. All judgment happens in Stages 1-4 (before) and 6-8 (after).

### Stage 6: Test Runner

Generates and runs tests per the prompt's test requirements and Stage 3's framework/conventions. On failure, builds a retry context and loops back to Stage 5 (State 9 / RETRY_LOOP in `ARCHITECTURE.md`).

**This is where most iteration happens.** A well-scoped Stage 2 task + well-specified Stage 4 prompt usually converges within 1-2 retries.

### Stage 7: Self-Verifier

With tests passing, checks for things tests don't catch: architectural fit, security/concurrency/data-integrity trade-offs, performance. Auto-fixes small, safe issues; flags everything else for Stage 8.

### Stage 8: Business Logic Reviewer

The only mandatory human checkpoint. Confirms the code solves the *actual* problem (Stage 1's success criteria), not just "passes its own tests." Rejections here loop back to Stage 2 (task breakdown), because a business-logic mismatch usually means the task was scoped around the wrong understanding of the requirement.

## Why Checkpoints Matter

Without checkpoints, errors compound silently across stages — by the time a misunderstanding surfaces (often only at deployment), you're unwinding 8 stages of context. Checkpoints turn a potential end-to-end failure into a small, local correction at the stage where the error originated. They also create natural pause points: you can stop after any checkpoint and resume later without losing context, because the approved output of each stage is a self-contained artifact.

## Master Workflow vs. Individual Stages

- **New feature, starting from a problem statement** -> use `prompts/MASTER-WORKFLOW.md`. It orchestrates all 8 stages and handles context-passing automatically.
- **You already have an approved spike document** (e.g., written by a PM) and want to start at Stage 2 -> load `prompts/stages/02-TASK-BREAKDOWN.md` directly with the spike document as input.
- **Re-running a single stage** (e.g., the codebase changed since Stage 3 ran, and you want to refresh the analysis before generating new prompts) -> load that stage's prompt directly, with its required inputs.
- **A rejected Stage 8 review** -> the master workflow handles the loop back to Stage 2 automatically; if running stages individually, manually re-invoke Stage 2 with the rejection feedback.

## Troubleshooting

**"Stage 4's prompts keep producing code that doesn't match our conventions."**
Stage 3's analysis is probably too shallow or too generic. Re-run Stage 3 and explicitly paste in 2-3 representative files per module (model, service, controller, test) rather than describing patterns abstractly.

**"Stage 6 keeps failing the same test after multiple retries."**
Check whether the retry context (built in Stage 6) is correctly diagnosing the root cause — sometimes the *test* is wrong, not the code (see the example in `examples/ecommerce-cart-example/07-TEST-RESULTS.md` for a worked case of this). If `self_verification_retries`/`test_failure_max_retries` (see `config/retry-limits.json`) are exhausted, the issue likely needs a human at Stage 8/Stage 2 — the task may be scoped around an incorrect assumption.

**"Stage 8 keeps rejecting for reasons that feel like they should've been caught earlier."**
This usually means Stage 1's success criteria were too vague to be "Met / Not Met" testable. Tighten the success criteria — each should be a yes/no question about the *feature*, not the *code*.

**"I want to skip a stage."**
See `docs/CUSTOMIZATION-GUIDE.md` — some stages (5, 6) are marked non-`required` in `config/checkpoint-definitions.json` and can be skipped if you're not generating/running code through this workflow (e.g., using it purely for planning).

## Escalation Paths

Most issues resolve within the stage that found them (a revise, or the Stage 9 retry loop). The following situations need a human decision beyond the normal checkpoint flow:

**Test retries exhausted (Stage 6 → State 10)**
`test_failure_max_retries` (default 5, see `config/retry-limits.json`) attempts have failed. Present the full retry history (every attempt's failure category and hypothesis, per `06-TEST-RUNNER.md`), the current best-effort code, and a recommendation — often "split this task further" or "the codebase analysis is missing a pattern Stage 4 needed." The human can: refine the Stage 4 prompt and retry, fix the remaining issue manually, or send it back to Stage 2 if the task itself was mis-scoped.

**Stage 8 conditional approval (Stage 8 → Stage 5)**
A flagged concern needs a concrete fix, but the requirement was correctly understood. Route the required fixes to Stage 5 as a new task input; Stages 5→6→7 re-run for just that fix, then return to Stage 8. See `08-BUSINESS-LOGIC-REVIEWER.md`'s "If Conditional" section.

**Stage 8 rejection (Stage 8 → Stage 2)**
The implementation is correct but solves the wrong problem, or a success criterion is "Not Met" in a way that can't be patched locally. This is a scoping issue, not a code issue — return to Stage 2 with specific feedback (what's wrong and why), and possibly revisit Stage 1's success criteria if the misunderstanding originated there.

**Stage 7 flags an architectural concern outside this task's scope**
E.g., "this works, but exposes that `ProductService.getById` doesn't handle soft-deleted products." Don't fix it inline — log it as a follow-up task (P1/P2) and let Stage 8 decide whether it blocks this release (Decision Matrix in `08-BUSINESS-LOGIC-REVIEWER.md`).

## Best Practices

**Do:**
- Read each stage's output before approving its checkpoint — catching a misunderstanding at Stage 1 costs minutes; catching it at Stage 8 costs a re-implementation.
- Invest in Stages 1-3: a clear problem statement, well-scoped tasks, and an accurate codebase analysis are what make Stages 5-7 converge quickly with few retries.
- Treat repeated retries (3+) as a signal to revisit the task's scope or the Stage 3 analysis, not just "try again."
- Keep success criteria in Stage 1 testable as "Met / Not Met" — vague criteria are what make Stage 8 rejections feel like they "should've been caught earlier."

**Don't:**
- Don't skip checkpoints to save time — an unreviewed Stage 3 or Stage 4 output tends to surface as rework at Stage 6 or Stage 8.
- Don't treat "tests pass" as equivalent to "done" — Stage 7 and Stage 8 exist because tests verify the code does what it was told, not that it was told the right thing.
- Don't let Stage 7's flagged concerns go undocumented — even "accept as-is" decisions should be recorded, so the reasoning is visible later.
- Don't bypass Stage 8 for "small" changes — it's the only checkpoint that catches a correct-but-wrong-problem implementation.
