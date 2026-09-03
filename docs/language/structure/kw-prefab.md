---
id: kw-prefab
name: prefab
category: structure
kind: keyword
tokens: prefab
sig: prefab Name: Model { Comp { field: value }, … }
tip: A model with preset component fields — spawn it, override what varies.
order: 9
---

A <code>prefab</code> names a model together with preset field values, so what every spawn of a kind shares is written once: <code>prefab Grunt: Creature { Stats { hp: 30 }, Weapon { def_id: 1 } }</code>. <code>spawn Grunt { Position { x: 40 } }</code> spawns the model with the prefab's presets and then the spawn's own fields on top. Prefabs chain — <code>prefab Grunt: Foe</code> where <code>Foe</code> is itself a prefab — so shared presets live in one place. Field values are ordinary expressions evaluated at each spawn (a preset may read a global such as a loaded sprite id), <code>@OnSpawn(Model)</code> runs as for any spawn of the model, <code>spawn</code> is also an expression yielding the new entity, and <code>Prefab.spawn(name:)</code> picks a prefab by name at runtime.

```ludic
# doc-check: skip — composite: prefabs plus their spawns
prefab Foe:   Creature { Faction { id: 2 }, Body { policy: BodyPolicy.TopDown } }
prefab Grunt: Foe { Stats { hp: 30, max_hp: 30 }, Weapon { def_id: WeaponId.Bite } }

let grunt = spawn Grunt { Position { x: 40, y: 60 } }
let other = Prefab.spawn(name: "Grunt")
```
