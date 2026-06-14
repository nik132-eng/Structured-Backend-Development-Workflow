# Task Breakdown: Shopping Cart Feature

> Source: 02-SPIKE-DOCUMENT.md

## Overview

Building server-side shopping cart functionality for authenticated users: a `Cart`/`CartItem` data model, endpoints to add/update/remove items and view the cart with a computed subtotal, and a checkout flow that converts the cart into an `Order` via the existing `OrderService`. Payment integration and guest carts are explicitly out of scope (per the spike document) and are not represented as tasks here.

## Task List

| Task ID | Title | Description | Dependencies | Estimated Effort | Sub-tasks | Sub-Checkpoint |
|---------|-------|-------------|--------------|-------------------|-----------|------------------|
| T-CART-001 | Create Cart & CartItem models + migration | Define `Cart` and `CartItem` Sequelize models and migration, with a unique constraint on `Cart.userId` | None | 1d | None | A |
| T-CART-002 | Add `ProductService.checkAvailability` helper | Add a stock-availability check used by cart add/update and checkout | None | 0.5d | None | A |
| T-CART-003 | Add item to cart | Implement `cartService.addItemToCart` and `POST /cart/items` | T-CART-001, T-CART-002 | 2d | T-CART-003-A, T-CART-003-B | B |
| T-CART-004 | Update cart item quantity | Implement `PATCH /cart/items/:itemId` with stock re-validation | T-CART-003 | 1.5d | None | B |
| T-CART-005 | Remove item from cart | Implement `DELETE /cart/items/:itemId` with ownership checks | T-CART-003 | 1d | None | B |
| T-CART-006 | View cart with computed subtotal | Implement `GET /cart` returning items, quantities, and live-priced subtotal | T-CART-003 | 1.5d | None | C |
| T-CART-007 | Checkout integration with Order module | Shared `LineItem` shape + `cartService.checkout` that creates an Order and clears the cart | T-CART-001, T-CART-006 | 2.5d | T-CART-007-A, T-CART-007-B | D |

### Task Details

```text
Task ID: T-CART-001
Title: Create Cart & CartItem models + migration
Description: Define database schema for cart and cart_items tables, create Sequelize models and a migration.
Acceptance Criteria:
  - [ ] Cart model has: id, userId, createdAt, updatedAt
  - [ ] CartItem model has: id, cartId, productId, quantity
  - [ ] Foreign key constraints: CartItem.cartId -> Cart.id, CartItem.productId -> Product.id
  - [ ] Unique constraint on Cart.userId (one cart per user)
  - [ ] Migration applies cleanly and is reversible
Dependencies: None
Estimated Effort: 1 day
Test Requirements:
  - Migration applies and rolls back cleanly
  - Unique constraint rejects a second Cart for the same userId
Sub-tasks: None

---

Task ID: T-CART-002
Title: Add ProductService.checkAvailability helper
Description: Add a reusable stock-availability check, centralizing the logic used by cart add/update and checkout.
Acceptance Criteria:
  - [ ] checkAvailability(productId, quantity) returns { available: boolean, product }
  - [ ] Throws AppError('Product not found', 404) for unknown productId
  - [ ] available is false when quantity > product.stockQuantity
Dependencies: None
Estimated Effort: 0.5 day
Test Requirements:
  - Unit: returns available: true when quantity <= stockQuantity
  - Unit: returns available: false when quantity > stockQuantity
  - Unit: throws 404 for unknown productId
Sub-tasks: None

---

Task ID: T-CART-003
Title: Add item to cart
Description: Implement the add-to-cart service method and endpoint, including cart auto-creation and stock validation.
Acceptance Criteria:
  - [ ] Cart is auto-created on first add if the user has none
  - [ ] If the product is already in the cart, quantity is incremented (not duplicated)
  - [ ] Adding/incrementing validates against current Product.stockQuantity via T-CART-002
  - [ ] POST /cart/items returns 201 with the updated cart
Dependencies: T-CART-001, T-CART-002
Estimated Effort: 2 days
Test Requirements:
  - Unit: creates cart if none exists
  - Unit: increments quantity if item already in cart, re-checking combined quantity against stock
  - Integration: 201 on success, 422 on insufficient stock, 404 on unknown product, 401 if unauthenticated
Sub-tasks:
  - T-CART-003-A: cartService.addItemToCart (service + model logic)
  - T-CART-003-B: POST /cart/items controller + route + validation

---

Task ID: T-CART-004
Title: Update cart item quantity
Description: Implement PATCH /cart/items/:itemId to change the quantity of an existing cart item, re-validating stock.
Acceptance Criteria:
  - [ ] Quantity can be increased or decreased
  - [ ] Increasing quantity re-validates against Product.stockQuantity via T-CART-002
  - [ ] Returns 404 if the item does not belong to the requesting user's cart
Dependencies: T-CART-003
Estimated Effort: 1.5 days
Test Requirements:
  - Unit: updates quantity on a valid request
  - Edge: increasing quantity beyond stock throws 422, item unchanged
  - Integration: 404 if itemId is not in the requesting user's cart
Sub-tasks: None

---

Task ID: T-CART-005
Title: Remove item from cart
Description: Implement DELETE /cart/items/:itemId with ownership checks.
Acceptance Criteria:
  - [ ] Removes the specified CartItem
  - [ ] Returns 404 if the item does not belong to the requesting user's cart
  - [ ] Returns 204 on success
Dependencies: T-CART-003
Estimated Effort: 1 day
Test Requirements:
  - Unit: removes item by id
  - Integration: 404 if item belongs to another user's cart
  - Integration: 204 on success
Sub-tasks: None

---

Task ID: T-CART-006
Title: View cart with computed subtotal
Description: Implement GET /cart, returning items, quantities, and a subtotal computed from live Product prices.
Acceptance Criteria:
  - [ ] Returns the user's cart items with productId, quantity, and current unit price
  - [ ] Subtotal is computed from live Product prices (not a stored snapshot, per spike assumptions)
  - [ ] Returns an empty cart with subtotal 0 if the user has no cart yet
Dependencies: T-CART-003
Estimated Effort: 1.5 days
Test Requirements:
  - Unit: subtotal computed correctly from current product prices
  - Integration: 200 with empty cart (subtotal 0) for a user with no cart
Sub-tasks: None

---

Task ID: T-CART-007
Title: Checkout integration with Order module
Description: Define a shared LineItem shape used by Cart and Order, then implement cartService.checkout to re-validate stock, create an Order via OrderService, and clear the cart on success.
Acceptance Criteria:
  - [ ] Shared LineItem shape defined and used by both cartService and orderService
  - [ ] checkout() re-validates stock for every cart item before creating the order
  - [ ] If any item now exceeds stock, checkout fails with 422 and the cart is left unchanged
  - [ ] On success, an Order is created via OrderService.createOrder and the cart is cleared
  - [ ] POST /cart/checkout returns the created order
Dependencies: T-CART-001, T-CART-006
Estimated Effort: 2.5 days
Test Requirements:
  - Type-check / unit: existing Order tests still pass with the shared LineItem shape
  - Unit: cart is cleared only on successful order creation
  - Edge: stock shortfall at checkout time returns 422, cart unchanged
  - Integration: POST /cart/checkout returns the created order
Sub-tasks:
  - T-CART-007-A: Shared LineItem shape (src/types/lineItem.js) + orderService update
  - T-CART-007-B: cartService.checkout + POST /cart/checkout endpoint
```

