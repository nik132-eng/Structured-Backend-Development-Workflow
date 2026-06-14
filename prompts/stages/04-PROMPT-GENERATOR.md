# Stage 4: Prompt Generator

**Purpose:** Turn each task from Stage 2, informed by the patterns and concerns from Stage 3, into a structured, execution-ready prompt that Stage 5 (Code Executor) can act on directly without further clarification.

**Input:** Task list (Stage 2), codebase analysis (Stage 3)

**Output:** One execution prompt per task (or per sub-task, if a task was broken down)

---

## Step 1: Match Each Task to Relevant Analysis

For each task in the Stage 2 task list, pull the parts of the Stage 3 analysis that are directly relevant:

- Which module(s) does this task touch?
- What patterns (naming, error handling, structure, validation, data access) apply to those modules?
- Are there any blocking/non-blocking concerns specific to this task's area?

Don't include the *entire* Stage 3 report in every prompt — extract only what's relevant to keep each prompt focused.

---

## Step 2: Make Prompts Language/Framework-Aware

Use the language and framework identified in Stage 3 to:

- Reference the correct file extensions, import/module syntax, and idioms
- Reference the correct test framework (from [`../../config/test-frameworks.json`](../../config/test-frameworks.json)) for the "Test Requirements" section
- Use terminology consistent with the codebase (e.g., if the codebase says "controller" not "handler", use "controller")

---

## Step 3: Build Each Prompt

Each generated prompt should follow [`../../templates/PROMPT-TEMPLATE.md`](../../templates/PROMPT-TEMPLATE.md) and include:

- **Context**: relevant existing code patterns/snippets from Stage 3 that this task should match (e.g., "Existing controllers follow this structure: ...")
- **Task Description**: exactly what to build, taken from Stage 2, with enough detail that no further clarification is needed
- **Expected Output**: specific files to create/modify, and what each should contain
- **Constraints**: anything this task must NOT do (e.g., "do not modify the existing `OrderService` interface — only add a new method")
- **Test Requirements**: from Stage 2's test requirements, expanded with Stage 3's test framework/conventions
- **Edge Cases to Consider**: from Stage 1's technical concerns and Stage 2's test requirements, made concrete for this specific task

---

## Step 4: Handle Sub-Tasks

If a Stage 2 task was split into sub-tasks (e.g., `T-CART-003-A`, `T-CART-003-B`), generate a separate prompt for each sub-task, but cross-reference them — e.g., `T-CART-003-A`'s prompt should note "`T-CART-003-B` will add the corresponding controller/route; ensure the method you add here can be called from it."

---

## Step 5: Order Prompts for Execution

Order the generated prompts to match the dependency order from Stage 2's task list. Note in each prompt which prior task(s) it depends on, so Stage 5 can confirm those are complete before starting.

---

## Example Prompt Structure

```markdown
### Prompt for Task T-CART-003-B: Add item to cart endpoint

**Context:**
Existing cart-adjacent endpoints (e.g., `POST /orders`) follow this controller pattern:
[snippet from Stage 3 analysis]
Error responses use the `AppError` class with HTTP status codes mapped via `errorHandler` middleware.

**Task Description:**
Add a `POST /cart/items` endpoint that adds a product to the current user's cart. If the user has no cart yet, create one.

**Expected Output:**
- `src/controllers/cartController.js`: new `addItem` handler
- `src/services/cartService.js`: new `addItemToCart(userId, productId, quantity)` method
- `src/routes/cart.js`: register the new route

**Constraints:**
- Do not modify the existing `Cart` model schema (Stage 3 flagged a pending migration for that — out of scope for this task)
- Reuse `ProductService.getById` for product lookups (do not query the Product table directly)

**Test Requirements (Jest, per Stage 3):**
- Unit test: `cartService.addItemToCart` creates a cart if none exists
- Unit test: `cartService.addItemToCart` increments quantity if item already in cart
- Integration test: `POST /cart/items` returns 201 and the updated cart
- Edge case: adding a product with quantity exceeding available stock returns 422
- Edge case: adding a non-existent productId returns 404

**Depends On:** T-CART-003-A (cartService.addItemToCart), T-CART-001 (Cart model + migration)
```

---

## Step 6: Quality-Check Each Prompt

Before finalizing, run each prompt through this checklist. If any item fails, revise the prompt rather than leaving it for Stage 5 to figure out.

- [ ] **Context is complete**: every pattern/snippet the prompt references actually came from Stage 3's analysis, not a generic assumption
- [ ] **Examples are exact**: code snippets match the real codebase's style (naming, error handling, structure) — not textbook/framework-documentation examples
- [ ] **Requirements are unambiguous**: a reader with no other context could implement this without asking a clarifying question
- [ ] **Edge cases are concrete**: each one names specific values/scenarios, not just categories (e.g., "quantity 0" not "invalid input")
- [ ] **Test requirements are specific**: named scenarios with expected outcomes, matching Stage 3's test framework and conventions
- [ ] **Files are explicit**: exact paths, and whether each is new or modified
- [ ] **Success criteria are checkable**: someone could verify each one against the output without re-reading the whole task

---

## Common Mistakes to Avoid

| Instead of... | Do this |
|---|---|
| Generic examples copied from framework documentation | Use real snippets from Stage 3's analysis of *this* codebase |
| Vague requirements ("make it work", "handle errors properly") | Specific requirements ("throw `AppError('Insufficient stock', 422)` if quantity exceeds `Product.stockQuantity`") |
| Assuming Stage 5 already knows the codebase's conventions | State naming, structure, and error-handling conventions explicitly in every prompt |
| Listing edge cases as categories ("handle invalid input") | Name the exact scenario and expected result ("quantity = 0 -> 422 with message 'Quantity must be positive'") |
| Re-explaining the entire feature in every prompt | Scope each prompt to its task; cross-reference related tasks by ID instead of repeating their content |

---

## Checkpoint Checklist

Before handing off to Stage 5 (Code Executor):

- [ ] Every task/sub-task from Stage 2 has a corresponding prompt
- [ ] Each prompt references concrete patterns from Stage 3 (not generic guidance)
- [ ] Each prompt's "Expected Output" lists specific files
- [ ] Each prompt's test requirements name the correct framework and specific cases
- [ ] Edge cases are concrete, not placeholders
- [ ] Prompts are ordered by dependency
- [ ] User has reviewed and approved the generated prompts

## Output

Save as `[feature]-prompts.md` if running standalone. When run as part of the master workflow, these prompts — executed one at a time — become the input to [`05-CODE-EXECUTOR.md`](05-CODE-EXECUTOR.md).
