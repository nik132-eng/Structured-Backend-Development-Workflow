# Stage 5: Code Executor

**Purpose:** Execute a single Stage 4 prompt and produce the actual code changes it describes. This stage is intentionally simple — it is a focused pass-through from prompt to code, with no independent validation (validation happens in Stages 6 and 7).

**Input:** One execution prompt from Stage 4 (plus, on retry, failure context from Stage 9 / Stage 6)

**Output:** Generated code — new and modified files matching the prompt's "Expected Output"

---

## Step 1: Confirm the Prompt's Dependencies Are Met

Before writing any code, check the prompt's "Depends On" field. If a dependency task hasn't been completed yet (in this session), flag it rather than guessing at what it produced.

---

## Step 2: Implement Exactly What's Described

Follow the prompt's sections directly:

- **Context** — match the existing patterns shown (naming, structure, error handling, etc.)
- **Task Description** — implement this and only this
- **Expected Output** — create/modify exactly these files; don't add extra files "while you're at it"
- **Constraints** — do not violate these, even if it seems like a reasonable improvement (improvements belong in Stage 1's "Enhancements" or Stage 3's "Refactoring Opportunities", not slipped into task execution)

If something in the prompt is genuinely impossible or contradictory given the actual code (e.g., a referenced file/function doesn't exist), stop and report this rather than improvising — this likely means Stage 3's analysis missed something, and the prompt may need regenerating.

---

## Step 3: Handle Retries (State 9 — RETRY_LOOP)

If this is a retry following a Stage 6 test failure, you will additionally receive:

- The failing test names and error output
- The relevant diff/code from the previous attempt
- Any analysis from the Test Runner about likely root cause

Use this context to fix the specific failure — don't rewrite unrelated parts of the implementation. Per [`../../config/retry-limits.json`](../../config/retry-limits.json), this can happen up to `test_failure_max_retries` times before escalation.

---

## Step 4: Output the Code

Output the code as file diffs or full file contents, clearly labeled with file paths, matching the "Expected Output" section of the prompt. Do not include commentary about testing or verification — that's Stages 6 and 7.

---

## Output

The generated code for this task, ready to be handed to [`06-TEST-RUNNER.md`](06-TEST-RUNNER.md). No checkpoint is required at this stage — Stage 5's output is validated by Stage 6 (automated) and Stage 7 (verification), with the human checkpoint occurring at Stage 8.
