# Generated Prompts: Task T-CART-003 (Add Item to Cart)

> Source: 03-TASK-BREAKDOWN.md (T-CART-003, T-CART-003-A, T-CART-003-B), 04-CODEBASE-ANALYSIS.md
> Depends on: T-CART-001 (Cart/CartItem models), T-CART-002 (ProductService.checkAvailability) — assumed complete

---

## Prompt for Task T-CART-003-A: `cartService.addItemToCart`

### Context

Existing services follow this pattern (`src/services/productService.js`):

```javascript
const { Product } = require('../models');
const AppError = require('../errors/AppError');

const productService = {
  async getById(productId) {
    const product = await Product.findByPk(productId);
    if (!product) throw new AppError('Product not found', 404);
    return product;
  },
};

module.exports = productService;
```

Errors use `AppError(message, statusCode)`. Validation errors use status `422`.

`ProductService.checkAvailability(productId, quantity)` (from T-CART-002) returns `{ available: boolean, product: Product }` and throws `AppError('Product not found', 404)` if the product doesn't exist.

### Task Description

Implement `cartService.addItemToCart(userId, productId, quantity)`:
- Find the user's `Cart` (via `Cart.findOne({ where: { userId } })`); if none exists, create one
- Call `ProductService.checkAvailability(productId, quantity)`; if `available` is `false`, throw `AppError('Insufficient stock', 422)`
- If a `CartItem` for this `productId` already exists in the cart, increment its `quantity` by the requested amount (re-checking availability against the **new total** quantity)
- Otherwise, create a new `CartItem` with the given `quantity`
- Return the updated cart with its items (include `CartItem` association)

### Expected Output

- `src/services/cartService.js`: new file, exports `cartService` object with `addItemToCart(userId, productId, quantity)`

### Constraints

- Do not modify `src/models/cart.js` or `src/models/cartItem.js` (T-CART-001's models are final for this task)
- Do not call `Product.findByPk` directly — use `ProductService.checkAvailability` and `ProductService.getById` only
- Do not implement the controller/route in this task (that's T-CART-003-B)

### Test Requirements (Jest)

- Unit test: `addItemToCart` creates a cart if none exists for the user
- Unit test: `addItemToCart` creates a new `CartItem` if the product isn't already in the cart
- Unit test: `addItemToCart` increments `quantity` if the product is already in the cart
- Unit test: `addItemToCart` throws `AppError('Insufficient stock', 422)` if `checkAvailability` returns `available: false`
- Unit test: `addItemToCart` re-checks availability against the combined quantity when incrementing an existing item

### Edge Cases to Consider

- Adding a product with `quantity` exceeding `Product.stockQuantity` -> throws 422, no `CartItem` created/updated
- Adding the same product twice where the *combined* quantity exceeds stock (even though each individual add was within stock) -> throws 422 on the second add
- Adding a non-existent `productId` -> propagates `AppError('Product not found', 404)` from `ProductService.checkAvailability`

### Depends On

T-CART-001, T-CART-002

---

## Prompt for Task T-CART-003-B: `POST /cart/items` controller + route

### Context

Existing controller pattern (`src/controllers/orderController.js`):

```javascript
const orderService = require('../services/orderService');

const orderController = {
  async create(req, res, next) {
    try {
      const order = await orderService.createOrder(req.user.id, req.body.items);
      res.status(201).json(order);
    } catch (err) {
      next(err);
    }
  },
};

module.exports = orderController;
```

Routes use `express-validator` for request body validation, and the shared `requireAuth` middleware (`src/middleware/auth.js`) which populates `req.user`.

### Task Description

Add a `POST /cart/items` endpoint:
- Validate `req.body` has `productId` (integer) and `quantity` (integer, >= 1) using `express-validator`
- Call `cartService.addItemToCart(req.user.id, req.body.productId, req.body.quantity)`
- Return `201` with the updated cart on success
- Errors (404, 422, validation errors) are handled by the existing `errorHandler` — controller just calls `next(err)`

### Expected Output

- `src/controllers/cartController.js`: new file, exports `cartController` with `addItem(req, res, next)`
- `src/routes/cart.js`: new file, registers `POST /cart/items` with `requireAuth` and validation middleware, wired to `cartController.addItem`
- `src/app.js`: register the new `cart` router (one-line addition, alongside the existing `orders` router registration)

### Constraints

- Follow the exact controller shape shown in Context (thin controller, `try/catch` -> `next(err)`)
- Do not add cart-viewing or other endpoints here — only `POST /cart/items`
- `src/app.js` change must be a minimal addition (one `app.use(...)` line); do not reorganize existing route registrations

### Test Requirements (Jest + Supertest)

- Integration test: `POST /cart/items` with valid body returns `201` and the updated cart (matches shape returned by `cartService.addItemToCart`)
- Integration test: `POST /cart/items` without auth returns `401`
- Integration test: `POST /cart/items` with `quantity: 0` or missing `productId` returns `400` (validation error)
- Integration test: `POST /cart/items` for a product with insufficient stock returns `422`
- Integration test: `POST /cart/items` for a non-existent `productId` returns `404`

### Edge Cases to Consider

- Missing `Authorization` header -> `401` (via `requireAuth`, not custom logic in this controller)
- `quantity` provided as a non-integer (e.g., string `"abc"`, or `1.5`) -> `400` via `express-validator`, before `cartService` is ever called

### Depends On

T-CART-003-A
