---
id: ivec2-dot
name: IVec2.dot
category: ivec2
kind: namespace-method
tokens: IVec2.dot
sig: IVec2.dot(a, b) -> int
tip: The dot product ax*bx + ay*by.
order: 7
ns: IVec2
member: dot
---

Returns the integer dot product <code>ax*bx + ay*by</code>. Its sign tells you whether two directions point roughly the same way.

```ludic
program Demo {
  handler Step phase Update {
    let facing = IVec2.dot(heading, toTarget)
  }
}
```
