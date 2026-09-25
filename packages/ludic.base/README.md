# ludic.base

The vocabulary a game made of mechanic packages shares. A mechanic (fishing, needs, a shop, the
weather) depends on `ludic.base` and on nothing else - never on another mechanic. The game is the
only code that knows two mechanics, and it wires them together.

(`ludic.core` is a different, older package: the engine's canonical ECS components, used by the
examples under `examples/library/`.)

```ludic
import "ludic.base"
```

## The rules

1. **A mechanic uses only this.** If a mechanic needs a second mechanic to compile, that is the
   bug. Its tests are one program: `ludic.base`, the mechanic, and a fake for each port.
2. **Ports for questions.** What a mechanic needs to ASK the world is a record of function
   values it owns (`FishingWorld { is_water: fn(float, float) -> bool }`), in primitive and
   `ludic.base` types only. The game binds it once.
3. **Queues for facts.** What HAPPENED is pushed onto a `Queue<T>` the mechanic owns (`caught`)
   and drained by the game in a later phase. A mechanic never acts on another's behalf.
4. **Verbs for changes.** A mechanic's state changes only through its exported functions
   (`fishing_cast`, `pack_add`). Nothing assigns another module's globals.
5. **Phases for order.** A system names its phase; within a phase the game's list is the order.
   No system says "after fishing".
6. **Its own save section.** Each system saves under its own key with its own version and
   migrates its own old versions in `load`. A missing section is a reset.
7. **Its own dice.** A mechanic is handed an `Rng`, never draws from `Random.*`, so moving it
   cannot shift anyone else's rolls.

## The API

| | |
| --- | --- |
| `Tick { dt, frame, hours }`, `tick_new(dt, frame, hours)` | what a system's tick receives |
| `PH_INPUT`, `PH_SENSE`, `PH_SIMULATE`, `PH_RESOLVE`, `PH_COMMIT`, `PH_PRESENT`, `PH_COUNT` | the phases, in the order they run |
| `Queue<T>`, `q_new<T>(name)`, `q_push(q, v)`, `q_drain(q) -> []T`, `q_len(q)`, `q_clear(q)` | facts, first in first out |
| `core_undrained() -> []string` | the names of queues still holding facts; ask it at the end of a frame |
| `Rng`, `rng_new(seed)`, `rng_seed(r, seed)`, `rng_next(r)`, `rng_float(r)`, `rng_between(r, lo, hi)`, `rng_span(r, lo, hi)` | a xorshift32 stream of its own (`rng_between` is inclusive; `rng_range` is taken by `Random.range`) |
| `SaveNode { found, version, data }`, `save_tree()`, `save_section(root, key, version, v)`, `load_section(root, key) -> SaveNode`, `save_encode`, `save_decode` | the save tree: `{"fishing": {"v": 3, ...}}`; `v` is reserved in a section, and a non-object value rides under `data` |
| `sv_int`, `sv_float`, `sv_bool`, `sv_str` (key, fallback), `sv_ints` | typed reads with a fallback; a float is kept as thousandths |
| `sv_put_int`, `sv_put_float`, `sv_put_bool`, `sv_put_str`, `sv_put_ints` | the matching writes |
| `System { key, phase, version, init, reset, tick, save, load }`, `system_new(key, phase)` | a system; a null function is a verb it does not have |
| `core_add(s)`, `core_clear()`, `core_count()` | the game's system list (a key may appear once) |
| `core_init_all()`, `core_reset_all()`, `core_tick_all(t)`, `core_save_all() -> Val`, `core_load_all(v)` | the runner: in the order added, tick phase by phase |

## A toy mechanic

```ludic
module toy_fishing
numbers float
import "ludic.base"
export property Caught { species: int = 0, weight: float = 0.0 }
export property FishingWorld { is_water: fn(float, float) -> bool = null }  # its port
var world: FishingWorld = null
var dice: Rng = null
var casts: int = 0
export var caught: Queue<Caught> = null                                   # its facts
export function fishing_bind(w: FishingWorld) -> void { world = w }
export function fishing_cast(x: float, z: float) -> bool {                 # its verb
  if not world.is_water(x, z) { return false }
  casts += 1
  return true
}
function fishing_reset() -> void {
  casts = 0
  dice = rng_new(7)
  caught = q_new("fishing.caught")
}
function fishing_tick(t: Tick) -> void {
  while casts > 0 {
    let c = new Caught
    c.species = rng_between(dice, 0, 2)
    c.weight = 0.5 + rng_float(dice)
    q_push(caught, c)
    casts -= 1
  }
}
export function fishing_system() -> System {
  let s = system_new("fishing", PH_SIMULATE)
  s.reset = fn fishing_reset
  s.tick = fn fishing_tick
  return s
}
```

## A game wiring two of them

`toy_pack` is the same shape: verbs `pack_add(kind, n)` / `pack_count(kind)` and a system in
`PH_COMMIT` that saves its counts. Neither knows the other; the game binds fishing's port, writes
the route, and orders the three.

```ludic
import "toys/fishing"
import "toys/pack"
import "ludic.base"
program Game {
  numbers float
  function lake(x: float, z: float) -> bool { return x < 100.0 }

  # the route: a landed fish goes into the pack
  function route_fishing_pack(t: Tick) -> void {
    let fish = q_drain(caught)
    for i in 0 .. len(fish) { pack_add(fish[i].species, 1) }
  }

  function game_start() -> void {
    let w = new FishingWorld
    w.is_water = fn lake
    fishing_bind(w)
    core_add(fishing_system())
    let r = system_new("route.fishing_pack", PH_RESOLVE)
    r.tick = fn route_fishing_pack
    core_add(r)
    core_add(pack_system())
    core_reset_all()
  }
}
```

Both are compiled and run by `tests/route_test.ludic` (the mechanics are `tests/toys/`).

## Tests

Each piece has a program under `tests/`, built and run directly:

```bash
ludic build packages/ludic.base/tests/queue_test.ludic --headless -o /tmp/queue_test && /tmp/queue_test
```

`queue_test`, `rng_test`, `save_test`, `system_test` and `route_test`. Two things the language
does not do yet shape them: a generic call inside a `test` body is not resolved (so the queue
cases are functions a test calls), and test blocks share one program's globals (so each case
that uses the runner starts with `core_clear()`); `ludic test <dir>` with a fresh state per
test will lift the second.

## Later

- `port FishingWorld { ... }` / `bind` will replace the record of function values, checked at
  compile time instead of a null at run time.
- `open registry Systems of System` could replace `core_add`: each mechanic `def`s its system and
  the game's own `def`s give the order. Function values in a `def` work today (`def Systems a {
  tick: fn a_tick }`); what is missing is a registry a package declares and a game fills, in an
  order the game controls. Until then the list is built by calls, in one place.
- `module toy_fishing uses ludic_base` will make rule 1 a compile error rather than a review.
