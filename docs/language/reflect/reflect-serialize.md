---
id: reflect-serialize
name: Reflect.serialize
category: reflect
kind: namespace-method
tokens: Reflect.serialize
sig: Reflect.serialize(entity) -> value
tip: Walk an entity's components into a value tree.
order: 13
ns: Reflect
member: serialize
---

Walks every component the <code>entity</code> carries and every field of each into a generic <a href="value-object"><code>object</code></a> value tree: one member per component, each a sub-object of its fields. A <code>fixed</code> field becomes a <a href="value-fixed"><code>fixed</code></a> node, everything else an <a href="value-int"><code>int</code></a> node, so a <code>serialize</code> → <a href="reflect-apply"><code>apply</code></a> round-trip is bit-exact; the model id rides along under the reserved <code>"@kind"</code> key. Pair it with <a href="json-encode"><code>Json.encode</code></a> for a one-call save. It names no component or field, so it works over any schema — the pattern auto-save and debug inspectors use.
