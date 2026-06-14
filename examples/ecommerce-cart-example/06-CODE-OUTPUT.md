# Code Output: Task T-CART-003 (Add Item to Cart)

> Generated from 05-GENERATED-PROMPTS.md by Stage 5 (Code Executor). Simplified for example purposes.

## `src/services/cartService.js` (new)

```javascript
const { Cart, CartItem } = require('../models');
const AppError = require('../errors/AppError');
const productService = require('./productService');

const cartService = {
  async addItemToCart(userId, productId, quantity) {
    let cart = await Cart.findOne({ where: { userId }, include: CartItem });
    if (!cart) {
      cart = await Cart.create({ userId });
      cart.CartItems = [];
    }

    const existingItem = cart.CartItems.find((item) => item.productId === productId);
    const totalQuantity = existingItem ? existingItem.quantity + quantity : quantity;

    const { available } = await productService.checkAvailability(productId, totalQuantity);
    if (!available) {
      throw new AppError('Insufficient stock', 422);
    }

    if (existingItem) {
      existingItem.quantity = totalQuantity;
      await existingItem.save();
    } else {
      await CartItem.create({ cartId: cart.id, productId, quantity });
    }

    return Cart.findOne({ where: { userId }, include: CartItem });
  },
};

module.exports = cartService;
```

## `src/controllers/cartController.js` (new)

```javascript
const cartService = require('../services/cartService');

const cartController = {
  async addItem(req, res, next) {
    try {
      const cart = await cartService.addItemToCart(
        req.user.id,
        req.body.productId,
        req.body.quantity
      );
      res.status(201).json(cart);
    } catch (err) {
      next(err);
    }
  },
};

module.exports = cartController;
```

## `src/routes/cart.js` (new)

```javascript
const express = require('express');
const { body } = require('express-validator');
const requireAuth = require('../middleware/auth');
const validate = require('../middleware/validate');
const cartController = require('../controllers/cartController');

const router = express.Router();

router.post(
  '/items',
  requireAuth,
  [body('productId').isInt(), body('quantity').isInt({ min: 1 })],
  validate,
  cartController.addItem
);

module.exports = router;
```

## `src/app.js` (modified — one line added)

```javascript
// ...existing requires...
const cartRouter = require('./routes/cart');

// ...existing app.use registrations...
app.use('/cart', cartRouter);
```

---

This code is now passed to [`07-TEST-RESULTS.md`](07-TEST-RESULTS.md) (Stage 6).
