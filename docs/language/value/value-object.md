---
id: value-object
name: Value.object
category: value
kind: namespace-method
tokens: Value.object
sig: Value.object() -> value
tip: An empty object node.
order: 7
ns: Value
member: object
---

Builds an empty <code>object</code> node (kind <code>6</code>) — an ordered set of key/value members. Set members with <a href="value-put"><code>Value.put</code></a>; read them with <a href="value-get"><code>Value.get</code></a>, <a href="value-key_at"><code>Value.key_at</code></a>, and <a href="value-count"><code>Value.count</code></a>. This is the shape <a href="reflect-serialize"><code>Reflect.serialize</code></a> produces.
