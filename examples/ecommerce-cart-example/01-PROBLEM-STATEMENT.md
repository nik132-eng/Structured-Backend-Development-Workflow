# Problem Statement (Initial / Raw)

> We need shopping cart functionality. Right now customers can only place an order directly — there's no way to collect items over time before checking out. Add a cart so customers can add products, change quantities, and remove items, then check out into an order. Eventually this will connect to the new payment provider we're integrating, but that's a separate project.

## Context Provided by Requester

- **Platform**: Node.js / Express REST API, PostgreSQL via Sequelize
- **Existing modules**: `User` (auth, profiles), `Product` (catalog, stock), `Order` (checkout, order history)
- **Users affected**: All logged-in customers
- **Timeline**: Needed for next release (3 weeks)
- **Constraints mentioned**: Must work with existing stock levels in `Product`; cart should persist across sessions (stored server-side, not just client-side)

## Initial Gaps Identified by Stage 1

The raw statement doesn't specify:
- What happens to cart items if stock runs out between adding to cart and checkout?
- Is there a cart expiry / abandoned cart policy?
- Can a guest (non-logged-in) user have a cart, or login-only?
- Does checkout create an `Order` directly, or is there an intermediate state?

These gaps were resolved during Stage 1's clarification step — see [`02-SPIKE-DOCUMENT.md`](02-SPIKE-DOCUMENT.md) for the refined problem statement.
