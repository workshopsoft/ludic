---
id: query-within
name: Query.within
category: query
kind: namespace-method
tokens: Query.within
sig: Query.within(prop, pos, x, y, radius, x_field, y_field) -> []int
tip: Every bearer of prop inside a radius of a point.
order: 4
ns: Query
member: within
---

Returns the live entities carrying <code>prop</code> whose position is within <code>radius</code> of <code>(x, y)</code>, as a <code>[]int</code> of entity ids in ascending id order — index it with <code>len</code> / <code>[i]</code>. Position is read from property <code>pos</code> at <code>x_field</code>/<code>y_field</code>, exactly as in <a href="query-nearest"><code>Query.nearest</code></a>. The boundary is inclusive (distance <code>&lt;= radius</code>), measured by exact integer distance. Use it for area-of-effect damage, proximity triggers, flocking neighbours, or "what's near the cursor".

Parameters:
- `prop` — the property that filters which entities are considered
- `pos` — the property holding the coordinates
- `x`, `y` — the centre of the query
- `radius` — the inclusive radius
- `x_field`, `y_field` — field ids of the x / y coordinate within `pos`

```ludic
program Demo {
  property Position { col: int = 0, row: int = 0 }
  property Unit { hp: int = 0 }
  model Soldier { Position, Unit }
  entry {
    spawn Soldier { Position { col: 1, row: 1 }, Unit { hp: 5 } }
    spawn Soldier { Position { col: 8, row: 8 }, Unit { hp: 5 } }
    let U  = World.prop_id("Unit")
    let P  = World.prop_id("Position")
    let cx = World.field_id(P, "col")
    let cy = World.field_id(P, "row")
    let hit = Query.within(U, P, 0, 0, 3, cx, cy)   # just the (1,1) soldier
    print(len(hit))                                  # 1
  }
}
```
