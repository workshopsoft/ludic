---
id: value-str_owned
name: Value.str_owned
category: value
kind: namespace-method
tokens: Value.str_owned
sig: Value.str_owned(s: string) -> Value
tip: A str node that owns its text.
order: 38
ns: Value
member: str_owned
---

Makes a <code>str</code> node whose text the tree owns: <a href="json-free_all"><code>Json.free_all</code></a> frees it with the tree, and giving the node other text frees it. For a text made for a tree that is let go whole.
