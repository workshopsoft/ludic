---
id: value-bool
name: Value.bool
category: value
kind: namespace-method
tokens: Value.bool
sig: Value.bool(b: bool) -> value
tip: Wrap a bool in a value node.
order: 4
ns: Value
member: bool
---

Builds a <code>bool</code> node (kind <code>3</code>). It encodes to JSON <code>true</code>/<code>false</code>. Read it with <a href="value-as_int"><code>Value.as_int</code></a> (0 or 1).
