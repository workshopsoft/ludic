---
id: type-vector
name: Vector
category: types
kind: type
tokens: Vector
sig: Vector
tip: A 2D vector — two fixed components (x, y), copied by value.
order: 13
---

<code>Vector</code> is a 2D vector: two Q16.16 <code>fixed</code> components, <code>x</code> and <code>y</code>, packed into a single value that is copied by value and never heap-allocates. It is the natural type for positions, velocities, directions, and offsets. Build one with <code>Vector.make(x, y)</code> (or <code>Vector.zero()</code>), read the parts with <code>Vector.x</code> / <code>Vector.y</code>, and combine them with the <code>Vector.*</code> math — add, scale, dot, length, normalize, rotate, and the rest. Every operation is deterministic fixed-point, so results are bit-identical on every platform.

```ludic
program Demo {
  handler Step phase Update {
    let velocity: Vector = Vector.scale(Vector.from_angle(heading), speed)
    position = Vector.add(position, velocity)
  }
}
```
