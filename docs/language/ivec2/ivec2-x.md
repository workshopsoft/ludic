---
id: ivec2-x
name: IVec2.x
category: ivec2
kind: namespace-method
tokens: IVec2.x
sig: IVec2.x(v) -> int
tip: The x component of an integer vector.
order: 2
ns: IVec2
member: x
---

Reads the <code>x</code> (column) component of an <code>IVec2</code> as a plain <code>int</code>.

```ludic
program Demo {
  handler Step phase Update {
    let col = IVec2.x(IVec2.make(4, 7))
  }
}
```
