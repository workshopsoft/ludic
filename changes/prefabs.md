bump: minor
type: feat
**Prefabs.** `prefab Grunt: Creature { Stats { hp: 30 }, Weapon { def_id: 1 } }` names a model with preset fields; `spawn Grunt { Position { x: 40 } }` spawns it, the spawn's own fields winning over the presets. Prefabs chain (`prefab Grunt: Foe` where `Foe` is a prefab) so shared presets live once. `spawn` is now also an expression yielding the new entity (`let e = spawn Grunt { … }`), and `Prefab.spawn(name: "Grunt")` spawns one chosen at runtime by name (-1 when none matches).
