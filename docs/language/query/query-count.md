---
id: query-count
name: Query.count
category: query
kind: namespace-method
tokens: Query.count
sig: Query.count(prop) -> int
tip: How many live entities carry a property.
order: 1
ns: Query
member: count
---

Returns the number of live entities that carry the property <code>prop</code> (a property id from <a href="world-prop_id"><code>World.prop_id</code></a>). A quick population count — how many enemies are alive, how many pickups remain — without writing a query loop.

Parameters:
- `prop` — a property id (from `World.prop_id("Name")`)

```ludic
program Demo {
  property Enemy { hp: int = 0 }
  model Slime { Enemy }
  entry {
    spawn Slime { Enemy { hp: 3 } }
    spawn Slime { Enemy { hp: 3 } }
    let E = World.prop_id("Enemy")
    print(Query.count(E))   # 2
  }
}
```
