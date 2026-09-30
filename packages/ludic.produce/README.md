# ludic.produce

Production queues: what a building can make, a queue per building that works its head item down in
game time, costs paid through the game's bank, queue limits, rally points, and cancelling with
refunds - all as data. Uses [`ludic.base`](../ludic.base/README.md) and nothing else. No unit,
resource or building is named in the logic; making the unit is the game's, told by a fact.

```ludic
import "ludic.produce"
```

## What it offers

- **Items** (`ProduceItems`), each a row: what it `makes` (the game's kind) and how many, its cost
  (resource list beside an amount list), its `time` in game seconds, the `pop` it takes, the `needs`
  (tech ids the game answers), `unique` (an upgrade: once per owner, refused when done or already
  waiting), and the refund percentages for cancelling while waiting or while being made.
- **Buildings** (`ProduceBuildings`): `items` it may make, the queue's `slots`, its `speed`, and
  `pay_at_start` (the cost is taken as an item reaches the front, not as it is queued; an item that
  cannot be paid waits there and says so once).
- **A queue per registered building.** `produce_queue` checks the building makes it, there is a
  slot, the tech, the `unique` rule and the bank, and puts it on. The head item is worked down by
  `dt * kind speed * building speed * the owner's speed` (the last asked through a port). When it is
  done and the owner has supply (`room`) and there is somewhere to put it (`can_finish`) it is made:
  a `COMPLETED` fact, and the queue moves up. Otherwise it is held, and says why, once.
- **Rally.** A point or an entity (the game sends what is made to work the entity), carried on the
  fact.
- **No machine here.** A queue has no states worth a graph; the data is the items and the rules.

## Data

```ludic
def ProduceItems from "items.lres"
def ProduceBuildings from "producers.lres"
```

```
villager { makes: UN_VILLAGER, cost_res: [RES_FOOD], cost_n: [50], time: 25.0, pop: 1 }
archer   { makes: UN_ARCHER, cost_res: [RES_FOOD, RES_GOLD], cost_n: [25, 45], time: 35.0, pop: 1, needs: [TECH_BOWS], refund_active: 50 }
wheel    { makes: UP_WHEEL, class: 1, cost_res: [RES_GOLD], cost_n: [100], time: 40.0, unique: true }

hall   { items: [PRD_VILLAGER, PRD_WHEEL], slots: 5 }
range  { items: [PRD_ARCHER], slots: 5, speed: 1.0 }
```

| registry | fields |
| --- | --- |
| `ProduceItems` (`PRD_<KEY>`) | `makes`, `class`, `n`, `cost_res` + `cost_n`, `time`, `pop`, `needs`, `unique`, `refund_queued`, `refund_active` |
| `ProduceBuildings` (`PRB_<KEY>`) | `items`, `slots` (at most `PRODUCE_QUEUE_MAX`, 16), `speed`, `pay_at_start` |

Both are open and saved by index: a game that saves appends.

## Ports to bind

```ludic
export port ProduceWorld {
  has_tech: fn(int, int) -> bool       # (owner, tech) (true)
  room: fn(int, int) -> bool           # (owner, pop): supply for it (true)
  can_finish: fn(int, int) -> bool     # (building id, item): somewhere to put it (true)
  speed: fn(int, int) -> float         # (owner, item): the owner's techs' multiple (1.0)
}
export port ProduceBank {              # required
  have: fn(int, int) -> int            # (owner, resource)
  spend: fn(int, int, int) -> bool
  refund: fn(int, int, int) -> void
}
```

The owner is one of `PRODUCE_OWNERS` (16). Supply is the game's: it counts a unit when the
`COMPLETED` fact arrives, and `room` says whether the next one fits.

## Verbs

| | |
| --- | --- |
| `produce_add(id, kind, owner) -> handle`, `produce_remove(building, refund)`, `produce_handle_of(id)` | the buildings |
| `produce_queue(building, item) -> 0 or PRODUCE_E_*`, `produce_can(building, item)` | put on; ask |
| `produce_cancel(building, slot)`, `produce_cancel_last(building)`, `produce_clear(building)` | take off, with refunds |
| `produce_set_rally(building, x, z)`, `produce_set_rally_target(building, target, x, z)`, `produce_clear_rally(building)` | rally |
| `produce_set_speed(building, mult)`, `produce_pause(building, paused)`, `produce_mark_done(owner, item, yes)` | |
| `produce_len`, `produce_item_at`, `produce_progress`, `produce_remaining`, `produce_done(owner, item)`, `produce_queued(owner, item)`, `produce_rally_kind/x/z/target`, `produce_owner_of`, `produce_buildings`, `produce_alive` | reads |
| `produce_tick`, `produce_reset`, `produce_system()` | the system, `"produce"` in `PH_SIMULATE`, with its save |

## Facts

`produce_facts() -> Queue<ProduceFact>`, `{ what, building, id, owner, item, makes, n, slot, reason, pct, rally, x, z, target }`:
`PRODUCE_F_QUEUED`, `PRODUCE_F_STARTED`, `PRODUCE_F_COMPLETED` (make `makes` x `n` at building `id`, send
it to the rally), `PRODUCE_F_CANCELLED` (`pct` of the cost went back), `PRODUCE_F_BLOCKED` (`reason`:
`PRODUCE_R_SUPPLY`, `PRODUCE_R_SPACE`, `PRODUCE_R_COST`), `PRODUCE_F_REJECTED` (`reason`: `PRODUCE_E_*`).

## The save

Its own section: each building's queue, progress, rally and speed, and what each owner has finished.

## Tests

```bash
ludic test packages/ludic.produce
```
