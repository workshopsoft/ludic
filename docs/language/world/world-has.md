---
id: world-has
name: World.has
category: world
kind: namespace-method
tokens: World.has
sig: World.has(entity, prop_id) -> int
tip: Does an entity have a component?
order: 2
ns: World
member: has
---

Returns non-zero when <code>entity</code> carries the component <code>prop_id</code>. Use it before <code>World.get</code> on a dynamically-attached component.
