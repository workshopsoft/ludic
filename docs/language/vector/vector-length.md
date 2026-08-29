---
id: vector-length
name: Vector.length
category: vector
kind: namespace-method
tokens: Vector.length
sig: Vector.length(v) -> fixed
tip: The length (magnitude) of a vector.
order: 8
ns: Vector
member: length
---

Returns the Euclidean length of <code>v</code>, computed with the deterministic fixed-point square root. When you only need to compare magnitudes, comparing <code>Vector.dot(v, v)</code> avoids the square root.

```ludic
program Demo {
  handler Step phase Update {
    let speed = Vector.length(velocity)
  }
}
```
