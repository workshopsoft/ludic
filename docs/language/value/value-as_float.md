---
id: value-as_float
name: Value.as_float
category: value
kind: namespace-method
tokens: Value.as_float
sig: Value.as_float(value) -> float
tip: Read a number node as a float.
order: 37
ns: Value
member: as_float
---

Returns the number any number node carries as a float: a <code>float</code> as it is, an <code>int</code> widened, a <code>fixed</code> converted from Q16.16. Other nodes return <code>0.0</code>.
