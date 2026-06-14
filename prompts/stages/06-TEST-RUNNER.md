# Stage 6: Test Runner

**Purpose:** Generate and run tests for the code produced in Stage 5, following the test patterns identified in Stage 3, and report results. On failure, prepare a precise retry context for Stage 9 (Retry Loop) / Stage 5.

**Input:** Generated code (Stage 5), test patterns and framework from Stage 3's analysis, test requirements from Stage 2/4

**Output:** Test results (pass/fail with details); on failure, a structured retry context

---

## Step 1: Identify the Test Framework

Cross-reference Stage 3's findings with [`../../config/test-frameworks.json`](../../config/test-frameworks.json) to confirm the framework (e.g., Jest, Pytest, RSpec) and the project's test file conventions (location, naming, fixtures/mocking style).

If Stage 3 didn't identify a framework (e.g., no codebase access was available), ask the user which framework to target.

---

## Step 2: Generate Tests

Using the test requirements carried from Stage 2 (and refined in Stage 4's prompt), generate:

- **Unit tests**: for each new/modified function or method, covering normal cases and the specific edge cases listed in the prompt
- **Integration tests**: for each new/modified endpoint or cross-module interaction
- **Edge case tests**: explicitly covering every "Edge Cases to Consider" item from the Stage 4 prompt — do not skip these even if they seem unlikely

Tests should follow the codebase's existing conventions (file naming/location, fixture setup, mocking approach) as identified in Stage 3.

---

## Step 3: Run the Tests

Execute the generated tests against the Stage 5 code. Report results per test:

```text
PASS  cartService.addItemToCart > creates a cart if none exists
PASS  cartService.addItemToCart > increments quantity if item already in cart
FAIL  POST /cart/items > returns 422 when quantity exceeds stock
  Expected: 422
  Received: 201
  at tests/integration/cart.test.js:42
```

---

## Step 4: On Failure — Build Retry Context

If any test fails:

1. Collect the failing test names, expected vs. actual results, error messages/stack traces, and the relevant section of the Stage 5 code.
2. Categorize each failure to sharpen the root-cause hypothesis:
   - **Logic error**: the code ran, but produced the wrong result (wrong value, wrong exception type, missing validation branch)
   - **Mock/setup error**: the test's mocks/fixtures don't match what the code under test actually calls
   - **Integration error**: a failure involving the real database/test environment (constraint violation, connection issue, migration not applied)
   - **Framework/config error**: the test itself is misconfigured (wrong import, stale snapshot, test runner config) rather than the implementation being wrong
3. Form a hypothesis about the root cause, informed by the category (e.g., "stock validation is missing in `cartService.addItemToCart`" — a logic error, fix the implementation; vs. "the mock for `ProductRepository.findById` never resolves" — a mock/setup error, fix the test).
4. Package this as a **retry context**:

```text
Retry Context for T-CART-003-A (attempt N of [test_failure_max_retries]):

Failing Tests:
- POST /cart/items > returns 422 when quantity exceeds stock
  Expected: 422, Received: 201

Category: Logic error

Likely Cause:
- cartService.addItemToCart does not check requested quantity against Product.stockQuantity before adding to cart

Relevant Code:
[snippet of the function in question]

Suggested Fix Direction:
- Add a stock check before persisting the cart item; return/throw a validation error the controller maps to 422
```

5. Pass this retry context back to Stage 5 (this is **State 9 — RETRY_LOOP** in [`../../ARCHITECTURE.md`](../../ARCHITECTURE.md)). If the category is **mock/setup** or **framework/config**, note in the retry context that the fix likely belongs in the *test file*, not the implementation — Stage 5 should adjust its target accordingly.

Per [`../../config/retry-limits.json`](../../config/retry-limits.json), the default is `test_failure_max_retries: 5`. Track the attempt count. If it's exceeded:

- Stop retrying.
- Transition to **State 10 — ESCALATE_TO_HUMAN**: present the full retry history (all attempts, all failures, with their categories), the current best-effort code, and a recommendation (e.g., "consider splitting T-CART-003-A further — the stock-check logic may belong in `ProductService`, not `CartService`, per the Stage 3 analysis").

---

## Common Failure Patterns

| Category | Symptom | Where the fix usually belongs |
|---|---|---|
| Logic error | Wrong value/exception returned; code runs but produces an incorrect result | Stage 5 (implementation) |
| Mock/setup error | "Cannot read property of undefined", mock never resolves, assertion on a mock that wasn't called | The test file — fix the mock/fixture, not the implementation |
| Integration error | Constraint violation, connection error, "table/column does not exist" | Test environment/migrations, or a genuine schema issue to flag back to Stage 3 |
| Framework/config error | Import errors, stale snapshots, test runner config errors unrelated to the feature | Test file or project config — rarely the generated implementation |

---

## Step 5: On Success — Hand Off

If all tests pass, report the full pass results and hand off to [`07-SELF-VERIFIER.md`](07-SELF-VERIFIER.md) along with the test results.

---

## Output

- **On pass**: test results (all passing), forwarded to Stage 7.
- **On fail (retries remaining)**: retry context, forwarded to Stage 5 (Stage 9 / RETRY_LOOP).
- **On fail (retries exhausted)**: escalation package, forwarded to the human operator (State 10).

No human checkpoint occurs at this stage on success — it flows directly into Stage 7. The human checkpoint is at Stage 8.
