# ludic.furniture

What fills a room a player owns. Kinds of furniture are rows a game writes in a `.lres`; an interior is an
**instance** the game names with a key string (a flat, a cabin, a house - the game's own idea, which this package
never names), and what is placed in it is checked and kept per key. The room's extent and its own geometry are
asked of the game through a port, money through another; what happened comes out as facts. Uses
[`ludic.base`](../ludic.base/README.md) and nothing else.

```ludic
import "ludic.furniture"
```

**Placement** is on a grid (when the world says a cell size above 0) or free (cell 0), and every placement is
checked, cheapest no first: the rule of its place (which also finds its height and what it stands on), the room,
other furniture, the world's own geometry, the category's limit, the instance's budget. A refused verb says
why (`furniture_why`, a `FURN_REFUSED` fact). Only the host edits, and only for a player the world lets edit that
instance (`may_edit`: the owner, a roommate - the game's rule).

## The data

| Registry (prefix) | Record | What a row is |
| --- | --- | --- |
| `FurnitureCategories` (`FCAT`) | `FurnitureCategory` | a category: `title`, `icon`, and a `limit` on how many of it one instance holds (0: none) |
| `FurnitureItems` (`FURN`) | `FurnitureItem` | a kind: `model` (`@Asset("gltf")`) and `socket` (`@Node(model)`), `category`, `w` by `d` by `h` metres, `place` (`floor`, `wall`, `ceiling`, `surface`), `stackable` and `surface_h` (what other things stand on), `yaw_steps` (4: quarter turns; 0: any angle), `price`, `refund_pct`, and `cost` against the instance's budget |

```
chair  { category: FCAT_SEATING, w: 0.5, d: 0.5, h: 1.0, price: 100 }
table  { category: FCAT_DECOR, w: 2.0, d: 1.0, h: 0.8, price: 400, cost: 2, stackable: true }
lamp   { category: FCAT_DECOR, place: "surface", w: 0.3, d: 0.3, h: 0.5, price: 50 }
```

The rules of a place:

- **floor**: its base is the floor's height there; it may not go into another piece whose height it shares.
- **wall**: the world must say there is a wall (`wall_ok`); the height is the one asked, kept between the floor and the
  ceiling; only its centre must be in the room. It passes over a floor piece lower than it is hung.
- **ceiling**: hangs from the ceiling's height at that point; a ceiling lower than the piece is refused.
- **surface**: stands wholly inside a `stackable` piece's footprint, on the topmost such piece, at its base plus
  its `surface_h` (its height when 0). No piece under it is a refusal. Such a piece is carried when its parent
  moves or turns, and goes into stock with it.
- **Footprints are turned rectangles** and overlap is the true separating-axis test (touching is not overlapping), so
  two pieces at 45 degrees clear each other where their bounding boxes would not.
- **On a grid** the footprint is rounded up to whole cells, its corner sits on a cell corner, and turns are
  quarters at most.

## The ports

```ludic
export port FurnitureWorld {
  room: fn(string, int) -> float                # (instance, 0 min x, 1 min z, 2 max x, 3 max z) (unbound: 0..10)
  cell: fn(string) -> float                     # grid size; 0 is free placement (unbound: 0)
  floor_y: fn(string, float, float) -> float    # (unbound: 0)
  ceiling_y: fn(string, float, float) -> float  # (unbound: 3)
  wall_ok: fn(string, float, float, float, float) -> bool   # (instance, x, z, yaw, width): a wall to hang on? (unbound: no)
  blocked: fn(string, float, float, float, float, float, float, float) -> bool   # (instance, x, y, z, w, d, h, yaw): the world's own geometry (unbound: nothing)
  budget: fn(string) -> int                     # (unbound: 100)
  may_edit: fn(string, int) -> bool             # (instance, player) (unbound: anyone)
  is_host: fn() -> bool                         # (unbound: yes)
}
export port FurniturePurse {
  spend: fn(int, int) -> bool     # (player, amount): false when it is not there
  earn: fn(int, int) -> void
}
```

`blocked` is how a game's collision (walls, doors, stairs, a physics query) says no to a piece; `FurniturePurse` has
no default, so a game that buys or sells binds it.

## Verbs and facts

Stock is what a player owns and has not placed, per instance and kind. `furniture_buy` and `furniture_give` fill
it, `furniture_place` takes one out, `furniture_remove` puts the piece (and what it carries) back,
`furniture_sell` turns stock into `refund_pct` of its price.

`furniture_facts(st)` is a `Queue<FurnFact>` (`what`, `instance`, `player`, `id`, `item`, `x`, `y`, `z`, `yaw`,
`amount`, `code`): `FURN_PLACED`, `FURN_MOVED`, `FURN_ROTATED`, `FURN_REMOVED` (one for each piece that went to
stock), `FURN_BOUGHT` and `FURN_SOLD` (`amount` and `x` the money), `FURN_GIVEN`, `FURN_REFUSED` (`code`).
The codes: `FURN_OK`, `FURN_NO_ITEM`, `FURN_HOST`, `FURN_EDIT`, `FURN_STOCK`, `FURN_BOUNDS`, `FURN_COLLIDES`,
`FURN_WORLD`, `FURN_BUDGET`, `FURN_RULE`, `FURN_LIMIT`, `FURN_MONEY`.

## API

| | |
| --- | --- |
| `furniture_buy(player, instance, item, n) -> bool`, `furniture_give(instance, item, n)`, `furniture_sell(player, instance, item, n) -> int` | stock |
| `furniture_place(player, instance, item, x, y, z, yaw) -> int` | one from the stock; the new piece's id, or -1 (`y` is a wall piece's height, the rest find their own) |
| `furniture_move(player, instance, id, x, y, z)`, `furniture_rotate(player, instance, id, delta_degrees)`, `furniture_remove(player, instance, id)`, `furniture_clear(player, instance) -> int` | the pieces placed; what stands on a piece goes with it |
| `furniture_check(instance, item, x, y, z, yaw) -> int`, `furniture_pose_x/y/z/yaw/parent()` | the code a ghost would get, and the pose it would take (snapped, at its height) |
| `furniture_why()` | why the last verb said no |
| `furniture_count`, `furniture_id_at(instance, i)`, `furniture_has`, `furniture_item_of`, `furniture_x/y/z/yaw`, `furniture_parent` (by instance and id) | what is placed |
| `furniture_stock(instance, item)`, `furniture_placed_of`, `furniture_budget_used`, `furniture_budget_left`, `furniture_category_count` | counts |
| `furniture_pick(instance, x, z) -> int` | the topmost piece at a point, what a cursor picks |
| `furniture_instances()`, `furniture_instance_at(i)`, `furniture_forget(instance)` | the instances there is a record of |
| `furniture_facts() -> Queue<FurnFact>` | the facts |
| `furniture_reset()`, `furniture_system() -> System` | `"furniture"`, `PH_COMMIT`: reset, and its save section (`furniture_save`, `furniture_load`) |

The save keeps each instance under its key: its stock per kind, and each piece as id, kind, pose (floats in
thousandths) and parent; ids go on from where they were. Kinds are saved by position, so `FurnitureItems` is
`@AppendOnly`.

## Tests

```bash
ludic test packages/ludic.furniture
```

A fake world (a 6 m room, a pillar, walls on two sides, a budget, one player who may not edit): stock and buying,
the room's edge, pieces by their true shape, the world's geometry, wall, ceiling and surface rules, the category
limit and budget, moving and turning what carries things (or refusing the whole move), removal, selling, who may
edit, a grid, and the save per instance key.
