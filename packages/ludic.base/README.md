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

1. **A mechanic uses only this.** Its module line says so - `module ludic_clock uses ludic_base`
   - and the compiler refuses a reference into any other module, a package's included. Its tests are one program: `ludic.base`, the mechanic, and a fake for each port.
2. **Ports for questions.** What a mechanic needs to ASK the world is a `port` it owns
   (`export port FishingWorld { is_water: fn(float, float) -> bool }`), in primitive and
   `ludic.base` types only. The game binds it once, as a declaration (`bind FishingWorld {
   is_water: fn lake }`), and the compiler refuses a program that uses a port with a required
   member and never binds it. A member with a default may be left out.
3. **Queues for facts.** What HAPPENED is pushed onto a `Queue<T>` the mechanic owns (`caught`)
   and drained by the game in a later phase. A mechanic never acts on another's behalf.
4. **Verbs for changes.** A mechanic's data is its `state` (`ToyFishingState`), handed to its
   functions as a parameter, and it changes only through its exported functions (`fishing_cast`,
   `pack_add`). Nothing writes another module's state; a function value (`fn fishing_tick`) is
   called with its states supplied, so a system never passes them itself.
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
| `Queue<T>`, `queue_new<T>(name)`, `q_push(q, v)`, `q_drain(q) -> []T`, `q_len(q)`, `q_clear(q)` | facts, first in first out (`queue_new`, not `q_new`: that name is render3d's quaternion). A queue keeps its own count, so its verbs take only the queue: a mechanic's verbs take only the mechanic's own state |
| `q_tag(q) -> QueueTag`, `core_undrained(tags, out) -> int` | the names of the given queues still holding facts, into a list the caller keeps; ask it at the end of a frame |
| `Rng`, `rng_new(seed)`, `rng_seed(r, seed)`, `rng_next(r)`, `rng_float(r)`, `rng_between(r, lo, hi)`, `rng_span(r, lo, hi)` | a xorshift32 stream of its own (`rng_between` is inclusive; `rng_range` is taken by `Random.range`) |
| `SaveNode { found, version, data }`, `save_tree()`, `save_section(root, key, version, v)`, `load_section(root, key) -> SaveNode`, `save_encode`, `save_decode` | the save tree: `{"fishing": {"v": 3, ...}}`; `v` is reserved in a section, and a non-object value rides under `data` |
| `sv_int`, `sv_float`, `sv_bool`, `sv_str` (key, fallback), `sv_ints` | typed reads with a fallback; a float is kept as thousandths |
| `sv_put_int`, `sv_put_float`, `sv_put_bool`, `sv_put_str`, `sv_put_ints` | the matching writes |
| `System { key, phase, version, init, reset, tick, save, load }`, `system_new(key, phase)` | a system; a null function is a verb it does not have |
| `core_add(s)`, `core_clear()`, `core_count()` | the game's system list (a key may appear once) |
| `def Systems key { ... }`, `SYS_<KEY>`, `SYS_COUNT` | a system declared from any module; the list starts from these |
| `core_init_all()`, `core_reset_all()`, `core_tick_all(t)`, `core_save_all() -> Val`, `core_load_all(v)` | the runner: in the order added, tick phase by phase |

## Entities: `Table<T>` and its indexes

A mechanic that keeps many of something (Things on the ground, animals, drops) keeps them as rows
of a `Table<T>` in its state rather than as a list it scans. The table is data-oriented and
allocates nothing per query:

- **Rows are dense.** Hot data is columns - `tb.f[c]` (floats) and `tb.i[c]` (ints), one value per
  row - and `tb.rec[row]` is a record `T` for everything cold. A removal moves the last row into
  the gap (`tb_remove`), so a sweep over `0 .. tb_len(tb)` touches contiguous memory.
- **Handles go stale.** `tb_add` returns a handle: a 22-bit slot and a 9-bit generation. `tb_row(tb,
  h)` is -1 once the entity is removed, even after the slot is reused. Keep handles, never rows.
- **Indexes are kept by the setters.** `tb_set_f`, `tb_set_xz`, `tb_set_i` (or writing `tb.f` /
  `tb.i` directly and then `tb_refile`) stamp the row's change tick and refile it in every index
  that reads that column, in O(1). An index is never a frame behind.
  - `tb_grid(tb, cx, cz, gate, cell)` - a spatial hash over two float columns, gated by an int
    column (a row is filed while it is non-zero: "active"). `tb_nearest(tb, g, x, z, maxr, mc, mv)`
    searches rings outward and stops at the first ring that cannot hold anything nearer;
    `tb_within(..., out)` fills a caller's `words`. Buckets double as the rows grow.
  - `tb_index(tb, col, gate)` - a cached query: the rows holding each value of an int column (a
    kind). `ix_rows(ix, v)`, `ix_count(ix, v)`, `ix_first(ix, v)`.
  - `tb_nearest_of` / `tb_within_of` plan between the two: a rare kind is scanned from its own
    list, a common one searched by rings.
- **Change detection.** `tb_advance(tb)` moves the table to its next tick; `tb_changed_since(tb,
  tick, out)` and `tb_added_since` name the rows written since - what a save or a message needs to
  send a delta instead of everything.
- **Observers.** `tb_on_add(tb, fn f)` / `tb_on_remove(tb, fn f)`: `f(handle)` (its states supplied,
  like a system's) is told each handle as its row is made and before it goes.
- **Groups and chunks.** `tb_remove_all(tb, ix, v)` removes every row an index files under one
  value - a kind, or a chunk of the world a stream lets go (`chunk_of(x, z, size)` packs a chunk's
  cell into an int). An index keeps a small value (below 1024) in its own slot and gives a larger,
  sparse one (a chunk's packed cell) a slot through a map, so each value costs one list.
- **Change detection is per 64-row block too**: `tb_changed_since` skips a block nobody wrote
  since. A row moved into a removal's gap keeps its own tick; the removal is the observer's.
- **Parallel work reads, never writes, a state.** `Job.parallel_for(n, fn work, ctx)` over a
  table's columns runs on every core; the compiler refuses a worker that takes a state as `mut`
  (a result goes into `ctx`, a shared count through a `Sync` handle kept in the state).
- **A row, for a row reducer.** `Row<T>` (`tb`, `row`, `h`, `rec`) is one row as the action drain
  hands it to `reducer T in S.table on A(r: mut Row<T>, a: A)` (LANGUAGE.md, "A reducer on a row"):
  the action's `@Target` field carries the handle, the drain resolves it and fills a Row it keeps.
  The table's owner writes a row through its `@RowVerb`s, which take the Row first and keep the
  columns with the record's `@Column` fields.
- **Stable ids.** `IntMap` (`imap_new`, `imap_put`, `imap_get(m, k, none)`, `imap_del`) maps an
  id kept in a save or a message to a handle without a scan.

Ludic frees nothing a safe program allocates, so a query that built a list per call leaked every
frame. Every question here writes into a buffer the caller keeps. What each costs, against a
`[]Record` list scanned (`M4 Pro`, one thread):

| | 10 000 | 100 000 | 1 000 000 |
| --- | --- | --- | --- |
| nearest, any | 0.37 us (list 30) | 1.5 us (list 307) | 7.2 us (list 3075) |
| nearest of a kind (1 in 40) | 1.4 us (list 5.8) | 3.3 us (list 56) | 12 us (list 864) |
| by id | 0.1 us (list 1.7) | 0.09 us (list 17) | 1.5 us (list 324) |
| within 30 m | 0.9 us | 1.5 us | 6.9 us |
| a move, refiled | 11 ns | 14 ns | 44 ns |

`tests/ecs_fuzz_test.ludic` holds the grid and the kind index against a scan through thousands of
random adds, removes, moves, kind changes and gate flips.

## A toy mechanic

```ludic
module toy_fishing uses ludic_base
numbers float
import "ludic.base"
export property Caught { species: int = 0, weight: float = 0.0 }
export port FishingWorld { is_water: fn(float, float) -> bool }           # its port
export state ToyFishingState {
  dice: Rng = null
  casts: int = 0
  caught: Queue<Caught> = null                                   # its facts
}
export function fishing_cast(toy_fishing_st: mut ToyFishingState, x: float, z: float) -> bool {                 # its verb
  if not FishingWorld.is_water(x, z) { return false }
  toy_fishing_st.casts += 1
  return true
}
function fishing_reset(toy_fishing_st: mut ToyFishingState) -> void {
  toy_fishing_st.casts = 0
  toy_fishing_st.dice = rng_new(7)
  toy_fishing_st.caught = queue_new("fishing.caught")
}
function fishing_tick(toy_fishing_st: mut ToyFishingState, t: Tick) -> void {
  while toy_fishing_st.casts > 0 {
    let c = new Caught
    c.species = rng_between(toy_fishing_st.dice, 0, 2)
    c.weight = 0.5 + rng_float(toy_fishing_st.dice)
    q_push(toy_fishing_st.caught, c)
    toy_fishing_st.casts -= 1
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
  bind FishingWorld { is_water: fn lake }

  # the route: a landed fish goes into the pack
  function route_fishing_pack(fishing: ToyFishingState, pack: mut ToyPackState, t: Tick) -> void {
    let fish = q_drain(fishing.caught)
    for i in 0 .. len(fish) { pack_add(pack, fish[i].species, 1) }
  }

  function game_start(base_st: mut BaseState) -> void {
    core_add(base_st, fishing_system())
    let r = system_new("route.fishing_pack", PH_RESOLVE)
    r.tick = fn route_fishing_pack           # a fn(Tick) -> void: its states are supplied
    core_add(base_st, r)
    core_add(base_st, pack_system())
    core_reset_all(base_st)
  }
}
```

Both are compiled and run by `tests/route_test.ludic` (the mechanics are `tests/toys/`).

## Text without allocating: `StrBuf` and `StrTable`

Ludic frees nothing, so a line built every frame - a clock, a countdown, a prompt - grows the
program for as long as it runs. Write it into a kept `StrBuf` instead (`sb_clear`, `sb_add`,
`sb_int`, `sb_int2`, `sb_byte`, and `sb_pat(sb, "{1} of {2}", a, b, c, d)`, whose pattern stays a
literal at the call so a translator still finds it), then `sb_intern(sb, table)`: the `StrTable`
hands back ONE string per distinct text, looked up by content and copied out only the first time
those bytes are seen. What is handed on is the table's and never changes, so anything that keeps
a string as a key stays right. Growth stops once each text has been seen (1440 clock minutes, the
countdown's values); past `strs_new(most)` entries it falls back to a plain copy.

## Tests

Each piece has a program under `tests/`, and `ludic test` runs them all, every test block in a
process of its own:

```bash
ludic test packages/ludic.base
```

`queue_test`, `rng_test`, `save_test`, `system_test`, `registry_test` and `route_test`. They were
written before a generic call inside a `test` body resolved and before each test had a fresh
state, so the queue cases are functions a test calls and the runner's cases start with
`core_clear()`; neither is needed any more.

## Declared systems

- `Systems` is an `open registry`, so a system can be declared instead of added: `def Systems
  fishing { phase: PH_SIMULATE, tick: fn fishing_tick }` from any module. The runner starts from
  the declared systems - the order the compiler gives an open registry: ludic.base's own (none),
  then each other module's by module name, each module's in the order it is read - and `core_add`
  appends after them. A game that wants to decide the order itself writes the `def`s in its own
  files, or keeps calling `core_add` in one place.
