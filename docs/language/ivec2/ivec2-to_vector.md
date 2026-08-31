---
id: ivec2-to_vector
name: IVec2.to_vector
category: ivec2
kind: namespace-method
tokens: IVec2.to_vector
sig: IVec2.to_vector(v) -> Vector
tip: Widen to a fixed-point Vector.
order: 10
ns: IVec2
member: to_vector
---

Widens an integer vector into a fixed-point <code>Vector</code>, so a grid coordinate can flow into the sub-pixel <code>Vector.*</code> math (interpolation, rotation, length).

```ludic
program Demo {
  handler Step phase Update {
    let world = IVec2.to_vector(cell)
  }
}
```
