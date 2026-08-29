---
id: world-attach
name: World.attach
category: world
kind: namespace-method
tokens: World.attach
sig: World.attach(entity, prop_id) -> void
tip: Attach a component to an entity at runtime.
order: 13
ns: World
member: attach
---

Adds component <code>prop_id</code> to <code>entity</code>, so <code>World.get</code>/<code>set</code>/<code>has</code> then work on it.
