---
id: prefab
title: Prefab
order: 47
---

A <code>prefab</code> is a model with preset component fields — <code>prefab Grunt: Creature { Stats { hp: 30 }, Weapon { def_id: 1 } }</code> — spawned with <code>spawn Grunt { Position { x: 40 } }</code>, where the spawn's own fields override the presets. Prefabs chain (<code>prefab Grunt: Foe</code>, where <code>Foe</code> is itself a prefab) so shared presets live once. <code>spawn</code> is also an expression yielding the new entity (<code>let e = spawn Grunt { … }</code>), and <a href="prefab-spawn"><code>Prefab.spawn</code></a> spawns a prefab chosen at runtime by name.
