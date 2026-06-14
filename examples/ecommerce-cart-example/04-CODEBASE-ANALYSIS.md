# Codebase Analysis: Shopping Cart Feature

> Source: 03-TASK-BREAKDOWN.md, module scope from 02-SPIKE-DOCUMENT.md

## Executive Summary

Analyzed the Order, Product, and User modules (Cart is new) against the 03-TASK-BREAKDOWN.md task list. The codebase is consistently layered (routes -> controller -> service -> model) with a shared `AppError`/`errorHandler` convention, Sequelize ORM, and Jest/Supertest testing. No blocking issues were found — the Cart feature can be built directly on top of existing patterns with no pre-build fixes required.

## Module Structure

| Module | Files/Directories Reviewed | Dependencies | Tasks Touching This Module |
|--------|------------------------------|---------------|------------------------------|
| Order | `src/models/order.js`, `src/services/orderService.js`, `src/controllers/orderController.js`, `src/routes/orders.js`, `tests/integration/orders.test.js` | Depends on Product (line item pricing), User (ownership); will depend on Cart after this feature | T-CART-007-A, T-CART-007-B |
| Product | `src/models/product.js`, `src/services/productService.js` | No internal dependencies (foundational) | T-CART-002, T-CART-003-A |
| User | `src/middleware/auth.js`, `src/models/user.js` | No internal dependencies (foundational) | T-CART-003-B, T-CART-004, T-CART-005, T-CART-006, T-CART-007-B (auth on all cart routes) |
| Cart (new) | n/a — does not exist yet | Will depend on User (auth) and Product (stock checks); Order will depend on Cart | T-CART-001, T-CART-003 through T-CART-007 |

No circular dependencies found or introduced — Cart depends on User/Product, Order depends on Cart, and Cart does not depend on Order.

## Patterns & Conventions

**Naming Conventions:**
- Models: singular PascalCase (`Order`, `Product`, `User`), files lowercase singular (`order.js`)
- Services: `[Entity]Service` exporting an object of functions, e.g. `orderService.createOrder(...)`
- Controllers: `[entity]Controller`, handler names match HTTP verbs loosely (`create`, `update`, `remove`, `list`)
- Routes: plural REST resource paths (`/orders`, `/products`)

**Error Handling:**
- Custom `AppError` class (`src/errors/AppError.js`) with `(message, statusCode)` constructor
- Services throw `AppError`; a global `errorHandler` middleware catches and formats responses as `{ error: { message, code } }`
- Validation errors specifically use `new AppError(message, 422)`

**Structure:**
- Layered: routes -> controller -> service -> model. Controllers are thin (extract params, call service, map result to response). Business logic lives entirely in services.

**Validation:**
- Request body validation via `express-validator` middleware declared in route files (e.g., `src/routes/orders.js` has `body('items').isArray()`)
- Domain validation (e.g., stock checks) happens in services, raised as `AppError`

**Data Access:**
- Sequelize ORM. Migrations in `migrations/`, one file per change, timestamp-prefixed
- Multi-step writes wrapped in `sequelize.transaction(...)` — see `orderService.createOrder`, which creates the `Order` and its `OrderItems` in one transaction

**Testing:**
- Jest (confirmed against `config/test-frameworks.json`)
- Unit tests: `tests/unit/[service].test.js`, mocking the model layer via `jest.mock`
- Integration tests: `tests/integration/[resource].test.js`, using a test database and `supertest` against the Express app

## Technical Concerns

| # | Issue | Module(s) | Impact | Recommendation | Effort | Priority | Blocking? |
|---|-------|-----------|--------|-----------------|--------|----------|-----------|
| 1 | `orderService.createOrder` takes `items: { productId, quantity }[]` directly from the controller with no shared type/validation beyond `express-validator` | Order, Cart (new) | T-CART-007-B needs to produce this exact shape from cart items; any mismatch fails silently at the service layer (no runtime type checking) | T-CART-007-A should define the shared `LineItem` shape as a JSDoc typedef referenced by both services, and add a small runtime assertion in `createOrder` | Quick fix | Medium | N |
| 2 | `Product` model has `stockQuantity: INTEGER`, no check constraint preventing negative values at the DB level | Product | T-CART-003-A's stock validation is the only thing preventing overselling; if bypassed (e.g., direct DB write elsewhere), no DB-level backstop | Out of scope for this feature — note as tech debt | Medium refactor | Low | N |
| 3 | No existing "one row per user" pattern to copy for `Cart.userId` unique constraint (T-CART-001) | Cart (new), User | Slight risk of getting the Sequelize migration syntax wrong without a reference | Use `User.email`'s unique index migration (`migrations/0003-add-user-email-unique.js`) as the syntax reference | Quick fix | Low | N |

