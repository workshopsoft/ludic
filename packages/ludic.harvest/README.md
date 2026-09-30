# ludic.harvest

Resource nodes, the units that gather from them, the buildings that take a load in, and the
gather-carry-drop loop between them as a `@Machine` in a data table. Uses
[`ludic.base`](../ludic.base/README.md) and nothing else: where the world is, how a unit walks and
where the stockpile is are the game's, asked through ports. No resource, unit or building is named in
the logic; every kind is a row.

```ludic
import "ludic.harvest"
```

## What it offers

- **Nodes** of a kind (`HarvestKinds`): the resource it yields, how much it holds (or never runs
  out), how many gatherers may work it at once, whether it grows back, whether it vanishes when spent.
- **Gatherers** of a class (`HarvestGatherers`): the load carried, the pace (and its own pace for
  a given resource), how near it must stand, how far it looks for another node when its own is spent,
  how long a hand-in takes.
- **Drop-offs** of a kind (`HarvestDrops`): which resources it takes (none listed: all).
- **The loop.** `Idle -> ToNode -> Gathering -> ToDrop -> Dropping -> ToNode ...`. Each step is a
  row of `steps.lres` (`HarvestSteps`), so a studio edits it as a graph. A row is `from`, `to`, `on`
  (an action's name, or `""` for a condition the tick senses), a `guard` and an `enter`. The first
  row from a mood whose guard passes is taken, so the order of rows from one mood is their priority.
  Nothing else writes a gatherer's mood.
- **The tick senses, the table decides.** Each frame `harvest_tick` counts who is at each node,
  moves a gatherer on when its node ran out, gathers, runs the hand-in clock, regrows nodes and takes
  out the spent ones that vanish, leaving flags on each gatherer's row. The guards only read those
  flags, and an `enter` calls the world's ports and says what happened.

## Data

```ludic
def HarvestKinds from "nodes.lres"         # the game's, each a row
def HarvestGatherers from "gatherers.lres"
def HarvestDrops from "drops.lres"
```

```
tree    { resource: RES_WOOD, amount: 200, slots: 3 }
berries { resource: RES_FOOD, amount: 100, slots: 4, vanish: true }
farm    { resource: RES_FOOD, amount: -1, slots: 1, ease: 0.6 }          # never runs out
spring  { resource: RES_WATER, amount: 50, most: 50, regrow: 1.0, vanish: false }
```

| registry | fields |
| --- | --- |
| `HarvestKinds` (`HVK_<KEY>`) | `resource`, `amount` (`HV_INFINITE` = -1), `most`, `radius`, `slots`, `regrow`, `vanish`, `ease` |
| `HarvestGatherers` (`HVG_<KEY>`) | `capacity`, `rate`, `rate_res` + `rate_mul` (side by side), `reach`, `seek`, `drop_time` |
| `HarvestDrops` (`HVD_<KEY>`) | `accepts` (resources), `radius` |

All three are open and saved by index, so a game that saves appends. The machine's rows are
`steps.lres` in this package; the machine itself is checked by the compiler (every mood reached, every
mood with a way out).

## Ports to bind

```ludic
export port HarvestWorld {
  pos_x: fn(int) -> float, pos_z: fn(int) -> float        # a unit's place (required)
  alive: fn(int) -> bool                                   # (true)
  move_to: fn(int, float, float) -> bool                   # begin walking there (true)
  stop: fn(int) -> void                                    # stop walking (nothing)
  carry_bonus: fn(int, int) -> int                         # (owner, resource): a tech's bigger load (0)
  rate_mul: fn(int, int) -> float                          # (owner, resource): a tech's faster hands (1.0)
}
export port HarvestBank { deposit: fn(int, int, int) -> void }   # (owner, resource, n), required
```

Unit, node and drop-off ids are the game's own. The bank is the game's: `ludic.wallet` holds one
kind of money, so an economy of several resources is the game's table, bound here and to
`ludic.build` / `ludic.produce` for what they charge.

## Verbs

| | |
| --- | --- |
| `harvest_add_node(id, kind, x, z) -> handle`, `harvest_remove_node(node)` | a node (its amount is the kind's) |
| `harvest_add_gatherer(unit, owner, class) -> bool`, `harvest_remove_gatherer(unit)` | a unit that gathers |
| `harvest_add_drop(id, kind, owner, x, z) -> handle`, `harvest_remove_drop(drop)` | a building that takes loads |
| `harvest_assign(unit, node) -> bool`, `harvest_stop(unit)`, `harvest_return(unit) -> bool` | orders (actions, reduced at the end of the phase) |
| `harvest_take(node, n) -> int`, `harvest_nearest_node(res, x, z, r)`, `harvest_nearest_drop(owner, res, x, z)` | the game's own reach into the tables |
| `harvest_mood(unit)`, `harvest_carrying(unit)`, `harvest_carrying_res(unit)`, `harvest_node_of(unit)`, `harvest_node_amount(node)`, `harvest_node_busy(node)`, `harvest_node_id(node)`, `harvest_node_alive(node)`, `harvest_nodes()`, `harvest_gatherers()`, `harvest_drops()` | reads |
| `harvest_tick`, `harvest_reset`, `harvest_system()` | the system, `"harvest"` in `PH_SIMULATE`, with its save |

## Facts

`harvest_facts() -> Queue<HarvestFact>`, `{ what, unit, node, owner, resource, n, reason }`:
`HV_F_ASSIGNED`, `HV_F_BEGAN` (gathering has started: play the swing), `HV_F_FULL`, `HV_F_DEPOSITED`
(`n` of `resource` went to the bank), `HV_F_DEPLETED` (a node ran out), `HV_F_MOVED_ON`, `HV_F_IDLED`
(`reason`: `HV_R_STOPPED`, `HV_R_NO_NODE`, `HV_R_NO_DROP`), `HV_F_GONE` (the unit was lost).

## The save

Its own section: nodes, drop-offs and gatherers as rows of ints (positions in thousandths). A gatherer
comes back sent again to where it was, carrying what it carried; a hand-in in progress starts over.

## Tests

```bash
ludic test packages/ludic.harvest
```
