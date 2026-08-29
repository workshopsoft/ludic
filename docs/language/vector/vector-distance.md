---
id: vector-distance
name: Vector.distance
category: vector
kind: namespace-method
tokens: Vector.distance
sig: Vector.distance(a, b) -> fixed
tip: The distance between two points.
order: 9
ns: Vector
member: distance
---

Returns the distance between points <code>a</code> and <code>b</code> — <code>Vector.length(Vector.sub(a, b))</code>. Handy for range checks and proximity triggers.

```ludic
program Demo {
  handler Step phase Update {
    if Vector.distance(pos, target) < 8.0 { arrived() }
  }
}
```
