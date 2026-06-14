# Checkpoint Guide

Checkpoints are short checklists run at the end of each pipeline stage, defined in `config/checkpoint-definitions.json` and recorded using `templates/CHECKPOINT-CHECKLIST.md`. This guide explains what to actually check (beyond just reading the checklist item) and common mistakes at each one.

## Stage 1 Checkpoint: Spike Document

**What to check:**
- Read the "Problem Statement (Refined)" out loud — does it answer what/why/who/when/constraints without referring back to the original raw request?
- For each item in "Module Scope -> In-Scope Modules", ask: "if this module turned out to need *no* changes, would the feature still work?" If yes, it probably shouldn't be in-scope.
- "Success Criteria" should be answerable Met/Not Met later, in Stage 8, without re-interpretation.

**Common mistakes:**
- Treating "Open Questions" as optional — an unresolved open question here becomes a wrong assumption baked into Stage 2's task breakdown.
- Listing modules as "in scope" because they're *related*, not because this feature *changes* them. Being read by a module doesn't make it in-scope; being modified does.

## Stage 2 Checkpoint: Task Breakdown

**What to check:**
- Any task estimated at more than ~3 days — was it actually split into sub-tasks, or just left oversized with a note?
- Pick 2-3 tasks at random and check their "Test Requirements" — are they specific (named scenarios) or generic ("add tests")?
- Trace the dependency graph — does execution order make sense, and are there no cycles?

**Common mistakes:**
- Tasks that bundle "implement X" and "refactor Y to support X" into one task — these should usually be separate tasks (refactor first, with its own tests) so a failure in one doesn't block the other.
- Sub-checkpoints (tasks needing extra Stage 3/8 scrutiny) being identified too late — flag these here, not when you're already in Stage 4.

## Stage 3 Checkpoint: Codebase Analysis

**What to check:**
- "Coding Patterns Found" — could you hand this section to a new team member and have them write code that fits, without seeing the actual codebase? If not, it's too abstract.
- Every "Technical Concern" should be marked Blocking Y/N — any blocking concern must be resolved (or moved into the task list) before Stage 4.
- Confirm the test framework/conventions section matches `config/test-frameworks.json` and what Stage 6 will actually need.

**Common mistakes:**
- Analyzing only the *new* module (e.g., only `Cart`) and skipping existing modules the feature integrates with (e.g., `Order`) — integration points are usually where Stage 6/7 surprises come from.
- Marking a concern "non-blocking" because fixing it feels like scope creep, without checking whether the *new* feature makes the concern materially worse (re-read Stage 1's "Enhancements to Consider" — if the concern is there, it was already flagged as relevant).

## Stage 4 Checkpoint: Prompt Generation

**What to check:**
- Pick one generated prompt and check: does its "Context" section contain an actual code snippet (not a description of one)?
- "Edge Cases to Consider" — are these the *same* edge cases from Stage 2's test requirements, just copy-pasted, or have they been made concrete with real values/scenarios?
- Check prompt ordering against the Stage 2 dependency graph.

**Common mistakes:**
- Constraints that are too vague to enforce ("don't break anything") instead of specific ("do not modify the `Cart` model schema — that's a separate migration task").
- Prompts that re-explain the entire feature instead of just the task — this dilutes focus and increases the chance Stage 5 does more than the task requires.

## Stage 5/6 Checkpoints (Optional)

These are marked `"required": false` in `config/checkpoint-definitions.json` because Stage 6's pass/fail result is itself a checkpoint of sorts. If you do check manually:

- **Stage 5**: did the generated code touch only the files in the prompt's "Expected Output"? Extra files touched "while at it" should be reverted and, if genuinely needed, turned into a new task.
- **Stage 6**: for a passing run, briefly scan the generated tests — do they test behavior, or do they test that the implementation does what the implementation does (tautological tests)?

## Stage 7 Checkpoint: Self-Verification

**What to check:**
- For each "Auto-Fix Applied", was it re-tested? (Should be stated explicitly.)
- For each "Flagged for Business Logic Reviewer" item, is there a concrete recommendation, not just a description of the problem?

**Common mistakes:**
- Auto-fixing something that changes behavior in a way Stage 2's test requirements didn't anticipate — if a fix isn't covered by an existing test, it's not "safe," it should be flagged instead.

## Stage 8 Checkpoint: Business Logic Review

**What to check:**
- Walk through *every* success criterion from Stage 1, even ones that seem obviously met — this is the only stage that re-reads Stage 1 in full.
- For each flagged Stage 7 concern, make an explicit decision (accept / accept with follow-up / reject) — don't let any concern pass through silently.
- If rejecting, is the feedback specific enough that Stage 2 can act on it without another round-trip to the reviewer?

**Common mistakes:**
- Approving because "the code looks fine" without checking it against Stage 1's success criteria specifically — code can be well-written and still solve the wrong problem.
- Rejecting with feedback that's actually a Stage 7 concern (architecture/performance) rather than a business logic mismatch — route those back to Stage 7, not Stage 2.