## Dependency Graph

```text
T-CART-001 (1d)          T-CART-002 (0.5d)
       \                     /
        \                   /
         v                 v
        T-CART-003 (2d) [Checkpoint A precedes this]
         /        \          \
        v          v          v
T-CART-004 (1.5d)  T-CART-005 (1d)  T-CART-006 (1.5d)
   [Checkpoint B applies to 004, 005, 006]
                                       \
                                        v
                              T-CART-007 (2.5d) [Checkpoint D]
                                  ^
                                  |
                          T-CART-001 (LineItem shape input)
```

**Critical path:** T-CART-001 -> T-CART-003 -> T-CART-006 -> T-CART-007

## Sub-Checkpoints

**Checkpoint A (after T-CART-001 and T-CART-002):** Foundations ready
- [ ] Cart/CartItem models and migration applied; unique constraint on `Cart.userId` enforced
- [ ] `ProductService.checkAvailability` returns correct results for sufficient/insufficient/unknown product

**Checkpoint B (after T-CART-003, T-CART-004, T-CART-005):** Core cart CRUD complete
- [ ] Add-to-cart deduplicates (increments existing item) and enforces stock limits
- [ ] Quantity updates re-validate stock
- [ ] Item removal enforces per-user ownership

**Checkpoint C (after T-CART-006):** Cart view complete
- [ ] `GET /cart` returns correct items, quantities, and subtotal computed from live prices
- [ ] Empty-cart case returns subtotal 0

**Checkpoint D (final, after T-CART-007):** Feature complete
- [ ] Checkout re-validates stock and fails safely (422, cart unchanged) on shortfall
- [ ] Successful checkout creates an Order and clears the cart
- [ ] All tests passing across T-CART-001 through T-CART-007

## Timeline Estimate

- **Sequential:** 10 days (1 + 0.5 + 2 + 1.5 + 1 + 1.5 + 2.5)
- **With parallelism:** ~8.5 days (T-CART-004, T-CART-005, and T-CART-006 can run in parallel once T-CART-003 is complete — critical path becomes T-CART-001 -> T-CART-003 -> T-CART-006 -> T-CART-007 = 1 + 2 + 1.5 + 2.5 = 7 days, plus T-CART-002's 0.5d which can run alongside T-CART-001)
- **Critical path:** T-CART-001 -> T-CART-003 -> T-CART-006 -> T-CART-007

## Testing Strategy (per task)

- **Unit tests:** Jest, target >= 85% coverage for `cartService` and the new `ProductService.checkAvailability`
- **Integration tests:** Jest + Supertest against a test database, covering every new/changed endpoint (`POST /cart/items`, `PATCH /cart/items/:itemId`, `DELETE /cart/items/:itemId`, `GET /cart`, `POST /cart/checkout`)
- **Edge cases:** insufficient stock (add, update, and checkout-time), unknown productId, cross-user ownership on update/remove/checkout, empty cart on view and checkout

## Notes

- Payment integration is explicitly out of scope per the spike document and is not represented in this task list.
- T-CART-007 (checkout) is the highest-risk task — it's the only one that modifies the existing `Order` module (via the shared `LineItem` shape), so Stage 3 (Codebase Analyzer) should pay particular attention to `orderService.createOrder`.
- Cart expiration / abandoned-cart cleanup is out of scope for this phase, per the spike's assumptions.

---

**Status:** Approved
**Approved By:** Engineering Lead
**Date:** 2026-05-21
