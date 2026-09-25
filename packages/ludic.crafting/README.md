# ludic.crafting

Recipes and making them: what goes in, what comes out, where it is made and how long it takes,
whether it can be made right now, taking the makings, giving them back, and a recipe made by
holding a button rather than clicking it. Uses [`ludic.base`](../ludic.base/README.md) and
nothing else - the pack and the stations are the game's, asked through ports.

```ludic
import "ludic.crafting"
```

## The recipes

`CraftRecipes` is an `open registry` the game fills, one `def` per recipe; `CRAFT_<KEY>` is its
index. A station that holds a recipe holds its index, so a game that saves that appends.

```ludic
def CraftRecipes torch { out: IT_TORCH, ins: [IT_WOOD, IT_CLOTH], ns: [1, 1] }
def CraftRecipes rope  { out: IT_ROPE, n: 2, ins: [IT_WILLOW], ns: [4], hold: 2.6 }
def CraftRecipes stew  { out: IT_STEW, ins: [IT_MUSHROOM, IT_WATER], ns: [2, 1], station: POT, minutes: 25 }
```

| field | |
| --- | --- |
| `out`, `n` | what it makes, and how many |
| `ins`, `ns` | the makings and how many of each, side by side |
| `station` | where it is made: `CRAFT_HANDS` (0, the default) is anywhere; any other number is the game's |
| `minutes` | game minutes at its station (0: made at once); a timed recipe at a station is started there |
| `hold` | seconds of holding to make it (0: a click) |
| `group` | the game's grouping (a tab, a heading) |
| `learned` | false: never made |

## The ports

```ludic
export port CraftPack {
  count: fn(int) -> int                  # how many of an item
  take: fn(int, int) -> bool
  add: fn(int, int) -> int
  room: fn(int) -> int                   # how many more fit (unbound: no limit)
  leaves: fn(int) -> int                 # what an item leaves once used, -1 nothing (unbound: nothing)
}
export port CraftStations {              # unbound: only the hands; nothing can be started
  ready: fn(int) -> bool                 # can this station be used right now?
  start: fn(int, int) -> bool            # put recipe in station; false gives the makings back
}
```

A game with an inventory package binds `CraftPack` to it; this package never names one.

## API

| | |
| --- | --- |
| `craft_count()`, `craft_ok(i)`, `craft_recipe(i)`, `craft_find(item)`, `craft_by_key(key)` | the table |
| `craft_inputs(i)`, `craft_input(i, k)`, `craft_input_n(i, k)` | a recipe's makings |
| `craft_has(i)` | every making is in the pack |
| `craft_can(i)` | learned, the makings, its station ready, and room for what it makes |
| `craft_take(i)`, `craft_refund(i)` | the makings out (and what they leave in), and back again |
| `craft_make(i) -> bool` | make it: at once into the pack, or started at its station; false and nothing taken when it cannot |
| `craft_holds(i)`, `craft_hold_start(i) -> bool`, `craft_hold_stop()`, `craft_holding()`, `craft_hold_frac(i)`, `craft_hold_run(dt) -> bool` | the hold: `run` is true on the frame it is made; it stops itself when the recipe can no longer be made |
| `craft_facts() -> Queue<Crafted>` | `{ recipe, item, n, station, queued }`, one per making (`queued`: started at a station) |
| `craft_reset()`, `craft_system() -> System` | `"crafting"`, `PH_SIMULATE`: a reset; nothing is saved |

The hold is run by whatever screen shows it (`craft_hold_run(dt)` from that screen's tick), since a
screen may pause the world.

## Tests

```bash
ludic test packages/ludic.crafting
```
