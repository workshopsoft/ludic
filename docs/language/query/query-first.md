---
id: query-first
name: Query.first
category: query
kind: namespace-method
tokens: Query.first
sig: Query.first(prop) -> int
tip: The lowest-id live entity carrying a property, or -1.
order: 2
ns: Query
member: first
---

Returns the first (lowest entity id) live entity that carries <code>prop</code>, or <code>-1</code> if none do. Handy for a singleton-ish lookup — the player, the current boss, the one active portal — and to test existence (<code>Query.first(prop) &gt;= 0</code>). Read its fields with <a href="world-get"><code>World.get</code></a>.

Parameters:
- `prop` — a property id (from `World.prop_id("Name")`)

```ludic
program Demo {
  property Player { hp: int = 0 }
  model Hero { Player }
  entry {
    spawn Hero { Player { hp: 100 } }
    let P  = World.prop_id("Player")
    let hp = World.field_id(P, "hp")
    let e  = Query.first(P)
    if e >= 0 { print(World.get(e, P, hp)) }   # 100
  }
}
```
