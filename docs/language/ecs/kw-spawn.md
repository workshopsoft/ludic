---
id: kw-spawn
name: spawn
category: ecs
kind: keyword
tokens: spawn
sig: spawn Label { Prop { field: v }; … }
tip: Create a model instance carrying the listed properties, seeding their fields.
order: 0
---

A <code>spawn</code> creates a new model instance and attaches the listed properties, each field starting from its default and then taking any overrides you give. The `Label` after `spawn` is just a readable name for the instance at that call site — it does not have to be a declared model — while the `{Prop { … }; …}` block is what actually determines which properties the instance carries. If you `spawn` a declared `model`, every property in that model comes along automatically. A newly spawned instance is visible to matching queries immediately, and one spawned mid-loop at a higher id is even visited in the same tick, so spawn into a later phase if you want to defer that.

```ludic
program Waves {
  property Position { column: int = 0, row: int = 0 }
  property Velocity { delta_x: int = 0, delta_y: int = 0 }
  property Health   { current: int = 100, maximum: int = 100 }
  model Enemy { Position, Velocity, Health }

  handler SpawnWave phase Start {
    spawn Grunt   { Position { column: 18, row: 4 }; Velocity { delta_x: -1 }; Health { current: 20 } }
    spawn Brute   { Position { column: 18, row: 9 }; Velocity { delta_x: -1 }; Health { current: 60 } }
  }
}
```
