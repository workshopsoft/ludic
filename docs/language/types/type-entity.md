---
id: type-entity
name: entity
category: types
kind: type
tokens: entity
sig: entity
tip: The id/handle of a spawned model instance, as returned by self().
order: 4
---

An `entity` is the id — an integer handle — of a <b>spawned model instance</b>. When you `spawn` a `model`, the running thing is a model instance, and its `entity` is the handle you use to refer to it: `self()` yields the `entity` of the instance the current `query` loop is visiting, and statements like `despawn`, `attach`, `detach`, `enable`, and `disable` take an `entity` to say which instance to act on. You rarely do arithmetic on it; think of it as an opaque reference into the ECS rather than a number. It is stored as an `int` under the hood and is part of the saved snapshot.

```ludic
for (current_position) in query [Position, {Enemy}] {
  let this_enemy: entity = self()
  if current_position.row > 14 { despawn this_enemy }
}
```
