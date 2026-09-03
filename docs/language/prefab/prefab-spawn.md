---
id: prefab-spawn
name: Prefab.spawn
category: prefab
kind: namespace-method
tokens: Prefab.spawn
sig: Prefab.spawn(name: s) -> entity
tip: Spawn a prefab chosen by name at runtime; -1 if none has that name.
order: 1
ns: Prefab
member: spawn
---

Spawns the prefab whose name matches the string, with all its presets, and returns the new entity — or -1 when no prefab has that name. Set what varies per spawn afterwards through <code>Prop.of(entity)</code>.

```ludic
# doc-check: skip — illustrative
let e = Prefab.spawn(name: roster.roll())
Position.of(e).x = tile.x * 16
```
