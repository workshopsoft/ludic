---
id: reflect-apply
name: Reflect.apply
category: reflect
kind: namespace-method
tokens: Reflect.apply
sig: Reflect.apply(entity, value) -> int
tip: Write a value tree's fields back into an entity.
order: 14
ns: Reflect
member: apply
---

The inverse of <a href="reflect-serialize"><code>Reflect.serialize</code></a>: writes the fields of a value-tree <code>value</code> back into a live <code>entity</code>, and returns how many were set. Only components the entity already has and fields the schema knows are applied; reserved <code>"@"</code>-keys (like <code>"@kind"</code>) and unknown names are skipped, so a partial or older save loads cleanly. Feed it the output of <a href="json-parse"><code>Json.parse</code></a> to load a save.