## Tech Debt

- `Product.stockQuantity` has no DB-level non-negative constraint (see concern #2) — pre-existing, not introduced by this feature
- `orderService.createOrder` has a 180-line function that could be split (transaction setup, line item validation, order creation are all inline) — pre-existing, noted as a refactoring opportunity below but not required for this feature

## Refactoring Opportunities

| What Exists | Improvement | Benefit |
|-------------|-------------|---------|
| `orderService.createOrder` is one large function mixing transaction setup, validation, and creation | Extract `validateLineItems(items)` as its own function | T-CART-007-B can call the same validation function for checkout-time stock re-check, avoiding duplicated logic |
| `ProductService` has `getById` but no availability check | Add `checkAvailability(productId, quantity)` (T-CART-002) | Directly required by T-CART-003-A and T-CART-007-B; centralizes the stock-check logic |

## Pre-Build Tasks

None — no blocking concerns identified. All three technical concerns above are non-blocking and are either absorbed into existing tasks (concern #1 into T-CART-007-A, concern #3 into T-CART-001) or logged as tech debt (concern #2).

## Patterns Summary (Critical for Prompt Generation)

```
Naming Conventions:
- Models: singular PascalCase, files lowercase singular (order.js)
- Services: [entity]Service.js exporting an object of functions (cartService.addItemToCart)
- Controllers: [entity]Controller.js, handlers named create/update/remove/list/get
- Routes: plural REST paths (/cart, /cart/items), registered in src/app.js

Code Structure:
- Framework: Node.js / Express
- Dependency wiring: plain module imports (no DI container)
- Error Handling: throw `new AppError(message, statusCode)` from services;
  global `errorHandler` middleware formats `{ error: { message, code } }`;
  validation errors use status 422
- Validation: express-validator in route files for request shape;
  domain/business validation (e.g., stock checks) in services via AppError

Database:
- ORM: Sequelize
- Table/column naming: snake_case-free — Sequelize default camelCase columns,
  singular model names mapped to plural tables
- Migrations: timestamp-prefixed files in migrations/, one per change
- Multi-step writes: wrapped in sequelize.transaction(...)

Testing:
- Framework: Jest
- Location: tests/unit/[service].test.js (mocks models via jest.mock),
  tests/integration/[resource].test.js (supertest against the Express app, test DB)
- Coverage target: >=85% (per 03-TASK-BREAKDOWN.md Testing Strategy)

Response/Error Format:
Success: controller returns the resource/result directly as JSON
Error:   { "error": { "message": "...", "code": <statusCode> } }
```

## Recommendations

- All new Cart files should mirror `src/models/order.js`, `src/services/orderService.js`, `src/controllers/orderController.js`, and `src/routes/orders.js` structurally
- Cart routes should live at `src/routes/cart.js`, registered alongside `orders.js` in `src/app.js`
- Reuse `AppError` and the existing `errorHandler` — do not introduce a new error type
- T-CART-007-A's `LineItem` typedef should live in `src/types/lineItem.js` (new file) and be imported by both `cartService` and `orderService`

## Readiness Assessment

- **Ready to build now:** Yes
- **Blockers:** None
- **Risk level:** Low — codebase patterns are consistent and well-documented; the only moderate-impact concern (#1) is already addressed within T-CART-007-A's scope

## Assumptions & Notes

- Full read access to the Order, Product, and User modules was available; no sections were based on description alone
- `Cart` and `CartItem` do not exist yet, so "patterns" for them are inferred from the structurally closest existing module (`Order`/`OrderItem`)

---

**Status:** Approved
**Approved By:** Engineering Lead
**Date:** 2026-05-22
