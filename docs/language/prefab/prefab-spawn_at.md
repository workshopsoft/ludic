---
id: prefab-spawn_at
name: Prefab.spawn_at
category: prefab
kind: namespace-method
tokens: Prefab.spawn_at
sig: Prefab.spawn_at(name: s, at: IVec2) -> entity
tip: Spawn a prefab by name and place it.
order: 2
ns: Prefab
member: spawn_at
---

`Prefab.spawn` followed by writing the new entity's `Position` — the common case in one call.

```ludic
# doc-check: skip — illustrative
let foe = Prefab.spawn_at(name: "Grunt", at: IVec2.make(60, 60))
```
