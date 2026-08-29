---
id: world-get
name: World.get
category: world
kind: namespace-method
tokens: World.get
sig: World.get(prop_id, field_id, entity) -> int
tip: Read a component field by id.
order: 0
ns: World
member: get
---

Reads the value of field <code>field_id</code> of component <code>prop_id</code> on <code>entity</code>, by numeric id rather than by name — the reflective form the bare <code>world_get</code> provides.
