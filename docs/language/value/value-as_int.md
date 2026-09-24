---
id: value-as_int
name: Value.as_int
category: value
kind: namespace-method
tokens: Value.as_int
sig: Value.as_int(value) -> int
tip: Read a scalar node as an int.
order: 16
ns: Value
member: as_int
---

Returns the raw scalar an int/fixed/bool node carries, or a float node's whole part (a <code>fixed</code> comes back as its Q16.16 bits). Non-scalar nodes return <code>0</code>.
