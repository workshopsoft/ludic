---
id: ivec2-y
name: IVec2.y
category: ivec2
kind: namespace-method
tokens: IVec2.y
sig: IVec2.y(v) -> int
tip: The y component of an integer vector.
order: 3
ns: IVec2
member: y
---

Reads the <code>y</code> (row) component of an <code>IVec2</code> as a plain <code>int</code>.

```ludic
program Demo {
  handler Step phase Update {
    let row = IVec2.y(IVec2.make(4, 7))
  }
}
```
