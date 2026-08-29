---
id: type-fixeds
name: fixeds
category: types
kind: type
tokens: fixeds
sig: fixeds
tip: A buffer of fixed-point values — f[i] reads and writes a fixed.
order: 8
---

A <code>fixeds</code> is a raw buffer whose elements are <code>fixed</code> (Q16.16) values: index it with <code>buffer[i]</code> to read or write a <code>fixed</code> directly, with no bounds checking. You obtain one by allocating raw storage with <code>words(n)</code> — each slot is 32 bits — and typing the binding as <code>fixeds</code> so that indexing uses the fixed-point element size. Reach for it when you want a tight, fixed-size numeric array with deterministic math — a table of speeds, per-tile weights, a heightfield — and a growable <code>[]fixed</code> slice would be more than you need.

```ludic
program Heights {
  handler Setup phase Start {
    let heights: fixeds = words(4)
    heights[0] = fx(2)
    heights[1] = heights[0] + fx(1)
    print(flr(heights[1]))
  }
}
```
