---
id: value-float
name: Value.float
category: value
kind: namespace-method
tokens: Value.float
sig: Value.float(x: float) -> value
tip: Wrap a float in a value node.
order: 36
ns: Value
member: float
---

Builds a <code>float</code> node (kind <code>7</code>) carrying <code>x</code>. Read it back with <a href="value-as_float"><code>Value.as_float</code></a>; <a href="value-as_int"><code>Value.as_int</code></a> gives its whole part. <code>Json.encode</code> writes it as a number.
