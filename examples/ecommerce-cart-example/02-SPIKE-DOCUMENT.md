# Spike Document: Shopping Cart Feature

## Problem Statement (Refined)

Logged-in customers need the ability to add products to a persistent, server-side cart, adjust quantities, and remove items, prior to checkout. Checkout converts the cart into an `Order` (existing flow) and clears the cart. Guest carts are **out of scope** for this phase — cart requires authentication. If a cart item's product becomes out of stock or has insufficient quantity before checkout, the user is shown an error at checkout time and must adjust the cart (no automatic removal). Carts do not expire automatically in this phase (abandoned cart cleanup is a candidate for a future enhancement).

## Success Criteria

- [ ] Authenticated users can add a product (with quantity) to their cart
- [ ] Authenticated users can update the quantity of an item already in their cart
- [ ] Authenticated users can remove an item from their cart
- [ ] Authenticated users can view their current cart (items, quantities, computed subtotal)
- [ ] Checkout creates an `Order` from the cart contents and clears the cart, reusing the existing `Order` creation flow
- [ ] Adding/updating cart items validates against current `Product.stockQuantity`

## Module Scope

**In-Scope Modules:**
- **Cart Module (new)** — core feature: cart model, endpoints, service logic
- **User Module** — authentication (existing middleware), cart is keyed by `userId`
- **Product Module** — stock validation, product lookups for cart items
- **Order Module** — checkout converts cart to order (extends existing creation flow)

**Out-of-Scope Modules:**
- **Payment Module** — does not exist yet; explicitly deferred to a separate project per the requester
- **Notification Module** — no cart-related notifications (e.g., abandoned cart emails) in this phase
- **Analytics Module** — no cart analytics/event tracking in this phase

**Dependencies:**
- Cart Module depends on User Module (auth) and Product Module (stock checks)
- Order Module's checkout flow depends on Cart Module (new dependency introduced by this feature)
- No circular dependencies detected — Cart does not depend on Order

## Technical Approach

Add a new `Cart` module following the existing layered pattern (model / service / controller / routes) used by `Order`. A `Cart` has many `CartItems`, each referencing a `Product` and a `quantity`. One cart per user (created on first "add item" call if none exists). Checkout reuses `OrderService.createOrder`, passing cart items as line items, then clears the cart's items on success.

## Technical Concerns & Mitigations

| # | Issue | Impact | Recommendation | Blocking? |
|---|-------|--------|-----------------|-----------|
| 1 | `Product` table has no index on `stockQuantity`, and cart operations will read it on every add/update | Could slow down under load as cart volume grows | Not blocking now (cart volume is low initially); flag as P2 follow-up | N |
| 2 | No existing pattern for "user has at most one of X" (one cart per user) | Risk of duplicate carts if not enforced at DB level | Add a unique constraint on `Cart.userId` | Y |
| 3 | `OrderService.createOrder` currently takes line items as a raw array passed from the controller — no shared "line item" type between Cart and Order | Minor duplication risk between Cart and Order line item shapes | Extract a shared `LineItem` shape/interface used by both; small refactor | N |

## Enhancements to Consider

| What Exists | How It Could Be Improved | Benefit to This Feature |
|-------------|---------------------------|---------------------------|
| `OrderService.createOrder` accepts raw line item arrays | Define a shared `LineItem` type/interface | Cart -> Order handoff becomes type-safe and self-documenting |
| `ProductService.getById` does not check `stockQuantity` | Add a `ProductService.checkAvailability(productId, quantity)` helper | Reused by both Cart (add/update) and checkout validation |

## Assumptions

- Cart is per-user, not per-session — guest carts are not needed for this phase
- One active cart per user (no "saved for later" / multiple carts)
- Cart persists indefinitely until checkout or manual removal (no TTL in this phase)
- Currency/pricing snapshot is NOT taken at add-to-cart time — price is read live from `Product` at checkout (per existing `Order` behavior)

## Open Questions (If Any)

- None outstanding — all initial gaps were resolved during clarification.

---

**Status:** Approved
**Approved By:** Product Lead
**Date:** 2026-05-20
