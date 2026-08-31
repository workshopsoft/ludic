---
id: value-null
name: Value.null
category: value
kind: namespace-method
tokens: Value.null
sig: Value.null() -> value
tip: An empty null node.
order: 1
ns: Value
member: null
---

Builds a <code>null</code> node — the absent value. <a href="value-get"><code>Value.get</code></a> and <a href="value-at"><code>Value.at</code></a> return one for a missing key or out-of-range index, so a reader never faults on absent data. Its <a href="value-kind"><code>Value.kind</code></a> is <code>0</code>.
