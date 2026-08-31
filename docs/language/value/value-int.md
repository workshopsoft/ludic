---
id: value-int
name: Value.int
category: value
kind: namespace-method
tokens: Value.int
sig: Value.int(n: int) -> value
tip: Wrap an int in a value node.
order: 2
ns: Value
member: int
---

Builds an <code>int</code> node (kind <code>1</code>) carrying <code>n</code>. Read it back with <a href="value-as_int"><code>Value.as_int</code></a>. This is the node <a href="reflect-serialize"><code>Reflect.serialize</code></a> uses for every non-<code>fixed</code> field.
