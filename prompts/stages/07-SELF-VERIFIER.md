# Stage 7: Self-Verifier

**Purpose:** With code passing its tests (Stage 6), step back and check it for architectural fit, trade-offs, and performance implications that tests alone wouldn't catch. Auto-fix what's safe; flag what isn't.

**Input:** Passing code (Stage 5/6), test results (Stage 6), codebase analysis (Stage 3)

**Output:** Verification report; auto-fixed code where safe, plus a list of flagged concerns for Stage 8

---

## Step 1: Architectural Concerns

Compare the implementation against Stage 3's documented patterns and Stage 1's technical approach:

- Does this code follow the same structure as similar existing code (controller/service/repository layering, naming, file organization)?
- Did Stage 5 introduce any new dependencies, patterns, or abstractions not justified by the task? (e.g., a new utility library for something the codebase already has a helper for)
- Does this code respect the module boundaries from Stage 1's Module Scope (no reaching into out-of-scope modules' internals)?

---

## Step 2: Trade-offs & Threats

- Are there any security implications (input validation, authz checks, injection risks) given the codebase's existing security patterns?
- Does this introduce any data integrity risks (e.g., missing transaction boundaries for multi-step writes)?
- Are there concurrency concerns (race conditions on shared resources, e.g., two requests adding to the same cart simultaneously)?

**Security checklist** — walk through each, against the codebase's existing conventions (Stage 3):

- **Input validation**: does every new input go through the same validation as comparable existing endpoints (not just type-checked, but range/format-checked)?
- **Authorization vs. authentication**: is the endpoint not just behind auth, but does it also verify the *caller owns or may access* the specific resource (e.g., this cart belongs to this user)?
- **Injection risks**: any raw queries or string-built commands introduced, where the existing codebase uses an ORM/parameterized queries?
- **Secrets**: any credentials, tokens, or keys hardcoded instead of read from config/env, matching existing convention?
- **Sensitive data exposure**: does any response include fields (passwords, tokens, internal-only data) that existing similar endpoints exclude?
- **Rate limiting / abuse**: if the codebase has rate limiting on comparable endpoints, does this new endpoint have it too?

---

## Step 3: Performance Implications

- Does this introduce any N+1 query patterns, unnecessary loops over large collections, or synchronous calls in a hot path?
- If Stage 3 flagged related performance risks (e.g., missing index), does this task make that risk worse, the same, or does it actually need that fix to perform acceptably?

---

## Step 4: Classify Issues

For each issue found, classify as:

- **Auto-fixable (safe)**: small, local, unambiguous fixes that don't change the task's intent. Examples:
  - Adding a missing `await`
  - Wrapping related writes in a transaction per existing codebase convention
  - Adding an input validation check that mirrors an existing pattern elsewhere in the codebase
  - Removing unused imports
  - Extracting a magic number/string to a named constant
  - Adding a null/empty check before accessing a property, matching how similar code elsewhere handles it
  - Adding debug/info logging at the same points and level as comparable existing code

- **Flag for human (Stage 8)**: anything that changes scope, requires a judgment call, or touches code outside this task's "Expected Output". Examples:
  - "This task works but exposes that the existing `ProductService.getById` doesn't handle soft-deleted products, which could cause stale cart items."
  - Adding caching — affects data-freshness guarantees, needs a product/team decision
  - Adding rate limiting where no comparable endpoint has it — establishes a new policy, not just a fix
  - Changing an error/exception type — could be a breaking API contract change for clients
  - Restructuring code toward a different design pattern (e.g., strategy pattern) — correct but out of scope for this task

Per [`../../config/retry-limits.json`](../../config/retry-limits.json), auto-fix attempts are capped at `self_verification_retries` (default 3) — if an auto-fix doesn't resolve cleanly within that budget, downgrade it to a flagged concern instead.

---

## Step 5: Apply Auto-Fixes

Apply safe auto-fixes directly to the code. Re-run the relevant Stage 6 tests (or note that they should be re-run) to confirm the fix doesn't break anything.

---

## Output Format

```text
Verification Report for [Task ID]:

Architectural Review:
- [Finding] -> [Assessment: OK / Auto-fixed / Flagged]

Trade-offs & Threats:
- [Finding] -> [Assessment]

Performance:
- [Finding] -> [Assessment]

Auto-Fixes Applied:
1. [Fix description] -> [Why it was safe to auto-fix]

Flagged for Business Logic Reviewer (Stage 8):
1. [Concern] -> [Why it needs human judgment] -> [Recommendation]
```

---

## Checkpoint Checklist

Before handing off to Stage 8 (Business Logic Reviewer):

- [ ] Architectural fit checked against Stage 3 patterns
- [ ] Security, data integrity, and concurrency considered
- [ ] Performance implications considered, especially re: Stage 3's flagged risks
- [ ] All safe issues auto-fixed and re-tested
- [ ] Remaining concerns are clearly flagged with recommendations, not buried

## Output

Verified code (with auto-fixes applied) plus the verification report, forwarded to [`08-BUSINESS-LOGIC-REVIEWER.md`](08-BUSINESS-LOGIC-REVIEWER.md). This is the last automated stage — Stage 8 is the final human checkpoint.
