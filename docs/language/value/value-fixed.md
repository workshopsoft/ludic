---
id: value-fixed
name: Value.fixed
category: value
kind: namespace-method
tokens: Value.fixed
sig: Value.fixed(f: fixed) -> value
tip: Wrap a fixed in a value node.
order: 3
ns: Value
member: fixed
---

Builds a <code>fixed</code> node (kind <code>2</code>) carrying the raw Q16.16 value <code>f</code>. <a href="json-encode"><code>Json.encode</code></a> writes it as an exact decimal (e.g. <code>0.5</code>) that <a href="json-parse"><code>Json.parse</code></a> reads back bit-for-bit.
