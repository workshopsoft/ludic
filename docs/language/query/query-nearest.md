---
id: query-nearest
name: Query.nearest
category: query
kind: namespace-method
tokens: Query.nearest
sig: Query.nearest(prop, pos, x_field, y_field, x, y) -> int
tip: The bearer of prop closest to a point, by squared distance.
order: 3
ns: Query
member: nearest
---

Returns the live entity carrying <code>prop</code> whose position is closest to <code>(x, y)</code>, or <code>-1</code> if none. Position comes from property <code>pos</code> at its integer fields <code>x_field</code> and <code>y_field</code> — pass the same id for <code>prop</code> and <code>pos</code> to query the coordinate component itself, or a separate tag for <code>prop</code> to mean "nearest <em>Enemy</em>". Distance is compared by exact squared integer distance (no square root), and ties go to the lower entity id, so the result is fully deterministic. The go-to for target acquisition, "interact with the closest thing", or nearest-neighbour AI.

Parameters:
- `prop` — the property that filters which entities are considered
- `pos` — the property holding the coordinates
- `x_field`, `y_field` — field ids of the x / y coordinate within `pos`
- `x`, `y` — the point to measure from

```ludic
program Demo {
  property Position { col: int = 0, row: int = 0 }
  property Enemy { hp: int = 0 }
  model Slime { Position, Enemy }
  entry {
    spawn Slime { Position { col: 2, row: 0 }, Enemy { hp: 3 } }
    spawn Slime { Position { col: 9, row: 0 }, Enemy { hp: 3 } }
    let E  = World.prop_id("Enemy")
    let P  = World.prop_id("Position")
    let cx = World.field_id(P, "col")
    let cy = World.field_id(P, "row")
    let e  = Query.nearest(E, P, cx, cy, 0, 0)   # the enemy at col 2
    print(World.get(e, P, cx))                    # 2
  }
}
```
