# ludic.rts

Command and control of many units, as a game played with a mouse wants it: a selection per player and
ten control groups, an order queue per unit (shift-queue), formations that spread a move over a place,
stances that decide what an idle unit does when an enemy is near. Uses
[`ludic.base`](../ludic.base/README.md) and nothing else. The kinds of order, the stances and the
formations are rows of data; walking, distances, who is an enemy and who is alive are the game's,
asked through a port, and what happened is a queue of facts. It does not depend on
[`ludic.build`](../ludic.build/README.md), [`ludic.produce`](../ludic.produce/README.md) or
[`ludic.harvest`](../ludic.harvest/README.md): a `gather` or `build` order gets a unit into reach of
its target and says so; the game's route hands it to whichever mechanic does the work.

```ludic
import "ludic.rts"
```

## What it offers

- **Selection.** `rts_select`, `rts_toggle`, `rts_select_box` (a drag over the player's own units by the
  world's positions; `kind` for a double click), `rts_select_at` (a click, the player's own first).
- **Control groups.** `RTS_GROUPS` (10) a player: `rts_group_set`, `rts_group_add`,
  `rts_group_recall` (`add` keeps the selection). A unit that is removed leaves them.
- **Orders as data.** `RtsOrders` rows have a `mode`, and the logic knows only the modes:
  - `RTS_M_POINT`: go there (move, attack-move: with `engage` it answers enemies on its way);
  - `RTS_M_CHASE`: follow a target into reach and engage it until it is gone (attack);
  - `RTS_M_WORK`: go into reach of a target and work it until the game says it is done (gather, build, repair);
  - `RTS_M_PATROL`: go between here and a place for good;
  - `RTS_M_STOP`: clear the queue and stand; `RTS_M_HOLD`: stand, and engage only what comes into reach.

  The package's own rows come first (`RTSO_MOVE`, `RTSO_ATTACK_MOVE`, `RTSO_ATTACK`, `RTSO_GATHER`,
  `RTSO_BUILD`, `RTSO_PATROL`, `RTSO_STOP`, `RTSO_HOLD`); a game appends its own with
  `def RtsOrders from "orders.lres"`. A row says whether a group given it `formed` into the player's
  formation, whether it is `queueable`, its `range` (0: the unit's reach) and how often it `repath`s to a
  moving target.
- **A queue per unit.** `rts_order_unit(unit, order, x, z, target, queue)`: `queue` (shift) puts it
  behind the rest if the order is queueable, otherwise it replaces them. `RTS_QUEUE_MAX` (16) deep; a
  full queue refuses, with a fact. A kind may take only some orders (`RtsKinds.orders`); `stop` is
  always taken.
- **Formations** (`RtsFormations`): a grid (`cols`, 0 for as square as it comes; 1 a column; 24 a line),
  a wedge, a ring, or explicit offsets, with a `gap` on top of the units' sizes, a `stagger`, whether it
  turns `facing` the way the group moves, and `spread: false` for "everyone to the point". A group given
  a `formed` order is centred on the point and turned from its middle towards it, and each unit takes the
  nearest slot still free. Each player has a current formation (`rts_set_formation`).
- **Stances** (`RtsStances`): how far an idle unit looks for an enemy (`acquire`, or `use_range`), how far
  from where it stood it follows one (`chase`; 0 only if it is in reach now), whether it answers the one
  that hurt it (`retaliate`, told by `rts_attacked`), whether it goes `home` afterwards, and which order
  it answers with (`answer`) and goes home with (`back`). The package has aggressive, defensive,
  stand_ground and passive.
- **Kinds** (`RtsKinds`): the `reach` a unit engages or works from, its `radius` for formation spacing,
  its default `stance`, the `orders` it takes.

A player's order takes the stance's own orders off the queue, so the stance never stands in the way.
Orders given to the selection go only to the player's own units that take them.

## Data

```ludic
def RtsKinds from "kinds.lres"
def RtsOrders from "orders.lres"          # after the package's own
def RtsStances from "stances.lres"
def RtsFormations from "formations.lres"
```

```
villager { reach: 1.5, radius: 0.4, stance: RTSS_PASSIVE, orders: [RTSO_MOVE, RTSO_GATHER, RTSO_BUILD, RTSO_STOP] }
knight   { reach: 2.0, radius: 0.6 }
archer   { reach: 12.0, radius: 0.5, stance: RTSS_STAND_GROUND }
repair   { mode: RTS_M_WORK, repath: 1.5 }
phalanx  { shape: RTS_S_GRID, cols: 6, gap: 0.2, facing: true }
```

All are open registries saved by index: a game that saves appends.

## Ports to bind

```ludic
export port RtsWorld {
  pos_x: fn(int) -> float, pos_z: fn(int) -> float     # a unit's or target's place (required)
  alive: fn(int) -> bool                                # (true)
  radius: fn(int) -> float                              # a target's size: a building, a mine (0)
  move_to: fn(int, float, float) -> bool                # begin a path; false: there is none (true)
  stop: fn(int) -> void                                 # (nothing)
  arrived: fn(int) -> bool                              # the path is finished (true)
  in_reach: fn(int, int, float) -> bool                 # (unit, target, reach): near enough to act on it (a distance from the positions, less the target's radius)
  find_enemy: fn(int, float) -> int                     # (unit, radius): whom it would pick, -1 none (-1)
}
```

Unit and target ids are the game's own. `move_to` is where the game's pathfinding (`ludic.nav`, a
flow field) begins a path; `rts` never names it.

## Verbs

| | |
| --- | --- |
| `rts_add_unit(unit, kind, owner)`, `rts_remove_unit(unit)`, `rts_is_unit`, `rts_units()`, `rts_unit_at(i)` | the units under command |
| `rts_select`, `rts_deselect`, `rts_toggle`, `rts_select_clear`, `rts_select_box`, `rts_select_at`, `rts_selected_count`, `rts_selected(i)`, `rts_is_selected` | selection |
| `rts_group_set`, `rts_group_add`, `rts_group_recall`, `rts_group_clear`, `rts_group_count`, `rts_group_unit` | control groups |
| `rts_order_unit`, `rts_order(player, order, x, z, target, queue)`, `rts_order_of_mode(mode)` | orders to one unit, or to the selection |
| `rts_finish(unit)`, `rts_attacked(unit, by)` | the game says the work is done; the game says a unit was hurt |
| `rts_set_stance`, `rts_set_stance_all(player, stance)`, `rts_stance`, `rts_set_formation(player, form)`, `rts_formation_of` | stance and formation |
| `rts_orders_count`, `rts_idle`, `rts_order_at(unit, i)`, `rts_target_at`, `rts_x_at`, `rts_z_at`, `rts_head_order`, `rts_head_auto`, `rts_working`, `rts_kind_of`, `rts_owner_of` | reads |
| `rts_tick`, `rts_reset`, `rts_system()` | the system, `"rts"` in `PH_SIMULATE`, with its save |

## Facts

`rts_facts() -> Queue<RtsFact>`, `{ what, unit, order, mode, target, x, z, reason, n, auto }` (`auto`: the
stance's own order, not the player's):

| | |
| --- | --- |
| `RTS_F_ORDERED` | an order was given (`n` 1 when queued) - a sound, a marker |
| `RTS_F_AUTO` | a stance gave one |
| `RTS_F_ARRIVED` | a move or a patrol leg got there |
| `RTS_F_ENGAGED` | in reach of its target: **this is where the game acts** - strike it for a chase, start gathering for `RTSO_GATHER`, `harvest_assign`; for `RTSO_BUILD`, `build_assign` |
| `RTS_F_DISENGAGED` | no longer in reach or the order ended; `reason` is `RTS_R_TARGET_GONE`, `_OUT_OF_REACH`, `_FINISHED`, `_REPLACED`, `_LEASH` |
| `RTS_F_LOST_TARGET`, `RTS_F_BLOCKED`, `RTS_F_STOPPED`, `RTS_F_IDLED`, `RTS_F_GONE`, `RTS_F_REFUSED` | the rest |

## A route: rts to the other mechanics

The game is the only code that knows two of them:

```ludic
function route(rts_st: mut RtsState, harvest_st: mut HarvestState, build_st: mut BuildState) -> void {
  let f = q_drain(rts_facts(rts_st))
  for i in 0 .. len(f) {
    if f[i].what == RTS_F_ENGAGED and f[i].order == RTSO_GATHER { harvest_assign(harvest_st, f[i].unit, f[i].target) }
    if f[i].what == RTS_F_ENGAGED and f[i].order == RTSO_BUILD { build_assign(build_st, f[i].target, f[i].unit) }
  }
}
```

and the other way: `BUILD_F_RELEASED` and `HV_F_IDLED` tell the game a worker is free, which it answers
with `rts_finish(unit)` (or a new order).

## The save

Its own section: each unit's queue (with the stance's own orders), stance and anchor, each player's
formation and the control groups. The selection is not saved. A unit comes back to ask the world for a
path again; a unit's id must mean the same thing after a load, which is the game's to keep.

## Tests

```bash
ludic test packages/ludic.rts
```
