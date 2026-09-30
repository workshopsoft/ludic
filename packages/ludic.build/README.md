# ludic.build

Placing structures on a grid - a footprint of w x h cells, turned a quarter at a time, under
placement rules written as data - paying for them through the game's bank, and building them with
workers: construction is a `@Machine` in a data table. Uses [`ludic.base`](../ludic.base/README.md)
and nothing else. No structure, terrain or resource is named in the logic.

```ludic
import "ludic.build"
```

## What it offers

- **A grid** the game sets once (`build_grid(w, h, cell, ox, oz)`): `build_cell_of_x/z` and
  `build_world_x/z` turn a world coordinate into a cell and a footprint's middle back.
- **Kinds** (`BuildKinds`), each a row: the footprint and whether it turns; the cost (resource list
  beside an amount list); the work in seconds of one worker's effort (0 builds at once), how many
  workers fit, and how fast `n` of them are (`n ^ pace_exp`); the refunds as percentages of the
  cost (cancelled before work, cancelled during, destroyed when finished); and the **rules**:
  - `need`, `forbid`: tags every cell of the footprint must carry / none may carry, from the game's
    `BuildTags` names, read through the world's mask;
  - `near` + `near_dist`: stand within so many cells of a finished structure of one of these kinds,
    the owner's;
  - `apart` + `apart_dist`: none of these, anyone's, within so many cells;
  - `needs`: the owner has a finished structure of each (a tech by building);
  - `limit`: at most so many per owner.
- **`build_check(kind, owner, cx, cz, rot, paid) -> BUILD_E_*`** says why not, in the order bounds,
  blocked (a site, or the world's `blocked`), terrain, forbidden, limit, needs, adjacent, spacing,
  cost; `build_can_place` is the yes/no a ghost under the mouse wants. It reads only.
- **Construction as a machine.** A site is `Placed -> Building -> Done -> Destroyed`, and a
  destroyed one can be placed again. The rows of `steps.lres` (`BuildSteps`) are `from`, `to`, `on`
  (an action's name, or `""` for what the tick senses), a `guard` and an `enter`; the first row from a
  state whose guard passes is taken. Nothing else writes a site's state.
- **Workers** are the game's units: `build_assign(site, worker)`, `build_release(worker)`. A
  worker works one site. The tick adds `dt * n ^ pace_exp` to the progress; `build_work` adds work
  without a worker. A worker that is gone is dropped.

## Data

```ludic
def BuildTags from "tags.lres"         # buildable, shore, road...
def BuildKinds from "structures.lres"
```

```
house  { w: 2, h: 2, work: 25.0, cost_res: [RES_WOOD], cost_n: [30], need: [BTAG_LAND], workers: 3 }
wall   { w: 1, h: 1, work: 4.0, cost_res: [RES_STONE], cost_n: [5], need: [BTAG_LAND], near: [BK_TOWER], near_dist: 6 }
market { w: 3, h: 2, work: 40.0, pace_exp: 0.7, needs: [BK_HOUSE], limit: 2, apart: [BK_MARKET], apart_dist: 5 }
dock   { w: 1, h: 3, work: 30.0, need: [BTAG_SHORE], forbid: [BTAG_LAND] }
```

Both registries are open and saved by index: a game that saves appends.

## Ports to bind

```ludic
export port BuildWorld {
  tags: fn(int, int) -> int          # (cell x, cell z): a mask, bit i for BuildTags i (0: none)
  blocked: fn(int, int) -> bool      # something the world keeps there: a tree, a unit (false)
  alive: fn(int) -> bool             # a worker still there (true)
}
export port BuildBank {              # required
  have: fn(int, int) -> int          # (owner, resource)
  spend: fn(int, int, int) -> bool   # (owner, resource, n)
  refund: fn(int, int, int) -> void
}
```

The cost is taken whole when a site is placed, after `have` says it is all there, and given back by
the kind's percentages. `ludic.wallet` holds one sort of money; a game with several resources binds
the bank to its own table.

## Verbs

| | |
| --- | --- |
| `build_grid(w, h, cell, ox, oz)`, `build_cell_of_x/z`, `build_world_x/z` | the grid |
| `build_check(...)`, `build_can_place(...)`, `build_why()` | the rules |
| `build_place(kind, owner, cx, cz, rot) -> site`, `build_place_done(...)` | place (paid) or give (free, finished on the next tick); -1 and a REJECTED fact when refused |
| `build_cancel(site)`, `build_destroy(site)`, `build_rebuild(site)`, `build_remove(site)` | actions (reduced at the end of the phase), and taking one off for good |
| `build_assign(site, worker)`, `build_release(worker)`, `build_work(site, seconds)` | work |
| `build_state`, `build_is_done`, `build_progress`, `build_workers`, `build_worker_at`, `build_site_of`, `build_kind_of`, `build_owner_of`, `build_uid`, `build_by_uid`, `build_cell_x/z`, `build_rotation`, `build_width/height`, `build_at(cx, cz)`, `build_count(owner, kind, done_only)`, `build_sites`, `build_site_at(i)`, `build_alive` | reads |
| `build_tick`, `build_reset`, `build_system()` | the system, `"build"` in `PH_SIMULATE`, with its save |

A site's cells are held from the moment it is placed and freed on the tick that sees it destroyed.

## Facts

`build_facts() -> Queue<BuildFact>`, `{ what, site, uid, kind, owner, cx, cz, rot, worker, reason, n }`:
`BUILD_F_PLACED`, `BUILD_F_REJECTED` (`reason`: `BUILD_E_*`), `BUILD_F_STARTED` (the first worker began),
`BUILD_F_COMPLETED` (spawn the structure's entity, open its production), `BUILD_F_CANCELLED` (`n` percent
of the cost went back), `BUILD_F_DESTROYED`, `BUILD_F_REBUILT`, `BUILD_F_RELEASED` (a worker is free:
`reason` `BUILD_R_DONE`, `BUILD_R_LOST`, `BUILD_R_ASKED` - send it on to its next order).

## The save

Its own section: each site as `[uid, kind, owner, cx, cz, rot, state, progress]`. The grid is the
game's to set before it loads. A site comes back `Placed` and the next tick makes a finished one
`Done` and a ruin a ruin again, none of them saying so; one under construction waits for its workers
to be sent again. Keep a site across a save by `uid` (`build_by_uid`), never by handle.

## Tests

```bash
ludic test packages/ludic.build
```
