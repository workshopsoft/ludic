---
id: value-free
name: Value.free
category: value
kind: namespace-method
tokens: Value.free
sig: Value.free(value) -> void
tip: Give back a tree's nodes and lists.
order: 39
ns: Value
member: free
---

Gives back every node and list under <code>value</code>, itself included; its strings stay. The same as <a href="json-free"><code>Json.free</code></a>. Only for a parsed tree: one put together by hand may share a node or hold a literal.
