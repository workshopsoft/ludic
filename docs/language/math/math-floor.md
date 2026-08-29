---
id: math-floor
name: Math.floor
category: math
kind: namespace-method
tokens: Math.floor
sig: Math.floor(x) -> int
tip: Round a fixed value down to the nearest whole int.
order: 5
ns: Math
member: floor
---

Takes a <code>fixed</code> value and returns the largest <code>int</code> not greater than it — rounding toward negative infinity, so <code>Math.floor(2.7)</code> is <code>2</code> and <code>Math.floor(-0.2)</code> is <code>-1</code>. This is the fixed-to-int conversion you reach for when turning a smooth position into a whole tile or pixel index. It is the same operation as the bare <code>flr(x)</code>.

Parameters:
- `x` — the `fixed` value to round down

```ludic
program TileIndex {
  const TILE_SIZE: fixed = 16.0

  var world_x: fixed = 40.5

  handler Locate phase Update {
    let column = Math.floor(world_x / TILE_SIZE)   # 2
  }
}
```
