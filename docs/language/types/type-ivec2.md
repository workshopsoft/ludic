---
id: type-ivec2
name: IVec2
category: types
kind: type
tokens: IVec2
sig: IVec2
tip: An integer 2D vector — two int components (x, y), copied by value.
order: 14
---

<code>IVec2</code> is an integer 2D vector: two whole-number <code>int</code> components, <code>x</code> and <code>y</code>, packed into a single value that is copied by value and never heap-allocates. It is the natural type for tile and grid coordinates, cell offsets, and integer sizes — anywhere a fractional part would be meaningless. Build one with <code>IVec2.make(x, y)</code> (or <code>IVec2.zero()</code>), read the parts with <code>IVec2.x</code> / <code>IVec2.y</code>, and combine them with the <code>IVec2.*</code> math — add, sub, scale, dot, and the grid-distance <code>IVec2.manhattan</code>. Every operation is exact integer arithmetic, so results are bit-identical on every platform. Widen to a sub-pixel <code>Vector</code> with <code>IVec2.to_vector</code> when you need fractional math.

```ludic
program Demo {
  handler Step phase Update {
    var cell: IVec2 = IVec2.make(4, 7)
    cell = IVec2.add(cell, IVec2.make(1, 0))
  }
}
```
