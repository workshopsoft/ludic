# ludic.shop

Vendors behind counters: what each sells and buys, what a thing costs and fetches at the
player's standing, what each vendor is short of this week, and buying and selling through the
game's money and pack. Uses [`ludic.base`](../ludic.base/README.md) and nothing else.

```ludic
import "ludic.shop"
```

Items and vendors are the game's data, handed over as it boots: every item's base price and the
fraction of the curve a vendor pays for it (`shop_config_items`), and every vendor's shelves, what
it buys and the one thing it refuses (`shop_add_vendor`, numbered in the order added). A vendor is
a number; its name, face and words stay the game's.

## The rules it keeps

These hold whatever the numbers become, and the tests hold them:

1. **A shop is not a fountain.** A vendor never pays as much for a thing it stocks as it charges
   for it - not in a week it wants them, not at the best standing, and not even by a $1 floor: a
   penny item it stocks fetches nothing.
2. **Friction falls with standing and never inverts.** Buying runs from 1.15x base at standing 0
   to 0.92x at 100, selling from 0.62x to 0.85x (times the item's fraction), so a newcomer pays a
   little over and sells a little under, and the two never cross.
3. **Raw material keeps its order.** A sale is ROUNDED, not truncated, so cheap things spanning a
   wide range of base prices do not all land on $1.

## The ports

```ludic
export port ShopWorld {
  rep: fn() -> int                       # standing, 0 to 100
  day: fn() -> int                       # the game day; the demand turns every week (unbound: 1)
  buy_mult: fn() -> float                # a shortage on everything bought (unbound: 1)
  also_buys: fn(int, int) -> bool        # (vendor, item) taken beyond its list (unbound: none)
}
export port ShopPurse { money: fn() -> int, spend: fn(int) -> bool, earn: fn(int) -> void }
export port ShopPack { count, take, add, room }   # room unbound: no limit
```

## API

| | |
| --- | --- |
| `shop_config_items(prices, sell)`, `shop_clear_vendors()`, `shop_add_vendor(stock, buys, refuses) -> int` | the data |
| `shop_config_curve(buy_new, buy_best, sell_new, sell_best)`, `shop_config_demand(wants, want_mult, glut_mult, days, seed)` | the numbers (defaults 1.15, 0.92, 0.62, 0.85; 3 wanted at 1.5x, one glut at 0.6x, 7 days, seed 1013) |
| `shop_visit(v)`, `shop_away()`, `shop_vendor()`, `shop_at_counter()` | who is behind the counter (-1 nobody) |
| `shop_price_buy(it)`, `shop_price_sell(it)`, `shop_price_sell_at(v, it)`, `shop_buy_factor()`, `shop_sell_factor()` | prices; with no vendor, no demand and no fountain guard |
| `shop_stocks(v, it)`, `shop_buys(v, it)`, `shop_stock(v)`, `shop_sellable(v)` | shelves, and what in the pack a vendor takes |
| `shop_wants(v, it)`, `shop_glutted(v, it)`, `shop_wanted(v)`, `shop_demand_mult(v, it)`, `shop_week()`, `shop_set_want(v, it)` | the week's demand, from the shop's own `Rng` seeded by the week |
| `shop_can_buy(it)`, `shop_buy(it) -> bool`, `shop_sell(it, n) -> int` | one bought; up to `n` sold to the vendor at the counter |
| `shop_trades() -> Queue<ShopTrade>` | `{ what: SHOP_BOUGHT / SHOP_SOLD, vendor, item, n, price }` |
| `shop_reset()`, `shop_system() -> System` | `"shop"`, `PH_COMMIT`: a reset; nothing is saved (the week follows from the day) |

## Tests

```bash
ludic test packages/ludic.shop
```
