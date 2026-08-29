---
id: math-ceil
name: Math.ceil
category: math
kind: namespace-method
tokens: Math.ceil
sig: Math.ceil(x) -> int
tip: Round a fixed value up to the nearest whole int.
order: 6
ns: Math
member: ceil
---

Takes a <code>fixed</code> value and returns the smallest <code>int</code> not less than it — rounding toward positive infinity, so <code>Math.ceil(2.1)</code> is <code>3</code> and <code>Math.ceil(4.0)</code> stays <code>4</code>. Use it when you need to cover a fractional amount with whole units: how many full tiles a span touches, or how many rows a variable-height list needs.

Parameters:
- `x` — the `fixed` value to round up

```ludic
program RowsNeeded {
  const ROW_HEIGHT: fixed = 12.0

  var content_height: fixed = 30.0

  handler Layout phase Update {
    let rows = Math.ceil(content_height / ROW_HEIGHT)   # 3
  }
}
```
