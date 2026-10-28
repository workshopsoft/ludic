# Changelog

All notable changes to the Ludic toolchain, newest first. Each section is
generated from the changesets under changes/ by `ludic dev release`, grouped by
change type. Preview the next one with `ludic dev release --dry-run`.

A released section may carry a hand-written summary paragraph above its groups
(v0.2.0 has one); the generated bullets below it are not edited by hand.

## v0.23.0 — 2026-10-28

### Features

- **A `numbers float` file is strict about where its numbers come from.** Two rules, both found
  converting a renderer and a game from float bits in an `int` to real floats:

  - A decimal literal takes the kind of what it meets. `factor == 0.0` against a `fixed` parameter,
    `half(3.0)` into a `fixed` one and `var z: fixed = -1.5` are `fixed` literals there, rather
    than a `fixed` and a `float` that do not mix.
  - A computed integer never becomes a float implicitly. `count < limit` with an `int` on one side
    and a `float` on the other is an error that asks for `float(x)`: in a file whose numbers are
    floats, an `int` meeting one is almost always raw bits, and promoting it compares the bits as a
    number. It caught a uniform fed an integer as float bits, and a test comparing a tint's bits
    with its value. Integer constants still promote, and `float(x)` is always allowed.
- **A default font, and `ludic font bake`.** The toolchain now ships Noto Sans (SIL OFL 1.1; Regular and
  Bold TTFs, the licence and a README under `fonts/`, in the install and the release tarball like
  `templates/`). A game that names no font - `overlay_init(st, "")` - draws `ludic.ui` text with it
  instead of nothing, and `ludic ui-preview` started without `--font` measures with it (`hello` reports
  its directory; `--no-default-font` keeps the old half-size measure; the protocol's line formats are
  unchanged). `ludic font bake <ttf> [-o DIR] [--size N] [--chars SPEC]` (a new `bin/ludic-font-bake`)
  bakes any TrueType font into the `font.json` + `font.png` atlas the overlay and the preview read, with
  the runtime's own rasteriser: Latin, Latin Extended-A, Greek, Cyrillic and common punctuation by
  default, a glyph the font lacks left out. The default font is baked and committed
  (`fonts/noto-sans/baked/`, about 300 KB), so there is no bake on first use; `ludic-dev test-fonts`
  keeps it in step with the tool.
- **A local is declared once per block, and a function returns what it says it returns.** A second
  `let` or `var` of a name in the same block used to shadow the first silently - a settings page
  compared a vegetation setting against the volumetric one because of it - and is now an error.
  Names declared in different blocks, loop variables and parameters are unaffected. And a function
  with a result type that can reach the end of its body without a `return` is an error: it used
  to hand back whatever its result slot held, which is how a self-test split into helpers
  reported FAILED for a step that had passed. `examples/rejected/` holds both.
- **A name is defined once, for every kind of declaration.** Two functions with one name were
  already an error; two `var`s or `const`s (or an enum and a const), or two `property` / `event`
  records, kept the first definition silently. A game lost months to it: two files both said
  `KEY_LEFT`, one meaning an arrow key's code and one a binding slot, and the menus read the slot.
  They are now an error that names both files and lines. `examples/rejected/` holds the two cases,
  checked by a new `reject_case` in the test runner (an example the compiler must refuse).
- **A native library's licence ships with it.** `ludic bundle` copies each linked package's
  `native/LICENSE*` files beside the `.exe` on Windows and into `Contents/Resources` on macOS, so
  Jolt Physics' MIT notice travels with every copy of the game. `tools/native/lib.sh` passes lld-link
  `-implib`, which Git Bash leaves alone (it rewrote `/implib:` into a Windows path).
- **A package can carry a native library.** `native "<target>" "<path>"` in a package's
  `package.ludic` names a C/C++ library per target (`macos-arm64`, `windows-x64`, ...). The
  compiler records the libraries of every package a program imports, and every link - `ludicc -o`,
  `ludic build`, `ludic test`, `ludic bundle` - links them: on macOS with an rpath to the package
  and to `Contents/Frameworks`, where `ludic bundle` places and signs them; on Windows through the
  import library, the `.dll` copied beside the executable. `tools/native/lib.sh` builds a library
  from a pinned, checksummed source; `ludic.nativeecho` is the worked example, and
  `packages/README.md` says what a shim may pass across.
- **A queue keeps its own count, so a package verb takes only its own state; `ludic migrate state --prune`.**
  ludic.base's `Queue<T>` carries its name and pending count itself: `queue_new(name)`, `q_push(q, v)`,
  `q_drain(q)`, `q_clear(q)` take no `BaseState`, and neither does any package verb that pushes a fact -
  `wallet_earn(wallet_st, n)`, `inv_add(inventory_st, ...)` - so a reducer on a package's state can call
  its own package's verbs. `core_undrained(tags)` names the queues given to it (`q_tag(q)`) that still
  hold facts. `ludic migrate state --prune` takes out each state parameter a function no longer uses
  (nor anything it calls) and the argument that fills it, including an argument for a parameter the
  callee has dropped: run it over a game to follow this change.
- **A reducer may read other states.** `reducer Wallet on Buy(w: mut Wallet, s: Shop, a: Buy)` writes
  its own state and reads the ones declared between it and the action, supplied by the drain like its
  own. What only becomes known inside the drain - a value another reducer just set, the map in play,
  where the save lives - no longer has to be faked into the action, and a verb that reads several
  systems while it changes one is a reducer instead of an act. A second state to WRITE is still
  refused, now with the way out in the message (`examples/actions/reads.ludic`).
- **A reducer on a table's row** (phase 27.3). An action names one row of a ludic.base `Table<T>` by
  its handle, in a field marked `@Target`, and `reducer Deer in Herd.deer on Spook(r: mut Row<Deer>,
  n: Noise, a: Spook)` runs once, for that row alone (the table may sit down a path, `WildState.w.tab`).

  - **The drain resolves the handle** (`tb_row`) and hands the reducer a `Row<T>` (new in ludic.base:
    `tb`, `row`, `h`, `rec`) that it keeps, one per row reducer, filled in place: a targeted action
    allocates nothing. A stale handle runs nothing; `LUDIC_ACTIONS_LOG=1` prints a line for it. Row
    reducers order among an action's reducers by their state's name, then the table's path.
  - **The row goes no further**, checked at compile time: a row reducer reaches `r.rec` and `r.h`, not
    `r.tb` or `r.row`; it does not assign, store, copy or hand on the row except to a `@RowVerb` (a
    function of the record's own module taking `Row<T>` first); a field marked `@Column` (a table
    column mirrors it) is written only by a verb; only the module owning the state declares a row
    reducer; states between the row and the action are read. `mut` is allowed on a `Row<T>` parameter.
  - **`ludic schema`'s code section** gains `row_reducers` (`record`, `table`, `state`, `action`,
    `target`, `predicted`, `net`, `module`, `at`) and `row_verbs` (`name`, `record`, `module`, `at`),
    and every action its `target`; row reducers are not listed under `reducers`. `ludic deps` names a
    row reducer `reducer Deer in Herd.deer on Spook`; ludic-lsp's outline does too.
  - Examples `actions/rows`; rejects for a missing `@Target`, two of them, a `@Column` write, reaching
    the table, a row handed to a non-verb, a table that is not one, the parameter shape, a second
    state written, a verb with no row, and a reducer outside the state's module. `@Predicted`, `@Net`
    and `@Broadcast` on actions and row reducers are later steps of phase 27.
- **A schema for editors, and every error as JSON.** `ludicc --emit-schema out.json` (and `ludic
  schema [file] [-o FILE]`) writes what the compiler resolved once the program type-checks: every
  record with its fields' types, defaults, doc comments and places; every registry with its record,
  prefix, resource file, openness and its entries in their final order after the open-registry merge
  (key, constant, index, file:line:col of the entry and of each field value, and which file brought
  which entries in); every const; and every function a `fn` value can name, with the `fn_type` a field sees (its states stripped).
  Deterministic, `"schema_version": 1`. Fields and registries carry editor attributes on the existing
  `@` syntax - `@Ref(Registry)`, `@OneOf(PREFIX_)`, `@Range(lo, hi)`, `@Unit("m/s")`, `@Asset("gltf")`,
  `@Color`, `@Node(field)`, `@Clip(field)`, `@Material(field)`, `@Tint(SLOT)`, `@Derived`, `@Text`, `@Multiline`, `@Key`, and `@AppendOnly` / `@ByKey` on
  a registry - which change nothing but go into the schema; `@Ref` naming no registry is an error, and
  so is `@Node` / `@Clip` naming a field that is not a glTF (`@Asset("gltf")`, or an `@Ref` to one), and
  a listing `@OneOf` (`@OneOf(A, B)`, not a prefix `@OneOf(P_)`) naming a constant that does not exist, and `@Tint` naming no constant. A field may now carry several attributes. `ludicc --check
  --diagnostics=json` (`ludic build --check --diagnostics=json`) prints every error as one JSON array
  of `{file, line, col, severity, message}` on stdout; tokens and nodes now know their column.

  `Build.schema_hash()` answers FNV-1a 64 of the program's own schema (the bytes `ludic schema` prints),
  computed only when a program names it, and 0 under `ludicc --release`, which `ludic bundle` now passes.

  A target no part of the program declares (an `@Ref` registry, an `@Tint` or listed `@OneOf` constant) is
  a warning and `"unresolved": true` in the schema, so a package can name the game's registry; a name of
  another kind is an error. `@OneOf` on a string field takes words, and every registry row's value is
  checked against them.

  The schema has a `components` list: each UI component's module, place, doc, template and stylesheet
  paths, its `props` and `state` (type, default as written, place, doc), `states_read` (the states its
  header names, apart from its model), `derived` fields with their types, and the `functions` and
  `events` its template calls with their parameters (states and instance stripped), and the
  registered native tags its template uses. A `natives` list gives every `ui_native` /
  `ui_native_input` call with a literal tag: the tag, the function called, its handler and its place.
- **A state machine as data: `@Machine(Record.field)`** (phase 27.1). A registry marked
  `@Machine(Deer.mood)` is the transitions of a machine over that enum field of the records a state's
  `Table<Deer>` holds: its record has `from` and `to` (the enum's variants), `on: string` (an action's
  name, `""` for a transition the tick asks), `guard: fn(Row<Deer>, reads...) -> bool` and
  `enter: fn(Row<Deer>, reads...) -> void`; the states are the enum's variants and the start is the
  field's default. Its rows are data - an `.lres` or `def`s - so the studio edits the machine as a graph.

  - **The compiler writes the machine.** For each action an `on` names, a row reducer in the
    registry's file (`reducer Deer in Herd.deer on Spook`, beside any the program writes, after them):
    the row's state, the first transition from it on that action whose guard passes, the field set,
    `enter` run. When a row leaves a state on a guard alone, `state DeerStepsMachine` (the kept row
    view) and `deer_steps_tick(m: mut DeerStepsMachine, s: mut Herd, reads...)`, one transition a row
    a tick, called from the program's system. Guards and enters are called by name; nothing allocates.
  - **The table is the whole machine.** The field is written by nothing else: an assignment to it or
    a `machine` block's `become` over it outside the written code is a type error (`Deer.mood is the
    machine DeerSteps's (@Machine(Deer.mood)) - it changes only by a transition in its table`); a new
    row takes its state in its `new`. A guard and an enter take the row first, are the record's
    module's, and keep a row reducer's rules (`r.rec` and `r.h` only, a `@Column` field only through a
    `@RowVerb`); a guard writes nothing through its row.
  - **The graph is checked**, each an error naming its row: a state never reached from the start, a
    state with no way out, an `on` naming no action or an action with no `@Target`, a self-transition
    with no guard, and two ways out of a state on one trigger behind an unguarded first. Also refused:
    `@Machine` on anything but a registry, a field that is not a plain enum with a default, a
    `@Column` field, no table (or two) of the record, a transitions record of another shape, and a
    machine outside its table's state's module.
  - **`ludic schema`'s code section** gains `machines` (`registry`, `record`, `field`, `enum`, `table`,
    `start`, `states`, `actions`, `tick`, `module`, `at`); the registry carries `@Machine` among its
    attributes. `ludic deps` names a machine's reducer `reducer Deer in Herd.deer on Spook (machine
    DeerSteps)`. vocab: `@Machine`; docs `annot-machine`; LANGUAGE.md "A machine as data".
  - Examples `actions/machine` (with `deer_steps.lres`); rejects for an unreachable state, no way out,
    an unknown action, an action with no row, a self-transition with no guard, an ambiguous trigger, a
    guard that writes, the field written by hand, `@Machine` off a registry and a field that is no
    enum. The `machine` block stays for a machine that is only code.
- **An action on the wire: `@Net`, `@Predicted`, `@Broadcast`, `@Validate`** (phase 27.5). `@Net action Fire { ... }` is sent by a guest to the host (reliable, in order) instead of being reduced on the guest; the host checks it (`@Validate(fn)`, and the port's `allow`), reduces it with the ordinary reducers and tells the others (`@Broadcast(all | owner | none)`). With no session bound it is reduced where it is dispatched, so one package serves solo, host and guest.

  - **`@Predicted`** on the action or on single reducers (state or row): the guest also reduces it at once, keeping an undo record (the reducer's whole numbers, bools, floats, enums and the first 16 elements of a list of numbers; not a `@Column`, not a `@Machine`'s field). The host's confirm drops it; a refusal restores it, newest first, and replays what followed. A ring of 32 actions in flight; past that an action is sent without a guess.
  - **The compiler writes** the encoder and decoder of each `@Net` action over a kept `[]int` (a word per field after a four-word header carrying the schema hash, so a different build is dropped), the pending and undo rings (sized once: a frame allocates nothing), the drain's check and after-step, and the port `NetActions` (`role`, `to_host`, `to_peer`, `to_all`, `allow`, `owner_of`, `rejected`) - every member defaulted, so the compiler names no socket. `ludic.net` gains `netact_role`, `netact_to_host`, `netact_to_peer`, `netact_to_all` and `netact_take` to bind it to a session.
  - **A transport calls** `net_actions_receive(from, words, n)`; a reducer reads `action_sender()`; `net_actions_pending()`, `net_actions_forget(pid)`, `net_actions_reset()` and `net_actions_stat(n)` complete it (all no-ops in a program with no `@Net` action).
  - **Checked**: only whole numbers, bools, floats and enums go on the wire; `@Predicted`, `@Broadcast` and `@Validate` need `@Net`; `@Broadcast(owner)` needs a `@Target`; a validator is `(states it reads..., a: Action, sender: int) -> bool`.
  - `ludic schema`'s `actions` gain `net` (`predicted`, `broadcast`, `validate`, `fields`), `reducers` and `row_reducers` gain `predicted` and `net`. New annotation pages `@Net`, `@Broadcast`, `@Validate`.
  - **`ludic.vitals`** moves onto it: a guest's asks are the action `VitalsAsk` (not the `VitalsRequest` outbox, which is gone), the host checks it with `vitals_ask_ok`, and a guest's own `predict` pool is a `@Predicted` row reducer that the host's refusal puts back.
- **Box kits: one unit mesh drawn at each instance's own width, depth and height.** A kit whose vertices carry
  `_ANCHOR` (VEC4: sx, sz, sh, sd) and `_OFFSET` (VEC3, metres) beside `POSITION` is placed at
  `x = sx w + ox`, `z = sz d + oz`, `y = sh h + sd d + oy`, so a parapet stays 1 m high and 0.25 m thick and a gable
  stays at 30 degrees at any size, while one mesh draws a whole street (`kitbox.ludic`: `kitbox_new`, `kitbox_add`,
  `kitbox_bounds`, `kitbox_card`; `kitbox_read` reads the anchors from a glb). A game's bake registers them with
  `kitbake_box(kb, model, node, box)` before `city_cells_bake`, whose signature is unchanged; the culling sphere, the
  impostor card and the HLOD box come from the kit's anchors, so they match what `kit.vert` draws. `GPU_MAX_ATTRS` goes
  from 8 to 12 (anchors on locations 8 and 9), and kit instance records are 4 vec4s (`kgpu` reads 20 floats an instance
  and writes 16).

  **Breaking (file format):** a cell holding a box instance is written as **LWC version 2** (box columns); older readers
  refuse it. Version 1 cells read unchanged. Rebuild the tools and rebake cells after updating.
- **Check an unsaved buffer.** `ludic build --check --diagnostics=json --stdin-file <path>` (and
  `ludicc --check --stdin-file <path>`) checks the program as usual, but wherever the compiler would open
  `<path>` - the entry, an import reached through a barrel, a component's `.xml` / `.lss`, an `.lres` -
  it reads the text on stdin instead, so an editor's diagnostics follow typing without a save. Paths are
  matched after normalising both (separators, relative to the working directory, `.` / `..` folded).
  Diagnostics carry the file's usual name with lines and columns in the buffer; a `<path>` the program
  never opens is reported as one warning.
- **City buildings carry a roof kind.** `ludic.city`'s `Buildings` rows have a free-string `roof` field (a word the game's
  kits know, such as `gable` or `hip`; `""`, the default, means flat). It loads as written and reaches
  `CityInstances.roof`, so a game can map each word to a kit.
- **Combat mechanics: `ludic.vitals` and `ludic.weapons`.** Two packages on `ludic.base` alone, each with data registries carrying editor attributes, verbs, facts, a save section, tests and a README.

  - **`ludic.vitals`** - per-actor pools as data (`VitalPools`: health, armour, stamina, a shield, fuel; maximum, regeneration and the delay after use, absorption order and overflow), damage types, hit zones and per-class resistances (`DamageTypes`, `HitZones`, `VitalClasses`), and a damage pipeline (zone, resistance, what armour absorbs by the type's pierce, then health). An actor's phase (alive, downed with a bleed-out, dead, respawned) is a `@Machine` whose graph is `steps.lres`; untouchable windows; verbs hurt, heal, spend, restore, set_max, revive, kill; facts DAMAGED, DOWNED, DIED, REVIVED, DEPLETED, RESTORED. Host-authoritative damage: a guest shows predicted feedback, asks the host for the rest, and follows its snapshots and relayed facts. One-line port adapters bind `ludic.melee`'s `MeleeDamage` and world, `ludic.abilities`' `AbilityEffects` and `AbilityResources`, `ludic.weapons`' `WeaponsDamage` and `ludic.respawn` to vitals. Class clips are named on the facts for the animation layer.
  - **`ludic.weapons`** - `WeaponClasses`, `Weapons`, `AmmoTypes`, `Attachments`, `WeaponSkins` and `Loadouts` rows: fire modes (semi, burst, auto, charge), rate, damage with a range falloff, spread with bloom and recovery and stance/move/sight modifiers, a recoil pattern, hitscan with penetration or projectiles with gravity, fuse, bounce and a blast falloff, magazines with tactical and empty reloads (or shell by shell), attachments whose stat modifiers stack by fixed rules, skins, loadouts and a weapon wheel with ammo counts. Shooting goes through a `WeaponsWorld` port (aim ray, raycast, sweep) and damage through `WeaponsDamage`; spread and recoil jitter come from dice seeded per shot so host and guest draw the same shot; the host validates a guest's shot (rate, magazine, origin), derives the seed itself and rewinds the world through a lag-compensation hook. Every clip is a name on the facts for the animation layer; nothing here moves a bone.
- **Crash reports for games.** `ludic.crash` installs the runtime's crash handler (`runtime/native/crash.ll`
  on macOS, `crash_win.ll` on Windows: `SIGSEGV`/`SIGBUS`/`SIGILL`/`SIGFPE`/`SIGABRT`/`SIGTRAP` on an alternate
  stack, `SetUnhandledExceptionFilter`) and, when the game dies, writes one crash record - JSON lines, format
  LCR1 - into the game's crash folder: build, version, OS, signal or exception, fault address, registers,
  the backtrace as return addresses and the loaded images with their `LC_UUID` / CodeView GUID. The next
  start finds, rotates (`keep_n`) and lists them, honours the player's consent (off: a local file, nothing
  sent), and hands each to the game to show or to send through `ludic.telemetry` (which gains `line_max`,
  for events longer than 2048 bytes). `ludic build` and `ludic bundle` keep the build's symbols by id
  beside the output, never inside the bundle - a `.dSYM` keyed by `LC_UUID`, a `.pdb` by GUID and age -
  and `ludic symbols [--json]` lists them for the studio.
- **Four action-RPG mechanic packages**, each depending on `ludic.base` only and driven by data.

  - **`ludic.abilities`** — abilities, spells and skills as data: cost through a resource port, cast time, cooldowns, groups and charges, targeting, effect chains applied through ports, channels, learnable levels and a hotbar.
  - **`ludic.melee`** — attacks as data on animation clips: hit windows and shapes, combos by input window, blocking and parrying, poise and stagger; a fighter's phase is a `@Machine`, damage goes through a port.
  - **`ludic.loot`** — weighted loot tables (nested, guaranteed, rolls), rarity tiers by level and luck, affixes, uniques dropped once, seeded rolls, drops as facts.
  - **`ludic.travel`** — waypoints a player discovers and fast-travels between: unlock rules, cost in coins and hours, the load through a port, map markers as data.
- **Four mechanic packages for a live, online game: `ludic.progression`, `ludic.phone`, `ludic.liveops`, `ludic.furniture`.** All generic - the content is rows a game writes in a `.lres`, what the world answers is ports, what happened is facts, each saves its own section - and each uses `ludic.base` (the phone also `ludic.ui`) and nothing else.

  - **`ludic.progression`** - XP and levels from `XpCurves` (a threshold table, or a formula with parameters) and `XpAwards` per activity key (multiplier, track, a skill it trains), `Unlocks` (a game's item or feature key by level, required unlock, role, skill level, and a price, bought through a port), `Skills` that grow with use to a cap and export stat modifiers through `ProgressionOut`, roles with tracks of their own and prestige, a `ProgressionWorld.xp_mult` port for live multipliers, `PROG_LEVEL_UP` / `PROG_UNLOCKED` facts. Host-authoritative; a client takes a snapshot.
  - **`ludic.phone`** - an in-world phone as `ludic.ui` components with stories: `PhoneApps` rows (icon, title, component), a machine (away, raised, in an app) worked by key or pad, contacts whose call is a fact in the game's own words, message threads with buttons, toasts and a notifications list, and contacts / messages / jobs / map / shop / settings / camera / notifications apps whose data the game gives through ports. Saves the messages, the book and the options.
  - **`ludic.liveops`** - freemode events (`FreemodeEvents`: players, duration, areas, cooldown, weights by UTC hour and weekday) on a schedule the session seed decides, `LiveModifiers` (double XP and money, discounts, featured content; dated in UTC, rotating, or fetched through a `LiveRemote` port and kept in the save), `Seasons` with tiers and a premium track, daily and weekly objectives drawn from the seed. Host-authoritative; rewards are facts the game pays.
  - **`ludic.furniture`** - player housing interiors: `FurnitureItems` (`@Asset` / `@Node`, footprint, category, price, floor / wall / ceiling / surface, stackable), placed in an instance the game keys, on a grid or freely, checked against the room, other furniture by true shape, the world's geometry through a port, a category limit and a budget; buy, sell, place, move, rotate and remove (what stands on a piece goes with it), saved per instance key.
- **Functions are values (L2).** `fn(int, float) -> bool` is a type, `fn name` is any top-level
  function's value (it used to be only a thread worker's address), and a call through a local, a
  global, a record field, a slice element, a parameter or a result of a function type is an
  indirect call. Two different function types do not mix, a call through one checks its argument
  count, and a value may be `null`. A registry can hold behaviour and a package can take
  callbacks. `Job.parallel_for` still checks that its worker takes (int, pointer) and returns
  nothing. `ludic-dev selfhost-build` now says why it failed instead of exiting 1 silently.
- **HLOD proxies in the colours of the buildings they stand for.** A far block drew every proxy box in one hand-set grey
  (`proxy_r/g/b`, 0.55 by default) on its walls and its roof alike, so past the full-detail radius the city went almost white
  (a lit roof of 0.55 where the kit's roof is 0.11). Now:
  - `RenderKit` has `proxy_roof` and `proxy_roof_r/g/b`: the roof of its HLOD box has its own colour (rows without them draw as
    before, walls and roof one colour).
  - `kit_proxy_read(render3d_st, dir, file, node, kit)` (kitbox_read.ludic, CPU, no device) derives both from the kit's own mesh:
    every triangle in its material's base colour, the walls weighted by what a side view sees (area times the horizontal part of
    the normal), the roof by what a view from above sees (area times the upward part). Textured or vertex-coloured kits are left
    as their row says. The pure arithmetic is `hlod_colour_tri` / `hlod_colour_apply` (hlod.ludic).
  - `hlod_prism_roof(m, px, pz, y0, y1, wall, roof)`; `hlod_prism` is unchanged (one colour). A merged box's colours are its
    members' weighted by their wall area and their plan (a door no longer counts as much as the building it is on).
  - `kitbake_rows` writes the proxy colours when they are not the defaults.
  Rebake the cells' `.lwh` (and the rows) after updating to get the new colours.
- **HLOD: a kit drawn far off as a few boxes that follow its shape.** Past the full-detail radius every thing was one box (its kit's
  footprint times its height, centred on its place), so a landmark read as a block: a crane was the 32 x 24 x 50 m box round its tower
  and jib (and, its mesh not being centred, 10 m off where it stands).
  - `hlod_parts(tri, ntri, max_parts)` (hlod.ludic, pure): a kit's triangles (9 floats each, its own frame) into at most `max_parts`
    boxes (`HLOD_PART` floats each: x0, y0, z0, x1, y1, z1). The cells of a 20-cell grid along each axis that the triangles pass
    through are marked and taken as boxes (each grown along x, z, then y over marked cells, fitted to the triangles' points in them);
    then the pair whose box round both adds the least empty volume is merged until `max_parts` are left (each box keeps its cheapest
    partner). A portal crane is its four legs, its beams and its jib; a stadium's stands stay round its pitch.
  - `kit_parts_read(render3d_st, dir, file, node, max_parts)` (kitbox_read.ludic, CPU, no device): the same from a kit's node.
  - `hlod_bake_parts(content, kits, parts, ...)` / `hlod_bake_dir_parts(...)`: `parts[kit id]` (or null) draws each thing of that kit
    as its parts (turned, moved and scaled with the instance, in the kit's proxy colours), never merged with its neighbours.
    `hlod_bake` / `hlod_bake_dir` are these with no parts, unchanged.
- **Land-use tones on the tile ground.** `tilemap_draw` reads a per-tile 8-bit class mask
  (`<tile>.mask.png`, `tmd_mask_pattern`) and a table of up to 8 flat tones (`tmd_tone_set`, or `GroundTone`
  rows with `tmd_tones_apply`). The tones are vertex colours averaged over each level's cells, so they add no
  shader and no texture. A tile with no mask draws the old tint, and so does a class with no tone.
- **Light zones: boxes with no sun and their own ambient, for tunnels and other covered places.** `lightzone_add(st, x, y,
  z, yaw, w, h, d, feather)` adds a turned box with a feathered edge; `lightzone_ambient` gives it an ambient colour and a
  share of the sky; `lightzone_clear` and `lightzone_rebase` (the floating origin) manage them. Inside a zone every lit
  shader drops the sun's direct light, bounce, leaf glow and sheen, water glitter and volumetric shafts. Up to 512 zones are
  kept and the 8 nearest the camera are bound each frame; with none, the cost is one loop that exits at once. Shown and
  measured by `lab/lightzone_lab.ludic` and `lab/lightzone_check.py`.
- **One vocabulary, from the compiler, for every editor.** `ludicc --emit-syntax` (`ludic syntax [--json] [-o FILE]`)
  prints the language's words from the compiler's own table (`selfhost/frontend/vocab.ludic`): every keyword with its
  role (declaration, modifier, statement, operator, constant) and whether the parser reserves it, every declaration's
  form, the built-in types and phases, every attribute with what it goes on, its arguments and a one-line doc
  (`@Ref`, `@OneOf`, `@Range`, `@Unit`, `@Asset`, `@Color`, `@Node`, `@Clip`, `@Material`, `@Tint`, `@Derived`,
  `@Text`, `@Multiline`, `@Key`, `@AppendOnly`, `@ByKey`, `@PerMap`, `@Chunked`, `@max`, `@owns`, `@frame`, `@Sync`,
  `@Computed`, `@alloc_ok`, ...), the operators and the literal forms. `"syntax_version": 1`. The emitter asks the
  parser's own recognisers of every row and refuses one they disagree with.

  `ludic-dev syntax` writes the keyword, type and phase lists of `ludic_syntax.h`, the TextMate grammar, the JetBrains
  lexer, `ludic-mode.el` and the language server between marked lines; `ludic-dev syntax --check` (also run by
  `check-vocabulary` and the regression suite) fails when one falls behind or lacks a word, when docs/language has no
  page for a keyword, type, phase or attribute, or when the parser tests a word or reads an attribute the vocabulary
  lacks. The grammars gain `module uses port bind action reducer dispatch registry def open component prop view alias
  friend unsafe numbers of as from mut system` and more; docs/language gains a page for each of them and for every
  editor, registry and memory attribute.

  The language server's outline names every declaration by its own kind: `export property` / `state` are structs with
  every field as a child (a field's default no longer swallows the fields after it), `event` / `action` events, `port`
  an interface, `registry`, `enum` with its members, `component` / `view` with their props, state and events, and
  `reducer S on A`. Hover and go-to-definition resolve an attribute's argument - `@Ref(Kits)` to the registry,
  `@Node(model)` to the field it names - and hover on the attribute shows its reference page; a `fn(...) -> T` field
  shows its whole type.
- **Online mechanics: missions, lobbies and a persistence service.** Three packages for a game of open sessions, jobs and shared progress, all generic and all data.

  - **`ludic.missions`** - jobs, contact missions, heists, races and adversary modes as data graphs. A mission is rows of nodes (go-to, collect, deliver, eliminate, defend, minigame, survive, escape the law, race gates, wait for the team, choice, score, signal) and edges (on done, fail, timeout or a choice; conditions; forks and joins), which a studio edits like a machine table. A run per lobby or team keeps objective state, markers as facts, checkpoints and retries, roles by preference, teams, cuts and a pot split to the last coin through payment keys; heist chains have planning boards (setups, alternatives, modifiers, the leader's cuts); a player's race or mode is a `Creation` judged against its kind's limits and compiled to the same plan. Host-authoritative: snapshots out, asks in.
  - **`ludic.lobby`** - sessions of a kind (public, invite-only, friends, crew, solo, a job's instance): admission, matchmaking and quick join by region, ping, skill, crew and friends, the moves between freemode and a job's instance and back (seats kept, a new session when the old is gone), host migration with the host's state handed on, join in progress, kicks and vote-kicks, passive mode, and anti-grief rules and bad sport as data. The phases are a `@Machine`; Steam lobbies are an optional port.
  - **`ludic.persist`** - player data kept by a small authoritative service written in Ludic (`packages/ludic.persist/tools/persistd.ludic`) over `ludic.net`, and the client that caches it and plays on offline: records by player and namespace with versioned schemas (`ludic.save` migrations), atomic transactions with idempotency keys, an append-only journal and snapshots, an auth port, rate limits. Tested in process and as a child process killed and restarted on real UDP.
- **Open-world mechanics: `ludic.roads`, `ludic.wanted`, `ludic.respawn`, `ludic.procgen`.** Four packages on `ludic.base` alone, each with data registries carrying editor attributes, verbs, facts, a save section, tests and a README.

  - **`ludic.roads`** - a road network as per-map `@PerMap` tables (nodes, roads as Catmull-Rom splines with lanes, a limit and a priority, turn rules), shortest and fastest routes over edges (forbidden turns, dead ends, one way roads), and traffic: cars following lanes with the Intelligent Driver Model, one car at a time through a junction by priority, stop, yield and signal, through ports for their bodies (`RoadsBody.place`, `.probe`) and the world (`RoadsWorld`).
  - **`ludic.wanted`** - a heat level against a subject: crimes as weighted rows (witness, repeat, cap), decay out of sight, levels and responses per level as data, the phases (Clear, Wanted, Searching) as a `@Machine` whose graph is `steps.lres`, and facts for the game's AI.
  - **`ludic.respawn`** - death to respawn: per-map respawn points (`@PerMap`), a rule per cause (nearest, checkpoint, home or start; flat and proportional cost, free deaths, wait, untouchable window), checkpoints by passing, locked points, and facts.
  - **`ludic.procgen`** - deterministic seeded generators in integer math: room-and-corridor dungeons, tile maps from edge-socket rules (wave function collapse), scatter within regions. The algorithms are written out precisely in its README, `tests/procgen_golden.json` holds inputs and outputs for 19 cases, and `tests/reference/procgen.py` is a second implementation that agrees with it number for number, so an editor's preview can match bit for bit. The save is only the seeds.
- **Placed things are baked into instanced kits.** `kitbake.ludic` turns a list of placements into the map's `RenderKits` rows (one kit for each model, node and interior atlas, so every building that names a model shares one mesh, drawn instanced by its cell) and the cell files and index the large world streams; rows already written keep their ids and a re-bake only appends. `ludic.city`'s `tools/cells_bake_city.ludic` (`city_cells_bake`) does it for `Buildings` rows, and `tests/cells_bake_test.ludic` runs it on the fixture city: 72 buildings in 6 kits drawn as one culler list a kit, then `hlod_bake` over the same files. Run by a person or a `hook before build`; the game only loads the result.
- **Reversed depth everywhere.** Every pass draws with Vulkan clip space and reversed depth: D32F, 1 at the
  near plane and 0 at the far one, cleared to 0, compared `GREATER`. The camera's far plane is at infinity
  (`m4_perspective_rz`, `r3d_proj_far`), unless a fog wall hides the land as well (`R3D_FOG_LAND=0`); then it
  clips at the wall's reach, as before. A 5 cm near plane now resolves about 0.07 mm at 1000 m, where it
  used to resolve about a metre. Shadow maps compare `GEQUAL` with a negative slope bias. Shaders read
  depth through `depthClip(d)` and treat `DEPTH_SKY` (0) as the sky. The SPIR-V wrapper stops remapping depth,
  and `kinst_planes` reads near and far in the new clip space; a far plane at infinity gives no plane. The
  OpenGL `m4_perspective` and `m4_ortho` are kept for CPU math only.
- **Starter templates and `ludic release`.** `ludic new <name> [--template <t>]` copies a starter and
  `ludic templates [--json]` lists them: `blank` (the default, unchanged), `third-person` and
  `first-person` (ludic.character over ludic.lab's plate), `2d-platformer` (ludic.platformer) and
  `top-down` (a tile map), each checked with `ludic build --check`. The manifest gains `release` lines
  (`release id`, `title`, `authors`, `channel <os> "<name>"`, `feed`, `keep`, `notes`, `entitlements`,
  `sign`, `notary_profile`, `upload s3 "<bucket>" "<endpoint>"`, `dir`, `exe`, `icon`), and
  `ludic release [--os osx|win|linux] [--dry-run] [--json] [--key-id ID --secret KEY]` turns them and the
  bundle into Velopack's `vpk download s3`, `vpk pack` and `vpk upload s3`, stopping at the first
  failure. `--dry-run` prints the exact commands with the credentials redacted, `--dry-run --json` the
  plan as JSON. Credentials come from `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`, never the
  manifest, and a project's own `script "release"` still takes the command.
- **Steam as a package.** `ludic.steam` is the Steamworks runtime API as a `ludic.base` mechanic: a start-up state machine
  (`steam_start`: ready, unavailable with a reason, or restarting outside Steam), the user, friends and avatars, rich presence
  from `SteamPresence` rows, lobbies (create, join by Join Game click, invite or launch argument, search with filters, data, chat),
  achievements, stats and leaderboards driven by the data registries `SteamAchievements`, `SteamStats` and `SteamLeaderboards`
  (an achievement can unlock itself at a stat's goal; one earned with no Steam is kept in the save section and sent when Steam
  is there), Steam Cloud files beside `ludic.save`, Steam Input by `SteamActions` row, DLC, the recording timeline, and Steam's
  relay as a `ludic.net` socket option (`bind NetSocket { open: fn steam_net_open, ... }`; UDP stays the default). With no
  backend, or one that cannot start, every call is a safe no-op. A dev build's link gets the verbs `steam_state`, `steam_unlock`,
  `steam_reset`, `steam_lobby_create`, `steam_lobby_leave`, `steam_stat` and `steam_presence`. `steam_fake_driver` is a Steam in
  memory, so a game's tests need no Steam.

  **`ludic.steamworks` is the real backend, built from your own SDK.** The Steamworks SDK is Valve's and cannot be in an open
  toolchain, so nothing of it is committed: `STEAMWORKS_SDK=<sdk> sh native/build.sh` runs a checked-in generator
  (`tools/steam_gen.ludic`) over the SDK's `steam_api.json` (426 flat-API methods wrapped, each answering "nothing" while Steam is
  down), compiles it and a hand-written shim against the SDK's headers into git-ignored `gen/` and `lib/<target>/`, and copies
  the SDK's runtime library beside them. `ludic bundle` puts both libraries in the app and signs them. `docs/PACKAGES.md` has the
  pattern for a native library that may not be redistributed.
- **Still water as planes and meshes, with a wet mask.** `WATER_MAX` goes from 8 to 16. A body can be a mesh
  (`water_mesh_add`, or a `WaterBodies` row with an `asset` and a `node`): a baked lake polygon or river ribbon,
  drawn with the water material on its own triangles only. A plane marked `masked` (`water_body_mask`) draws only
  on wet texels of a per-tile wet mask (`water_wet.ludic`: `<tile>.wet.png`, read nearest first, mixed tiles kept
  in resident layers, `wet_at` on the CPU), so a dry cut below the plane's level stays dry. `water_rebase` follows
  the floating origin. The `shore` fixture and its lab (`lab/shore_lab.ludic`, `lab/shore_check.py`) show and
  measure it.
- **Storey lines on kits: a line across the walls every `storey_h` metres of height.** A `RenderKits` row with `storey_h` (metres, 0 = none)
  and `storey_line` (thickness, 0.12 m) has `kit.frag` darken a thin band every `storey_h` metres on every upright face, so a box kit of 3 floors and
  one of 72 show the same lines (they count height in metres, not texture coordinates, and a box instance's scale never stretches them). A box
  instance's lines hang from its top (its own `h`, the eave) down, so a plinth under the building shifts nothing: they are every storey up from its
  pad and the last is the eave; another kit's count up from its base. Faces that look up or down have none, and a line thinner than a pixel fades out instead of
  shimmering. `kgpu_kit_storey(g, id, h, line)` sets it on the GPU kit (`bw_setup_kits` does it from the row), `kitbake_storey(kb, id, h, line)`
  writes it into the rows of a bake. `kit.vert` gains outputs `v_h` (the height above the instance's base) and `v_top` (a box instance's `h`, -1 for another). Shaders rebuilt
  (`ludic-dev shaders`). The impostor cards and HLOD proxies are baked without lines.
- **Terrain LOD lock: coarse levels no longer move roads, pads and shores.** `terrain_bake` takes a comma-separated list
  of land-use classes to lock and a tolerance (`... [patch_texels] "3,4,5,1" [mask] [tol]`, default 5 mm;
  `tmb_lock_new` in `tilemap_bake.ludic`). A coarse patch level whose triangles would move a locked texel by more than the
  tolerance is cut down to level 0's cells along the locked ground, graded 2:1 so it has no slivers, and stored as a
  locked mesh. Every other level, and any bake with no lock or no mask, is written byte for byte as before.

  **Breaking (file format):** a tile with a locked level is written as **LWT version 2** (level kind 1, a locked mesh);
  older readers refuse it. Version 1 tiles read unchanged. Rebuild the tools and rebake terrain with the lock to use it.
- **The RTS mechanics: `ludic.rts`, `ludic.build`, `ludic.produce`, `ludic.harvest`** - what an Age-of-Empires-like game is built
  from, each a mechanic of `ludic.base` alone (ports for the world, queues of facts, verbs, its own save section), none
  depending on another, and every kind of content a row of data a studio can edit.

  - **`ludic.rts`** - a selection per player (click, box, shift), ten control groups, an order queue per unit with shift-queue, and
    formations and stances. Orders are rows of `RtsOrders` with a mode the logic knows (`RTS_M_POINT`, `CHASE`, `WORK`, `PATROL`,
    `STOP`, `HOLD`); move, attack-move, attack, gather, build, patrol, stop and hold ship as data. Execution asks the world through
    `RtsWorld` (positions, a path, reach, an enemy to pick) and says `RTS_F_ENGAGED`, `ARRIVED`, `LOST_TARGET` and the rest as facts.
  - **`ludic.build`** - footprints of w x h cells turned a quarter at a time, placement rules per kind (tags every cell needs or must
    lack, next to a finished structure, apart from another, what the owner must have, a limit), a cost taken through `BuildBank`, and
    construction as a `@Machine` (Placed, Building, Done, Destroyed) that workers progress, with a pace curve per kind.
  - **`ludic.produce`** - a queue per building of items from data (time, cost, supply, tech, once-only upgrades), queue limits, cost
    at the queue or at the start, refund percentages for cancelling, a rally point or entity, held until supply and room allow.
  - **`ludic.harvest`** - resource nodes (amount, slots, regrowth, vanishing), gatherer classes (capacity, pace per resource),
    drop-offs, and the gather-carry-drop loop as a `@Machine` whose rows live in `steps.lres`; a spent node is left for the next one
    near it. The stockpile is the `HarvestBank` port.
- **The open sea.** A still-water plane in sea style (`sea: true` on a `WaterBodies` row, or `water_sea_add`): the surface stays flat and swells bend the light - read from two small tiling textures of slopes (baked once from a few dozen plane waves of whole wavenumbers spread over a cone of directions, so no parallel stripes, mipped so a wave a pixel cannot resolve averages to flat instead of crawling as glitter), flat toward the horizon; the colour deepens with the water under it and is plain deep sea from nine metres down and over the edge of a map's ground; a foam band lies along every shore where the water over the bed is under a metre deep (white at the swash, lace out to the band's edge, nothing at a metre, none on the dry texels of the wet mask, none where the plane meets the ground to the millimetre), on the sea only. The rectangle reaches `WATER_SEA_REACH` (100 km, or the camera's far distance if more) past the map, so the sea runs to the horizon from anywhere on it. Drawn on the wet mask's wet texels with no reflection pass (the sky, and the haze of the fog, are one read of the prefiltered sky), one quad drawn by its own program (`WATER_SEA` in `water.frag`: the sea's code alone, the lake's likewise): on the lab's coast the pass costs about 0.45 ms at the beach, 0.28 at the horizon and 0.47 with the sea filling the frame on an M4 Pro at 1080p, against 1.17, 0.74 and 1.46 for the first version of the sea and about 2.2, 2.0 and 4.4 for the same plane in the old style (`R3D_PROF=1`, `lab/sea_lab.ludic`, `lab/sea_budget.py`). `applyFog` in `lighting.glsl` is now `applyFogSky` with the haze's sky colour handed in (`applyFog` reads it as before, the same colour), so a surface that reads the sky anyway does not read it twice. The sea reads its tiles' depth only where the bed is shallower than nine metres. A lake or a river keeps its look, and its thin wash can be switched off with `wash: false` (`water_body_wash`). A mesh body (a river mouth) drawn at the sea's height now wins over the plane instead of fighting it: planes are drawn a hair behind. The wet mask is read across tile borders (four texels each through the page) instead of clamped inside a tile's layer, so a border is not a step of half a texel in the edge. `prof_reset` starts the GPU means again for a lab holding one view then the next, and the water pass's scene capture has its own slot (`water capture`).
- **The profiler reports the least single frame of a pass beside its mean** (`R3D_PROF=1`: a `least N us` column on each row). A busy GPU only ever adds to a pass, so the least frame is the pass's own time where the mean moves with whatever else the machine is doing; the results that arrive in the frames after `prof_reset` (the ring's latency) belong to the shot before it and are no longer counted. The sea's shader: the foam's fade at the wet mask's edge reads the mask once where the four reads lay in one tile (the same pixels), the swash's phase is two sines instead of a noise, and the shadow tap is skipped for a glitter under a hundredth of the sun's colour.
- **Weather, clock, vehicles, physics colliders, ground layers and water are data now**, not records a
  game hands in through functions: each package has an open (or per-map) registry a game fills with
  `def X from "file.lres"`, so an editor can author them.

  - **`ludic.weather`**: `WeatherKinds` (one row a kind, `WK_<KEY>`, `@Range`/`@Unit` on its numbers) and
    `WeatherSettings` (the valley's wind). `ludic.clock`: `ClockSettings` (the day's length in real minutes, start
    hour, night, moon, calendar).
  - **`ludic.vehicles`**: `VehicleSpecs` (a kind's numbers and model) and `VehicleSeats` (where a rider sits, in the
    model's space). **`ludic.physics`**: `ColliderShapes`, made into shapes with `phys_shape_of`.
  - **`ludic.render3d`**: `GroundLayers` (a map's painted layers: density image, what grows, the `GroundFill`
    numbers), `GroundKinds` and `WaterBodies` (a map's planes), applied with `ground_layer_fill` and
    `water_bodies_apply`. `ludic.vehicles` and `ludic.physics` ship a `studio.lres` for the seats and colliders.
  - Every older entry point keeps working and wins over the rows: `weather_kinds`, `weather_config_wind`,
    `clock_config`, `clock_config_moon`, `clock_calendar`, `clock_set_scale`, `vehicles_spec`, hand-built
    `GroundFill`s and `water_init`. A game that declares its own `GroundLayers` or `WaterBodies` registry next to
    `ludic.render3d` must drop it for the package's (the private `water_bodies_clear` is now `water_planes_clear`).
- **`Text.to_float(s)`** - a leading decimal number read from a string as a `float` (`strtod`
  underneath), the twin of `Text.to_int`. A game's data files carry fractions - an effect's
  strength, a model's reach - and there was no way to read one back.
- **`dev_mode()` (ludic.base)** is the one documented dev switch (`R3D_DEV` set, not `0`); `ludic.devlink`'s `DevlinkWorld.enabled` defaults to it, and the docs no longer name a `dev_tools` symbol.

  **An allocation-fence failure (exit 86/87) leaves a crash record** when the `ludic.crash` handler is installed: signame `ALLOC_FENCE`, the frame, bytes kept and the top three allocation sites first in `context`. `crash_exit_name` names 86/87.

  **App name and version reach the program:** `Build.app_name()`, `Build.app_version()`, `Build.app_id()` from `package.ludic`. `Os.save_dir()` (and config/cache_dir, and every Os call) with the wrong argument count is a clean compile error instead of a compiler crash.

  **`ludic.crash`:** `crash_boot(build)` wires the handler from package.ludic and a `CrashSettings` row (dir, keep_n, enabled, context); dev verbs `crash_pending` and `crash_context`. **`ludic.vitals`** gives a removed actor's record to the next `vitals_add` (a spawning crowd no longer trips the fence).

  **`ludic.lab` `LabSteps`:** rows of named setup steps; `lab_boot` draws a first frame and a progress bar between them before the scene's setup, and prints `lab: step <key> (i of n)`.
- **`ludic deps` says what a function can come to CHANGE** (`widest_write_reach`, and `--wreach N`
  lists the functions by it): the states it reaches as `mut`, through calls, `fn` values and step
  lists. Reach itself is sharper: `Port.member()` reaches that member's binding only, and
  `Registry[i].field` (or a local holding `Registry[i]`) reaches that field only - a question asked of
  a port or a table that also holds verbs no longer reaches the verbs.
- **`ludic deps` sees through fn values, and lists the widest functions.** A step list or a registry of
  fn values takes no state and still reaches every state its steps take; `widest_reach` is the most
  states any function can come to - by a call, a `fn f` it writes, or a global holding fn values it
  reads - reported beside `widest_function` with how many of them it does not take itself
  (`the widest reach: app_boot (src/app/boot.ludic:30), 72 states (72 through calls and fn values it
  does not take)`). `--widest N` lists the N functions that take the most states with what each
  reaches; `--reach N` orders them by reach. A baseline written before this has no `widest_reach` and
  does not hold it until it is rewritten.
- **`ludic fmt` for editors.** `ludic fmt --lint --json` prints the violations `--lint` reports as one JSON
  array on stdout, `[{"file", "line", "col", "rule", "message"}]` ordered by file, line and column (the
  summary on stderr, `--lint`'s exit status, and the baseline never rewritten). `ludic fmt -` formats
  stdin to stdout under the project found from the working directory (the nearest `package.ludic`
  upwards), and refuses a buffer that does not read as Ludic - an open string, a bracket never closed or
  closed by the wrong one - with exit 2 and `<name>:<line>:<col>: error: ...` on stderr.
  `--stdin-name <path>` makes the buffer that file: the project is found from its directory, and
  `ludic fmt - --lint --json --stdin-name <path>` judges it against that file's baseline and `lint
  paths`, reporting it under the name given. Hooks around `fmt` and `get` read nothing from stdin and
  write to stderr when the command's stdout is a program's (`--json`, `-`).
- **`ludic remove <module>` and `ludic get --json`.** `remove` is the inverse of `add`: the `require`
  leaves `package.ludic`, the lock keeps what the remaining requires still reach (read from the store's
  copies of each package's manifest, no network), and each package leaving the lock loses the
  `ludic_modules/` link `add` made - never the shared store entry. A module that is not required is
  refused; source still importing a removed package is a warning. `ludic get --json` prints what the run
  changed in the lock as one JSON object on stdout - `{"added", "removed", "changed", "unchanged"}`, an
  entry as the lock records it (`name`, `version`, `hash`, `kind`, `provides`), a change as `{name, from,
  to, from_hash, to_hash}` - with the resolver's own lines on stderr.
- **`ludic-dev check-packages`: every first-party package in one program.** Registry prefixes and exported names are global, so packages that compile alone can clash in a game. The task imports every importable package into one program, binds nothing and runs `ludicc --check`; a declaration error (`defined twice`, an unknown `@Unit`, ...) fails it and names the packages involved. Only `port X is used here but never bound` and the `@Ref` "this program has no X" warnings are expected. CI runs it. `docs/PACKAGES.md` gains the naming rule for prefixes and exports.

  `@Unit` accepts `ms` (milliseconds) and `1/h` (a rate per hour); `ludic.lobby`'s `ping_max` fields have their `@Unit("ms")` back.
- **`ludic.anim` places a figure from a model read once, with no allocation.** Loading a skinned model per spawn (`gltf_load` + `anim_read_doc` + a skin clone + a new `AnimPlayer`) re-read the file and re-parsed the document for every ped. `anim_model_load` loads a node once and answers a repeat ask with a lookup; `anim_actor_pool` makes the per-figure parts (skin, player) before play; `anim_actor_spawn` and `anim_actor_despawn` take and return them, with the `Actor` from render3d's spares. A pool too small is counted (`anim_pool_misses`), never hidden. The actor table no longer doubles with every figure that ever came and went: a rebuild sizes it for the actors alive and swaps two tables, and `anim_actor_reserve` sizes it before play. `animset_restart` puts a player back at its graph's start.
- **`ludic.anim` plays animation graphs held as data: no game animates in code.** `AnimSets` grows from states, choices
  and edges into what a game needs for every motion: **state machines** with nested sub graphs (and exit states), any-state
  edges, conditions over float, int, bool and trigger parameters and over clip time (exit time), a fade per edge with a curve
  (linear, ease, custom points), priorities and interrupt rules; **blend spaces** (`AnimBlendSpaces`), 1D and 2D with exact
  weights over a triangulation made once, for locomotion, aiming and driving; **layers** - override and additive - through bone
  **masks** (`AnimMasks`) with weights driven by parameters; **sync groups** and clip **markers** so feet stay together;
  **clip events** (`AnimClips`) as facts gameplay and audio drain, each firing once per pass of its time, windows with
  begin, end and cancel; **root motion** as a per-clip option, reported through `anim_root_take` or the `AnimRoot` port with the
  body held in place; **skeletons** (`AnimSkeletons`) with canonical bone names, a root and a level of detail (update rate by
  distance, layers skipped far away). Gameplay speaks to a graph only through parameters
  (`anim_set_param`, `anim_set_bool`, `anim_set_int`, `anim_trigger`, `anim_request` by actor number). `anim_validate`
  returns the problems a studio can show: unknown clips, bones a mask names that the rig lacks, unreachable states,
  degenerate blend spaces, cycles. A tick allocates nothing (the heap is held still in a test). Sets written before keep
  working unchanged. The package's `studio.lres` names everything a graph editor needs.
- **`ludic.avatar`: character customisation as data.** A package on `ludic.base` alone for what a person looks like, with no body, part or feature named in the logic.

  - **Registries** - bodies (`@Asset("gltf")` / `@Node`), morphs with ranges (blend shapes or bone scale and offset), heritage presets blended by a mix, slots with layers, parts (`@Asset`, `@Node`, `@Material`, the bodies they fit, layering, `hides` and `conflicts`, level / flag / price unlocks), slot-level rules, palettes (`@Color`), decal zones and decals, premade outfits, and poses as `@Clip` rows - body motion is always a clip played through the animation graph, never procedural.
  - **An avatar per player**: `avatar_set_body`, `_set_heritage`, `_set_morph`, `_set_part`, `_set_color`, `_add_decal`, `_apply_outfit`, `_save_outfit`, buying and granting, validation, and `avatar_randomize` from the package's own dice.
  - **A stable id-based wire text** (`avatar_encode` / `avatar_decode`): ids, not indexes, so a registry may be reordered; a check letter; unknown or ineligible ids dropped and counted, a torn text changes nothing. The same encoding is the save section.
  - **`AvatarView`**, the port a renderer and animation layer bind: body, parts in layer order, colours, morphs, decals and the pose clip, documented in the README as the contract.
  - Facts (`AVATAR_CHANGED`, `_BOUGHT`, `_REFUSED`, `_FIXED`...), tests on a fixture kit.
- **`ludic.cars`: wheeled vehicles as data and a simulation behind ports.** Handling as rows (`CarModels`: engine
  torque curve, gears, brakes, steering by speed, any number of axles with suspension, tyres from `CarTyres`' normalised
  grip curves, aero, nitrous, health, arcade-to-simulation blend and assists), tuning (`CarParts`), paint
  (`CarLiveries`), classes, seats and sockets (`@Asset` / `@Node` / `@Clip`). A raycast-wheel model over the game's
  physics body (`CarBody`, `CarWorld.cast`; no native change to `ludic.physics`), a planar model of the same
  tyres and drivetrain, and a lane follower over `CarRoad` for traffic, switched by distance. Entering, leaving and
  carjacking are a `@Machine`; damage and dents are facts; ownership (garage slots, retrieve, call, store, insurance
  claims, the impound) is a second `@Machine` over `CarBank` and `CarPlaces` ports; the package plays no animation,
  it asks the game's animation graph for states by name (`CarAnim`). Party play is one authority per car
  (the host, or the driver) with fourteen-int snapshots, an interpolation ring and refusal of impossible claims,
  all without per-frame allocation.
- **`ludic.city`: a city as authored data.** Districts a designer outlines, blocks built through a Blender generator (`BuildingGenerators` presets with knob schemas; a `CityBlock` keeps the preset, knobs, seed, the glTF that came back and a `built_hash` that `city_block_hash` says is stale or fresh), buildings placed with a stable key, kit or generated asset and node, footprint, floors, interior class (none, fake with an `InteriorAtlases` atlas, enterable with a map of its own), doors, lot and address, and their own or zoning-estimated capacity. `Districts`, `CityBlocks`, `Buildings` and `Landmarks` are per-map tables (the last two chunked by 256 m); `ZoningRules`, `BuildingKits`, `BuildingGenerators` and `InteriorAtlases` are the game's.

  Nothing is generated at run time. Cells of buildings stream in and out as the player moves (`city_stream`, or `city_stream_step` a load a frame, with a fact each way for a renderer), and what is loaded answers queries by cell, rectangle, radius and id, homes and workplaces near a point by capacity and kind of land, the district, zoning and ambient crowd and traffic at a point, and head counts (`city_census` over a map one cell at a time: an authored 88,000-building city holds 640,000 residents and counts in about 120 ms).
- **`ludic.city`: building colliders from the row, baked.** `CityBuilding.footprint` is the building's real plan (a simple polygon in the model's own frame; empty means the rectangle `w` x `d`). `city_colliders_bake` cuts every plan into convex pieces (ear clipping for a concave one) and writes one `collider_<cx>_<cz>.lwk` file a chunk; `city_colliders_in` and `city_colliders_out` load and remove a chunk's pieces through the new `CityPhysics` port, so a game binds two functions and writes no collision code. `city_footprint_problem` says what is wrong with a plan. `ludic.physics` gains `phys_prism`, the convex shape of a piece (a polygon stood up between two heights).
- **`ludic.crews`: gangs and crews.** A package on `ludic.base` alone; membership, money and player positions come through ports.

  - **Registries** - `CrewRanks` (power and permissions), `CrewRelations` (ally, neutral, rival, war as rules: contest, friendly fire, mutual, kill and bounty shares, hold time, escalation by kills), `CrewSettings`, `CrewSources`, `CrewEmblems`, and `Territories` (`@PerMap` discs, polygons or grid cells with value and income).
  - **Crews**: create, invite, join, leave, kick, promote, transfer, a bank with a daily limit per rank, emblem and colours, disband.
  - **Influence** per crew per territory from kills, presence and reported jobs, with decay and a cap; bounties; rivalries that harden by themselves.
  - **Turf war as a `@Machine`** (`steps.lres`): peace, contested, war (declared or escalated, scored by kills), captured or held, cooldown; territories pay income into the owner's bank.
  - **Host-authoritative**: verbs refuse on a guest (`CREW_NOT_HOST`); `crew_snapshot` / `crew_apply_snapshot`; facts for every change; a save section by key.
- **`ludic.crowd`: the ambient population of a living city.** A mechanic on `ludic.base` alone. Data: `PedTypes` (speeds, fear and bravery, what it does when scared, the chance it phones the police, carry, witness weight), `PedLooks`, `PedSchedules` (acts by the hour with scenario anchors), `CrowdThreats` and `CrowdSettings` as registries, and `PopulationZones` (polygons with peds-a-hectare and vehicles-a-km2 curves by the hour, a mix of types) and `PedScenarios` (benches, smoking spots, cash machines, stalls) as `@PerMap` tables a designer paints. Runtime: people made round each player in a ring, not in view, within a budget, each unit a pure function of (seed, cell, slot) so every machine makes the same people; full, mid and far tiers by distance with budgets that draw the radii in; walking through a `CrowdNav` port (corners, sidewalk points, crosswalks and their lights, jaywalkers); scenarios used within capacity; groups of friends; reactions as a `@Machine` (Calm, Alert, Flee, Panic, Cower, Fight, Call); crimes reported as `CROWD_REPORT` facts for `ludic.wanted` and witnesses answering its `witnessed` port; `crowd_traffic_target` for `ludic.roads`; a host-owned population with a four-word-a-ped delta for clients; a pooled, allocation-free tick (2 400 peds in about 25 us on average; tested: no heap growth).
- **`ludic.missions`: Ludic Studio edits a mission's graph.** The package ships a `studio.lres` with a `TableGraph` entry
  `missions` (Missions, MissionSteps and MissionEdges, every step kind with a colour and an icon, pass and fail
  terminal), and a dev-link verb `mission_problems <mission key>` that answers the existing `check.ludic` lint, one
  string per problem, for the running game.
- **`ludic.physics`: Jolt Physics as a package.** Shapes (box, sphere, capsule, cylinder, a
  boulder's dome, a heightfield, a mesh), still, kinematic and dynamic bodies that can be removed
  for real, rays, a foot's landing height, a push out of what a body stands in, overlaps, buoyancy
  against a `PhysWater` port with its current, and hard contacts and splashes as facts - stepped at a
  fixed 1/60 s, deterministic across machines. Jolt v5.6.0 is built here from its pinned tag
  (`native/build.sh`) through the phase-15 route.
- **`ludic.property`: housing and businesses.** A package on `ludic.base` alone; money, interior loading, items and vehicles are ports.

  - **Registries** - `PropertyKinds` (an interior map and further maps of a multi-map interior, garage, storage and upgrade slots, rentable, raidable), `Properties` (`@PerMap` entrances with price, rent and district), `PropertyUpgrades`, and `BusinessLoops`.
  - **Ownership per player** (`realty_buy`, `_sell`, `_rent`, `_trade`, `_upgrade`) through a purse port, rent a game day at a time with a grace period and taking back, access lists (owner, invited, crew, friends, public).
  - **Instanced interiors**: `realty_enter` gives each visit an instance id (the live one is joined), the game loads the map through `RealtyLoad`, `realty_go_floor` moves between the maps of one interior, the last one out closes it.
  - **Storage** of items and vehicles through ports, raids with a cooldown, passive income, upkeep.
  - **Business loops as a `@Machine`** (`steps.lres`): supply, produce on a timer, full, a timed sale run that pays.
  - **Host-authoritative**: verbs refuse on a guest (`REALTY_NOT_HOST`); `realty_snapshot` / `realty_apply_snapshot` replicate; facts for every change; a save section by key.
- **`ludic.render3d` draws and walks a map's ground from the studio's height tiles.** `tmap_new` takes the map row's numbers (`tiles`, `tile_size`, `tile_res`, `tile_cols`, `tile_rows`, `origin_x/z`, `height_min/max`, an optional offset) and reads the 16-bit PNG tiles exactly as the studio writes them: texel centres, image row 0 the low z, bilinear across tile edges, a tile with no file flat. A pool of tiles streams nearest first within a per-frame budget, `tmap_height` is the allocation-free port physics and walkers ask, and `tmap_field` fills the array `phys_heightfield` takes (a hole where a tile is not loaded). The ground is drawn from **baked** levels of detail: `tools/terrain_bake.ludic` cuts every tile into patches and levels and writes one `.lwt` file a tile (quantized heights and normals, the row's numbers in its header so a file baked for other numbers is refused); `tmd_frame` streams the patches nearest first, each an actor the model pass lights and shadows, with a skirt hiding the cracks between levels. The game makes no mesh in play. Nothing is sized in code.
- **`ludic.render3d` loads binary glTF.** `gltf_load` and `gltf_cached` read a `.glb` (the header, the JSON chunk and the BIN chunk) through the same path as a `.gltf` with its `.bin`: the two are told apart by the file's first bytes, the accessors read only the byte ranges a node needs from the BIN chunk, and a damaged file (another version, a chunk past the end, no BIN chunk) is refused with a line saying so. `gltf_open` and `gltf_bin_reopen` are the document and binary for a reader that comes after a load, and `ludic.anim` reads clips through them, so a `.glb` animates too. The studio's Blender generators export `.glb`; a row's `@Asset("gltf")` names either.
- **`ludic.render3d`: a map's clearings, edits and hero things as rows over its painted ground.**
  Paint stays the forest; a row exists only where a designer said something. Four `@PerMap` registries sit beside
  `ground_layers.lres` (`ground_rows.ludic`): `GroundClearings` (areas) and `GroundStrips` (trails), handed over
  with `ground_clearings_use`, thin every trampled layer - a polygon by the even-odd rule, a strip within half its
  width of the centre line, each back to full across `feather` on the disc's smoothstep (`ground_clear_shape.ludic`;
  `r3d_ground_clearing_area` / `_strip` are the verbs, and discs still work). `GroundEdits` names a grown solid thing by
  its id and says how it differs - removed, moved, turned, resized, grown as another kind - and applies as the thing
  grows, so the list, the draw and everything keyed by id agree; `GroundHeroes` places solid things by hand, listed
  with the layer whose new `GroundFill.kind` is theirs, in the chunk they stand in, ids in layer 63's range
  (`ground_hero_id`, which `ground_solid_id` no longer gives). `ground_edits_use` takes both at a map's load and
  prints once each row it cannot honour (a thing that no longer grows, an id edited twice, a kind no layer grows).
  Outside every clearing and edit the same candidates stand with the same numbers: the golden's earlier sections are
  unchanged, and it gains `clearing_shapes` (289 probes) and `edits` (five edits, two heroes, three chunk lists).
  `studio.lres` shows the clearings, strips and heroes; `GroundSolids` carries each thing's `cells`.
- **`ludic.render3d`: a running dev build can have a painted ground layer replaced in memory, and its cover grown again (plan 29.8, the editor's live link).**
  `ground_density_patch(render3d_st, layer, png)` cuts one layer of the open ground densities from a PNG exactly as the dev copy does (`gd_tile_q`, now shared with `gd_write_layer`: 6 bits of density, 4 of scale, empty tiles and one-value tiles free) and holds its tiles in a buffer of its own; the layer's index words point there (bit 30 of the length word), the tile cache is emptied and the blades' window reads the layer again when it is the blades'. Nothing is written, `ground_density_close` lets the buffers go and the next map load reads its file. `streams_forget(render3d_st)` lets every stream's cached chunks go (the records back to the spare list, as an eviction does) so the next walk fills them from what the ground says then - the cover after a density or a clearing changed. Neither is for a frame: they are the editor's, one call per change. `layer_chunks_regrid(layer)` lets a fixed layer on the CPU path (no GPU cull) drop the spatial grid it sorted its instances into, so chunks put or dropped under it show on the next update; the ring never needed it, a re-grow does.
- **`ludic.render3d`: painted ground layers grow solid things, with ids, and the trample is data.**
  `ground_fill`'s candidate is its own function, `ground_candidate` (pure `gf_*` steps with the density read
  between them, into a caller-held `GroundCand`), and `ground_fill` draws exactly its answers - the same
  operations in the same order as before, so every cover layer grows bit for bit what it did. A layer with
  `solid: true` is filled at `step0` with band 0's hashes whatever the camera, a far band drawing a stable
  subset; each thing has an int id from (layer, chunk, cell) (`ground_solid_id`), and `ground_solid_list` /
  `ground_solid_at` answer a chunk's things or one by id for physics, the nav bake and saves.
  `r3d_ground_clearing(x, z, r_in, r_out, floor)` hands the trample over as discs the editor can see, beside
  the `r3d_on_ground_trample` callback, which still works. `tests/ground_fill_test.ludic` holds all of it to
  `tests/ground_fill_golden.json` (written by `tests/gen/ground_fill_golden.ludic`), the file the studio's
  TypeScript generator is tested against.
- **`ludic.roads`: design heights, levels, structures, 16,384 roads and a fast nearest road.** `RoadSeg.heights` (one `RoadHeight { y, free }` per anchor, as `handles`) and `level` (`ground`, `structure`, `tunnel`) put a road above or below another at the same (x, z); `roads_seg_height`, `roads_seg_level`, `roads_seg_designed` and `roads_pose_y` read them, and cars are placed at their road's design height (a road with none follows the ground as before). New `RoadStructures` registry (`roads/structures.lres`: seg, from, to, kind bridge/viaduct/flyover/tunnel, type beam/arch/cable/box, over, deck_w, deck_t, parapet, pier_spacing, gaps) and `RoadProfile.median`, `shoulder` and `max_grade`. A map may have 16,384 roads (was 4,000; a turn is keyed `in * 32768 + out`). `roads_nearest` goes through a grid over the polylines instead of every step of every road, with the same answers, and `roads_nearest_y(x, y, z)` counts the gap in height, so under a flyover it is the road below. All new fields are defaulted, so an older map reads and drives as it did; `studio.lres` binds them for Ludic Studio. The nearest search is bounded by the size of the grid, not by how far the point is (a point a billion metres off the map is as cheap as one at its edge), and a NaN or infinite point has no nearest road.
- **`ludic.transit` and `ludic.citizens`: NPCs that live in a modern city.** Two mechanics on `ludic.base` alone, everything generic and in data.

  `ludic.transit` (public transport): `TransitModes` (capacity, speed, dwell, fare models flat / distance / zone, taxis on demand) and `TransitSettings` registries, and `TransitLines` (stops, a drawn path, headways by the hour, operating hours) and `TransitStops` (stand points, transfer links) as `@PerMap` tables a designer paints. A timetable that is a pure function of the clock (no vehicle is simulated; `transit_pose` says where any run is at any second), a time-dependent Dijkstra journey planner with transfers, walking legs and fares (about 0.4 us a plan on a small map, 70 us on a 576-stop grid), boarding with capacity and a wallet port, and the vehicles near a player handed to the game's traffic through a port (the schedule stays the truth).

  `ludic.citizens` (a persistent life simulation): `NeedDefs`, `PlaceTags`, `Activities` (with `anim` / `clip` / `prop` / `stance` as data for whoever embodies them: no pose is written anywhere), `CitizenArchetypes`, `CitizenNames` and `CitizenSettings`; a population made deterministically from the city's homes and jobs through a `CitizensCity` port (stable ids, names, kinds, natures, wages, cars, friends, jobs near home); a utility decision over needs, money, the hour, the shift and their nature, an economy loop (wages per shift from a workplace's till, prices, upkeep; money is conserved), and a trip by walk, transit, their own car or a taxi; level of detail - far citizens are events in a wheel of minute buckets (200 000 citizens for a simulated day in about 2.3 s, about 1.6 ms a one-minute tick), mid ones walk the planner's legs (about 80 ns a citizen a tick), near ones are handed to the crowd, cars or NPCs through `CitizensBody` and handed back; witnesses (for `ludic.wanted`), accidents, hires, moves, missions, a host's corrections and a digest for clients, and a seeds-and-deltas save. `adapters/` binds the ports to `ludic.transit`, `ludic.crowd` and `ludic.city`, each tested against the real package.
- **`ludic.weapons`, `ludic.crews` and `ludic.property` move onto `@Net` actions**, as `ludic.vitals` did: the requests a game used to build by hand are actions the host checks (`@Validate`, with a port member that says the sending machine plays that actor or player) and reduces with the same verbs.

  - **`ludic.weapons`**: a guest's shot is the action `WeaponsFire` (`@Broadcast(all)`). `weapons_fire_ok` is its validator (holding the gun, loaded, rate, origin, and `WeaponsWorld.allow_shot(sender, actor)`), `weapons_host_take` the host's resolution (lag compensation, its own seed), a `@Predicted` row reducer counts the owner's shots in the air so a refusal takes one back, and every other guest receives the action and shows the shot. Gone: `ShotRequest`, `ShotConfirm`, `weapons_outbox`, `weapons_confirms`, `weapons_net_confirm`, `weapons_host_fire`. The magazine is not in an undo record, so the owner's inventory snapshot still sets it right.
  - **`ludic.crews`**: a guest's verbs dispatch `CrewAsk { who, kind, a, b, c }` (`CASK_*`), and `crew_create` the action `CrewFound`, which carries the name and tag as bytes. The host checks (`crew_ask_ok`, `CrewWorld.allow_ask`) and calls the very verb. A guest's verb no longer says `CREW_NOT_HOST` or makes a `REFUSED` fact.
  - **`ludic.property`**: a guest's verbs dispatch `RealtyAsk { who, kind, hm, hk, a, b }` (`RASK_*`), a site named by the hashes of its map and key. The host checks (`realty_ask_ok`, `RealtyWorld.allow_ask`) and calls the very verb. A guest's verb no longer says `REALTY_NOT_HOST`.
  - Each has a test of two peers over a fake transport.
- **`numbers float` — a module whose decimal literals are `float`.** A bare `1.5` is `fixed`
  unless a float is in sight, which is the right default for deterministic code and the wrong
  one for a renderer or a game whose numbers are all IEEE: `Math.sqrt(2.0)` came out in `fixed`,
  and every literal needed a `float(...)` round it. A file that says `numbers float` (at the top,
  or inside a `program` block) gets float literals, and passes the mode on to every non-runtime
  file it imports, so one line in a barrel or an entry file covers a whole package. Runtime files
  under `runtime/` are never switched, so the engine's own fixed-point code keeps its meaning.
- **`ref "Table.field" "Registry"` in package.ludic: a game's own registry over a package's `@Ref`.** A package
  declares `@Ref(GroundKinds) kind: int` because it needs a default; a game whose rows name its own kinds writes
  `ref "GroundLayers.kind" "PlaceKinds"` once, and in that program the field refers to that registry wherever an
  `@Ref` is checked - a map's rows under `ludicc --check`, a `.lres` row - and the schema export reports it
  (`{"name": "Ref", "args": ["PlaceKinds"], "declared": "GroundKinds", "by": "package.ludic:8"}`), so an editor
  reads the same. The table is a registry (its record's field) or a record's name; a field with no `@Ref` gets
  one. In the package's `entry` program (or every program, when it names none) a table, field or registry the
  program lacks is an error at the manifest's line; another program under the package - a test of one part -
  skips a line whose table or registry it lacks. A field set by two lines is an error. Older toolchains ignore
  the line.
- **ludic.anim/studio.lres.** The package's own editor binding for Ludic Studio: `AnimSets` drawn as a graph
  (states, transitions, choices with need bands and rates). Counted only in a game that uses the package.
- **ludic.carbody: ludic.cars' body over Jolt.** A new package with the `CarBody` port's make, drop, read, push, torque and step and the
  wheel ray `CarWorld.cast` over ludic.physics, so a game binds them in two lines (`bind CarBody { make: fn carbody_make, ... }`, `bind
  CarWorld { cast: fn carbody_cast }`) and copies no adapter. The hit's grip is the game's `CarWorld.grip` at the point found. A
  pose, force or ray that is not a real number is refused at the boundary.
- **ludic.launcher.** A generic first screen for any game: `LauncherScreen` and its parts (brand, menu,
  update, crash slot, news, language, links, footer), each a `ludic.ui` component with `.lss` and
  `.stories.lres` for the studio's UI editor. What it says and offers is data the game fills in a `.lres`
  (`Launchers`, `LauncherButtons`, `LauncherLinks`, `LauncherNews`: title, `@Asset("png")` logo, art and
  background, buttons as rows with verbs, links, a news feed address or rows); what it asks of the game is
  `LauncherWorld` (save, update, language and crash answers, all with defaults) and `LauncherNet`; what the
  player did comes out as `LauncherFact`s. The "crashed last time" slot is a port for ludic.crash or the
  game to fill. Themeable through `--lc-*` variables; its own words are keys (`lang/launcher.en.po`).
- **ludic.render3d: large-world capabilities for a city of hundreds of thousands of buildings on a 16 km map.**

  - **Floating origin** (`forg.ludic`) - world positions in double, render space a float offset from a power-of-two-snapped origin that rebases with hysteresis and no jitter; integer-cell + float-offset positions.
  - **World partition and streaming** - cell size and tier radii as data (`world_partition.lres`), per-cell content files and an index (`cellfile.ludic`, `BuildingKits`), and a pure streaming scheduler (`wstream.ludic`) with a per-frame time budget, a memory budget, forward-first priority and hysteresis.
  - **HLOD** (`hlod.ludic`, `tools/hlod_bake.ludic`) - a merged far proxy a cell, baked by a task a person runs; octahedral impostors for far buildings (`oimp.ludic`).
  - **Instancing at scale** - a CPU culler with cell-level culling and an adaptive distance scale (`kinst.ludic`) and a GPU one: parallel compute cull and two-pass binning into indirect draws (`kgpu.ludic`, `kinst_cull.comp`); stress benchmarks in `bench/`.
  - **Fake interiors** - interior mapping for facade windows: an `InteriorAtlases` registry, a room a window by deterministic hash, lights on at night, selected by the `INTERIOR_MAP` variant of `kit.frag`.
  - **Real interiors** - portal visibility (`portal.ludic`) and multi-map, instanced interiors with a door / load / spawn transition API (`intr.ludic`).
  - `r3d_on_prepare`, a hook that runs before the frame's first pass, for compute dispatches; eight shader programs and three compute programs added, `ludic-dev shaders` regenerated.
- **render3d takes what a frame draws as callbacks.** A program used to have to define
  `scene_draw`, `scene_draw_casters` and `stream_fill` by name - a contract only the linker
  enforced, whose shape nothing checked (two examples defined `scene_draw_casters` with no
  parameter while the renderer passed one), and one scene per program. It registers them now:
  `r3d_on_draw(fn ...)`, `r3d_on_casters(fn ...)`, `r3d_on_stream_fill(fn ...)` (hooks.ludic).
  render3d also declares `numbers float` itself, so a program that imports it without the line
  still gets a working renderer. The Noise functions check their argument count: a call one
  short crashed the compiler, or - where it happened to fit - put fbm2's octaves in its seed.
- **render3d: actors turned any way.** `actor_place_rot(a, x, y, z, yaw, pitch, roll, sx, sy, sz)` places an
  actor with a full rotation (yaw about y, then pitch about x, then roll about z, as `translate * Ry * Rx * Rz *
  scale`) and a scale per axis; `actor_place_q(a, x, y, z, q, sx, sy, sz)` with a quaternion; and
  `actor_billboard(render3d_st, a, x, y, z, size, spin)` turns a card to face the camera. `actor_place` is
  unchanged (yaw only).
- **render3d: blended actors - smoke, a shield's bubble, an additive glow.** An `Actor` takes `blend`
  (`ACTOR_OPAQUE` 0, as before; `ACTOR_ALPHA` 1, laid over the scene; `ACTOR_ADD` 2, added to it), `alpha`
  (times the material's own alpha, its texture's included), `soft` (metres of soft-particle fade against the
  scene's depth), `unlit` (base colour x emissive, no light) and `blend_casts`. Blended actors are drawn by
  `r3d_frame` in a pass of their own after the opaque scene and the water and before bloom and the tonemap:
  depth-tested, writing no depth, "over" sorted far to near (premultiplied), additive after, lit with the same
  sun, shadow, sky light and fog as opaque actors (an additive one dimmed by the air rather than fogged), a
  closed shape drawn inside then outside. They cast no shadow by default and are skipped by the opaque, shadow
  and reflection passes. Nothing is made per frame. `packages/ludic.lab/example/blend.ludic` shows them.
- An aspen leaf hangs on a flattened stalk and turns in air a spruce never feels, and the
  kit had no way to say so. `layer_flutter(l, v)` gives a scatter layer a per-leaf tremble:
  the vertex stage offsets each leaf by a phase taken from its own place on the card, so
  neighbouring leaves are never in step, and writes the result out as a varying the
  fragment stage uses to flash the leaf's pale underside as it turns. The flash is the part
  that reads - a still frame of a tremble is a still frame of nothing. One uniform, one
  varying, no extra pass, and every other layer leaves it at zero.

  Also fixes the sway itself, which was measured in METRES: `hgt * hgt * 0.35` is right for
  a 40 cm flower and puts ten metres of sideways into a 14 m trunk, so every tall tree in
  the valley stood bent over like a fishing rod. It is a fraction of the model's own height
  now, so the tip moves a few per cent of the tree whatever the tree is and the base does
  not move at all.
- Anti-aliasing that exists, and a lens for the viewfinder.

  THE SHIPPING DEFAULT HAD NO ANTI-ALIASING AT ALL. The temporal resolve was removed (for
  good reasons - it reprojected water through the surface plane and dragged the mirror image
  behind the camera), the setting's first option went on saying "Temporal", and MSAA defaults
  to one sample. Every machine without DLSS - which is every Mac - drew a frame full of grass
  blades and needle cards with nothing smoothing a single edge.

  FXAA now, in the sharpen pass, because that pass already reads this pixel's neighbourhood
  and runs last on the LDR image. It has no history, so it cannot drag or smear a reflection.
  Measured on edge pixels: 25.5% less single-pixel staircase.

  One trap worth recording. The unsharp mask's delta is computed from the RAW image and only
  then applied to the anti-aliased colour. Taking the centre from the FXAA result and the
  neighbours from the raw texture measures a difference that is half smoothing and half
  signal, so the mask sharpens exactly the edges FXAA just softened - measured, that first
  version was 29% WORSE than no anti-aliasing at all.

  And depth of field, for the photo mode: a disc of taps whose radius is the pixel's circle
  of confusion, signed so the two sides of the focal plane differ and normalised by the focus
  distance, because a lens focused at two metres throws a background out far harder than one
  focused at two hundred. A tap only counts if it is at least as out of focus as the pixel
  it is blurring into, which is what keeps a sharp foreground from haloing into a blurred
  background. It runs between the scene and the bloom so a blurred highlight still blooms,
  and the whole pass is skipped when the aperture is shut - in ordinary play there is no lens
  and this never draws.
- Light you can see: sun shafts, and mist that lies in the valley.

  Everything before this made the air a COLOUR APPLIED TO A SURFACE. Nothing put light in
  the space between surfaces, so a basin at dawn had no shafts, no pooled mist and no rays
  off a ridge at any hour, however the fog was tuned.

  A half-resolution march from the camera to the depth buffer, asking the SAME shadow the
  rest of the frame asks - the cascades, the baked height-field shadow and the cloud mask -
  so a shaft is cast by the actual trees and the actual ridge, and a passing cloud dims its
  own rays. Henyey-Greenstein scattering, because real air throws light forward, which is
  why a low sun fills a valley when you look into it and does almost nothing when you look
  away. Density and a separate ground-hugging MIST layer ride the sun's elevation from
  daylight.ludic, so the mist forms in the cold at either end of the day and burns off by
  mid-morning.

  It composites into the HDR scene with the bloom pyramid's own tent upsample under ONE/ONE
  blending - which is exactly what was wanted and already existed - and before bloom, so a
  shaft blooms like the bright thing in the air it is. Into post_hdr and not post_scene:
  post_scene is the copy the water refracts, and shafts added there would sit under the lake.

  The tuning that mattered was the SKY term. It is added at every step, so at 0.06 it
  accumulated into a flat grey wash that lifted lit and shadowed air by the same amount -
  which is the contrast a shaft is made of. The valley came out as one pale sheet with no
  rays in it. At 0.012 the sun's term dominates and there is light to see rather than fog.

  R3D_NOVOL=1 switches it off for an A/B. Off in Settings skips the pass whole rather than
  marching once, because a feature is off when it costs nothing.

  Measured, 400 frames at 07:00: OpenGL 7.1 -> 7.3 s, Vulkan 7.2 -> 7.4 s. Backends agree
  to 0.08/255.
- One wind, and everything in the valley is moved by it.

  The grass had a gust built from two sines and the trees had NO gust term at all - just a
  per-instance wobble - so the meadow rippled and the canopy above it swayed to an unrelated
  rhythm and nothing ever crossed the valley. A real gust is a WAVE: you watch it come over
  the grass, it reaches you, and it goes on into the trees behind you.

  wind.glsl is prepended to EVERY stage, so the grass's vertex shader, the crown's vertex
  shader and the water's fragment shader read the same field at the same world position and
  cannot drift apart. No uniforms are declared in it on purpose - u_time and u_wind already
  exist in several of those files and redeclaring them is a compile error in whichever stage
  includes both - so the caller passes what it already has.

  Two numbers mattered. The gust's WAVELENGTH has to fit inside a view or nothing is ever
  seen to travel: the first cut was 209 m crest to crest, longer than the meadow you can see,
  so the whole frame sat in one phase and read as everything breathing together. It is 74 m
  now and a front crosses a normal view in a couple of seconds. And `stiff` lets one field
  move a blade a long way and a bole hardly at all.

  R3D_DEBUG_WIND=1 paints the field on the ground, which is the only way to SEE a gust in a
  still: two shots a moment apart show the fronts and show them moving.

  Measured: no cost. 400 frames, GL 6.9 s, VK 7.2 s.
- Rain that leaves something behind.

  Rain fell and the ground did not change: the weather was a curtain of particles in front
  of a dry valley, and a shower was something you waited out rather than something that
  happened to the place.

  One scalar, u_wet, 0 dry to 1 soaked, doing the three things a wet surface does. It
  darkens the albedo. It drops the roughness hard, which is what makes a soaked meadow read
  as SOAKED rather than merely dark - the sky glances off it. And it pools: a wet ground
  does not darken evenly, water finds the low places and the flat ground holds what a slope
  sheds, so the puddle mask is the macro noise the materials already use gated on slope,
  and a puddle takes the world's up for its normal rather than the ground's relief.

  It joins the shore's existing wet band rather than fighting it - the same term, from a
  different cause.

  Measured: 34.1% of the frame changes between dry and soaked, and no cost - GL 7.1 s
  either way over 400 frames.
- The air and the light are the hour's, not one constant apiece.

  Aerial perspective is a curve now. A low sun shines through far more air than a high
  one and shines ALONG the ground rather than down onto it, so density, height falloff
  and forward scatter all ride the sun's own elevation, and overcast thickens the air
  while flattening the scatter. The term that was missing entirely is distance
  DESATURATION: a surface is pulled toward its own luminance faster than the fog itself
  arrives. Without it, blending a saturated ridge toward a saturated blue noon sky left
  a saturated ridge, and a midday frame had a mountain three kilometres off reading as
  vividly as a bench two metres from the camera.

  The grade is the hour's too. White balance, the shadows' floor, contrast and
  saturation were nine literals bound at the draw; daylight.ludic writes them now.
  Noon is the case worth naming: direct sun is warm-white and the only thing filling a
  midday shadow is a blue sky, so noon gets a cool balance over a blue-lifted shadow
  with hard contrast between it and the lit ground, and dawn and dusk get the reverse.
  Gain is deliberately left alone - the grade is `c * gain + lift * (1 - c)`, so it
  warms the whole frame rather than the highlights.

  The visible sky is relit. It is one HDRI turned on its axis so its sun sits where the
  hour wants it, and turning a photograph does not change what colour it was taken at -
  so a sunset had a mid-morning blue overhead. An analytic sky supplies the chroma while
  the photograph keeps the luminance, so the cloud stays where it is and goes orange at
  dusk, and the zenith goes deep blue at noon, with no second sky shipped. It fades out
  under the horizon, where the night's own tint, stars and moon take over, and eases off
  under heavy cloud.

  And the ground bounce follows the ground: the colour a surface is filled with from
  below is the map's now, crossing from meadow to rock at its treeline, instead of one
  green constant everywhere including above the scree.

  R3D_NOAIR=1 restores all of it to what it was, so a before-and-after comes from one
  binary at one hour. Measured at 400 frames: no cost on either backend.
- The phone looks like a phone.

  A 28px rounded body on a dark wallpaper gradient, a transparent status bar, a slim nav pill, and a home grid of rounded-square tiles in eight distinct colours, with the app's first letter as the glyph where it has no icon. Accent is #E8B04A and secondary #7FB2D9; radii, wallpaper and tile colours are all --ph-* tokens, so a game themes them by data.
- The world answers to a body standing in it. `grass_push(x, z, r)` bends every blade
  within a radius away from a point and presses it down, so a walker opens a bow wave
  through a meadow instead of passing through it; `water_wade(x, z, strength)` puts
  spreading rings and a patch of churn into the lake's normals at a point, so a wader
  marks the surface and a swimmer disturbs the whole of it. Both are one uniform each
  (`u_push`, `u_wade`) read in the vertex and fragment stage that was already running -
  no extra pass, no extra draw.
- Things sit ON the ground rather than hovering over it. The screen-space GI pass takes
  a second, much tighter set of taps (a 0.40 m radius that grows with distance, with a
  range check so a far surface behind a near one cannot darken it) and folds the result
  into the ambient occlusion it already had. The wide radius answers "how enclosed is
  this", which a trunk meeting grass barely registers; the tight one answers "is
  something touching here", which is the shadow the eye looks for to place an object.
  It is eight taps on a buffer the pass had already bound.
- Three things a crown and a hand light were getting wrong.

  **An aspen's trunk quaked with its leaves.** `layer_flutter`'s mask was the vertex's
  HEIGHT alone — anything more than 1.2 m up trembled — so on a ten metre aspen the whole
  bole moved, and a tree that is supposed to shiver read as a column of cloth. What
  separates a leaf from a bole is not height, it is distance from the model's own centre
  line: the leaves are out at the edge of the crown and the trunk is on the axis. The mask
  is radial now, and small plants keep the old one, because a flower is all leaf.

  **Foliage in the camera's face.** A third-person camera walks into a crown and the branch
  between it and the body is an opaque wall a metre from the lens; in first person it is the
  whole screen. `#define NEAR_FADE` dithers tree foliage out inside arm's length of the
  camera — in the depth PREPASS, so the lit pass never sees those pixels either and the
  equal-depth optimisation is untouched. `gl_Position.w` is the view depth for a perspective
  projection, so it costs one varying and no uniform. Blades, cards and flowers are left
  alone on purpose: they live at the player's feet, they are always that close, and fading
  them opens a hole in the meadow. Nor is the BOLE ever faded: a trunk and its needle cards
  are one mesh drawn by one program, so the first cut dissolved the trunk into a dither
  pattern as you walked up to it - a solid tree you can see through reads as a fault, where
  a branch getting out of your way reads as the camera being polite. The mask is the same
  signal the quake uses. The shadow pass keeps every leaf, or a tree would stop shading the
  ground it stands on as you walked up to it.

  **A hand light had the reach of a candle, whatever it was meant to be.** `handLight`'s
  falloff was an inverse square windowed off between 26 and 6 metres, with both numbers
  hard-coded: two per cent of its own near field by ten metres out, so carrying a torch at
  night lit your boots and nothing else. `daylight_hand` takes a `reach` in metres now and
  the falloff is a gentle power out to it — about nine tenths at a metre, half at half the
  reach, a tenth at nine tenths of it, nothing past it. A pool of light with a gradient in
  it rather than a hotspot with a cliff.

  **And the wheel on macOS did nothing, or everything.** `scrollingDeltaY` is a double, and
  the Cocoa event pump truncated it to an int PER EVENT before accumulating: a trackpad or a
  Magic Mouse sends a stream of fractions of a line, every one of which truncated to zero, so
  the wheel was dead; a notched mouse sends three to ten lines at once, so it jumped. The
  fraction is accumulated now, a precise delta is scaled from points to notches, and the
  remainder carries to the next frame - one gesture, one step, on both kinds of mouse.
- ludic.anim's studio.lres binds the rig of a graph (`rig_table: "AnimSkeletons"`, `rig_ref: "skeleton"`, `rig_file: "model"`, `rig_node: "root"`, `clip_pattern: "{prefix}_{clip}"`): the studio's animation preview and graph tools play each graph on the skeleton its own `skeleton` names, in every game that uses the package, with no entry of the game's own. Needs a studio with `rig_ref`.
- ludic.anim: `AnimStateDef.duration_by` names a parameter of seconds and plays the state's clip over that time (rate = clip length / seconds, off while the parameter is 0 or less), so a reload clip ends with the magazine whatever the weapon's reload time: a `weapons.RELOAD_STARTED` row with `also: "reload_time"` feeds it. The graph checks the parameter exists (`anim.unknown_param`) and ludic.anim's studio.lres binds the field (`node_duration_by`).
- ludic.anim: a request by name (`anim_request`, a `request` binding row, `crowd.act_key`, `cars.seat_state`) now reaches the states of sub graphs and layers, not only the base graph's. The rule: a plain name searches the base graph, then the sub graphs, then each layer's graph; `layer/state` names a layer by its key, `sub/state` a sub state, segments chain. A request to a sub graph's state also brings the graph above into the sub state that runs it, and the sub graph starts at that state. `anim_link_validate` reads the same rule for `anim.link_unknown_state`. Documented in the README ("A request by name").
- ludic.cars declares signal sources for a rider's graph, so seat and door states are `AnimBindings` rows instead of a game's `CarAnim` port: facts `cars.BOARDING`, `cars.SEATED`, `cars.EXITED`, `cars.EJECTED`, `cars.DRAGGED` whose word is the seat row's graph state (`state_enter`, `state_sit`, `state_leave`, `state_jacked`: per side and seat, so one request-by-name row serves them all), values `cars.riding`, `cars.driver`, `cars.passenger`, `cars.speed`, `cars.steer`, `cars.door`, and the text source `cars.seat_state`. New facts `CAR_BOARDING` and `CAR_DRAGGED`, and `CarFact.word`. README documents the sources.
- ludic.character tells an animation graph more, by name: `character.direction` (the motion's heading against the facing, -1..1 half turns, positive left; real when the game's new `CharacterBody.strafe` makes the body face the camera and move along the stick), `character.crouch` (0..1, from the held crouch, the new `CharacterInput.crouch`, or the existing `CharacterBody.sneaking`), `character.sprint` (0..1) and `character.gait` (0 still, 1 walk, 2 run, 3 sprint). The sprint is a third speed tier, data-driven: `char_config_gaits(crouch, sprint)` (the sprint has no speed, hence no sprint, until a game gives one), `char_sprint(on)` / `CharacterInput.sprint`, `char_crouch(on)` / `CharacterInput.crouch`; queries `body_direction`, `body_crouch`, `body_sprint`, `body_gait`. The README documents every source and range.
- ludic.hints: a card's `priority` (0..9, default 0) orders the cards of one urgency on the rail.

  The rail ranked by urgency and then by registry order, so a card that is true only for a while
  (dusk coming, first light) could never take a place from a standing tip that happened to be
  earlier in the registry. A card now carries a `priority`; within an urgency the higher one takes
  a place first, and equal priorities keep the registry's order, so a registry that sets none ranks
  as it did.
- ludic.render3d: `bw_cut(render3d_st, bw, wx, wz, yaw, hw, hd)` leaves out of the drawn world every instance whose origin stands inside a turned rectangle: a building the game draws itself (an enterable shop with a real doorway and room) and the detail kits on its walls. A cell already in is read again without them; cells that load later never have them. `bw_cut_rect` records one without the reload, `bw_apply_cuts` is the filter a cell's content goes through as it loads (the GPU and the CPU culler both see the cut list), `bw_cut_count` and `bw_cut_out` say how many. The far HLOD proxies are not cut. Tested in bigworld_gpu_test.
- ludic.render3d: `model_from_arrays` makes a Model from vertex, colour and index arrays a game worked out (a decal laid on a wall's triangles, a muzzle's star, a streak), so a game draws a shape of its own through the actor pass without touching a pointer. One primitive in the plain white material; the vertex colour shapes the colour and, for a blended actor, the alpha. `model_set_arrays` fills such a model again in the same buffers with no new memory (a smaller shape than it was made with), so a game that must not grow in play makes its models once and refills them. `model_release` gives one back.
- ludic.ui: arrows in a tab strip, as HTML's `role="tablist"` does them. Left and Right walk the
  `role="tab"` siblings (wrapping), Down from a tab goes to the first focusable control of the panel
  it controls (`aria-controls` names the panel's id; with none, the first control after the strip),
  and Up from that control returns to the tab marked `aria-selected`. Elsewhere the arrows move the
  focus as before.

  A strip inside another tab's panel (Settings' Video pages under its Video tab) walks back out too:
  Up from its tabs returns to the outer strip's selected tab, as Up from any panel's first control does.
- ludic.weapons declares `weapons.armed` (0/1 while a weapon is in hand, so an upper-body layer weighted by it is off once holstered), `weapons.held_kind` (the held class's row order plus one, 0 unarmed) and the text source `weapons.hold` (the class's `hold` name, to request by name). ludic.crowd declares `crowd.variant` (`crowd_anim_variant`): a stable 0..1 per ped from its uid, look seed and the world seed, for a graph's idle choice bands. Both READMEs document the sources.
- ludic.weapons: `weapons_set_mag(weapons_st, h, gun, n)` sets the rounds in a gun's magazine outright, held to 0 .. its capacity, the reserve untouched; refused for no such gun and while that gun reloads. A game that keeps its own inventory (a save read back, a shop that sells a gun loaded) puts back what the magazine held: `weapons_give` always fills it.

### Fixes

- **A `Math.*` call has a type the checker knows.** `Math.max`, `Math.sqrt` and the rest are computed
  inline by the emitter, and the checker gave every one of them the unknown type, which agrees with
  everything - so `dispatch Notify { a1: Math.max(5, n) }` put an int into a string field, passed L4
  and failed in LLVM (`%t63 defined with type i32 but expected ptr`). The checker now gives each the
  type the emitter does: a float or double first argument is that type (`sign` an int); otherwise
  `min`, `max`, `abs` and `clamp` keep the first argument's type, `sign`, `floor`, `ceil`, `round`,
  `posmod`, `wrap` and `ping_pong` are ints and the rest fixed. The bare `min` / `max` / `abs` /
  `clamp` builtins the same. Where the arguments cannot be told, the result stays unknown.
- **A `return` inside an `@On` listener ends that listener, not the whole dispatch.** Listeners are
  compiled into one `@ev_<E>` function, and `return` branched to its exit: every listener declared
  after the one that returned, and every foreign listener, never heard the event. The shape it
  broke is the common one - a listener per kind that returns early for every kind but its own -
  where only the first-declared kind was ever answered. `examples/events/answer.ludic` holds it.
- **A bake reads what was drawn.** `gpu_tex_read_all` (every bake's `bake_pack`) copied a texture on a
  submit of its own without submitting the frame's draws first, so it read whatever the image held before
  them: the sky bake's BRDF table came out all zeros for one light width and right for another, depending on
  whether something else had flushed. It flushes first now, and so does `gpu_tex_write_all`.
- **A chunked table's keys are unique across its map, and not interned.** A row's id is `(map, key)`, so a
  tree moved into another chunk keeps it, and `ludicc --check` refuses a key written in two of a map's
  chunk files, naming both. The keys are no longer interned: interning every key a player walked past would
  have filled the bounded intern table and kept them all for good. A chunk slot keeps its keys in its own
  buffers, rewritten in place when the slot is refilled; `intern(row.key)` keeps one past `_out`.
- **A component's first showing, and a screen's pool growing past its most, are loads to the alloc fence; a pool grows
  by stretches.** Reading a template and its styles, a screen's first two builds and a pool reaching a new high-water
  mark are bounded growth, but in a session that opens something new every few seconds they rose six windows in a row
  and the fence ended the run as "declared but unbounded" (`tpl_read`, `sel_new`, `ui_kept`, `value_new`, `mm_join`,
  `bd_pass_down` at frame 4199). `uc_load`, `pl_new` and every pool miss now call `Mem.rewarm()`, as a trip starting
  does; a pool's Values, scopes, passes and made lines grow by a stretch (half again, 16 at least) as its nodes did, so
  a screen reaches its most in a few loads rather than one per Value (166 loads in a driven session's first 4500
  frames, where one a Value made 1300, and then only when a screen is first opened); and a pooled node is made with room in its lists (16 children, 8 classes, attributes
  and values; a scope 8 names), so an element taking a pooled node later grows none of them. A visit to a screen already
  shown is judged as ever: a lab control keeping 64 declared bytes every 300 frames is still reported within 6 windows.
- **A compressed texture is never drawn into.** On Vulkan, binding a texture to a sampler by name
  did not make it the bound texture, as it did on OpenGL, so a following `gpu_tex_param` or
  `gpu_tex_mips` acted on whatever was bound last. The water's reflection asked for its mip chain
  that way and, once kit textures came as BC7 (23.3), built one into a kit texture: MoltenVK blits
  through a render pass, and Metal aborted ("BC7 is not color renderable"). Binding for a sampler
  now binds, as OpenGL's did; mip generation leaves a compressed texture alone (its levels came with
  it); and a pass that would have a compressed image as a colour attachment leaves it out and says so.
- **A count in the hole of a made line is no longer kept once per count.** `i18n_made` makes a line for a caller that lets
  it go, but an argument that held a key or a bracket - a game's step and its count, "Catch 5 trout  ({count})", where the
  count is itself a bracketed `fmt.count_of` line - was made by `L` through `km_kept_arg`: the argument's string kept for
  good in `ka_s`, and its text in `L`'s cache, for every count a HUD ever showed (the fence's "declared but unbounded" at
  `keyed_buf.ludic` `km_kept_arg` and `nest.ludic` `kx_flat` / `kx_strip`). Inside `i18n_made` such an argument is now made
  the same way and let go once written (`km_made_arg`); `L` keeps what it makes as before. Five hundred counts of a step
  made through the maker kept 1000 lines and 500 arguments; now none (`tests/made_args_test.ludic`).
- **A crowd no longer allocates in a frame.** `ludic.crowd`'s `cw_move` asks the grid for the peds within 1.6 m, and `tb_within` / `tb_within_of` pushed into the caller's list with a bare `push`, so the first cell that held more peds than the list ever had made the list grow mid-play (`alloc-fence: grid_within_cell ... grow`, exit 86 in a game that never called `crowd_reserve`). `crowd_build` and `crowd_budget` now size the ped pool, the maps, the grid and every query list for `max_peds` themselves (`crowd_reserve` is still there and no longer needed), and the grid's within queries fill the caller's list as a kept list that grows to the most an answer has held and stays. A regression test puts every ped into one cell for 3000 frames under the alloc fence.
- **A dev link session no longer blinds the alloc fence.** A request that grew the process heap was taken as the
  fence's new floor (`Mem.play()` + `Mem.settled()`), and the heap moves with every other thread's allocations (Metal,
  the driver), so 230 of a driven session's requests in 12000 frames re-floored it - each one resetting every declared
  site's rising streak, so "declared but unbounded" could never be said in a session driven over the link. Now only a
  request that kept memory the fence counts (`Mem.kept()` rose while it was answered: a model's JSON, a path, a reload)
  re-floors; one that kept nothing, or only moved the heap, leaves the fence alone. `tests/devlink_fence_test` adds a
  request whose memory is declared: the heap grows and the fence is not settled again for it.
- **A dispatched action no longer allocates a record each time.** `dispatch A { ... }` made a fresh
  record for the queue, and Ludic frees nothing, so a system dispatching every frame (an input's
  `Move`, a frame's time) grew the program by a record a frame. The queue now keeps a list per
  action: a dispatch takes the next one (making one only when all are queued), fills every field
  as `new` would - given, or its default - and `drain_actions()` hands them all back once the queue
  is empty. A reducer reads its action only during the drain, so nothing sees a record after it is
  reused; keep what must last in the state, not the action. `ludic.base`'s `actions_test` holds a
  reused record getting its defaults back.
- **A distance a HUD shows is no longer kept once per value.** A game's bracketed line (`txt_line`: a key and its
  holes wholly between bytes 29 and 30, "42 m", "mule deer, 62 m") shown as an element's text went to the translator,
  and `L` kept one made text per distinct line - two cache entries and their strings for every metre walked - until
  its 4000-entry cache was dropped whole and began again, so a player's session grew without end (the fence's
  "declared but unbounded" at `kx_flat` / `kx_strip`). ludic.ui now makes such a line through the program's maker
  (`md_holes` sees the bracket) and holds it while it is shown, and `i18n_made` makes it by its key (`kx_whole_key`,
  then `km_text`) with nothing kept. Five minutes of wandering made 19 + 5 distance lines through `L`; now none.
- **A frame that draws more than any before no longer grows the heap on the Mac.** MoltenVK's command
  pooling kept every command object a frame had ever recorded - about 650 bytes for each draw beyond the
  busiest frame so far, for as long as the game ran. render3d turns it off
  (`MVK_CONFIG_USE_COMMAND_POOLING=0`, unless the environment already says otherwise) before the first
  Vulkan call; the objects are made and freed with their command buffer, at no measured cost.
  `examples/rendering/steady.ludic` ramps a frame from 20 to 200 actors and fails on what pooling left.
  A buffer written through its mapping is also read once at the start of the next frame's commands,
  so MoltenVK makes its Metal buffer then rather than at its first draw, however much later that is.
- **A function named like a built-in a call always takes is refused.** `function words(st, k)` compiled,
  and every call to it became the built-in `words(n)` - n zeroed ints, with a pointer for n - and LLVM
  refused the IR far from the cause. A top-level function whose name a call always takes as the
  compiler's own (`words`, `keep`, `print`, `save`, `load`, `key`, ...; the table is
  `selfhost/check/check_builtins.ludic`, held to `emit_call` by `ludic-dev syntax --check`) is now an
  error at its declaration, as `run` already was. Every other built-in (`buffer`, `floats`, `double`,
  ...) yields to a function the program declares, in the checker as it already did in codegen.
- **A function named like an engine namespace method's target is refused where that method is
  called.** `Random.range` is `rng_range`, so a package's own `rng_range(a, b, c)` silently took
  every `Random.range(1, 6)` (and the checker then asked for its third argument). It is now an error
  naming the function, the namespace method and the call.
- **A generic function called from a `test` block works.** Test blocks were never type-checked, and
  the checker is what makes a generic call real, so `q_new()` inside a test was "unknown function".
  They are checked like `entry` now - which also means a type error in a test is reported.
- **A handle, a model and an actor let go come round again.** A texture or buffer freed gives its id
  back and the next one made takes it, so the per-handle lists stop growing; `model_release` frees a
  glTF model whole (its primitives, meshes, names, skeleton) and takes it out of `gltf_cached`'s
  cache; and `actor_release` takes an actor off the stage and keeps its record for the next
  `actor_new`. `examples/rendering/steady.ludic` holds 2000 actors placed and released at 0 bytes.
- **A key used only in a listener counts as used.** The key check walked the program's declarations but
  not the bodies kept beside them - `@On` listeners, the lifecycle hooks, tests, computed fields and
  scenes - so a key used only there was never checked against en.po and `ludic schema` listed it
  unused. They are walked now, as every other pass walks them.
- **A line with a line bracketed in it, made for a caller, keeps nothing.** `i18n_made` handed a line such as
  "[E / L click] Pick up firewood" or "Open your stash ([0/40])" to `L`, which kept the whole line and every count
  inside it once per distinct text, so each prompt a player aimed at and each count it showed stayed for good
  (`kx_flat`, `kx_strip`, `km_kept_arg`: the alloc fence's "declared but unbounded" in a long session). Now such a
  line, and a key glued to words, is written into the kept buffer a piece at a time - each bracket made the same way and
  let go once written - and handed back as the one string it makes; `i18n_let_go(s)` lets a caller that only reads it
  (a HUD splitting its prompt) give it back. `i18n_cached` says how many lines `L` keeps. `tests/made_test`: fifty
  prompts made and let go leave `L`'s cache as it was.
- **A line with holes a screen shows is let go once it is not shown.** A HUD's `t('fmt.percent', n)`
  or a marked "mule deer, 62 m" was kept for good twice over - ludic.ui's memo kept the marked line and
  its Value, and ludic.i18n's `L` kept the made text (with a list of arguments and their pieces made on
  the way, never given back) - so every value a meter or a distance passed through stayed, about 3 KB a
  600 frames at an idle camp, and the alloc fence ended the run as "declared but unbounded". Now
  `ui_maker(f)` gives ludic.ui a maker that hands back a NEW string and keeps nothing
  (`i18n_made`), and while a screen is built a t() with holes, or a marked line with holes as an
  element's text, is made through it and held by the screen's pool like its nodes: let go (`free`)
  once two builds of that screen pass without it. A memo now keeps its own copy of the text it is keyed
  by. `L` makes a key into a kept buffer (`keyed_make.ludic`), so a miss costs the one string it keeps;
  an argument that holds a key is kept once per distinct text. `ludic.ui/tests/ui_made_test` shows
  fifty values made and at most two held; `ludic.i18n/tests/made_test` that `i18n_made` makes what `L`
  makes.
- **A misspelled type is refused where it is written.** `function kind_of(f: CharFact)` for a
  `CharacterFact` used to be accepted and fail in the code writer as "member access on non-aggregate",
  far from the typo. A capitalised type in a parameter, a result or a field (plain, in a slice, or as a
  generic's argument) must name a declared property, record, state, event, enum or action, or a type
  parameter of its declaration: `kind_of's parameter f: there is no type CharFact`.
- **A name that meets a package's export says whose it is; ludic.ui's `UiAct` is its own.** A game's
  `UiAct` collided with ludic.ui's, which no program uses - it is private to ludic.ui now, so the game
  may have one. A real clash - a type named like one a package exports - is still refused, and the
  message names the package and the way out: `'UiNode' is defined twice (...): ludic_ui exports it, and
  exported names are one namespace - rename this one, or declare it without export inside a module of
  your own`.
- **A photograph keeps no memory of its own once the roll is made.** `photo_keep` pushed each frame's tags and
  file onto two lists that grew with the roll (+64 B twice a shutter, a "grow" the alloc fence ended a run for), and
  `photo_remove` made two new lists each time and gave none back. The roll now holds a slot per frame, filled with ""
  when it is made (the way its other columns are), `photo_add` writes the slot and `photo_remove` closes the gap in
  place.
- **A renderer that cannot draw says so and stops.** A `LUDIC_HOME` handed over with its `~` unexpanded
  (`env LUDIC_HOME=~/x`) left render3d without its shaders: "vulkan cannot start" was printed, and the run
  went on, logging "no SPIR-V variant" for every program - a world with no terrain, shadows or impostors.
  Now `r3d_home` puts a leading `~` under `$HOME`; the SPIR-V manifest ends with `E <count>` (written by
  `ludic-dev shaders`) and one without it, or miscounted, is refused; and every such failure is a fault
  (`gpu_fault.ludic`): `r3d_open` and each `r3d_load_step` return false on one, a program with no variant is
  listed, and a game asks `r3d_fault()` and ends with `r3d_fault_exit(code)`, which prints the reason and
  every missing program. `tests/manifest_test.ludic` holds the parse, the refusals, `r3d_tilde` and that
  every program in variants.list resolves in the shipped manifest.
- **A screen opened for the first time in play no longer fails the alloc fence.** ludic.ui's pools grow to the most a
  screen has needed and stay, and their nodes, scopes and passes were declared (`@alloc_ok`), but the Values they hold
  were not: the first opening of the pack in a judged run ended it (`value_lists` / `value_add` from `uv_new` /
  `ev_call_with`, exit 86), and so did the first map opening (`value_new` from `uv_float`). The Value a pool or the call
  ring grows by is now made by `ui_kept_val` (declared); the runtime's Value containers declare their room
  (`value_lists`, `value_add`, `value_put`), a kept list's items past its most (`value_item_new`) and the JSON encoder's
  one buffer (`jo_room`) - each a high-water mark, still judged as "declared but unbounded" if it keeps rising. And a real
  leak under it: a pooled Value a call answered a list into (`value_into_ints`) lost its items whenever the pool handed
  it out as something else, so every opening of a screen made them again - eight Values, for good. A list now marks
  the items `value_item` made as its own (`VL_OWNS`), keeps them as spares when it is turned to another kind or cut
  (`value_become`, `value_into_list`), and a list of another's Values (`value_add`) is emptied, never turned.
  `ludic.ui/tests/ui_value_reuse_test` turns an eight-item answer away and back 500 times: the heap grows 0. A run that opens and closes the pack, craft, map, journal, pause and settings 100 times
  under `R3D_ALLOC_FENCE=fail` keeps nothing.
- **A session driven over the dev link keeps nothing, so it no longer fails the alloc fence.** Every `shot` made its
  path into a new text that nothing let go, and an editor names every shot afresh (`ludic-studio-shot-<pid>-<n>.ppm`):
  since only a request that keeps memory the fence COUNTS re-floors it (`devlink-floor-kept-only`), these declared
  texts rose window after window until a QA session failed with exit 86, "declared but unbounded" at `text_of`
  (reproduced headless: fresh-path shots every 3 s fail at frame 4200; a reachability scan finds the old paths
  unreachable). Now a request's texts are the request's (`made.ludic`): a string argument or an `ui_override` path is
  made when its request is read and let go (`free`) when the next one is, and a shot's path when the next shot is
  taken. The per-distinct-word cache (`DL_WORDS`, `dl_words`) is gone with it: it was bounded, but an agent asking
  about ever new components or keys still rose under the fence. **The contract for a port member or a declared verb:
  a string it is handed lives for the request (a shot's path until the next shot) - copy it to keep it**, as
  `map_load`'s `keep`, ludic.ui's `ui_override` and `Input.type` already do. `tests/devlink_texts_test`: 296 shots
  with fresh paths grew the heap 14208 bytes before and 0 now; 396 requests of a word never sent before 8320 and 0.
- **A streamed world's reads give back what they make** (`ludic.render3d`, `ludic.city`). A long drive over a city tripped
  the allocation fence ("declared but unbounded", exit 86) after about a minute: every cell read kept its path, its file's
  bytes and its content after the content was copied into the instance arena (`cell_load`, `bw_load`; a proxy likewise,
  `hlod_load`), every wet-mask, land-use mask and hole-bit tile read kept its path (`wet_read`, `tmk_read`,
  `tm_holes_read`), every PNG decode kept its job record (`png_decode`), a chunk of building colliders kept its path and
  bytes (`city_colliders_in`), and the instance arena's free list grew in a frame as it fragmented. Each is given back
  now (`cell_content_free`, `hlod_mesh_free`), the arena's lists get their room once (`kar_reserve`, called by
  `kgpu_new` for its cells), and `gltf_file_exists(dir, file)` asks for a file without the caller making its path.
  `tests/stream_leak_test.ludic` reads each 200 to 300 times and expects the heap not to grow.

  **The terrain draw makes nothing in play** (`tilemap_draw.ludic`). Every patch slot's mesh, model and primitive records are
  made once with the draw (`tmd_new`); a change of level gives the old level's buffers back and uploads the new one into the
  same records (`tmd_fill`), so the memory no longer rises and falls with the patches in view. A walk across the gym's tiles
  and a drive into new ground had it rising window after window until the fence failed the run ("declared but unbounded" in
  `tmd_model_of` and `gpu_mesh_new`).
- **A string made in the middle of an expression is freed once it has been used.** `a + "/" + b` made
  `a + "/"`, copied it and kept it for ever; a template made one such piece per hole, plus each
  number's text; and a side of `==` built only to be compared stayed too. The compiler now frees each
  of those as soon as the next `+`, the comparison or `print` has read it, and `string(n)` hands back
  the start of what it allocated so its text can be freed at all. A string held anywhere - a
  variable, an argument, a function's result - is left alone. A loop of 20,000 template builds grew
  2.9 MB and now grows 0 (`examples/lang/string_temps.ludic`).
  A slice of a string (`s[a .. b]`, always a copy) counts too: `path[0 .. n - 4] + ".dds"` and
  `path[n - 4 .. n] == ".png"` no longer leave the slice behind.
  `Os.heap_bytes()` reads malloc's live bytes (macOS; 0 elsewhere) with no renderer linked in, for a
  test that a path allocates nothing.
- **A template literal inside another's `{…}` hole, and integer literals past 2^31 - 1.** The first
  crashed the compiler (the outer literal ended at the inner one's backtick); a hole is now read as
  code, so strings, chars and templates inside it are taken whole. The second was read as a wrapped
  negative int; a decimal literal past `2147483647`, or a hex one of more than eight digits, is now a
  `long` with its value, and giving one to an `int` is refused. Eight hex digits or fewer are still a
  32-bit pattern.
- **A template of one string hole is a new string.** `` `{s}` `` was `s` itself (`str()` passes a string
  through), so code that wrote it as a copy kept a pointer it then freed - ludic.ui's rule text named
  whatever reused the bytes. It now copies, where a template with any other part already made a new
  string; `str(s)` still passes through. No template in the game or the packages had a string as its lone hole.
- **A test program may hold a phase handler.** A program with `test` blocks and a `handler ... phase`
  (its own, or one a module it imports declares) failed to compile with LLVM's "use of undefined value
  '@rt_init'": the test runner called the runtime's `rt_init` whenever the program had systems, and a
  handler alone makes none. It now calls it only when it exists, as an `entry` program's `main` does.
- **A texture made and freed leaves nothing behind.** Making a texture's image once kept four small
  Vulkan create-info buffers, and a texture loaded from a .png kept the .dds path it looked for
  beside it; both are given back now. `examples/rendering/steady.ludic` holds a glTF model loaded and
  released at 0 bytes, and reads a frame's growth as the least of three windows after the device is
  idle, so a busy machine beside it does not fail it.
- **A validation run sees the game's MoltenVK.** With a layer asked for, the loader was pinned to
  ludic.render3d's MoltenVK only when the shell named no driver - but the SDK's setup-env.sh exports both
  VK_DRIVER_FILES and VK_ICD_FILENAMES at the SDK's own MoltenVK, so a shell with one left set loaded that
  one beside ours. The pin now overwrites VK_DRIVER_FILES and clears VK_ICD_FILENAMES; R3D_VK_ANY_DRIVER=1
  keeps the shell's driver for a run that means to try another.
- **A windowed program's input no longer stops it on the first frame.** Since slices carry their
  length, the window's built-ins (`win_held`, `win_mouse`, `win_pad`, `win_touch`, `win_text`,
  `win_present`) were handed the slice's header instead of its elements, so the platform wrote the
  mouse position over the length and the next read failed its bounds check. They take the elements,
  as an `extern` call already did.
- **Ambient occlusion no longer draws the ground's triangles.** The occlusion and contact passes (`ssgi.frag`) take a pixel's normal from the depth, so on a ground of 1 m triangles curved by a few degrees from one to the next, a sample taken across a triangle's edge was covered by the neighbouring triangle and the near side of every triangle came out darker: a pattern of the mesh in smooth ground, in sight at close range on any gentle slope. A sample now has to be behind the surface by more than four tenths of its sideways distance (about 22 degrees) to count, so creases (a wall on a floor, a step) keep their occlusion and a curve of a few degrees has none. Only the compiled `ssgi` fragment stage changes.
- **An `IntMap` whose keys come and go no longer leaves two arrays behind each time it sweeps.** When deleted keys filled an `IntMap` (ids that never repeat: a crowd's actors, a pool's uids), `imap_put` rehashed into a freshly allocated pair of arrays, the old pair never given back, so a map that churned ids allocated every few hundred spawns for ever. The sweep now goes through scratch arrays made once per size (and by `imap_reserve`), and only a real doubling allocates. Regression test under the alloc fence.
- **An action a UI button dispatches is reduced before the frame is presented.** ludic.ui runs a frame's
  presses after drawing it, and an action they dispatched waited for the end of the phase - after the
  host had presented - so what the button changed showed a frame late. `ui_show` and `ui_press` now
  drain the queue once the presses have run. A host that runs presses some other way calls
  `drain_actions()` before it presents.
- **An attribute before `export` is kept.** `@ToClients export event E`, `@Sync export property P`,
  `@Owned export model M` and the rest lost the attributes written in front of `export`: the parser read
  them, then parsed the declaration afresh and forgot them - so an exported remote event was silently
  local; and `export @ToClients event` was refused outright. Attributes and `export` now read in
  either order into the same declaration.
- **An editor's live link no longer fails the alloc fence, and a repeated request makes nothing.** A dev or headless
  run driven over `ludic.devlink` died with exit 86 the first time a request kept memory once judging had begun - a
  `ui_model` (the JSON encoder's buffer, a model list's items), a `shot` (its path), a reload - although none of it is
  a player's. A request that grows the heap is now taken as the fence's new floor, as a load is (`Mem.play()` +
  `Mem.settled()`, the rule the game's regrow verbs carried by hand), and the rest of that frame is judged as ever; a
  request that keeps nothing leaves the fence alone. And so that driving a game (`key "w" "down"`, `look`, `step`,
  `ui_model "Hud" "<out>"` again and again) keeps nothing, a string argument is made once per distinct text
  (`DL_WORDS`, 256) instead of once per request: 200 repeated requests grew the heap 6400 bytes, now 0.
  `tests/devlink_fence_test` holds both: 40 keeping requests over 2000 judged frames fail none, and repeats make nothing.
- **An element's text with a line bracketed in it is made and let go like a line with holes.** "[E / L click] Pick up
  firewood" shown as an element's text went to the translator, which kept one per distinct line; while a screen is
  built it now goes through the backend's maker (`md_holes`, `md_nested`) and is held by the screen's pool, let go two
  builds after the last that showed it.
- **CI bootstraps the toolchain again.** The toolchain's own programs keep module-level vars, which a
  plain compile now refuses; the bootstrap in `ci`, `bootstrap`, `docs` and `release`, `install.sh`'s
  from-source install and `ludic`'s hint compile `tools/ludic-cli/dev.ludic` with `--unsafe --globals`,
  as COMPILING.md already says.
- **Every program render3d can ask for is compiled.** heightgen with no survey and with SMOOTH were never in
  variants.list, so a smoothed or noise-only terrain (examples/rendering/chunks, smooth, reload) had no
  height field on Vulkan - silently until render3d's faults were made loud. Both are compiled now (61
  programs). A program's run-time defines are pure functions in program_defs.ludic (the height field, the
  ground's tiers, the blades), and tests/manifest_test reads every r3d_program / gpu_program / ac_prog_new call
  in render3d's source, holds each literal one and every value of each computed one to the shipped manifest,
  and fails a new computed call site until it is given its function.
- **Four guards an editor and a game asked for.**

  - **Two registries with one prefix say so.** Two registries that both say `as DRK` both make
    `DRK_COUNT`, which was already refused as `'DRK_COUNT' is defined twice (first in ...)`; the
    message now names both registries and the prefix they share (`registries DrinkSteps and
    DrinkRules both say 'as DRK' - give one of them a prefix of its own`), and a const written by
    hand that meets a registry's says which registry made the other.
  - **`@Asset("kind", optional)` needs no `map`.** A path under the game's root may be optional too;
    it changes nothing the compiler checks and tells an editor that a row may leave the field empty.
    `@Asset("kind")`, `@Asset("kind", map)` and `@Asset("kind", map, optional)` are as they were, and
    `map` still comes before `optional`.
  - **`ludic schema` lists a package with no module line.** `code.modules` names it for its folder
    (`ludic_render3d`), with its files, as `ludic deps` already did, so an editor reading the schema
    no longer has to mirror `pkg_name_of`.
  - **A handler's body is type-checked.** The checker read a function's body, the entry, the tests and
    the listeners, and left a handler's to the emitter, so a call from a handler that left out an
    argument or a state, gave one too many, or a `let s: string = 3` compiled (a left-out state
    arrived as null). A handler is checked as a function is now; a C function called from one wants
    `--unsafe` like any other (L7). Three examples that did arithmetic on a `bool` or a `countdown`
    say `int(...)`.
- **GPU-culled trees no longer draw in garbage colours on Vulkan.** A shader input a mesh does not feed (`a_col` on a
  model with no COLOR_0, which since the vertex-colour change is every kit tree) read a shared buffer of zeros bound per
  INSTANCE at 16 bytes each, 64 KB in all: room for 4096 instances. The GPU-culled scatter layers draw each LOD bucket
  from `firstInstance = level x layer count`, so on a layer of 2538 trees everything from the middle of level 1 on read
  past the buffer; MoltenVK does not bound vertex fetches, and the mid-distance conifers drew magenta, blue and green.
  The zeros binding now has a stride of 0 (`GVK_ZERO_STRIDE`): every vertex of every instance reads the first vec4,
  wherever a draw's instances start, and the buffer is 256 bytes. `R3D_GPU_CULL=0` had always drawn them right.
  `tests/zero_feed_test` holds the stride and that the last bucket of a large layer reads inside the buffer.
- **One MoltenVK in a process.** On a Mac with the Vulkan SDK installed, the runtime opened the SDK's loader
  (/usr/local/lib/libvulkan.1.dylib) before MoltenVK, and the loader loaded the SDK's own MoltenVK as its
  driver - beside ludic.render3d's, which every program is linked against: two copies, each with its pools,
  and the program drew through the SDK's ("MVKBlockObserver is implemented in both"). MoltenVK is opened
  first now (dlopen hands back the linked copy), and the loader only when a layer is asked for
  (VK_INSTANCE_LAYERS, VK_LOADER_LAYERS_ENABLE, R3D_VK_LOADER) - then pinned to ludic.render3d's MoltenVK
  through VK_DRIVER_FILES and lib/macos-arm64/MoltenVK_icd.json, unless the caller named a driver.
  examples/rendering/steady.ludic's stream round warms up over 300 cells and takes the least of three
  windows of 150, as the frame round does: one sample of it read +75 KB on a run whose twin read -5 KB.
- **Random.* works in any program, and the value tree comes in when `value_*` is called directly.**
  The seeded random numbers lived in the ECS runtime, so a tool or a program made only of `test`
  blocks got "unknown function rng_range"; they are their own runtime file now, spliced on demand
  (and imported by the ECS runtime for a game). A package calling `value_get` or `json_encode`
  itself, without a `Value.*` / `Json.*` anywhere, now gets the value tree too.
- **Spawning and despawning actors no longer leaks.** `ludic.vitals`' `vitals_remove` never gave an actor's `Vital` record (about 6 KB with its three pool lists) back, so every embodied ped cost that for good and the dev alloc fence named `vt__make` unbounded (exit 86 about 38 s into a Meridian run). Records now go to a free list that `vitals_add` reuses, a downed or dead one brought back to Alive by a new `VitalsRecycle` action of the phase machine (rows `recycle_downed` and `recycle_dead`). A state starts with `max_actors` records (new `VitalsSettings` registry, row 0; default 128) and `vitals_reserve(n)` makes room for more before play, with the table rows and the actor map. Handles are unchanged: the slot's generation moves on at a remove, so a stale handle misses. `vitals_reset` keeps the records. Regression tests spawn and despawn 15000 actors under the alloc fence.
- **Streaming new ground allocates nothing.** A streamed layer's cache made a record and a copy of
  its instances for every chunk the camera found, so the heap grew for as long as there was ground
  nobody had stood near - a boat drifting across the lake grew it every frame it crossed a cell. Each
  stream now makes its whole cache when it is created: a record per chunk it can keep and an arena of
  twice what its layer draws, compacted in place when it evicts. Replacing the world
  (`stream_clear_all`) now gives every record, list and stream back. `examples/rendering/steady.ludic`
  crosses 300 new cells with eviction running: 156 KB before, 0 after, every kept chunk still its own.
- **Text keys below a row, padding, and `tr`'s cast.** A `@Text Key` in a record nested in a registry
  row (and in each item of a list of them) is filled with its derived key, `<registry>.<row>.<field>.<i>.<field>`,
  as a top-level one is, and a `@Text []Key` a row leaves out takes `<...>.0`, `.1`, ... for as many as
  the source `.po` has - so no `.lres` spells a key. `field: null` is no text. `trf` / `trn`'s trailing
  `""` arguments are padding and not counted against the English's holes. And `string(x)` of a string or
  a `Key` is no allocation to the escape analysis: it is `x` itself, so a `tr(key)` that returns it
  passes `arena strict` (a template's lone hole still copies).
- **The Vulkan renderer no longer leaks memory as it loads and draws.** Every texture upload
  malloc'd a CPU copy of its pixels and never freed it (236 MB over the valley's boot, and again on
  every model loaded later); the pixels are now converted straight into the mapped staging buffer.
  The per-level and per-layer views made for mipmapped and layered targets outlived their texture,
  and on MoltenVK a view keeps its Metal texture alive, so every rebuild of the screen-sized targets
  left the last set in memory; a released texture now takes its views with it, and the cache is
  keyed by numbers rather than a string built on every call. The Vulkan structs filled for a draw, a
  pass, a barrier, a descriptor set or a buffer (about sixty call sites, several per draw) come from
  a reused 1 MB scratch ring instead of a malloc each; the descriptor-set cache and the retired
  buffer list are emptied and refilled rather than replaced; and on macOS the frame drains an
  autorelease pool (`Vk.frame_pool()`), which MoltenVK and the layer rely on. `R3D_VK_PROF` now
  also prints, every 120 frames, the Vulkan objects made and destroyed by kind and the length of
  every cache, so a kind made each frame and never destroyed shows at once.
- **The action drain is the program's; `--check` is every check; `count` is not a registry key.**
  The function that calls every reducer is written in the program's own file, so the module that
  declares the actions no longer depends on every module that reduces them (a game's `base` joined a
  69-module cycle). `ludic build --check` runs the code writer's checks too - a bind to a function that
  is gone, an unknown name - and still writes nothing. A registry entry keyed `count` is refused
  (`def Tools count: its constant would be TL_COUNT, which is the registry's size`). And a big
  program builds much faster: the emitter's and the checker's lookups by name are tables, not walks of
  the whole program (on Maroon Lake a check-only build, lowering included, went from about 20 s to under 10 s, its IR from about 2 minutes to under 10 s).
- **The alloc fence has a documented scene boundary.** A game that builds its world after a long idle screen (a launcher past `R3D_ALLOC_WARM`, 600 frames) is already being judged, so the world build's one-time allocations failed the run (exit 86) at the first world frame. No runtime change was needed: after the build, call `Mem.play()` then `Mem.settled()`. `Mem.play()` while tracking re-arms the warm-up and the frame is not judged; `Mem.settled()` re-baselines at once, so the build's kept memory is the new floor and a real leak after it still fails at its own frame. Mem.play() alone also works, but the fence then stays blind until 600 frames in a row keep nothing or the R3D_ALLOC_WARM_MAX (3000) deadline from the first play, and for at least R3D_ALLOC_REWARM (120) frames after the call; the pair is the deterministic form. `examples/lang/alloc_fence_scene.ludic` and its case in `tools/ludic-cli/test.ludic` prove both.
- **The alloc fence no longer reads declared bytes as a release.** `Mem.kept()` and the frame judge subtracted the declared (`@alloc_ok`) growth from the live count, which never held it, so a frame that made only declared memory reported a negative `kept` (-3360) and `alloc_fence_declared` / `alloc_ok_private` failed. A merge had put back lines that "declared bytes are never judged" had removed; they are removed again and the seeds regenerated.
- **The compiled vertex shaders no longer remap clip depth twice.** The storey-lines change regenerated `shaders/spv/` with a `ludic-dev` built before reversed depth, whose shader step still appended `gl_Position.z = (z + w) * 0.5` to every vertex stage: with the projections already in Vulkan's 0..1 range that put every depth the scene wrote into 0.5..1, so everything that reads the depth buffer back (the water's depth tint and shores, ambient occlusion, depth of field, the volumetric light) reconstructed positions that were not there, and the shore lab's water checks failed (11 of them). All of `shaders/spv/` is rebuilt with the current `ludic-dev` (`ludic-dev build` first, then `ludic-dev shaders`); the water drawn over tile ground reads its bed again. Rebuild `bin/ludic-dev` before regenerating the shaders on a checkout older than this.
- **The foliage's near-fade programs have SPIR-V.** The three `NEAR_FADE` variants were missing
  from `variants.list`, so on Vulkan the trees' and cards' programs failed to build.
- **The most negative int is emitted as itself.** The compiler's `itoa` negated a negative value before
  taking its digits, and `-(-2147483648)` overflows back to itself, so a literal such as `0x80000000` in an
  int (`b & 0x80000000`) was written into the IR as a bare `-` and the build failed in LLVM. The digits are
  now taken off the value as it is. Needs a reseed to reach `bin/ludicc`.
- **The roll's order and its page are made at their room.** `photo_order` and `photo_page_list` refill two kept
  lists every frame the Photos tab is up; made empty, each grew whenever the roll held more frames than ever before, and
  the alloc fence failed the run there (`photo_order`, `photo_page_list`, exit 86). They are made with room for 256 and 8.
  `tests/photo_test`: a roll of 40 filled and paged grows the heap 0 bytes.
- **The runtime's text builtins keep nothing a call does not hand back.**
  - `Log.*` builds nothing below the threshold (as documented) and frees the line it writes; a number
    field's text and a made message go too. A `Log.debug` in a frame loop left its line every frame.
  - `DateTime.format` frees each field's digits and each piece joined so far.
  - `Input.text()` writes the typed text into one buffer instead of joining a string per character.
  - `Path.stem` / `Path.normalize`, `Mime.of` / `Mime.sniff`, `Fs.write_text` / `copy` / `mkdir` and
    `Os.save_dir` / `config_dir` / `cache_dir` free their working copies, on every way out.
  - Every string `Text.*`, `Path.*`, `Mime.*`, `DateTime.format` and the `Os` directories return is
    fresh, so a comparison, a `+` or a `print` that reads it frees it; a string made for a `Text` call's
    argument (`Text.to_int(string(n))`) is freed once read.
  `examples/lang/runtime_temps.ludic`: 20,000 rounds grew 19.8 MB before and 0 after; 200 rounds of
  file work 64 KB before and 0 after.
- **The toolchain's suites run on Linux again** (CI's runner):

  - **The alloc fence no longer crashes off macOS.** Its heap scan called `malloc_size` without
    checking it was there, and its native-counter lookup passed macOS's `RTLD_DEFAULT` (-2) to glibc's
    `dlsym`, where it is 0. On glibc the fence counts the bytes asked for. The Vulkan loader's heap
    reading (`lvk_heap_bytes`) is 0 there instead of an unresolved symbol.
  - **`Fs.list` reads glibc's `dirent`** (the name at byte 19, not macOS's 21). It returned an empty
    name for `.`, and `ludic fmt --lint` walked `dir/` until it ran out of memory.
  - **`ludic build` and `ludic test` pass framework flags only on a Mac**; Linux's `ld` refused them.
  - **`ludic test` skips a test that cannot link for want of a native library**: the compiler writes
    `; ludic-native-missing: <package> <target>` for a package that names native libraries but none for
    this target, and the report says `skip <file>  (<package> has no native library for <target>)`.
    Off macOS, a link that lacks only macOS's own runtime (the window layer, Http, the crash
    layer) is skipped the same way.
  - **`ludic test <dir>` runs only the files with a `test` block**; a `*_test.ludic` module a test imports,
    or a checker program run by hand, is no longer compiled as a test of its own.
- **Vulkan's host allocations can be counted, a pipeline built in play keeps nothing, and actors come
  from a pool made at start-up.** With `R3D_ALLOC_VK=1` render3d hands one set of
  `VkAllocationCallbacks` to every create and destroy; the runtime counts live bytes, the peak and
  bytes per allocation scope (`lvk_ac_bytes`, `lvk_ac_peak`, `lvk_ac_scope_bytes`, `Vk.alloc_bytes`)
  for the memory fence to read. MoltenVK 1.4.2 routes few of its own objects through them. A pipeline
  made the first time a variant is drawn frees its seventeen create infos. `actor_init` makes 512 actor
  records, so an actor first placed in play takes one instead of allocating.
- **What is under the water reads as under it, and the shore's wash stays on the shore.** `water.frag` let a
  fish or a wader's legs through at almost their colour in air: absorption over 0.1-0.25 m of water is a few
  percent, and nothing else touched them, so a trout just under the surface was golden, sharp and brighter than
  the gravel round it (which the terrain already draws wet and under a film of the lake's colour). What stands
  clear of the bed is now darkened as a wet surface is and veiled toward the water's colour by its path, and
  everything under the surface is softened by the ripples' spread, which widens with its depth - one read of
  the pre-water scene's mips (`water_draw` makes the chain), narrowed where its footprint finds something above
  the surface. `terrain.frag` ran the shoreline's lap 22 cm up the bank and, gated on height above the line
  alone, over the whole lake bed within 120 m: its bands lay across the floor, seen through the shallows and
  plain from under the surface. It now stops 30 cm below the line, where the water's own wash ends.
- **`--emit-schema`: an empty `def X from "f.lres"` file is a contributor.** A resource file that a `def` (or a
  registry's `from`) reads but that holds no entries yet is now listed in the registry's `contributors` as
  `{"kind": "resource", "file": ..., "via": ..., "module": ..., "keys": []}`, after the files that brought entries.
  Before, the registry exported `"contributors": []` and a tool could not tell which file its first row belongs in.
- **`Http.text` and `Http.header` return copies.** They handed back the handle's own buffer (and on macOS the
  response object's string), which `Http.free` then released: a text read before the free and used after it
  was garbage or empty - maroon-lake's map list wrote a 0-byte maps.json. Each call now returns a string that
  is the caller's to keep. Read a body once per response.
- **`Json.parse` decodes `\uXXXX`.** An escaped code point is UTF-8 now - a surrogate pair joined into one, a
  lone surrogate or bad hex as U+FFFD - where the backslash was dropped and the hex kept as text ("iu015f"),
  and `\t`, `\r`, `\b` and `\f` are the characters they name. Python's `json.dump` writes non-ASCII this way.
- **`Json.parse` decodes an escaped string in one pass.** A string with escapes in it was joined a character
  at a time, and every shorter copy was kept: a long escaped text took gigabytes (ui-preview's story model
  reached 6.5 GB in three seconds). It is now decoded into one buffer sized from the text. ui-preview's
  protocol-v1.md states how an `@import` path is resolved and which key a `file` override answers to.
- **`Os.platform()` and `Os.arch()` allocate nothing after the first call.** Each call malloc'd an
  8 KB `uname` buffer and let it go, and a game asks the platform every frame in places (a launcher's
  wait, an update panel, a renderer's present). The buffer is made once and kept.
- **`expect_eq` and `expect_near` take floats.** On a float or a double they compared with an integer
  instruction, and the build failed in clang ("defined with type 'float' but expected 'i32'"); they
  compare as floats now (the wider kind of the two) and a failure prints the numbers.
- **`expect_eq` on strings compares their text.** It lowered to an integer compare of two pointers,
  which the IR refused; now two strings with the same text are equal (a null only to a null), and a
  failure prints both: `expect_eq failed (got "camp", want "lake")`.
- **`ludic build --check` reads the maps only for the package's entry.** A partial program - a unit test, a
  molecule, a bake's runner - lacks the game's constants, so checking every map's tables against it refused
  rows the game reads fine (`TH_*`, `NPCK_*` unknown). The maps are now checked with the `entry` package.ludic
  names (as `ludic build --check` with no file, and tests/pack.sh, do); `--maps` checks them anyway, `--no-maps`
  never. `ludicc` itself is unchanged: it reads them unless told `--no-maps`.
- **`ludic build` keeps its LLVM IR out of the project.** The intermediate `.ll` was written beside
  the binary (`build/<name>.ll`) and deleted after linking, so a project's tree held one for the
  length of every build, and two builds at once deleted each other's - which surfaced as a
  `clang: no such file` that read exactly like a compile error. It now goes to the run's own
  temporary directory and goes with it. `--save-temps` still keeps it at `build/<name>.ll`.
- **`ludic deps`: a reach counts every state apart, however the states are numbered.** The reach and
  write-reach bitsets packed 60 states to a word, but an `int` is 32 bits, so `1 << 45` came back as bit
  13 and states 32 apart shared a bit: a function taking both counted one, fewer than it takes, and the
  counts (`widest_reach`, `widest_write_reach`, `--reach`, `--wreach`) rose and fell with how a program's
  states happened to be numbered. The sets now hold 30 to a word. On Maroon Lake `widest_reach` goes
  58 -> 76 and `widest_write_reach` 54 -> 64 - the real numbers, which the old count hid.
  `examples/state/reach_wide.ludic` (40 states, S00 and S32 taken together) holds it.
- **`ludic migrate state --prune` keeps a state declared after a plain parameter, and a parameter named twice is refused.**
  A function like `home_keep(r: Records, save_st: mut Save)` was taken to lack `save_st`, and the
  prune gave it a second one at the front (`home_keep(save_st: mut Save, r: Records, save_st: mut
  Save)`) - which `ludic build --check` let through and clang then refused. The migration now counts a
  state anywhere in the list as declared, and the checker refuses a function that names two parameters
  alike (`add names two parameters n`).
- **`ludic.character`'s fact pool is presized and capped.** `chr_fact_more` made a new `CharacterFact` whenever every record was held, so a game that did not drain the facts promptly grew the pool for good and the alloc fence reported it unbounded. The pool is now 1024 records made with the state; a fact that finds all of them held is dropped and counted (`char_facts_dropped()`), and nothing is made in play. A regression test runs thousands of frames of jumping with nothing drained under the alloc fence.
- **`ludic.jobs`, `ludic.npc`: scopes and windows say what they hold.** A job's and a board's `scope` is `@OneOf(JOBS_SELF, JOBS_PARTY)` (the list also named the states and the group count, which are not scopes), so a game writes the package's own constants in its data instead of a registry of its own that an editor cannot match. `NpcStep.window` is `@OneOf(DAYW_)`, the way `JobDef.group` is `@OneOf(JG_)`: the game's windows, named by its prefix.
- **`ludic.render3d`: a developer switch wins over the game's setting.** `R3D_NOGI` (its own `r3d_env_no_gi`, read by the SSAO gate and the composite's strengths), `R3D_ANISO`, `R3D_MSAA`, `R3D_FOG_WALL` and `R3D_NOVSYNC` were set once at start-up and written over by the game's next settings apply; `r3d_set_anisotropy`, `post_set_msaa`, `r3d_fog_wall` and `gpu_vsync` now read their switch themselves, as `r3d_dlss` and `r3d_hdr` always did. And a skipped SSAO pass (GI Off, or `R3D_NOGI`) no longer leaves the composite sampling a never-written target, whose NaNs times a zero strength drew a black frame: it reads a 1x1 neutral texture (`post_neutral`) instead.
- **`ludic.render3d`: auto-exposure adapts in seconds, not frames.** The eye's easing was a fixed 0.08 of the way
  to the target per frame, so exposure settled in a quarter of the time at 240 Hz that it did at 60. It is now
  `1 - exp(-dt / tau)` with `dt` the seconds between two `r3d_frame` clocks (a clock that goes back counts as one
  60 Hz frame, a stall is held to half a second), so 30, 60, 144 and 240 Hz settle together. `tau` is 0.2 s as the
  scene brightens - exactly the old 0.08 a frame at 60 Hz - and 0.5 s as it darkens, since dark adaptation is the
  slow side of the eye (Ferwerda et al. 1996; Pattanaik et al. 2000). `post_adapt_speed(bright, dark)` sets them
  (0 is at once). `adapt.frag`'s `u_rate` is a `vec2` of the two shares, made by `post_adapt_rate`.
- **`ludic.render3d`: the fog wall hides things in the haze of the hour, not in the photograph's horizon.**
  `fogWallCol` was the sky photograph prefiltered at roughness 0.6 just above the horizon: half that lobe is a
  puresky image's slate lower half and the rest its own clouds, and the prefilter is never relit - so a clear
  morning in Maroon Lake drew a dark slate storm on the side away from the photograph's sun (0.11, 0.13, 0.19)
  and white milk on the other (0.59, 0.67, 0.80), and the drawn sky turned to the photograph's clouds above
  the band. The wall's colour is now the whole sky's light (its mean radiance, the irradiance an upward face
  takes) coloured as the drawn sky is at the horizon at this hour (`analyticSky`, by the same `u_sky_relight`),
  plus the sun scattered forward as before: the camp's morning wall measures (0.32, 0.38, 0.52). `analyticSky`
  and `u_sky_relight` move from `sky.frag` to `lighting.glsl`, and `daylight_bind` binds the relight for every
  lit program. A game with no fog wall draws as before.
- **`ludic.render3d`: the grade's lift is applied in display space, as its numbers mean.** `tonemap.frag` added
  `u_lift * (1 - c)` to the LINEAR colour after ACES, where a lift of 0.025 is a floor of 48/255 once the 2.2
  is applied: `daylight_set`'s "blue at noon" shadow floor (`post_lift_b` 0.012 + 0.013) painted every open
  shadow blue-grey - shaded grass in Maroon Lake measured (44, 60, 58) at 8:00, the blue channel above the
  green. The lift and gain now go on after the 2.2 and the colour returns to linear for the rest of the
  chain (saturation, vignette, HDR10), so the same numbers are the few-pixel floor they were written as: the
  shade measures (42, 57, 42), dark green. A game that set its own `post_lift_*` sees its shadows' floor drop.
- **`ludic.render3d`: the grass carpet is drawn from the clumps, not their cards.** `carpet_bake` drew each card
  layer's crossed card straight down, and a crossed card is two upright quads - edge-on from above, so they covered
  no texel and the tile came out all zeros (a game's baked carpet was a black, transparent tile that darkened its far
  ground). It now draws the model each card's atlas was baked from (`carpet_source`), with that model's own
  textures, through the impostor bake program; a model layer draws its own model. A game re-runs its carpet bake.
- **`ludic.render3d`: the sky's light from below the horizon is the scene's own ground, and a surface tilted
  down still sees its share of the sky.** `skyIrradiance` and `skyPrefiltered` tinted the ground half of the
  IBL with a private olive constant, so a stage on a grey plate was lit from a lawn; they read `u_ground_alb`
  now (the same colour the sun's bounce uses, bound with the IBL in `sky_bind_lighting`), whose default is
  that constant, so nothing changes unless a scene says what it stands on with the new
  `r3d_ground_albedo(r, g, b)`. And the sky/ground split never gives a normal less sky than its view factor,
  `(1 + n.y) / 2`: the old window cut the sky to nothing by `n.y = -0.25`, so every jaw, neck and hanging arm
  was lit by the ground alone and a pale skin came out olive. Upward and level normals are unchanged.
  `ludic.lab`'s plate says its ground is the plate (its texture's mean linear albedo).
- **`ludic.roads`, `ludic.cars`: clean under `arena strict`.** A project that declares `arena strict` refused to build with either package: `RoadsState.rd_dice` was made in the frame by `rng_new` the first time traffic needed it (it is now a state default, `rd_dice_ok` says whether `RoadsWorld.seed()` has seeded it), and the editor verb `car_get` built its refusal text in a verb the fence reached (the text is `@alloc_ok`). No behaviour changes: the dice roll the same numbers from the same seed.
- **`ludic.roads`: the nearest road is found anywhere on a large map.** The grid over the road polylines keyed
  a cell by a product of two biased cell numbers that wrapped negative in 32 bits, and an `IntMap` keeps keys of
  0 or more only: when its table grew (past 48 cells) every cell with a negative key was dropped, so
  `roads_nearest` and `roads_nearest_y` answered with a road's far point (its midpoint on a straight road) for
  any point near a road in such a cell, and a car could not be placed on it ("not on a lane"). A cell's key is
  now its two numbers cut to 15 bits each and packed into 30, never negative; two cells 1,048 km apart share a key,
  which only costs a few more steps scored.
- **`ludic.ui`: a held direction moves the focus once, not every frame.** Right, Left, Up and Down (and the d-pad and stick) move on the press, then repeat after `UiState.rp_first` (0.4 s) at `UiState.rp_every` (0.125 s, 8 a second). The platform's own per-frame key-pressed reports while a key is held are ignored; a tap too short to be seen held still moves once. The in-game phone stopped running through all its elements in a second. Nothing is allocated per frame.
- **`match` on a string compares by content, and on a `long` or a `double` by value.** Every arm was
  lowered as `icmp eq i32` whatever the subject was, so `match word { "embers" => ... }` named a
  pointer as an `i32` and the module did not assemble (`'%t1' defined with type 'ptr' but expected
  'i32'`). An arm now compares exactly as `==` does: a string by content, a `long` as 64 bits, a
  `float` or `double` as floating point; two 32-bit integers keep their single compare. A subject the
  `match` built itself (a template) is freed once an arm is chosen.
- **`return <value>` in a function that returns nothing is an error.** It used to reach clang as
  `store void`, which fails the link with an LLVM message about void types and no line in the
  program; it now says where, in words.
- **`ui_dump_to(root, path)` writes a laid-out tree to a file and keeps nothing.** An editor's live link asks for the
  tree (`ui_tree`) again and again; `ui_dump`'s text, joined a piece at a time (and `ui_hex` per colour), kept every
  piece for good - 25 MB over 36000 frames of a driven session. `ui_dump_to` writes the same lines into one buffer it
  lets go once the file is written. `tests/ui_dump_to_test`: the file is what `ui_dump` prints, and 200 dumps grow the
  heap by under 4 KB.
- **ludic.cars planar model no longer spins out and never carries a NaN.** The body-axes turn was added to the velocity by
  explicit Euler, which multiplies the speed by sqrt(1 + (w dt)^2) every step, so a hard turn at speed fed its own spin (a sedan at
  30 m/s with the stick at 0.6 went to 177 m/s). The turn is now an exact rotation of the (forward, right) velocity by the yaw step,
  the yaw rate and the speed are bounded, and the load transfer reads the force's acceleration, not the rotation's. `car_spawn`,
  `car_place` and `car_drive` turn NaN and infinities into 0, a ground that answers with none is level with the car, and a body pose
  that is not finite hands the car to the planar model. `is_finite(x)` joins ludic.base.
- **ludic.city streaming survives a non-finite position.** `city_stream` and `city_stream_step` with a NaN or infinite point
  load and unload nothing (they returned a loop over garbage cell numbers and hung the game); a point 1e30 m away is clamped to a
  cell, and `reach` is held to 0..32.
- **macOS: a game has a menu bar and quits when asked** — a windowed program gets the standard
  application menu (Hide, Hide Others, Show All, Quit *Name* ⌘Q) and a Window menu (Minimize ⌘M),
  named from the bundle's `CFBundleName` or the process name. Cmd-Q, the Dock's Quit, logout and
  the `quit` Apple event (`osascript -e 'tell application id "…" to quit'`, which failed with -1708)
  now end the run the way the window's close button does, so the game's own shutdown runs. Hiding
  the app (⌘H) or minimising the window does not end the run.
- **render3d allocates nothing in its steady state.** A buffer released and made again - what a
  streamed or growing buffer does every few frames - left about 224 bytes behind each time: the
  Vulkan allocator made a one-slot list per allocation, turned two 64-bit sizes into strings to read
  them as ints, and rebuilt its spare-record list whole to drop the last entry. It now keeps one
  slot, converts with `int()`, and pops. `Vk.heap_bytes()` reads malloc's live bytes (macOS), and
  `examples/rendering/steady.ludic` holds render3d to zero: 5000 buffer rounds and 600 whole frames,
  0 bytes each (the unfixed allocator: 1,120,000 over the 5000).
- A `test` block that shows a ludic.ui component works in every test of its file, not only the
  first. The runner re-ran the globals' initializers (where each component registers itself) and
  only then forgot the states, so every later test started with a fresh `UiState` that had no
  components: "there is no screen X". The states are now forgotten first. A screen that does not
  exist is still an error in `ui_errors`, and `ui_nodes` hands back an empty screen instead of null,
  so looking at it no longer crashes.
- A leaf is not matte.

  Foliage roughness was pinned to 1.0 and grazing Fresnel switched off, so nothing green in
  the game had a highlight anywhere: the glint off waxy leaves and wet needles, which is
  most of what makes a real stand look alive rather than painted, was simply absent.

  The reason it was switched off is real. A crown is card quads, and at a grazing angle the
  card's normal is a lie, so a plain specular lobe frosted whole crowns white against the
  sky. So the sheen comes back as its own term gated on exactly that: it fades out as the
  card turns edge-on, which is where its normal stops meaning anything. A tight lobe for the
  glint, a weak wide one for the waxy rim, and nothing at all at the angles that frosted.

  Thin-leaf translucency reaches further with it - a backlit stand glows for as far as you
  can see it, not 140 m - and a dense crown passes 0.45 of it rather than 0.3. The distance
  cap that stops a two-pixel clump card becoming a lime disc stays.
- Still water reads as water rather than polished metal. The planar reflection is
  returned at 0.72 of the scene's own exposure instead of all of it, the fresnel mix
  is capped at 0.70 rather than 0.86, and absorption falls from `(0.55, 0.24, 0.14)`
  to `(0.34, 0.15, 0.09)` per metre - so the bed is visible through the surface at the
  angles a player actually stands at, and a clear lake stops going opaque a metre and a
  half down. The ripple field is roughly halved and its normals flattened further
  (slope 0.26 -> 0.15), the reflection's ripple nudge halved with it, and the surface
  goes flat by 400 m rather than 600, so a sheltered lake is one sheet of water with a
  mountain in it instead of open chop to the horizon. Sun glitter and wind-streak foam
  come down to match.
- The fog's noon density is the game's, not overwritten at start-up.

  The renderer's last load step set `r3d_fog_density = 0.00024` unconditionally, after the game had set the map's
  own noon density (Maroon's `fog_noon`, set before `r3d_init`), so a booted map never got its own air: the figure
  only took effect after a world switch. It now sets its default only where the density is still 0.
- The forest past the fog wall is a stand of crowns, not a hillside of fish scales.

  `canopyOver` (`terrain.frag`) drew each crown on its jittered 5 m grid as a smooth hemisphere, its
  normal tilted in proportion to the distance from the centre (0.6 at the rim), every cell filled and
  every radius within 0.8-1.25 of the stand's. Seen from the overlook at noon, every crown wore the same
  lit crescent and the far hills read as a repeating fish-scale pattern (Maroon Lake's vqa8
  `ov_nohud`). Proved by `R3D_NOCANOPY=1`, which removes the pattern and nothing else.

  A crown is now a cone - one slope from the tip to the skirt (0.25), so the lit and shaded halves meet
  in a line through the tip rather than in a crescent - with a ragged seven-pointed edge, radii over
  0.65-1.35 of the stand's, and a thin stand leaving cells empty (the share filled follows the cover,
  half to all). The stand's colour, roof and gaps are as before.

  Measured on that view, two headless shots a side (each pair identical): the strongest off-centre
  peak of the hill's high-passed autocorrelation (how regular its fine detail is) 0.138 -> 0.084, against
  0.082 with the canopy off; 0.7% of the frame moves by more than 8, and 0.9% / 0.7% of two other noon
  views.
- The ground keeps more of its own colour, and the rock keeps all of it.

  55% of every ground pixel was the orthophotograph, at every distance and on every
  material. A survey image is a good record of WHERE the forest and the scree are and a
  poor record of what a steep rock face is coloured: it is shot through kilometres of air
  at an angle no player stands at, and it comes back pale. So the photograph keeps the
  meadow and the forest, where it carries real variation nothing else knows, and gives the
  rock back to the rock - by material and by elevation, never by distance, because a
  distance fade used to live here and was removed for a good reason (the photograph has
  the day's own shadows baked in, so grass grew dark patches as you backed away and they
  slid as you walked). Material and height do not move when the camera does.

  The far tier's rock fallback is the maroon mean rather than a neutral grey. TFAST_3 skips
  the rock sample and leaves that constant standing in for it, and the file's own rule says
  the cheap tier must keep the near tier's mean colour or the boundary shows as a ring.

  Ortho-classified snow now needs altitude. Bright and unsaturated is what snow looks like
  from a satellite and also what a sunlit rock face looks like, so faces were being painted
  90% white wherever the photograph was pale. Gully snow is gated on the snow line too,
  rather than on two absolute heights five hundred metres below where snow can lie.

  And the distance desaturation from `light-air-and-the-hour` is eased from 1.9 to 1.15.
  It was tuned on a valley whose rock was grey anyway; Maroon's air is thin and dry and the
  peaks are two kilometres from the lake.
- The lake mirrors a meadow's plants as plants, not as white blobs, and `R3D_NOREFL` turns the mirror off.

  The reflection pass drew through a mirrored camera (determinant -1) and kept the right faces by culling
  `GPU_FRONT`. That left every fragment it drew a back face to the rasterizer, so every shader that turns a normal
  by `gl_FrontFacing` (`model.frag`, `kit.frag`) turned it the wrong way in the reflection: a two-sided tuft or
  flower lit from its far side came out near white, and a hillside of them lay on the water as pale blobs. A pass
  drawn through a mirror now says so (`gpu_mirror`): its pipelines take counter-clockwise front faces and cull
  `GPU_BACK` as any other pass does, the same faces survive, and `gl_FrontFacing` means what it means elsewhere
  (`tests/mirror_face_test.ludic`).

  `R3D_NOREFL` set `r3d_no_refl`, which a game's water setting writes over when settings apply, so the switch did
  nothing. It is its own field now (`r3d_env_no_refl`), read beside the game's.
- The lake mirrors what stands in it, and its shore stays on the shore.

  `water_reflect_visible` judged a 32 m cell of water by five points - its centre and four near
  the corners - and skipped the reflection pass when every one was dry, off the frame or behind
  the ground. Wading off a dock, the water between the eye and the bank lies between those five:
  two were behind the camera and the rest on the bank, so the pass was skipped while the lake filled
  half the frame, and the surface mirrored the bare sky over everything under it - a wader's legs
  became a pale ghost and every fish a pale blob. A cell the camera is in or beside (within a cell's
  width) is now also walked on an 8 x 8 grid before it is called hidden
  (`tests/water_reflect_test.ludic`).

  `water.frag` keyed its shore terms - the wash, the lap and the soft edge that hides where the plane
  cuts the bank - on whatever the scene depth found under the surface. A fish 20 cm down or a pair
  of wading legs is not the bank: the shoreline's foam was laid over them and a shallow fish lost the
  surface entirely. Where the depth stands clear of the ground the terrain draws there (the paged
  height, read as `terpage.glsl` reads it), those terms read the bed under the pixel instead; the
  light to the object is still attenuated over its own depth.
- The orbit camera clears a dock's deck.

  The orbit and the eyes kept 0.55 m above the BED under them, and a dock's boards are not the bed
  (they are what the body can stand on over it, `CharacterGround.height`), so on the end of a pier
  the camera, held low by a look upward, sat inside the planks and the screen was full of boards.
  It keeps above the higher of the two.
- The phone home grid draws an app name once.

  An app with no icon drew its title inside the tile as well as under it (cut off, "Messages Mes"), and each app laid out as a row instead of a column. Tiles without an icon are now plain and the label sits under the tile.
- The viewfinder's depth of field no longer draws vertical streaks through grass.

  Every pixel gathered its circle of confusion with the same sixteen offsets, so a thin dark blade of
  grass was copied sixteen times in one fixed pattern, and a meadow of vertical blades read as vertical
  streaks over the whole frame. The spiral of taps is now turned by a different amount at every pixel
  (interleaved gradient noise) and has twenty-four taps, so the copies fall as fine grain. Measured on
  the meadow of a Maroon Lake viewfinder shot at f/4: horizontal-over-vertical gradient 1.27 -> 1.06, the
  column-to-column streak measure 1.64 -> 1.36. SPIR-V rebuilt with `ludic-dev shaders` (only
  `dof.frag`'s changed).
- `Actor.cast_hidden` separates being DRAWN from CASTING. `ac_visible` rejected any hidden
  actor from the shadow pass as well as the scene pass, so a game that hides the player's
  own body - first person, or a viewfinder held to the eye - lost that player's shadow
  entirely. An actor hidden because the camera is inside its head is still standing in the
  sun; set this on it and it keeps its shadow. Everything else still stops casting when it
  is hidden.
- glTF vertex colours (COLOR_0) now reach the model and kit shaders.

  The loader ignored COLOR_0, so a model coloured by vertex colour on shared materials (the
  studio's generated buildings) drew untextured grey. It now reads vec3 or vec4 COLOR_0, float or
  normalized unsigned byte or short, and uploads it as RGBA8 normalized on attribute 7. kit.vert and
  model.vert pass it on and kit.frag and model.frag (the plain lit path) multiply it into base
  colour, after the material factor and texture, as the glTF spec has it. A mesh without COLOR_0
  leaves the input unfed; Vulkan reads that as all zero, which the vertex shaders turn into white,
  so nothing allocates per frame and every other mesh draws as before. The scatter arena copies
  the colour buffer across LODs. SPIR-V rebuilt with `ludic-dev shaders`. Not yet covered: the
  foliage and card paths of model.frag, and the bake passes (bake.frag).

  Every vertex shader paired with model.frag now writes every varying it declares (v_col as white,
  and v_near and v_lh as neutral values): skin.vert, grass.vert, grass.mesh and grass_inst.vert.
  The first attempt wrote v_col only in model.vert and kit.vert, and MoltenVK refused every
  pipeline that paired another vertex shader with model.frag. `ludic-dev shaders` (and so
  `--check`) now fails when a fragment input has no vertex output at its location.
- ludic.weapons: a weapon's rate is exact at any tick rate. The carry between rounds (a round that leaves a little late pays the difference on the next) was kept only when rounds left on two ticks in a row, so a rate below the tick rate was rounded up to whole ticks: 650 a minute fired 600 a minute at 30 and 60 ticks a second (100 rounds in 10 s instead of 109) and 617 at 144. The carry now lasts for the whole run of fire, and a run ends when a tick finds the cool-down over and no round left. The test fires a 650-a-minute weapon for 10 s at 30, 60, 144 and 240 ticks a second.

### Performance

- **The terrain's height field takes half the GPU memory.** The baked height and surface normal
  shared one 4096^2 RGBA32F (256 MB); the height now stays alone in its R32F - the same 32 bits
  every placement, the CPU read-back and physics read - and the normal goes beside it as x and z in
  an RG16F (`ter_normal_tex`, bound as `u_ter_normal`), y rebuilt where it is read: 128 MB. The grass
  cull takes it as a third texture (binding 6). In Maroon Lake's play: 2793 -> 2647 MB; the camp's
  frame differs in 0.066% of pixels by more than 8, single grass blades at the slope gate.
- **`ludic build` / `ludic run` are incremental.** A fingerprint of every input (project files, the toolchain's packages, runtime, fonts, assets, compiler, flags) in `build/.ludic-cache` lets a build nothing changed for finish in about 0.1 s instead of compiling and linking. A touched file that leaves the generated code the same keeps the binary. Otherwise the IR is cut into per-core parts and only the parts whose text changed are compiled (objects cached by content), so one edited function or data row costs one or two parts of a dozen. `ludic build`/`run` print a `build: ...` line per phase, unbuffered, for a terminal or the studio's log. `LUDIC_NO_INCREMENTAL=1` turns it off; `ludic-dev test-incr` tests it. A kept symbols folder is reused when the binary's id is the same.

### Documentation

- **One way to name a model.** A record drawn as a model carries `@Asset("gltf") model` and `@Node(model) node`; the path is the link a game's own
  model table matches on, not a key convention in code. Documented in PACKAGES.md ("Naming a model"); `PedLook` (ludic.crowd) gains the pair,
  the rest (`CarModel`, `Weapon`, `Attachment`, `AvatarBody`, `VehicleSpec`, `FurnitureItem`, ludic.city) already had it.
- ludic.anim's studio.lres no longer says a rig is the game's: it names the package's own rig, a set's `skeleton` reference to an `AnimSkeletons` row (`model`, `root`, `prefix`; clips are `<prefix>_<clip>`). The studio cannot follow a graph-to-skeleton reference through `rig_table` yet, so a game still writes the rig keys in its own entry (see the comment).

### Breaking

- **OpenGL is gone from the toolchain; rendering is Vulkan only (MoltenVK on macOS).** The `Gl.*`
  namespace and everything behind it are removed: `runtime/native/gl.ludic`, the generated
  `gl_api.ludic` (478 entry points, 901 `GL_*` constants), the ABI thunks (`gl_thunks.ll`,
  `gl_thunks_win.ll`), the CGL / NSOpenGL / WGL context code (`gl.ll`, `gl_win.ll`, `win32_gl.ll`,
  the GL half of `cocoa.ll`), the `ludic-dev glgen` command with `tools/ludic-cli/glgen.ludic`, the
  `examples/rendering/gl_triangle.ludic` example, the `Gl` docs section, and the `-framework OpenGL` /
  `-lopengl32` link flags. A program that names `Gl.*` no longer compiles.

  What the OpenGL runtime carried besides OpenGL stays, under names that say what it is:

  - `runtime/native/window.ludic` (was `gl.ludic`), spliced by `Vk.*` and by `Time.now_us` /
    `Time.sleep_us`: `gl_width` / `gl_height` / `gl_pixel_scale` / `gl_set_drawable` /
    `gl_set_pixel_scale` are now `gfx_*`, `gl_set_window` / `gl_toggle_fullscreen` / `gl_set_retina`
    are `gfx_set_window` / `gfx_toggle_fullscreen` / `gfx_set_retina`, and the float-buffer helpers
    `gl_floats`, `gl_bytes_of`, `gl_put`, `gl_get`, `gl_put_bits`, `gl_get_bits`, `gl_ptr`, `gl_f32`,
    `gl_fixed` are `fbuf_*`. The state is `RtWinState` (`rt_win_st`).
  - `rtlib.ll` (`rtlib_win.ll` on Windows, was `gl.ll` / `gl_win.ll`): the `f_*`, `mem_*` and
    `fx_to_f32` helpers, and the clock, now `clock_now_us` / `clock_sleep_us` (were `gl_now_us` /
    `gl_sleep_us`). The window's `win_gl_resize` / `win_gl_drawable` / `win_gl_scale` /
    `win_gl_retina` are `win_resize` / `win_drawable` / `win_scale` / `win_retina`
    (`win32_window.ll`, `win_nowin.ll` on Windows). The context-only `win_gl_attach`, `win_gl_swap`,
    `win_gl_swap_interval` and `win_gl_update`, and `gl_vsync`, `gl_open`, `gl_swap`, `gl_screenshot`
    and `gl_resize_check`, are gone.
  - render3d's own vocabulary for formats, filters and blend factors, which was the `GL_*` constants,
    is now `GPU_*` in `packages/ludic.render3d/gpu_enums.ludic` (same values): `GL_LINEAR` is
    `GPU_LINEAR`, `GL_RGBA8` is `GPU_RGBA8`, and so on.

  `Time.now_us()` and `Time.sleep_us()` no longer need the program to name `Vk.*` or `Gl.*` to link.
  The compiler's seeds are regenerated (`g_uses_gl` became `g_uses_win`).
- **render3d draws with Vulkan only; its OpenGL backend is gone.** `gpu.ludic` keeps its seam -
  every `gpu_*` and `u_*` call a renderer or a game makes is unchanged - but each now speaks to the
  Vulkan backend alone: no `gl_*` entry point is called from the package, and the GLSL source is
  no longer assembled at run time (the same files are still what `ludic-dev shaders` compiles to
  SPIR-V). `gpu_request` accepts any name and runs Vulkan; there is no fallback, so a machine whose
  Vulkan cannot start is told why (`gpu_fallback_reason`, printed) and `r3d_init` fails.
  `gpu_is_gl()` stays, always false, for callers that still ask. The `R3D_GLCHECK` error checks went
  with the backend (their messages were built on every call, checked or not). A program that uses
  `Vk.*` now also links the runtime's window layer, which still lives with its OpenGL
  (`gl_width`, `gl_set_drawable`, ...); separating the two is the runtime's own decision.

### Change

- **A world replaced at run time gives back what it held - and what is cleared or replaced is no longer the
  caller's to keep pointing at.** A game that swapped its map kept about 7 MB of heap and 20 MB of GPU memory per
  swap, reachable from nothing: every actor it did not keep (with its own skeleton), every scatter layer's record,
  chunk index, GPU-cull arena, impostor and crossed card, the distant-grass carpet, the grass kind, and on the
  packages' side every Thing, animal, range and person record.

  **Behaviour changes - a caller must not keep a pointer across these:**

  - `ludic.render3d` `actor_release_all()` releases every actor on the stage but those `actor_hold` marked: a
    released record is the next `actor_new`'s. (`actor_clear_all`, off the stage and nothing given back, stays.)
  - `scatter_clear_all` frees each `Layer` record and its LOD list (the list `layer_set_lods` was handed; the models
    in it stay the loader's), its impostor and a crossed card it built: a layer pointer is dead after it.
  - `grass_kind_set` takes ownership of the kind it is handed and frees the one it replaces.
  - `model_release` frees each primitive's factors (`Prim.fac`): a primitive owns its own (the tile-map ground's
    patches each copy the ground's now).
  - `terrain_unload` and a second `terrain_set_carpet` free the carpet texture they held.
  - `ludic.things` `things_clear` puts every record on the spare list, as a removal does, and the next placement
    reuses it.
  - `ludic.wildlife` `wildlife_clear` keeps every record for the next valley's animal of its species - key and all -
    and a valley's ranges are the next one's (`wildlife_ranges_setup`).
  - `ludic.npc` `npc_clear` leaves the walkers in `npc_walkers` as inactive records (out of any crowd) for the next
    `npc_spawn`, and the posts for the next `npc_place`: who is about is who is `active`.
  - `ludic.base` `baked_path` returns an interned string: never free it.

  **Fixes:**

  - `ludic.render3d`: a skin clone given back (`skin_clone_free`, `actor_release`) waits on its source skin and is
    the next `skin_clone` of it (a freed clone left a block per node and joint behind - its matrix views); given back
    twice it still waits once. A texture load frees its baked file's name.
  - `ludic.anim`: a player bound to another rig gives back the last binding's tables, and a skin bound again its
    masks; `anim_oz_skel` frees the arrays ozz copied.
- **CI spends its hour where it counts.** A push that changes only prose (`docs/`, `changes/`, Markdown)
  runs the doc checks, now a job of their own (`docs-checks`: the fences, coverage of the
  implementation and the site), and skips the regression and editor suites. The release workflow no
  longer runs the suites a second time: it publishes once `ci` has passed on the tagged commit, or on
  its parent when the tag's commit is `ludic-dev release`'s own (`VERSION`, `CHANGELOG.md`, `changes/`).
- **Ludic lives on GitHub.** The repository is `github.com/workshopsoft/ludic`, the documentation and the
  installer are at `https://workshopsoft.github.io/ludic/`, and releases are GitHub Releases.

  - **`install.sh`** reads the release list from the GitHub API (`$LUDIC_GITHUB_API`).
  - **`ludic upgrade` and `ludic doctor`** fetch the installer from the new address.
  - **`ludic-dev publish`** creates the release through the `gh` CLI with `$GH_TOKEN`; in CI that is the
    workflow's own token.
- **The packages' registry text is keys (phase 26.4).** The fields a player reads in the open registries
  a game fills are `@Text ... : Key` now, so a compiled row that leaves one out takes its derived key
  (`<registry>.<row>.<field>`) and the English lives in the game's `en.po`: ludic.things' `ThingKind.name`,
  ludic.gear's `GearKind.blurb` / `howto` / `names` (`[]Key`), ludic.hints' `HintCard` line, title, steps
  and `later`, ludic.jobs' `JobDef.title` / `text` / `how`, ludic.npc's `NpcLine.text` and
  `NpcChoice.text`, and ludic.weather's `WeatherKind.name`. What a package hands back as text
  (`thing_name`, `gear_level_name`, `hints_step_text`, `npc_words`, `weather_name`) is the key's marked
  text, "" for none, made into words where it is drawn. Not text, so no longer `@Text`: ludic.npc's
  `NpcName.name` (a person's name, the same in every language), `NpcChoice.line` (a line's key) and
  ludic.settings' `SettingDef.text` (a text setting's default value). ludic.i18n's `tr`, `trf`, `trn`
  and `key_text` say `@alloc_ok`: `tr` is a cast, and what `trf` / `trn` make is kept by what shows it.
- **ludic.i18n draws plain text as it is: the English path is gone (phase 26.9).** `L` makes a key, a
  key glued into text, or a line bracketed inside another; anything else - a player's name, a chat
  line, a number - is drawn as it is, in every language, so a player named "Settings" stays
  "Settings". Removed with it: the lookup of English words (exact lines, patterns with holes, a
  paragraph a sentence at a time, padding), `Ln` (use `trn(kn"...")`), `i18n_pattern_count`, and an
  English argument's own lookup inside a key's hole. A language `.po` is read for its keys and
  plurals only. A game still on English msgids draws them untranslated until they are keys.

### Feature

- **A `Job.parallel_for` worker may read a state but not change one.** Every pool thread runs the
  worker at once, and the runtime hands each call the same state, so a worker that took a state as
  `mut` raced on it with nothing to say so. The compiler now refuses it (`fn bump: a worker runs on
  every core at once, so it may read CountState but not change it`): a result goes into `ctx`, a
  shared count through a `Sync` handle kept in the state. A function's signature already says what it
  touches, so this is the whole check - the same one a parallel scheduler needs to run two systems at
  once. `examples/library/threads.ludic` keeps its total in the words it hands the worker.
- **A bake's inputs can follow the data.** `bake_expand(inputs, map)` gives a Bakes row's inputs as they are
  hashed: `{map}` put as the map's key, and each input with a `*` put as the paths it matches, sorted as whole
  paths byte by byte, dot-names left out, a glob matching nothing gone. `bake_maps(first_input)` is the maps a
  `{map}` row covers: each directory under assets/maps holding its first input (`bake_maps_in` under another
  root). A runner hashes `bake_inputs_hash(bake_expand(row.inputs, map))`, the same path the check takes, so
  the two cannot disagree on stale; a game's Python tools are its checked twin.
- **A loaded model can be let go of: `model_release(model)`.** Its meshes are freed at once, and
  each texture once no other model uses it - the glTF loader shares textures between models (one
  path loaded once, a LOD chain borrowing its LOD0's material), so every cached texture now counts
  the primitives using it, and the last one frees it and forgets it, with any remembered material
  that named it. A game can unload a species' kit or a map's models when nothing of them is left,
  and loading one again afterwards is a fresh load. A scatter layer takes room for what it holds
  instead of its whole capacity up front (it doubles as it fills, to its cap), which in Maroon Lake
  was 0.4 GB of never-filled instance arrays. `examples/rendering/release.ludic` is the check.
- **A module's private names are its own.** A function, var or const a module does not export no
  longer collides with the same spelling in another module, in a file in no module or in the
  runtime: each private one is compiled under its module's name (`seed$shop`) and its module's
  references follow it. Exported names are still one namespace, and two exports of one name are
  still refused. Records and events still share one namespace. A program with no such clash compiles
  exactly as before.
- **A module's private records and events are its own.** A `property` or `event` a module does not
  export no longer collides with the same spelling in another module: each private one is compiled
  under its module's name and its module's types, `new`, `emit` and `@On` follow it. Exported ones are
  one namespace, and two events of one spelling are now refused (the first used to take the other's
  emits silently). Generic records, entity components and component or view records stay global.
- **A texture with a `.dds` beside its `.png` goes to the GPU BC-compressed, its mips included.**
  `tex_load` (and everything built on it: glTF materials, the terrain's materials, ludic.ui's
  pictures) looks for `<name>.dds` when the device has `textureCompressionBC` - every desktop GPU,
  Apple silicon through MoltenVK too - and uploads its blocks as they are: BC7 (colour in sRGB,
  or data read as it is), BC5 or BC4, a quarter of RGBA8 or less in video memory, no decoding and
  no mipmapping on the load. Only a DX10 `.dds` carrying the whole chain to 1x1 is taken; anything
  else is reported and the `.png` is used, as it is for a cut-out atlas (padded from the `.png`).
  `gpu_tex_compressed` and `R3D_BC7` / `R3D_BC7_SRGB` / `R3D_BC5` / `R3D_BC4` are the backend's
  entry; `examples/rendering/bc.ludic` is the check, and ludic.lab's plate carries its `.dds`.
- **A type checker runs before the emitter.** Numbers of different kinds, text and numbers, two
  record types, slices of different elements and functions of different types no longer mix; a call
  with the wrong number of arguments, a `return` of the wrong type and a `push` of the wrong element
  are errors with a line - several of these reached clang as an IR error, or compiled and ran wrong.
  Every mix-up is reported in one run. `pointer` stays untyped. `LUDIC_CHECK_REPORT=1` lists them by
  category without failing.

  It found, and this release fixes: render3d's HDR sky scan calling the float-bits extern `f_lt` with
  floats (it passed them in float registers the callee never read); `ludic.shooter`'s right-stick aim
  scaling a fixed deflection by 65536 again, which overflowed past half a push and turned the aim
  round; `prof.ludic` storing longs in an `[]int`; and extern calls, whose arguments are now coerced
  to their parameters like a function's. Runtime functions that return text (`Json.encode`, the
  value, XML, Tiled, HTTP and regex readers, `gl_get_string`) say `string`, and `Assets.ready()`
  says `bool`.
- **Actions and reducers.** `action PickUp { item: int }` is a typed record of something that
  happened; `reducer Bag on PickUp(b: mut Bag, a: PickUp) { ... }`, in the module that owns the state,
  says what it means for that one state - a reducer takes exactly its state and the action, and a
  second state is refused; `dispatch PickUp { item: 7 }` queues one from anywhere. The queue is drained
  at the end of every phase of the frame loop, after every phase of ludic.base's `core_tick_all`, and
  where a program calls `drain_actions()`: in dispatch order, each action's reducers in the order of
  their states' names, an action a reducer dispatches queued behind (a queue still growing after 64
  rounds stops the program, naming the action). `ludic deps` reports `widest_function` - the most
  states any function or entry point of the program takes - and `--check` ratchets it.
- **Animation wiring is data.** `ludic.anim` gains the open registry `AnimBindings`: a row names a source by a stable string
  (`crowd.speed`, `melee.SWING`, `weapons.RELOAD_STARTED`, `vitals.DOWNED`, `character.grounded`, `vehicles.seat_pose`) and the parameter,
  trigger or state of a graph it feeds, with a scale, offset, curve, clamp, gate and smoothing; `anim_link_tick(anim_st, dt)` once a frame does the rest,
  allocating nothing. `ludic.base` gains `SignalSources`, the registry mechanics declare their facts, per-actor values and words in
  (`SignalSource`, `SigFact`, `sig_find`, `sig_problem`, and a dev verb `signal_source` that lists them for a studio). `ludic.melee`, `weapons`, `vitals`,
  `crowd`, `character` and `vehicles` declare theirs in a `signals.ludic` each, and a new package adds its own with one `def` a source.
  `anim_link_validate()` reports a source nobody registered, a kind it cannot feed, a parameter or state the graph lacks, and two rows writing one parameter.
  **`animset_tick` now samples through ozz-animation** when the native layer built the player's skeleton and the clip (`anim_oz_enable`, `animset_release`),
  with the Ludic sampler as the reference and the fallback; the pose agrees within 3.5e-5 a component over fades, layers and root motion.
- **Bakes you can look at, and three more of the renderer's textures read from one.** `ludic.lab` writes
  raw 8-bit pixels (1 to 4 channels) as a PNG (`lab_png_write`, `png_write.ludic`, importable alone with its
  own `LabPngState`) and turns float textures into honest previews (`png_convert.ludic`: R32F min..max as
  grey, RG16F as red and green x255, HDR RGBA16F as x/(1+x) then sRGB). `ludic.render3d` takes three bakes
  the game names (`bake_load.ludic`) and makes each as before when one is missing or stale: an impostor's
  atlases as BC7 with their baked mips, through the compressed upload (`impostor_from_baked`,
  `impostor_fill_bc7`; a fog opening past its cards reads the bake again instead of painting), the sky's image-based light at the start yaw per prefilter width (`sky_baked_in`; any other
  turn of the sky is convolved), and the grass carpet (`carpet_from_baked`, `carpet_bytes`).
  `impostor_from_bytes` returns null, keeping nothing, when the bytes are not the impostor's shape.
- **Default parameters, components, views and templates.** A parameter can have a default (`pad: float = 8.0`).
  A call leaves out what it does not change, and may pass its first arguments by position and the
  rest by name.

  A `view` declaration is the one bridge between a program and its UI. It names the fields a
  template may read, the functions it may ask and the `on` events it may send, and it writes
  `view_<name>() -> UiView`.

  A `component Name { prop, state, fields, functions, on events }` declaration beside `Name.xml` and
  `Name.lss` is a UI component. Its template and styles are compiled in (with `@import` inlined), each
  mounted instance keeps its own props and state, styles are scoped to it, and a parent's `class`,
  `style` and `id` land on its root.

  `ludic.ui` is now a template runtime. Screens and components are XML files loaded at run time,
  with:
  - `{expression}` bindings;
  - `<if>`, `<else>` and `<each>`;
  - props, `<slot/>` and per-instance `<state>`;
  - `on-press` actions that send events, `set` state or `emit` to the component's user;
  - component libraries (`export="true"`, `<import src as>`);
  - HTML's elements (`div`, `p`, `h1`-`h6`, `ul`/`li`, `img`, `hr`, ...), with a default stylesheet;
  - HTML's attributes: `id`, `class`, `style`, `hidden`, `disabled` and `onclick`, with any other
    attribute kept for selectors;
  - the CSS box model (padding and margin in 1-4 values, borders, `px` and `%`) and flex layout
    (`flex-grow`, `justify-content`, `align-items`/`align-self`, `flex-wrap`, min and max sizes)
    under CSS's property names;
  - stylesheets, in a `<style>` or an `.lss` file (a Ludic StyleSheet) that others import and that
    can `@import` more;
  - CSS's selectors: `#id`, compound classes, `[attr=value]`, descendant and `>` combinators,
    `:hover`, `:disabled`, `:first-child`, `:last-child`, `:nth-child`, `:not` and more, weighed by
    specificity.

  - more CSS: custom properties and `var()`, `position` with insets and `z-index`, `em`/`rem`/`vw`/`vh`,
    `@media`, wrapping text and ellipsis, `overflow`, `+`/`~`, `:nth-child(an+b)`, `:checked`, `:active`;
  - more React: keyed lists, `<let>`, `<provide>` context, `<fragment>`, named slots, `on-mount` and
    `on-unmount`;
  - native elements a program draws itself (`ui_native`, `ui_fire`), and form controls;
  - errors with file and line, hot reload (`ui_reload`), and an inspector-style dump.

  The runtime is a UI framework, not only a template engine:
  - it takes input itself: focus and keyboard navigation, the pointer, scroll boxes, `autofocus`;
  - it has built-in controls (button, checkbox, radio, range, select, text, key), styled as CSS
    parts;
  - `ludic.ui/render3d.ludic` is a render3d backend, with textures, atlases, nine-slices, clipping
    and scale;
  - more CSS: `rgba()`/`#rrggbbaa`, `border-radius`, `outline`, `box-shadow`, `background-image`,
    `border-image`, group `opacity`, `@keyframes` / `animation` / `transition`;
  - HTML mixed content, and boolean attributes;
  - `popover` (a top layer that keeps the pointer and keys, with light dismissal), `title` tooltips,
    and `<progress>` / `<meter>`;
  - importing `ludic.ui/render3d.ludic` installs the backend, and atlases take rows;
  - hooks for the program's language, sounds and clock.

  What a game's screens found missing, now in `ludic.ui`:
  - `<input type="number" min max step>`: typed digits, Enter or leaving it commits them clamped, the
    arrows step it;
  - `<input type="key">` listens for any key (Tab and the arrows included) once Enter or a click starts
    it; Esc stops it, Backspace clears it, `shown` names the value, and `ui_capturing()` tells the host;
  - `note="..."` under any control's label (`.ui-note`); a range's `decimals`, `format="percent"` and
    `unit`; a track laid out as a row, with the range's fill as tall as it;
  - popovers anchored beside an element (`anchor="id"`, or a bare `anchor` for the element before it,
    `placement`), flipped to the other side and kept on the screen;
  - `flex-shrink` (a scroll box in a column takes the room its siblings leave), `flex: grow shrink`,
    `order`, and text in a row wrapping in the room its siblings leave;
  - `calc()` over px, %, em, rem, vw, vh and `var()`; `width: 0` and `height: 0` mean 0;
  - `text-shadow`; tooltips of several lines; `ui_opacity()` for a native's draw;
  - `border-image` drawn as painted with no background colour, tinted by one, and not at all under
    `transparent`; a picture file drawn untinted (an atlas cell still takes `color`);
  - the render3d backend loads a picture again when its file changes (`ui_image_reload`), draws a path
    with a drive letter as a path, and slices a nine-slice by its texture's own width and height;
  - a component root that is itself a component takes every user's class, style and id, and the
    sheets that style it are weighed together by specificity;
  - a component's event may be called `set`; a `string` prop given a number reads it as text; two
    components of one name are an error naming both files;
  - the scrollbar is `.ui-scrollbar` and `.ui-thumb`: a press on the thumb holds it where it was taken,
    a press on the track jumps the thumb's middle there, and neither presses what is under the bar;
  - a popover's own controls take its presses whatever lies under it, a press outside only closes it,
    and while one is up the scroll boxes outside it do not take the pointer;
  - the first gamepad moves the focus (d-pad, left stick), steps ranges and selects, and presses (A)
    and goes back (B); a held direction, on the pad or the arrow keys, repeats after 0.42 s and then
    every 0.11 s on the ui clock (`UiInput.held_*`, `pad_a`, `pad_b` for a host);
  - pointer events: `on-pointerdown` / `pointermove` / `pointerup` / `drag` / `wheel` with `event.x`,
    `y`, `dx`, `dy`, `button` and `wheel`, and `ui_native_input(tag, fn)` for a native; a press captures
    the pointer until release; the pointer hits the topmost element in painting order, and
    `pointer-events: none` lets it through;
  - `on-down` and `on-up` on a button (the pointer, Enter or A), with `:active` true while it is held
    there rather than whenever the pointer is down over it;
  - an anchored popover's `align="start|center|end"`, and `within="id"` (by default the nearest
    scroll box around it) for the bounds it is flipped against and kept inside;
  - `text-fit: shrink MIN` shrinks a line to its box, then cuts it with an ellipsis; `line-height`;
    an `em` reads the font size the element ends with (a `font-size` later in the rule, or in a later
    rule), not the one it had so far;
  - `min()`, `max()` and `clamp()`, in `calc()` or on their own; `top` / `right` / `bottom` / `left`
    as a percentage or a `calc()` of one, of the containing block;
  - a nine-slice's corners are clamped to half the box in each direction on its own and cut on whole
    pixels (`ui_nine_cuts`), so a small key cap has no seam;
  - `scroll-top="{px}"` holds a scroll box at an offset, with `on-scroll` when the player moves it;
    `ui_scroll_set(id, px)` moves one once;
  - `linear-gradient(...)` backgrounds; `aspect-ratio`; `object-fit` for pictures (the renderer's
    `image_w` / `image_h`) and `ui_object_fit` for natives;
  - `translate="no"` keeps an element's text as written; a title of several lines is translated whole,
    else line by line;
  - `<input type="key">` takes a mouse button (`UI_MOUSE_LEFT` / `RIGHT` / `MIDDLE`, 256-258) and is
    `:capturing` while it listens;
  - a `title` shows for the keyboard's focus too, after the same half second; a focus ring drawn
    through a renderer with no `rect` no longer crashes;
  - a component with no stylesheet of its own reads a theme's `:root` variables from around it (it
    did; now a test says so);
  - `ui_scale()` and `ui_box("id")`, the scale and an element's laid-out box, for a host;
  - `on-submit` on a text field (Enter or A; the focus and text stay unless `clear-on-submit`);
  - `zoom` on any element, and a length over a length in `calc()` is a plain number;
  - `on-hold` every frame a button is held, with `event.dt` and `event.t`;
  - a transition lands exactly on its end value (it had stopped a rounding error short of it, at every
    frame rate).

  render3d gains `tex_width` / `tex_height`, and the XML reader keeps text runs among elements in
  order (`mixed`).

  A `view` field set to a literal or a named function's result needs no type.

  Screens are drawn through a registered renderer. `Value` gains a float kind.

  Also:
  - A program's function named like one of the runtime's is refused; it had been silently taking the
    runtime's own calls. So is one named like a compiler built-in (`run`, `exit`, `free`, `fill`,
    ...): every call to a program's own `run` compiled into C's `system()`, and clang failed on the IR.
  - An index is evaluated before the slice's elements are read. A `xs[f()]` whose `f` grew `xs`
    read stale memory.
  - A runtime error names the file its expression is in, not the program's.

  Two declarations with one name (a package's private global and a program's, say) are reported as
  such before type checking. They used to surface as a page of type errors about the wrong type.
- **English left is an error (phase 26.9).** Under a `lang` line, a template's own words, a text
  attribute's, a quoted choice that reads as words and a `@Text` row still holding English now refuse
  the build, where they were warnings; `ludic deps` still counts them as `english_left`. Hole counts and
  undescribed splits stay warnings. ludic.ui's own words - the key field's "Right click", "Middle
  click", "Left click" and "press a key..." - are keys (`ui_tk(ui_st, k"ui.right_click", plain)`,
  `ui.*` in the program's `.po`), with their plain English for a program that binds no translator.
- **Entity verbs are owned by the packages.** `ludic.character` declares `player` (`x y z yaw vx vy vz grounded`),
  `ludic.crowd` `peds_near` / `ped_get`, `ludic.cars` `cars_near` / `car_get`: a game that uses them offers them to the
  editor link with no code. `<kind>_near x z r max?` answers a count and fixed-width records, nearest first, at most 16
  (`max` defaults to 12) so the reply stays inside `DV_OUT`; `<kind>_get id` answers one record. Yaw on the wire is
  render3d's, in degrees [0, 360) (`dv_reply_yaw`, 0 faces -z). `ludic.base` gains `dv_near_limit`, `DV_NEAR_DEFAULT`,
  `DV_NEAR_MAX` and `dv_reply_yaw`. See `ludic.devlink/README.md`.
- **Generic records and functions.** `property Pool<T> { items: []T }`, `function first<T>(xs: []T)
  -> T` and `function map<T, U>(xs: []T, f: fn(T) -> U) -> []U`; a type writes an instance as
  `Pool<Thing>`, nested as deep as needed. A call's type arguments come from its arguments, or from
  the declared type its result is written into, and are refused with the parameter named when
  neither says. Each instance is compiled once as an ordinary record or function. `ludic-fmt` keeps
  `Pool<Thing>` together while still spacing `a < b`.
- **Inflate in a caller-owned context.** `ZInflate` holds everything one inflate works in - the bit reader,
  the RFC's length and distance tables, and every Huffman table and scratch list a block builds - made once
  by `z_inflate_new()` and rebuilt in place, so an inflate allocates nothing and each thread that inflates
  holds a context of its own. `z_inflate_in(z, src, len, out, cap)`, `z_uncompress_in` (zlib) and
  `z_gunzip_in` (gzip) take the context; `z_inflate` / `z_uncompress` / `z_gunzip` keep their signatures,
  working in the one context `RtInflateState` holds, so no caller changes.
- **Layers: `module flow in layer app uses base, items`.** The modules of one layer use each other
  freely and may go round; anything outside the layer is still held to the module's `uses` (a
  layered module with no `uses` reaches nothing outside its layer), and a cycle is refused unless it
  stays inside one layer. `ludic deps` shows the layers and counts the largest cycle without the edges
  inside them, printing the count with them beside it.
- **Map-scoped tables: `@PerMap` and `@Chunked(n)` registries** — a registry whose rows live in each map's directory and are read when the map loads, or a chunk at a time.

  `@PerMap @ByKey registry Props of PropRow from "props.lres"` reads `<maps root>/<map>/props.lres` (the root is `package.ludic`'s new `maps "assets/maps"` line), and `@PerMap @Chunked(64) registry Instances of InstRow from "instances/{cx}_{cz}.lres"` one file per chunk. The compiler writes the table's `state` and its verbs in the declaring module (`props_load`, `props_clear`, `props_find`, `props_path`; `instances_in`, `_out`, `_slot`, `_find`, `_clear`, `_path`) and a typed fill over a small runtime `.lres` reader (`runtime/native/lres.ludic`, spliced on demand): a row names any int or float constant by name (resolved at load), a `fn` value by name, nested records and lists. Rows, their lists and the records in them are pooled and refilled in place, and `_find` is an allocation-free hash, so a load allocates nothing past the table's high water and a frame may bring a chunk in. `@Ref(T)` into a map table is a string key, checked against the same map. `ludicc --check` type-checks every map directory's tables against their records with file:line:col diagnostics (`--no-maps` to skip). The schema gives each registry a `"scope"` (`"map"` / `"game"`) and `"chunk"`, and a map `@Ref` `"scope": "map"`; `@Unit` now has canonical ASCII spellings (`deg`, `m/s2`, `N.m`, ...), listed as the schema's `"units"`, and any other spelling is a warning naming the right one.
- **Memory is safe unless it says `unsafe` (L7).** `words(n)`, `floats(n)`, `fixeds(n)`, `doubles(n)`
  and `pointers(n)` are bounds-checked, zero-filled slices now, and the type names mean those slices;
  `buffer(n)` is a `[]byte`, with `text_of`, `Fs.read_bytes`, `Fs.write_bytes` and `view(xs, start,
  count)` beside it. `bytes(n)`, indexing a raw pointer, `free`, `resize`, `Memory.*`, the raw file
  calls, `data_of` and calling a C `extern` are refused outside `unsafe { }` / `unsafe function`, and
  a project's own files may write `unsafe` only with `--unsafe`; the runtime and packages are the
  platform and are unsafe throughout. A slice passed to an extern goes as its data.

  Making the buffers slices found, and this release fixes: `Sync`'s atomics operating on a slice's
  header rather than its cell; `words(n)` handing back uninitialised memory; `input.ludic` keeping a
  stick's fixed axes in an int buffer; truetype's fixed outlines allocated as ints; skinning's float
  matrices typed as ints. Rendering is byte-identical, and a frame costs the same.
- **Modules.** `module NAME` in a barrel makes its directory a module, and a module's
  declarations are private to it unless they say `export`: a function, global, record or event of
  another module used without one is an error naming the module and where to mark it. `friend
  module NAME` sees everything (a test harness), a file in no module is public, and a package keeps
  its own module. `LUDIC_VIS_REPORT=1` lists every violation instead of stopping, so an existing
  program can be given its exports by a script before the rule applies to it.
- **Namespaces are declared in Ludic.** `alias meth(labels) = target` in a `namespace` block makes
  `Ns.meth(...)` a call to `target`, taking named arguments by those labels; with no label list the
  target's own parameter names are the labels. The engine's 41 table-driven namespaces - `Http`,
  `Udp`, `Process`, `Json`, `Value`, `Screen`, `Input`, `Audio`, `World`, `Tiled` and the rest, 438
  methods - moved out of the compiler into `runtime/native/namespaces.ludic`, and a package owns an
  API the same way. The code a program compiles to is unchanged byte for byte, and the checker now
  checks an alias call's arguments against its target.
- **No function writes a global: a module's changing data is a `state`.** `state Hiker { hips: int =
  -1 }` is a record with exactly one instance, which no code can name; it reaches code as a parameter,
  `h: mut Hiker` to change it or `h: Hiker` to read it, and the runtime supplies it at the entry points
  (`entry (h: mut Hiker)`, a handler's, a listener's or a lifecycle hook's parameters, a scene's `on
  enter (h: mut Hiker)`, a test's, a `ui` block's `Hiker.hips`, a function value - a system's, a port
  bind's, a package's callback - an engine system, a namespace method's target and every call into the
  runtime). A module-level `var` is refused; a module-level `let` is immutable all the way down. A
  read-only state is checked where it is written - an assignment or a `push` through it or through a
  local holding part of it, passing it where `mut` is wanted, a `machine` over its field - and so is a
  module-level `let`. Each test block gets fresh states. A program's type named like one the runtime
  declares (`property PadButton` beside the runtime's `enum PadButton`) is refused instead of failing
  in clang.

  `ludic migrate state [file|dir...] [--runtime] [--dry-run]` moves programs there: a var nothing
  writes becomes a `let`, each module's other vars one state (`FishingState`, `Render3dState`,
  `SceneDemoState`), every reference `fishing_st.name`, each function's states - to a fixed point over
  what it calls - its leading parameters, `mut` where anything below it writes, and each entry point
  declares them; the plans of every program given are merged before a file is edited. gpp's 35
  mechanic packages, ludic.ui, ludic.render3d, every example, the docs' fences and the runtime were
  moved with it. The toolchain's own programs build with `--globals` until they move too.

  Outside the runtime, the drawable's size and scale, the screen's framebuffer and the tilemap's tile
  size are read and set through its functions (`gl_width()`, `gl_set_drawable(w, h)`,
  `gl_screen_fbo()`, `gl_pixel_scale()`, `rt_map_tile_size()`), and ludic.ui's render3d backend
  installs itself through the `UiRenderers` registry.

  A component names the states its members read and change in its header, `component Tally (score:
  mut Score, look: Look) { ... }`: every getter, default, function and event takes them before the
  instance, a member's call to another passes them on, ludic.ui's calls into it are supplied them, and
  the template never sees them. `ludic migrate state` writes those headers (and adds to an entry
  point's or a component's existing list), gives a program's module named like a package a state of
  its own (`FishingAppState`), keeps a package's settable vars as state, rewrites a program's
  references to vars a package already moved into its state, and writes only under the programs and
  directories it is given - a change needed anywhere else stops the run with the files named.
- **Packages count under `uses`, and the mechanic packages hold themselves to it.** A module that
  says `uses` must name every package module it reaches (`ludic_inventory`, `ludic_ui`); a package
  with no `module` line is named for its directory (`ludic_render3d`), so a mechanic reaching into
  the renderer is caught. Only the engine's own runtime needs no naming. `module x uses` with nothing
  after it reaches no other module. A port whose every member has a default may go unbound and
  answers with its defaults. ludic.base, ludic.clock, ludic.effects, ludic.inventory, ludic.wallet,
  ludic.weather and ludic.tracks say `uses ludic_base` (ludic.base: nothing), and their records of
  function values are ports - `clock_bind(w)`, `inv_bind(r)`, `weather_bind(w)` and `tracks_bind(w)`
  are gone; a game writes `bind ClockWorld { ... }` (and so on) instead.
- **Packages stop reading the summer clock.** Rules that were about the light or the day's rhythm are asked
  of the game: `WildlifeWorld.heat` / `drinking_time` (thirst climbs in the heat and when they go down to
  drink), `PhotoLight.sun_elev` (the golden hour is the sun between -1 and 15 degrees, a flat noon one above 60;
  `PHOTO_NO_SUN` leaves the clock's hours), `NpcWorld.after_dark` / `deep_night` / `sunset` / `window` with
  `NpcStep.window` and `NpcKind.leave_by_sun` (a routine hangs on the game's windows of the day, a kind leaves
  at hours after sunset), and `WeatherWorld.wind_up` (the wind turns when the slopes are warm). Every member
  defaults to the old hours, so a game with no sun behaves as before.
- **Ports: `port Clock { now: fn() -> int, day: fn() -> int = fn first_day }` in a module and
  `bind Clock { now: fn game_hours }` where the program is put together.** A module asks for what it
  needs through `Clock.now()` without naming - or `uses`-ing - the module that answers. A port used
  and never bound, a bind that leaves out a member with no default, a member the port does not have
  and a second bind are refused; the binder must see the (exported) port.
- **Registries by declaration.** `registry Furnishings of Furnishing as HF` declares a table of
  records, and each `def Furnishings chair { name: "Camp chair", cost: 60 }` - in any file - is an
  entry of it, filled before any code runs. Every entry gets an index constant (`HF_CHAIR`, in
  declaration order), the table a count (`HF_COUNT`), and a record with a `key` field gets it filled
  in and a lookup, `furnishings_find(key)`. A def's fields are checked; a record literal naming a field
  its record does not have is now an error everywhere.
- **Resource files.** `registry Tools of Tool as TL from "data/tools.lres"` fills a registry from a
  data file of `key { field: value }` entries. It is read at compile time with the registry's record as
  its schema - a misspelt field, a wrong type or a repeated key is a compile error at the resource
  file's line - and compiled in, so nothing parses at start-up. Nested records and lists of them are
  bare `{ ... }` / `[{ ... }]`, typed by the schema; values are expressions, so an entry names another
  table's entry by its constant.
- **Text keys: `k"pause.resume"`, a `Key`, checked against `en.po`.** A text the player reads is named by
  a key of the new builtin type `Key` (`kn"..."` for a plural) - not a string, and no string one; at run
  time its text after a marker byte, so a runtime's `tr` is a cast. `lang "assets/lang" en` in
  `package.ludic` names the source language's `.po`, and the compiler holds every key to it: a key
  literal, a template's `t('key', ...)` and a registry's derived `@Text` key (`<registry>.<row>.<field>`,
  or `@TextKey("steps")`'s prefix; filled into a `Key` field a row leaves out) must be there, a plural
  one with a `msgid_plural`; `trf` / `trn` / `t()` given another number of values than the English has
  holes, text still written in English (a template's words, a `@Text` row's value - counted as
  `english_left` by `ludic deps`) and one English split into keys without `#.` descriptions are
  warnings. `ludic schema` gains `"lang"`: every key with its sites, unused and undescribed keys, splits,
  and each other language's missing, fuzzy and extra keys.
  A `Key` in a template literal's hole is an error (write `trf(k"...", ...)`), `trn` takes only a plural
  key and `tr` / `trf` refuse one; a program with no `lang` line (a package test) uses key literals
  unchecked and silently.
- **Textures a game baked at build time are read before the PNG.** `png_decode` first takes
  `assets/baked/png/<path>.tex` (a game's `ludic bake` output: the samples, ready to upload), and a cut-out
  load (`tex_load_ex` with dilate) first takes `assets/baked/cutouts/<path>.bc7` (padded as `tex_dilate`
  pads, then BC7 with its mips) - so a boot decodes, pads and converts nothing it can take ready-made. Both
  are ludic.base's baked form, read by hand (baked_tex.ludic: the "LBAK" header, the key and version); a
  missing or stale one falls back to the PNG as before. `tex_load_dds_at` reads a .dds at an offset.
- **The blades' density window can be filled without a GPU.** grass_density.ludic's gb_frame is split: gb_window_fill
  fills the GB_TILES x GB_TILES window of density tiles round the camera's (zeros off the map) and sets its corner,
  and gb_frame sends it. The same bytes as before; a test reads gb_win after gb_window_fill.
- **The built-in ECS grows.** Every component was a fixed array of 1024 slots, so a game past 1024
  entities could not have them (and until the last release silently corrupted memory trying). The
  per-entity stores are heap blocks now, doubled by `L_grow` as entities outgrow them, the new slots
  zero: 100 000 entities spawn and query. `Prop.has` bounds against the live capacity and
  `Pool.capacity` answers it. A snapshot (`save`/`load`, `world_save`/`world_load`) records its slot
  count first and a load grows to it before reading the stores back, so a snapshot's size follows the
  world's instead of a fixed 1024. A mod's registered components grow with the rest.
- **The ground's heights a chunk at a time: `terrain_chunk_heights(i, j, size_m, n, out)`.** For
  whatever is built per chunk (plan 23.5 of maroon-lake: the physics ground by 64 m chunks): n x n
  samples of chunk (i, j) of a grid laid from the terrain's corner, row-major into the caller's
  buffer, nothing allocated. Each is the ground's cubic B-spline at the texel under it - the
  separable (1 4 1) / 6 filter `ter_spline_at`, the same numbers ludic.physics' B-spline
  heightfield makes of the whole map - so neighbouring chunks share their edges bit for bit and
  agree with the drawn ground. The read-back lives from `terrain_generate` to `terrain_unload`.
  `examples/rendering/chunks.ludic` holds it.
- **The sun in the sky is drawn where the light comes from.** The sky photograph's own sun disc stands at one
  elevation (48 degrees) however the day turns it, so at 19:24 in July the light came from 11 degrees while a bright
  glow sat at 48. While a day runs, `sky.frag` now paints the photograph's disc and its glow out (the sky round them
  fills it, 4 to 10 degrees from the disc) and draws the real sun instead: a disc and an aureole of the light's own
  colour at the real direction (`daylight_set` keeps it in `sky_disc_dir` / `sky_disc_col`, apart from the light, which
  is lifted to 3 degrees and handed to the moon at night), cut by the horizon, so a sun that is down draws nothing. A game
  that never starts a day sees the photograph as before. The image-based light is unchanged: it is convolved with the
  sun clipped, so the disc's energy was never in it, and only the clipped glow (about a tenth of the ambient, soft and
  wide) stays where the photograph has it.
- **The sun is where it really is.** `ludic.render3d` gets `solar.ludic` - NOAA's general solar position
  calculation (`solar_elevation`, `solar_azimuth`, `solar_declination`, `solar_noon`: a latitude, a longitude,
  the clock's offset from UTC, a day of the year and an hour) - and `daylight_site(lat, lon, utc)` /
  `daylight_date(doy)` put the day's light on a site and a date: the sun's height and bearing, the moon (where
  the sun was a phase of a day ago) and the sky's turn all follow, and every curve that was keyed to the old fixed
  arc (the haze, the grade, the exposure) is keyed to the real elevation. Without a site the old arc runs as before.
  The photograph's sun disc is turned to sit exactly under the light (its own azimuth, not the start's), the terrain
  shadow's step is measured on the sky (a sun near the zenith sweeps azimuth fast and its shadow barely moves), and
  the sky's convolutions are only rebuilt once they exist.

  `ludic.clock` gets `clock_dates(month_starts)` and `clock_doy()` / `clock_doy_of(day)`: the real day of the year
  each game month begins on, so a game day lands on a date (ten to a month, the month's real length) and a sun or
  a season can follow it.
- **The sun's hours: `solar_sunrise` / `solar_sunset` (render3d) and `clock_set_sun` / `clock_set_night` (clock).** Where
  the sun crosses the horizon on a date, from a site (latitude, longitude, the clock's UTC offset) and a day of the year,
  found where it happens (the declination and the equation of time move through the day) and held to the almanac at
  Maroon Lake. `ludic.clock` keeps the hours the game last told it (`clock_sunrise` / `clock_sunset`, 6 and 20 until it
  does) so a window of the day can be an offset from them, and `clock_set_night` moves `clock_is_night` with the day.
- **`@Asset(kind, map)`: a path under each map's directory.** A field whose file lives in the map's own folder
  (a grass kind's density picture, `ground/blades.png`) says so, and `ludicc --check` looks for it in every
  map - a @PerMap row's in its map, a game-wide row's in all of them - refusing a map that lacks it unless the
  field is `@Asset(kind, map, optional)`. The schema marks the attribute `"scope": "map"`.
- **`Json.write_file(value, path)` saves without keeping anything.** It writes the text
  `Json.encode` would give straight to the file (through `path.tmp` and a rename), built in a buffer
  the runtime keeps, so a game that saves often holds nothing more for it. `Json.encode` itself is
  built the same way and makes only the string it returns: it used to join its text with `+`, keeping
  every piece and every number's text. `examples/lang/json_saves.ludic`: 1000 saves, 0 bytes.
- **`Udp.open_local(port)`: a socket only this machine reaches.** Bound to 127.0.0.1 alone (udp.ll,
  udp_win.ll), where `Udp.open` binds every interface - for a port only local tools should talk to, such
  as a development link.
- **`bind Purse { money: g_money }` - a port member bound to a variable.** A member that takes nothing
  may name a global instead of a function; the compiler writes the getter in the bind's file, so the
  one-line wrapper is gone. A member that takes something is refused a variable.
- **`def Recipes from "recipes.lres"` - a game fills a package's open registry from its own resource
  file.** The entries are checked against the registry's record as the file is read, with errors at
  the resource file's line, and they are defs of the module that wrote the line: the registry must be
  open to it, and they sit in the stable order (the declaring module's entries, then other modules'
  by name, and file order within a file).
- **`export open registry Items of Item` - a registry other modules may add to, in a stable order.**
  A `def` from another module into a registry that is not open is refused, and a def now goes
  through visibility like any reference (the registry exported, its module in the definer's `uses`).
  An open registry's index order is the declaring module's entries first, then every other module's
  by module name, each in the order it is read - independent of the order a barrel imports them in.
- **`friend module lab of fishing, data` - a friend of some modules, not all.** A scoped friend sees
  the private names of the modules it names and only the exports of every other; `friend module lab`
  alone still sees everything.
- **`gltf_cached(dir, file, node)` loads a still model once.** The same directory, file and node asked
  again hands back the model the first load made, found by comparing the names in place, so a game
  that places props while it plays - a fish, a bobber, a sign an animal leaves - reads no file and
  parses no document after the first. The model is shared by every actor drawing it and never
  released. A model whose document is read after the load (ludic.anim's clips) still goes through
  `gltf_load`.
- **`ludic build --check` / `ludicc --check`: check without building.** The parse, the type checker
  and the module rules (`export`, `uses`, layers, ports, registries) run, and nothing is emitted or
  linked - about three seconds on Maroon Lake where a build takes about a minute. In this mode the
  checker asks the module rules at each reference it resolves, since the emitter that usually asks
  them does not run.
- **`ludic deps --writes` warns about a write through a local alias.** `let t = thing_cur` and then
  `t.used = 1` writes another module's record just as `thing_cur.used = 1` does; a local bound straight
  from another module's global (or from such a local) is now followed within its function and each
  write through it listed as a warning. A reference that arrives from a function's result is not.
- **`ludic deps` - the module graph as the compiler resolved it.** It compiles the program with
  `LUDIC_DEPS` set, and the compiler records every reference its visibility pass sees (from module,
  to module) and every assignment to another module's global. It prints the modules, dependencies,
  largest cycle, cross-module writes and globals written from outside; `--graph`, `--dot`, `--writes`,
  `--uses MOD`, `--check FILE` and `--baseline FILE`.
- **`ludic schema` carries the code map: a `"code"` section.** Beside the records, registries and
  `lang`, the schema now lists what an editor's code map needs, from the compiler's own reading:
  `modules` (uses, layer, friend, files), `states`, `actions`, `reducers` and every `dispatch`, `events`
  (cancellable, net) with every `emit` and their `@On` listeners, `ports` (members with their `fn`
  types and defaults) and `binds` (port, member, the function named, where), `handlers` (phase, hook
  and what it names, `@Public`, `@Server` / `@Predicted`, `@Queries` with their filters, the scene and
  layer), `models` (`@Owned`, `@Sync`), `prefabs`, `scenes` (start, shows, lasts / loads and what
  follows, layers) and `fn_refs` - every `fn name` in code or in a resource file, with the slot it
  fills (a registry's field and row, a port's member, a record field, an argument, ...). Every place
  is `"file:line:col"`; the rest of the schema is unchanged, so `schema_version` stays 1.
- **`ludic test -j N` runs tests side by side.** Every file is compiled, linked and every test block
  run as up to N jobs at once (default: the machine's CPU count), each test with a `TMPDIR` of its own,
  and the report comes out in file order. `ludic test packages` takes about half the time.
- **`ludic test <dir>`, and every test block in a fresh process.** A directory stands for the
  `*_test.ludic` files under it and the files straight inside any `tests/` directory under it. Each
  `test` block now runs in a child process of its own (the runner answers `--list` and runs one test
  by name), so tests no longer share globals; a file's line says how many tests it ran. A failed
  `expect` names the file it is written in, not only the base name of the program's root.
- **`ludic ui-preview`: a game's ludic.ui components previewed for a studio, over stdio.** A new
  prebuilt tool (`bin/ludic-ui-preview`, built by `ludic-dev build` and shipped beside `ludic-lsp`) that
  is ludic.ui with a backend that records every draw call as a line of text, and component classes the
  studio describes: their template and styles (`load`, unsaved text welcome), their model (`model`),
  their functions' answers (`calls`). `frame t` runs ludic.ui's own frame - build, cascade, layout,
  input, draw - at interface time `t` and writes the draw list, then what happened (template errors
  with file and line, calls, sets, emits, sounds); text is measured with the game's `font.json`
  metrics on the CPU, translated through ludic.i18n with `locale`, and `tree` / `box` / `rules`
  inspect the frame, rules with the file and line they were written on. No game code, no GPU, no
  network. The wire protocol is frozen as `tools/ui-preview/protocol-v1.md`. ludic.ui gains what it
  needs, all additive: `UiClass.make_of`, `UiBackend.said` / `emitted`, `UiRule.text` / `at`, and
  `ui_root`, `ui_find`, `ui_rules_of`, `ui_class`, `ui_class_load`, `ui_file_forget`,
  `ui_errors_clear`, `ui_building`.
- **`ludic-fmt` enforces a project's style.** `lint` lines in `package.ludic` state it - one statement
  per line, file, function and comment-block limits (a file's opening comment its own) - and
  `ludic-fmt --check <files>` and `ludic-fmt --lint` (the project's paths) fail what breaks them, at the
  line. A baseline file is the ratchet that lets a rule arrive in an existing codebase: the counts a
  file had may stay but not grow, and they are lowered as they are fixed.
- **`ludic.anim` carries ozz-animation (0.17.0, MIT) as a native library**, the second package to do
  so after `ludic.physics`. Its skeleton and each clip are built at LOAD from the numbers the package
  already reads - a skin's parents and rest pose, a clip's flattened channels - so there is no bake
  step and no new file. `anim_oz_skel(sk)`, `anim_oz_clip(c)`, `anim_oz_ctx(s)` and
  `anim_oz_sample(ctx, clip, t, rot, pos, n)` are the first step (Maroon Lake's phase 19.1): a sampled
  rotation agrees with `anim_mix` to within 1e-4 a component. `anim_play` is unchanged. The library is
  built by `native/build.sh` from the pinned release, and on Windows it imports KERNEL32 alone.
- **`ludic.anim`: a clip's planned length; `ludic.base`: where a signal source's words come from.**
  `AnimClipInfo` gains `@Unit("s") duration: float` (0: unknown), the length a clip is planned to have before
  it is authored; the studio's graph simulation and problems read it (`clip_duration: "duration"` in
  ludic.anim's studio.lres) and the runtime ignores it, since the real clip's own length wins once it exists.
  `SignalSource` gains `words: string`, `"Registry.field"` entries comma separated, naming the table the words
  of a fact or text source come from; `ludic.cars` (the seat `state_*` fields) and `ludic.weapons` (the class
  `clip_*` fields and `hold`) fill it, so a studio can check by-name bindings without the game running.
- **`ludic.cars`, `ludic.physics`: a parked car costs about nothing.** A game that fills its car parks with real cars (bodies near the
  player, planar models further out) paid for every one of them every step, at rest or not: a car park of 90 parked sedans cost 0.47 ms a
  frame (Jolt 5.6, 60 Hz), 95 % of it Jolt's step, where a wheeled vehicle casts its four wheel cylinders every step even with its body
  asleep (`VehicleConstraint::mNumStepsBetweenCollisionTestInactive` defaults to 1).

  * `ludic.physics`: a vehicle asleep does not cast its wheels again (`SetNumStepsBetweenCollisionTestInactive(0)` in `jph_vehicle_make`):
    Jolt's simplified test keeps the last contacts, which nothing can change while nothing wakes the body (a contact, a push, a pedal or
    the wheel all do). A contact body taken away is let go by Jolt as before. Awake, every wheel is cast every step as before.
  * `ludic.cars`: `CarBody.awake(nid)`, a new port field (unbound: always awake, the old behaviour). A body car nobody is in, getting into
    or driving, with no AI and no horn, whose body the game says is asleep is not stepped (no read, no pedals, no wheels); a planar car
    or lane-following car left alone that has stood still `CAR_REST_T` (1 s, under `CAR_REST_V`) is not stepped either. `Car.asleep` says which were left the
    last step, `cars_asleep(st)` how many. A driver, a door or the AI steps the car again from the next step.

  * `ludic.cars`: `car_body_near(st, nid, m)`: a car that needs a body only close up (a parked car) is a body within `m` of a viewer
    when that is under `CarSettings.body_dist`, a planar car further out (0 gives it the settings' distance again). A full car park
    within the 150 m body distance was more Jolt vehicles than `ph_vehicles`' 256. `car_place` now also clears the rest timer.

  Measured (the OccuTown sedan, 60 Hz): 90 parked bodies 468 -> 57 us a frame; 90 parked planar cars 200 -> 3 us. Tests:
  `vehicle_test` "asleep it casts no wheel but keeps its contacts and its height; a push wakes it", `cars_planar_test` "a car nobody is
  at ... is not stepped", `cars_body_test` "a car given a nearer body distance". The macos-arm64 library is rebuilt (Jolt v5.6.0, SHA-256 checked); the windows-x64 one needs `native/build.sh`
  on the PC (no new symbols: until then a parked vehicle there is cast as before).
- **`ludic.cars`: a car can break down instead of wrecking, and a hurt engine sputters.** `CarSettings.breakdown`
  (off by default) turns health at 0 into a breakdown: `CAR_BROKEN`, health held at 0, the engine dead and off (it will
  not start), nobody thrown out, steering and brakes kept; `car_broken(cars_st, c)` asks. `car_set_health(nid, hp)` sets
  the body's health (a broken car given health has its engine back, in proportion, and runs under a driver);
  `car_repair` restarts the engine under a driver. `CarSettings.sputter_at` (0 off): under that share of body health a
  running engine misfires (`CAR_MISFIRE`), the torque falling with the health; both drivetrains share the hurt engine's
  share (`cr_engine_share`). Fixed: with the engine off the brake pedal of a vehicle or a planar car stayed reverse's
  throttle once the car had backed up, so it did not brake.
- **`ludic.character`: the water is asked at the body's height.** `CharacterGround.water` is `(x, y, z)` now: `y` is the
  body's feet (the walk's next place, the safe spot's ground), so a game whose water has levels under it (a tunnel's
  tube under a bay, a deck's underside below the surface) says "no water" for a body that is sealed off from it, and the
  body walks on instead of starting to swim. An unbound port is still dry; a binding that ignores `y` behaves as before.
  The test world has a tube under its lake: a walk down into it never swims, the same walk beside it does.
- **`ludic.devlink`: an editor's live link into a running dev build** (protocol v1, frozen with Ludic
  Studio). Loopback UDP through the `DevlinkNet` port, one request a frame parsed in place from one fixed
  8 KB buffer and answered into another; every verb a `DevlinkWorld` member defaulting to "not offered":
  `ping`, `hello` (the build's schema hash as 16 hex digits), `cam_get` / `cam_set` / `cam_release`, `goto`,
  `map_load`, `time`, `weather`, `shot`, `pause` / `resume` / `step`, the slow three answered later by id.
  A socket is opened only when `enabled()` says so (by default `dev_mode()`, see ludic.base), a sender off this machine is
  dropped, and a connected co-op session refuses everything but `ping` and `hello`.
- **`ludic.devlink`: the interface's verbs.** A `DevlinkUi` port, every member defaulting to "not offered":
  `ui_screen` (the screen's root class and its components), `ui_model "<Class>" "<out>"` and `ui_tree "<out>"`
  (the game writes a component's model or the whole tree to a file, no `..`, and the answer names it, so a
  datagram stays small) and `ui_override "<path>" "<file>"` (a template or stylesheet read from another file
  and reloaded keeping state; `""` clears one, `"" ""` all). Answered at once; nothing made per frame.
- **`ludic.devlink`: verbs are declared by whoever owns them, with their argument shapes.** A game or any
  package adds a verb with `def DevVerbs goto { args: "x:float z:float yaw:float?", run: fn goto_verb }`
  (`DevVerbs`, `DevCall` and the `dv_*` readers and reply writers are `ludic.base`'s, so a mechanic needs nothing
  but `ludic.base`). Devlink reads each request against the shape (`int`, `float`, `string`, `bool`, `?` for
  optional; a wrong one is `err bad_args "bad arguments: goto x:float z:float yaw:float?"`) and a verb that takes
  a while answers later by id through `late`. `hello` keeps its six v1 values (the verb list now includes the
  declared verbs) and adds a seventh with every declared verb's shape: `"goto x:float z:float yaw:float?;weather key:string"`.

  **Breaking for a game that binds `DevlinkWorld`:** `teleport`, `load_map`, `map_state`, `set_time` and
  `set_weather` are gone; `goto`, `map_load`, `time` and `weather` are now verbs the game declares. The core
  verbs (`hello`, `ping`, `cam_*`, `shot`, `pause`, `resume`, `step`, `ui_*`) stay in devlink.
- **`ludic.gear`: a charge's `low`.** `GearCharge` has a `low` level - the charge under which a game says it
  is nearly out - so a hint reads it from the row instead of a literal of its own. Default 0 (never low).
- **`ludic.hints`: who opened the card.** `HintsState.hn_own` is set when the player's key opens a card
  (`hints_key`) and cleared whenever the card closes, is muted or goes; `hints_own` reads it and
  `hints_keys_act` says what the arrows and Enter mean this frame - the card's walk and mute only for a
  card the player opened, nothing (they pass through to the game) for one shown on its own.
- **`ludic.i18n`: keys (phase 26).** A key names what a text is for, and `en.po` says it in English like any
  other language. A key is a string with a marker byte (`I18N_KEY`, `I18N_PLURAL`), its arguments after
  byte 31, so the code that makes text never takes `I18nState`: `tr(k)`, `trf(k, a, b, c, d)` and
  `trn(k, n, a, b, c)` build it, and `L` makes it into text where it is drawn - the language in use, else
  en.po (read the first time a key is asked for), else the key itself, `[[key]]` in a developer's build
  (`i18n_loud`). Holes take their arguments in the language's order, a key argument made first; plural
  keys go by each language's rule. A string with no marker takes the old English path, so a game can
  move over a file at a time.
- **`ludic.launcher`: a cinematic look.** Dark translucent panels, 1px hairline borders, 6px radius, small letter-spaced uppercase labels, a large title, a narrower vertical menu with accent hover and focus, and a tidy news card; all of it variables in `theme.lss` (`--lc-panel`, `--lc-line`, `--lc-radius`, `--lc-secondary`), so a game restyles it by data. The dimming veil child (positioned, so painted over the content) is gone: the shade is the screen's own gradient background.
- **`ludic.physics`: `phys_heightfield_tiles`.** The same ground as `phys_heightfield` cut the way `ludic.render3d`'s terrain mesh cuts it. Jolt splits
  a heightfield's cell from (i, j) to (i + 1, j + 1) and the renderer's level 0 from (i + 1, j) to (i, j + 1), so over four samples that are not in one
  plane (a bluff, a crest, a quay's edge) the surface a body stands on and the surface that is drawn differ by up to a quarter of the twist (24 cm on a
  2 m bluff over 1 m cells). This one lays the samples out a quarter turn round and turns the shape back inside its body, so the surface a ray finds is
  the mesh's. Same arguments, same `PHYS_HOLE`s; a game that draws a `TileMap` stands its ground on this.
- **`ludic.physics`: continuous collision detection per body.** `phys_ccd(st, id, on)` gives a dynamic body
  Jolt's `LinearCast` motion quality, so its shape is swept over each step and stopped at what it would
  skip: a car at 60 m/s moves a metre a step, more than a wall is thick. `phys_is_ccd(st, id)` asks. Off
  by default (a sweep costs); a still or kinematic body, a removed id or no world answers `false`. The shim
  gains `jph_body_ccd` and `jph_body_ccd_of`; `jph_body_add` is unchanged. The macos-arm64 library is rebuilt
  (Jolt v5.6.0, SHA-256 checked); the windows-x64 library still needs `native/build.sh` run on the PC for the
  new symbols.

  Measured (Jolt 5.6.0, 60 Hz, 1500 kg 4.4 m boxes): two cars head-on at 55 m/s each swap places without it,
  overlap 0.64 m with it on one, 0.02 m with it on both, so **a game sets `phys_ccd` on both cars**; a car at
  60 m/s into a standing car or a 0.1 m barrier is stopped by its own flag alone (the target's changes nothing).
- **`ludic.physics`: ragdolls and sensors.** A ragdoll is Jolt's `Ragdoll` (Samples/Utils/RagdollLoader.cpp's way): a
  definition built in calls (`phys_ragdef_begin`, `phys_ragdef_part` a part at a time - its joint, a capsule between two
  points in the joint's space, a mass, a swing-twist constraint to its parent with a bend for a knee or an elbow -
  `phys_ragdef_make`), then any number of ragdolls of it added from a pose and velocities (`phys_ragdoll_add`) and read back
  as bones every frame (`phys_ragdoll_read`: a part's body stands at its joint; `false` once every part sleeps). Parts sweep
  (LinearCast: a limb is thinner than a step's travel and a road's mesh has no thickness); parts that touch in the
  definition's pose never collide. `phys_sensor(st, id, on)` makes a body a sensor: its contacts are facts, it pushes
  nothing, and no query (ray, top, overlap, push) finds a sensor. `phys_step_us` is the last step's time in Jolt. The shim
  gains `jph_rag_*` and `jph_body_sensor`; the queries skip sensors. The macos-arm64 library is rebuilt (Jolt v5.6.0); the
  windows-x64 library still needs `native/build.sh` run on the PC for the new symbols.

  Measured on the island (M-series Mac, 60 Hz): Jolt's step 58 us with no ragdoll, 350 us average (530 worst) with six to
  eight 12-part ragdolls moving at once.
- **`ludic.render3d`: `gltf_accessor_ints` and `gltf_tris`.** `gltf_accessor_ints` gives an accessor's integer components (bytes, shorts or
  ints, signed or not) as `words`, the way `gltf_accessor_floats` gives the float ones. `gltf_tris` reads the triangles of every node a prefix
  names into two shared lists (points, and three point numbers a triangle), for a game's physics mesh or nav ground: one scratch serves every
  file, a model's own transforms are not applied. Both beside `gltf_points`, which reads the points of a model's convex collision pieces.
- **`ludic.render3d`: a clearing thins only the layers it names.** A `GroundClearing` row has `layers` (`"scatter"` for the
  layers that are not solid, `"solid"` for trees, rocks, stones and gatherables, `"blades"` for the GPU grass); none named
  keeps the old rule, every layer. `ground_clear_for(st, class, x, z)` is the question per class (`ground_clear_at` asks
  scatter), `r3d_ground_clearing_only(st, mask)` sets the clearing put last, and `grass_cull.comp` skips a clearing whose
  mask leaves the blades out, so a view corridor can open the trees and leave the meadow. A clearing is `GD_CLEAR_W` 11
  floats now (the mask is the last).
- **`ludic.render3d`: a grass kind.** The GPU blades' per-kind numbers - the cell, the spacing and its
  doubling distance, the reach, the row bands and rows, the blade's profile, heights, tussocks, width and
  arch, where it grows (slope, snow line, the photograph's green), its root, tip and gone-to-seed colours,
  the far tufts, the root's occlusion, roughness, sheen and wind - are a `GrassKind` record a game hands
  over with `grass_kind_set`, not constants in `grass.ludic` and the blade shaders. The defaults are the
  old constants, so a game that sets nothing draws what it drew. `grass_quality(s0_min, r_max)` holds a
  kind to a settings tier; `grass_profile_w` / `grass_profile_bend` are the one blade profile, for the
  meshes and a game's own preview of a kind.
- **`ludic.render3d`: a ground layer's `wade`.** `GroundLayer` / `GroundFill` have a `wade` - the deepest water, in
  metres, a layer grows in - so a map keeps its meadow tufts and flowers out of its lakes from the row itself
  (`ground_water_depth` says how deep a plane's water is over a point). Default 1000 (grows anywhere), so a row that
  says nothing grows as before; a solid or shoreline layer (cattails, mussels) leaves it.
- **`ludic.render3d`: a low sun is the colour the air leaves of it.** The sun's warmth was a ramp that stayed
  white down to 20 degrees and only greened at 11 - and a basin whose ridges take the sun at 15 to 20 never
  saw it warm. Its colour is now each channel's transmittance toward the sun (Kasten & Young's air mass,
  Rayleigh scattering by Bucholtz's fit, Angstrom's aerosol: `solar_air_mass`, `solar_transmit`) over the same
  at the photograph's own sun, held at 1 above it: a fifth of the blue gone at 21 degrees, half at 11, and the
  light dims with the air it crossed. `daylight_air(pressure, beta)` sets the site's air (pressure over sea
  level's, Angstrom turbidity; 1.0 and 0.06, a clear day at sea level, by default). Noon and anything above the
  photograph's sun draw as before.
- **`ludic.render3d`: a map's own rock, how its air thickens toward dusk, and a thinner wall haze.** The terrain's
  rock was dyed one fixed maroon in the shader, so every map had the Bells' mudstone. It is now `ter_rock_r` /
  `ter_rock_g` / `ter_rock_b` (`u_rock_tint`: the rock's mean albedo, linear) and `ter_rock_strata`
  (`u_rock_strata`: how hard the bedding shows on the steep faces), whose defaults are the old constants, so a
  game that sets nothing draws what it drew. The horizon's thickening of the air (`1 + 1.5 * lowsun` in
  `daylight_set`) is `day_lowsun_haze`, default 1.5: a high, dry basin sets less and a low sun's veil no longer
  buries the alpenglow. The haze the fog wall puts over the land past it falls to 0.05 at a kilometre (was 0.2), so
  a wall at 645 m takes about 0.11 of the horizon's colour instead of 0.24: a dark red face two kilometres off
  read lilac under it.
- **`ludic.render3d`: auto-exposure meters a histogram, favours the centre, and by day stays near the day's light.**
  It was the mean of the whole frame (the top of the mip chain), so a frame of shade was metered as if it were open
  ground: under a tree the exposure reached 7.0 against 0.83 on the meadow beside it and the shade read as noon.
  `adapt.frag` now sorts a 32-cell-wide grid of the frame into log-luminance bins, weighted toward the centre, drops
  the darkest 30 % and the brightest 2 % of the weight and averages the rest - Unreal's eye adaptation and Frostbite's
  camera (Lagarde & de Rousiers 2014) meter the same way; the band is averaged as light, as the old mean was, since a
  log mean raised a dusk frame a stop. By day the result is then held within 3 stops under and 1.5 over the exposure
  open ground would get from the sky's light on a level face and the sun's, and the hold fades out toward night: the
  tree is now 2.2. `post_metering(lo, hi, centre, below, above)` and `post_metering_open(share)` set it; (0, 1, 0, 16,
  16) meters the whole frame's mean as before. `post_key`'s default is 0.28 (the band mean's target; 0.19 was the whole frame's), and the
  adaptation's speed is unchanged.
- **`ludic.render3d`: the GPU blades grow where a painted density says.** `grass_density_layer(l)` names a layer of
  the ground densities (`ground_density_open`: the same 2 m texel, 64 m tiles, bake and dev fallback) as the
  blades'; `grass_cull.comp` then keeps a blade by that density, bilinear, where it used to apply its rules (the
  slope, the water's margin, the snow line, the photograph). Without one, nothing changes. The cull reads a
  window of 5 x 5 density tiles round the camera (160^2 bytes, a host-visible storage buffer, re-filled from
  the CPU tile cache when the camera crosses a 64 m tile), never the whole map. `grass_rule_at(x, z)` is the
  rules on the CPU, for a migration that paints them; `grass_density_texels()` the side a density PNG has.
- **`ludic.render3d`: the GPU blades keep to the clearings.** `grass_cull.comp` thins every blade by the clearings a
  game hands over (`r3d_ground_clearing`, `_area`, `_strip`; a map's `GroundClearings` rows), at each one's floor and
  feather, as `ground_clear_at` thins a trampled layer - so the long grass no longer grows through a camp's props, its
  logs and crates or a cabin's floor. The list rides to the GPU in a storage buffer of its own (`grass_clear.ludic`),
  sent again only when a clearing is put or the list let go, never per frame; the cull tests each clearing's box
  first (`tests/grass_clear_test.ludic`). The per-vertex path (`R3D_GRASS_GPU=0`) and the mesh-shader blades do not
  read them.
- **`ludic.render3d`: the fog wall leaves the land.** Past `r3d_fog_wall` nothing that costs is drawn - scatter
  layers, streams, actors, shadow cascades and the terrain's pages keep the wall's reach - but the terrain and the
  water draw to the camera's far plane under the day's aerial perspective and a share of the wall's haze
  (`u_fog_haze`: 0.5 at a 30 m wall, 0.35 at 175 m, 0.2 at a kilometre), so a skyline and its peaks stay in view at
  every fog distance. What the wall takes is dissolved by a dither over its last 30 m (six tenths of a nearer wall:
  `u_fog_cut`, `fogCut` in lighting.glsl, in model/depth/impostor/kit/oimp/hlod.frag) instead of ending in a line,
  and the sky's fog band and thick-fog cover take the same share. A cascade the wall left no layer for now reads lit
  (`shadow_cascade_none`) rather than sampling the last layer. New: `fog_land.ludic` (`r3d_fog_land`,
  `r3d_fog_land_set`, `r3d_view_far`, `cam_sphere_land`), `cam_sphere_in_view` (the frustum alone);
  `R3D_FOG_LAND=0` or `r3d_fog_land_set(false)` is the old wall. Maroon Lake, camp at fog 175 m: mean frame
  19.6 -> 20.3 ms (fog off 24.8), terrain pages unchanged (68 slots, 985 KB).
- **`ludic.render3d`: the forest past the fog wall.** The trees are grown only inside the wall's reach, so past it
  the slopes the land now draws through read as bare ground. A `GroundLayer` row may now say how much of the
  ground its crowns roof from afar (`canopy`, a share per unit of its mean density) and their colour (`canopy_r`,
  `canopy_g`, `canopy_b`, linear). At a map's open `ground_canopy_build` folds those rows' painted densities into
  one sRGB texture of the map (8 m texels, spread over 40 m, alpha the share roofed; 1024 x 1024 on an 8 km map,
  43-70 ms), and `terrain.frag` lays it over the ground where the wall's dissolve takes the trees (`u_fog_cut`):
  stands and glades from the densities and a 100 m field, and while a pixel is smaller than a crown, a crown on
  a jittered 5 m grid as a dome lit on its sun side with its gaps in shade (`canopyOver`, `crownCell`). It reads
  only while the land draws through a wall (`u_canopy_on`); with no wall nothing changes. New:
  `ground_canopy.ludic` (`ground_canopy_build`, `ground_canopy_sums`, `ground_canopy_side`, `ground_canopy_free`,
  freed by `ground_density_close`), `ground_canopy_tex.ludic`, `tests/ground_canopy_test.ludic`;
  `R3D_NOCANOPY=1` builds none. Maroon Lake at fog 4 (175 m): median frame +0.07 ms at the Bells view, +0.1 ms at
  the camp (six interleaved runs each); fog 9 pixel-identical.
- **`ludic.render3d`: the ground's rock line is the map's, the forest floor is a floor, and a meadow has
  forbs.** The terrain went to bare rock by height alone from a fixed 170-300 m of world y; on a map whose
  datum puts that in the middle of its spruce-fir (Maroon Lake: 3,130 m), the forest floor was painted with
  the maroon rock sheet, whose tiling read as ploughed furrows. It is now `ter_rock_line` / `ter_rock_band`
  (`u_rock_line`, `u_rock_band`; defaults 170 and 130, so a game that sets nothing draws what it drew).
  Where the photograph says dense conifer the ground is `forestFloor`: needle litter, darker humus and
  patches of low green (whortleberry, moss) a few metres across, with the turf sheet's own grain, and the
  photograph (a picture of crowns there) weighs a third as much. The meadow's own patches - the blades'
  patchiness, dry patches, tussocks and a new swale field (`grass_cull.comp`, `grass.vert` and the ground
  alike) - multiply the photograph as well as the ground under it, over their own mean, so they keep their
  strength. And a `GrassKind` can carry forbs in flower: `forb_share` of the GPU blades, in patches of
  `forb_patch` m, stand upright, `forb_wide` and `forb_tall` of a blade, the top `forb_tip` of each in one
  of three colours (`forb_a_*` .. `forb_c_*`); `grass_forbs_bloom` lets the game's season scale the share.
  0 (the default) draws none. The cull's Params block grew to 20 vec4s.
- **`ludic.render3d`: the tonemap keeps the scene's hue, and the day's contrast no longer darkens the shadows.**
  The filmic contrast (`post_contrast`, 1.23 at noon) was a power about mid grey, so it steepened BELOW mid grey as
  much as above: with ACES's toe a 6.5 : 1 sun-to-shade ratio reached the screen as 39 : 1 and a noon shadow on grass
  drew at 17-22 of 255. It now steepens above mid grey only (the identity below, eased over a stop): those shadows
  draw at 23-29. And ACES per channel turned a colour as one of its channels saturated - a bright red went orange,
  sunlit skin yellow-white ((243, 233, 214) at 8:00), a shaded orange shirt red, a blue sky cyan-white. The colour is
  now put back at the scene's own hue in Oklab (Ottosson 2020), with the lightness and the richness the per-channel
  curve gives (at least the scene's own saturation until it nears white, and the saturation the full contrast curve
  gave, so an opened shadow is not greyed), its chroma brought into gamut at that lightness and hue: the same skin is
  (249, 225, 209), the shirt's hue holds at 15-21 degrees in sun and shade where it ran 6 to 29. A grey draws exactly
  as before; the HDR10 output takes the same colour.
- **`ludic.roads`: a game can forbid a movement.** `roads_turn_forbid(e_in, e_out)` forbids the move from one edge into the next as
  a RoadTurns row would (routes go round it, a car never takes it) until the next `roads_build`: for a movement the rows do not rule
  out but the game knows cannot be made, such as a slip road into the far carriageway of a divided motorway whose median barrier runs
  on through the merge.
- **`ludic.roads`: junctions with a size.** A node was a point: a car went from one road's lane to the next at the node
  (a jump of a lane's width at a turn, of two at a U-turn), waited 1.5 m short of its centre (inside the junction drawn on
  the ground, on its crossings) and a junction let one car in at a time. A game can now give each road's ends their
  setbacks (`roads_edge_setbacks`: the waiting line, the turn path's mouths, the clear line), and then a car waits before its
  line, drives a continuous turn path from mouth to mouth (one cubic; a U-turn loops round a dead end's circle,
  `roads_node_uturn`), at its own speed along it, slowing for its bend (`roads_config_turn_accel`); takes its lane by the side
  it turns to (`roads_lane_onto`: a slip road merges into the kerb lane); is not let in while the lane beyond has no room (a
  junction kept clear); and, with `roads_config_conflict(width)`, goes through together with every car whose path keeps
  apart from its own. Lanes can begin where the bake paints them (`roads_edge_lane_base`: half a median, a one way road on
  the right of its line), `roads_config_jam(0)` leaves standing cars to the game, a car that waited 25 s goes first, and a
  wandering car with no place to go takes a road on instead of arriving. Along a turn path a car's gaps and body points are in ground metres (each car's road metres stretched through its turn paths to their
  own length: a follower behind a car in a U-turn's loop no longer crawls at the loop's pace, and `roads_car_point(slot, back)` keeps a
  body its length); each car's turn paths are measured once a tick (`RoadCar.ka/kka/kb/kkb`). Every default keeps the old behaviour (the 37
  tests stand unchanged); `junctions_test.ludic` adds 8, among them ten minutes of 40 cars on a street grid, a dead end and a
  highway merge with no two car bodies ever overlapping. The per-node holder lists (`rd_node_car`, `rd_node_id`,
  `rd_node_in`) are gone: a car holds the node it was let into (`RoadCar.hold`), and `RoadCar.pin`/`plane` are the road and
  lane it is turning off.
- **`ludic.roads`: merges, junctions that do not lock, multi-lane U-turns together.** Two movements that end in one lane and come
  together without crossing (a slip road into a highway's kerb lane, a side road turning into the near lane) were one at a time,
  each holding the junction for its whole path: a long gore held a highway car at its start for as long as a slip road car was
  anywhere in it. Now they go in the order they reach the lane (`merge.ludic`): a car is let in beside the other when it will be
  wholly behind it or wholly ahead of it, or when it comes from the higher priority road and the other can still stop short of the
  merge zone; it then follows the cars of the other movement nearer the mouth, and a car of the lower priority road gives way short
  of the zone to a moving car of the higher one. A car that goes first but has no room beyond the junction no longer holds back the
  cars whose paths meet its own (a full dead-end stub locked its junction). The lanes of a several-lane road loop round a dead end's
  circle a lane's width and a metre apart, so they go round together. `roads_enter_why(slot)` (`ROADS_ENTER_*`) says why a car may
  not go on. Tests: `tests/junctions_test.ludic` (a long gore both ways, the no-room junction).
- **`ludic.roads`: organic, European-style streets as data.** A road may carry Bezier `handles` (`RoadHandle`: in and out offsets in metres from each anchor; a side of exactly (0, 0) is automatic, and an all-automatic chain is the old Catmull-Rom spline), sampled by the graph builder at `clamp(ceil(control polygon / 4 m), 8, 64)` steps a span and read by every consumer of a road's shape (`roads_pose`, `roads_nearest`, lengths, routes); a road with no handles is sampled exactly as before. New fields, all defaulted so older maps read unchanged: `RoadNode.kind` (`junction`, `roundabout`, `plaza`, `deadend`) and `radius`; `RoadSeg.handles`, `profile` (`@Ref(RoadProfiles)`), `taper`, `name`, and more `kind`s (`lane`, `alley`, `pedestrian`, `stairs`). New per-map tables: `RoadProfiles` (a street's cross-section: carriageway, curb, gutter, sidewalks, planting strips, parking, tram bed, steps, material slots), `RoadFurnitureRules` (where lamps, benches, trees and signs go), `RoadProps` (chunked, what the rules made or a designer placed) and `RoadBakes` (the glTF Ludic Studio bakes the road surfaces into, offline; the package still draws nothing). The `roads_world` entry of `studio.lres` binds all of it and offers a European hierarchy of presets (boulevard, avenue, street, lane, alley, pedestrian, stairs, highway). Starter data in `data/profiles.lres` and `data/furniture_rules.lres`; a `curved` test map and tests.
- **`ludic.session`: `ply_rest_least()`, the party's rest for the clock** - the least any player on is
  resting, 1 while one is on their feet, so one player sitting never hurries another's day. A game binds it
  straight to `ClockWorld.rest_scale`. Its tests now also hold a freed slot handed to the next to join,
  `ply_leave_all`, and the nearest player alone being this one at its own distance; `ludic.shop`'s own test
  holds that rolling and asking the week's demand leaves the world's shared `Random` stream where it was.
- **`ludic.tactics`: what makes a shooter's enemy look smart.** Graded perception (a cone, range, light, line of sight through the
  `TacticsWorld` port, hearing, memory, five alert states), cover points generated by rays beside walls and props and picked by
  scores (protection, line of fire, range, travel, a flank's angle) with reservations, a utility scorer over `TacArchetype` rows
  (cover, peek, advance, flank, suppress, retreat, flee, surrender, search, reload, give up), morale and suppression, a fair aim-error
  model, and squads that share a contact, hand out the flanker's role and say callouts.
- **`ludic.vehicles`: a kind's numbers are the game's.** The seat height, a horse's walk, gallop,
  acceleration and turn, its stamina and hay, a boat's stroke, turn and the wind on it, and where a rider
  gets off (the horse's flank, the boat's wade) were constants in the package; they are a `VehicleSpec` a
  game hands each kind with `vehicles_spec(kind, spec)` before any vehicle of it is called, and
  `vehicle_spec(kind)` asks them. A kind with no spec cannot be called, and a reset keeps the specs.
  `VEHICLE_HAY_MIN` is gone: it is the horse spec's `hay_min`.
- **`ludic.wildlife`: a map may paint where a species lives.** Two new `WildlifeWorld` members, both with
  defaults that change nothing: `habitat_in(sp, x, z)` answers 1 inside a species' painted habitat, 0
  outside and -1 where the map paints none (the kind's rule stands), and `range_at(sp, k, r)` fills the
  map's k-th painted range, which is set out as painted and draws no dice. Spots, ranges, fills and
  newcomers keep to the paint (`wildlife_habitat_of`, `wildlife_find_spot_of`), never under water.
- **`ludic.zones`: where a world is simulated.** A disc per player, `(x, z, r)` with `r = zones_radius(fog)`
  (the fog distance plus 40 m, never under 150 m, 900 m with no fog), overlapping discs merged into
  clusters with a bounding circle, and `zones_contains` / `zones_nearest` for everything that asks; fixed
  arrays, nothing made per frame. The packages that simulate now ask their world port whether a place is
  simulated, with a default of everywhere: `WildlifeWorld.active` (an animal outside is frozen - its
  state kept, no dice drawn), `NpcWorld.active` (a walker outside is frozen, and nobody is born outside),
  `VehicleWorld.active` (a moored boat outside is left where it lies) and `ThingsWorld.restocks` (a
  morning restocks only inside).
- **`module fishing uses base, data` - a module declares what it may reach, and the compiler holds it
  to that.** A reference from a module that says `uses` into a module it does not name is refused,
  exported or not, with the use and the fix in the message ("fishing uses items.inv_add (...): add
  'uses items' to fishing's module line, or take it through a port"). A module with no `uses` keeps
  the old rule, a package's module is always usable, a friend is not held to it, a cycle in the
  declared graph is refused, and `LUDIC_VIS_REPORT=1` lists the violations as `uses:` lines.
- **`r3d_small`: a renderer sized for a small UI window.** Set before `r3d_open`, it gives the frame's
  uniform ring 2 x 4 MB (was 2 x 64), memory blocks of 8 MB with anything over 4 MB on its own (was 64 and
  16) and descriptor pools an eighth of a world's. Maroon Lake's launcher window, which draws a picture and
  text and never becomes the game, went from 817 MB to 446 MB with it and its own trims; the rest is the
  font atlas, the backdrop, Metal's command-buffer storage while it draws, and the program's states.
- **`t()` in a template: a key and its holes for the translator.** `{t('pause.resume')}` and `{t('hud.day', day)}` make
  the text the game's translator decodes at draw time: the key marked (byte 1; a key already marked, such as
  a plural's byte 2, keeps its mark), then each hole's value after a byte 31. The text goes through the memo,
  so a key and holes that read the same as last frame make nothing. Phase 26 (i18n keys).
- **`ui_mounted` and `ui_model_of`: an editor's questions of a running interface.** `ui_mounted(out)` fills the
  caller's list with the classes of the components the last frame showed, in tree order and each once;
  `ui_model_of(cls)` is the first mounted instance's model, read in place (the next frame fills it again), or
  null. For devlink's ui_screen and ui_model; asked on request, never a frame.
- **`ui_override(path, text)`: a template or stylesheet given from outside.** From then on a read of `path` answers
  `text`; a component whose template or stylesheet it is swaps its own and is shown again with its state kept,
  and an importer reads the new text. `ui_override_clear(path)` (or `""` for every one) brings the file back,
  and `ui_overridden(path)` says whether one stands. A developer build's disk polling leaves an overridden
  component alone. For a studio editing a running game's interface (devlink's `ui_override`); a game that
  overrides nothing pays a length check per file read.

  The override's path is compared normalised, and an absolute path matches the relative one it ends with: a
  game's lab build registers its components as `lab/../src/ui/...`, and a studio's `src/ui/...` (or its
  absolute path) named nothing, so an override answered ok and changed nothing.
- **ludic.lab - the visual lab as a package.** A scene is an entry in the open registry `LabScenes`,
  shown on a plate: a flat lit disc, a small sky of the package's own with the sun at one hour, and a
  frame clock. Headless, each of its cameras (`lab_shot`, `lab_shot_at`) settles and is written as
  `build/lab/<scene>/<shot>.png`; in a window N and P step through them. `tools/lab/run.sh` and
  `sheet.py` make a contact sheet. ludic.render3d gains `r3d_plate_mode(true)` - no terrain, grass or
  water is made - and `r3d_sky_path`; the example scene takes about 120 MB resident. `quit()` in a
  program with no frame loop no longer fails to link.
- **ludic.lab: 16-bit PNGs** — `lab_png_write16_from(st, path, w, h, channels, px, at)` writes 16-bit samples (two bytes each, most significant first) the way `lab_png_write_from` writes 8-bit ones, so a test can write a height map render3d's decoder reads back as R16; `lp_png_bytes(stride, h)` is the size of one.
- **ludic.render3d carries MoltenVK, so a Mac program has its Vulkan driver without the SDK.**
  `native/build.sh` builds MoltenVK from a pinned tag (v1.4.2, its SHA-256 checked; its own
  dependencies at the commits its ExternalRevisions pins), thinned to arm64 and signed, into
  `lib/macos-arm64/libMoltenVK.dylib`, with its licence in `native/LICENSE-MoltenVK`. Every program
  that imports render3d links it through its rpath - the package's lib/ while developing,
  `Contents/Frameworks` in a bundle, where `ludic bundle` puts and signs it - and the loader
  (`vk_mac.ll`) now also looks for `@rpath/libMoltenVK.dylib`. An SDK loader found first still wins,
  so the validation layer can be stacked in development. `gpu_is_gl()` is gone.
- **render3d's Vulkan renderer runs in a macOS window, through MoltenVK.** `R3D_GFX=vk` (or
  `gpu_request("vulkan")`) now presents to a `CAMetalLayer` on the window (`VK_EXT_metal_surface`,
  the runtime's `win_metal_layer()`), where it used to fall back to OpenGL. The loader also opens
  MoltenVK on its own - `Contents/Frameworks/libMoltenVK.dylib` in a bundle, beside the executable,
  or `$VULKAN_SDK/lib` - so a game needs no Vulkan SDK to ship it. A covered window is not drawn to
  (its layer would hold every frame for a second), and on macOS one frame stays in flight so the CPU
  runs the next tick while the GPU draws. OpenGL stays the default: on an M4 Pro the Vulkan frame is
  still about a third slower, most of it in the alpha-tested foliage.
- **ui-preview `hold`: a pseudo-class held on without input.** `hold "<id or key>" "hover"` (also `active`,
  `focus`, `focus-visible`, `checked`, `disabled`) shows a story's element as if it were hovered or focused
  from the next frame, on top of the real input; `tree`, `box` and `rules` answer as if it were real. `""`
  lets go of one element's holds, `hold "" ""` of all, and `reset` clears them. ludic.ui keeps the holds
  (`ui_hold`, `ui_hold_clear`, held.ludic); a game holds none, and the matcher's check of an empty table is all it costs.

### Performance

- **Cut-out edge padding runs on every core.** `tex_dilate`'s passes hand their rows, sixteen at a time, to
  `Job.parallel_for`: within a pass a row writes only its own still-masked texels and reads only
  neighbours the mask already let go, so the bytes are the ones the single-threaded loop made. The worker
  is handed plain buffers in a `DilateJob` and makes nothing. `tex_dilate_bytes` is the slice-taking
  form (safe_api.ludic), and `examples/rendering/dilate.ludic` holds the result against the old loop
  (prints DILATE OK). It was 206 ms of the main thread in a Maroon Lake boot.
## v0.22.0 — 2026-09-18

### Features

- **Every key on the keyboard is bindable** — the F-row, Home/End/PageUp/PageDown,
  Insert/Delete, Caps Lock and the numpad reach a game as codes 132-166.

  Until now the platform gave them no code at all, so a game's rebinding screen could
  not take one and nothing said why. Windows asked the active layout what they type and
  got nothing back (`w_vk_char` answers 0 for a key with no character); macOS let them
  fall through to `charactersIgnoringModifiers`, which reports `NSF1FunctionKey` and its
  neighbours at 0xF704 and up - outside the 256-bit held set either way.

  - **The codes are the same on both platforms**: 132-143 are F1-F12, 144-149 are Home,
    End, PageUp, PageDown, Insert and Delete, 150 is Caps Lock, 152-161 are the numpad
    digits and 162-166 its `*`, `+`, `-`, `.` and `/`. The numpad's Enter is Enter.
  - **`Key.F1`, `Key.Home`, `Key.Numpad0`** and the rest fold at compile time like the
    other named keys.
  - **`Input.key_label`** names them - "F1", "Home", "CapsLock", "Num 0", "Num /" - and
    does *not* ask the layout, because a key that types nothing is called the same thing
    on every layout.
## v0.21.1 — 2026-09-17

### Fixes

- A windowed game opens under its package's `app name`. `ludic build`, `ludic run` and
  `ludic bundle` pass it to the compiler (`ludicc --title <name>`), so `game_title()` - the
  window's first title - is the name the player knows rather than the `program` name, which
  showed for up to two seconds before the renderer retitled the window. Without an `app name`
  it is the `program` name, as before.
- `Crypto.random_bytes`, `Crypto.random_hex`, `Crypto.random_u32` and `Uuid.*` draw from the
  system CSPRNG on Windows (`RtlGenRandom`, advapi32). They read `/dev/urandom`, which Windows
  does not have, and every byte came back zero.
## v0.21.0 — 2026-09-17

### Features

- **A launcher's runtime** — start a program, step aside while it runs, and download large
  files with a progress bar.

  - **`Process.*`** — `Process.spawn(path, args)` starts a program directly (no shell) with this
    process's environment and working directory and returns at once; `Process.poll(h)` is `-1`
    while it runs, then its exit code (`128 + signal` for a signal death, `137` after
    `Process.kill`); `Process.free` lets a handle go. `posix_spawn` on macOS
    (`runtime/native/process.ll`); `CreateProcessW` on Windows (`process_win.ll`), with each
    argument quoted by the MSVC rules and no console window. Linked only into a program that
    uses `Process.*`.
  - **`Http.save_to(h, path)`** — before `Http.send`, streams the response body straight into a
    file (written at `path` itself, created on send) instead of memory; `Http.text` of such a
    request is empty and `Http.body_len` is the bytes written. **`Http.received(h)`** and
    **`Http.expected(h)`** (the `Content-Length`, or `-1`) are live while it is pending. macOS
    streams through an `NSURLSession` with a delegate built at run time, Windows through the
    WinHTTP read loop. Freeing a pending request now cancels it and parks its slot until the
    worker has let go, rather than freeing what the worker is still writing.
  - **`App.window_hide()` / `App.window_show()`** — take the game's window off the screen and
    bring it back without closing it or its GL / Vulkan surface; the run goes on while it is
    hidden. No-ops headless and before there is a window.

### Fixes

- A game's window takes the title it asks for. The runtime opens a game's window before `main`,
  titled with the `program` name, and `Gl.open` / render3d's `gl_open` and `gvk_open` attached
  to it without passing their title on, so a `program Valley` that opened "Maroon Lake" showed
  "Valley". `win_set_title` (cocoa.ll `setTitle:`, win32.ll `SetWindowTextW`, UTF-8 to UTF-16)
  now retitles it, and a second `win_open` on macOS retitles the open window instead of making
  another, as it already did on Windows.
## v0.20.0 — 2026-09-17

### Features

- The JetBrains plugin (1.6.0) has a Ludic tool window for the package, like the Gradle one:
  - an overview of the package (what it is, entry, version, dependencies, scripts, hooks, app);
  - its commands, scripts and hooks, run by double-click, with each command's hooks shown;
  - its dependencies against package.lock.ludic: the locked version, whether it is fetched
    and linked, the indirect ones, and Fetch, Update, Verify, Vendor, Add and Remove;
  - the app preview the `app` lines describe, and the asset roots with missing ones marked.
  The bar over package.ludic now appears only when something needs doing (fetch, or no
  toolchain), instead of carrying every command.
## v0.19.0 — 2026-09-17

### Features

- `Udp.*`: polled IPv4 datagrams - the transport under a game's own netcode. `Udp.open(port)`
  binds a non-blocking socket (port 0 picks one, `Udp.port` says which), `Udp.send` sends one
  datagram to an address and port, and `Udp.recv` drains what arrived without ever blocking;
  `Udp.from_ip` / `Udp.from_port` name the sender. `Udp.ip` / `Udp.ip_text` convert addresses,
  `Udp.resolve` looks a host name up and `Udp.local_ip` is the address a player on the same
  network would dial. BSD sockets on macOS (`runtime/native/udp.ll`), Winsock on Windows
  (`udp_win.ll`, linked with ws2_32), linked only into a program that uses `Udp.*`.
## v0.18.1 — 2026-09-16

### Fixes

- The release build links libm on Linux, which `float`/`double` code needs (glibc keeps
  `sinf`, `sqrtf` and the rest there). 0.18.0's release job stopped on this before
  publishing, so 0.18.1 is the first published build with float types, barrel imports,
  package scripts and hooks, and the JetBrains 1.5.0 support.
## v0.18.0 — 2026-09-16

### Features

- Run a single test by name: a compiled test program takes the test's exact name as its
  first argument (`./tests "adds"`), and `ludic test` gains `--test NAME` to pass it through.
  A name that matches no test is reported and fails the run. `ludic test --verbose` (`-v`)
  prints every test's `ok`/`FAIL` line, framed by `RUN <file>` … `PASS|FAIL <file>`, which is
  what editor test views parse.
- The JetBrains plugin covers much more of the IDE:
  - Run configurations for `ludic run`/`build`/`test` (plus any other `ludic` command), with
    gutter run buttons on `program` and on every `test "name"` block.
  - Test results appear in the IDE's test tree, with navigation back to each test block.
  - `file.ludic:line` locations are clickable in every console.
  - Smart indentation on Enter and when typing a closing bracket; quotes pair up.
  - A Color Scheme page and a Code Style page.
  - Live templates, New Ludic File templates, and a Ludic project in File | New | Project.
  - A Tools | Ludic menu, and a warning when the toolchain is missing.
  - `package.ludic` is treated as a package manifest:
    - a banner offers Fetch, Update, Verify, Run, Test, Build and Bundle, and warns when the lock is
      missing or older than the manifest;
    - gutter actions on `package` and `require` lines;
    - completion and quick documentation for directives and `app` keys;
    - its own icon.
  - `script` and `hook` lines complete and are validated; each script has a run button, the
    package banner has script shortcuts, and Tools | Ludic | Run Script… lists them all.
  - The toolchain's and the project's packages are listed under External Libraries.
  - The Structure view, parameter info and code-block navigation now come from `ludic-lsp`.
  - The plugin is now 1.5.0 and requires IntelliJ Platform 2024.2 or newer and LSP4IJ 0.21.
  - Fixed: Enter no longer inserts an extra `}`, and Comment Line no longer writes two spaces.
- `float` and `double`: IEEE floating point with ordinary operators, so renderer math reads
  `a * b + c` instead of `f_add(f_mul(a, b), c)`.
  - Decimal literals take their type from context (`let s: float = 0.1` is exactly 0.1), and
    stay `fixed` elsewhere, so existing programs keep their meaning.
  - `int`/`long` promote; `float(x)`, `double(x)`, `int(x)`, `long(x)` and `fixed(x)` convert.
  - `floats(n)` / `doubles(n)` buffers; float fields, globals, constants and parameters.
  - `Math.*` computes in float when given one; `string`/`print`/interpolation write the
    shortest round-tripping decimal; `float_bits` / `float_from_bits` expose the IEEE pattern.
  - `@deterministic` code may not use floats (it is now checked).
- `import "camp"` imports a directory through its barrel, `camp/index.ludic` (a fragment
  listing the directory's own imports). A directory without one is a clear error. Packages
  resolve the same way: `import "ludic.render3d"` reads `ludic.render3d/index.ludic`.
- `ludic-lsp` navigates like the compiler resolves:
  - Package imports (`import "ludic.render3d/r3d.ludic"`) resolve from `ludic_modules/` and the
    toolchain's `packages/`, so their names hover, complete and jump. Import strings are links.
  - `var` locals are tracked (declaration, usages, rename).
  - Hover shows the declared or inferred type of locals, parameters and globals.
  - Hover and go-to-definition on built-ins, built-in types and namespaces show the reference
    page, with a link to the online docs. Release archives now ship `docs/language` for this.
  - Go to type declaration (`textDocument/typeDefinition`) is supported.
  - Signature help carries per-parameter ranges and follows named arguments.
  - Completion inside a call offers the parameter names not given yet, `Namespace.` offers its
    members, and results are ranked: locals first, then globals, built-ins and keywords.
- `package.ludic` gains `entry`, scripts and lifecycle hooks:
  - `entry "src/game.ludic"` names the program `ludic run`/`build`/`bundle` compile. Without
    it, the one file under `src/` that declares a `program` is used.
  - `script "dev" "ludic run --headless"` defines a command: `ludic dev` (or `ludic script dev`)
    runs it with any extra arguments, and `ludic scripts` lists them.
  - `hook before|after <command> "…"` wraps `build`, `run`, `test`, `bundle`, `pack`, `get`, …
    or a script. A failing `before` hook stops the command; `after` hooks run only on success.
  - Quoted manifest values accept `\"` and `\\` escapes.

### Fixes

- **`==` / `!=` on records is identity again** — only two strings compare by content.

  Every pointer-typed comparison used to be lowered to a C-string content compare,
  so two distinct records (properties, slices, enums) compared their bytes up to
  the first zero byte: `a == b` could be true for different objects that shared a
  leading field, depending on layout. References now compare by identity
  (`icmp eq ptr`); `string` (and untyped `pointer`/`pointers` text) still compares by content,
  and comparing a `string` with a non-string reference is a compile error.
## v0.17.0 — 2026-09-16

### Features

- **Renderer switches stay out of shipped games** — every `R3D_*` environment switch in
  `ludic.render3d` (debug views, feature kills, file writers, hardware fakes, the Windows
  feature overrides) now goes through one gate: a headless build honours them as before, a
  windowed build only when `R3D_DEV` is set to anything but `0`. See `docs/SHIPPING.md`.

### Fixes

- **A lake can be the water that mirrors the world** — a reflecting body is clipped to its
  ellipse like any other unless it is an unbounded sea, so a map whose reflection belongs to
  its lake no longer floods every hollow in the survey with that lake's level; and the
  terrain's wet shore, forest and scree gates read the carved lake's line inside its outline
  (`u_lake`), the rule the grass already used, so a lake above the sea keeps its wet bank and
  no forest is painted down its bed.

  `terrain_lake_carve(false)` keeps a lake's line, outline and shore but skips carving its
  bed, for a height map that already carries a shaped one.
## v0.16.2 — 2026-09-15

### Fixes

- **Keys are physical positions on Windows and macOS, whatever the layout** - `Input.key_down('w')`
  is the key above S on every keyboard.

  - **Windows** keyed the held set by the character the active layout gave a virtual key, so
    a game's WASD belonged to whatever the layout put there: on AZERTY W and A were other
    keys, and with an input method on (Chinese, Japanese, Korean) every letter arrived as
    VK_PROCESSKEY and no letter key worked at all. The typing block is now read from the
    scancode; the arrows, the numpad and the F-keys still go by virtual key, and the frame
    key (`Input.key`, typing) keeps the layout's character.
  - **macOS** did the same through `charactersIgnoringModifiers`; it now reads `keyCode`.
  - **`Input.key_label(key)`** names a key for the player in their own layout - `'w'` shows
    as "W" on QWERTY and "Z" on AZERTY - so a game that shows its bindings never shows a
    key the player cannot find. Windows reads the layout; headless, macOS and the browser
    give the US character.
## v0.16.1 — 2026-09-15

### Features

- **HDR calibration, and two HDR fixes** — the HDR10 picture follows the player's display instead of one fixed curve.

  - **`r3d_hdr_calibrate(peak, paper, black)`** — nits as float bits: the brightest the display shows (100-10000),
    where the picture's and the interface's white sit (80-1000, never above the peak) and how far the darkest shade is
    lifted (0-5, fading out by paper white). The tonemap's and the overlay's HDR10 variants read them, and the display's
    HDR metadata is sent again with the new peak. The defaults are the old constants: 1000, 200 and 0.
  - **`ov_hdr_nits(nits)` / `ov_hdr_paper()`** — what the overlay draws next is at that many nits on an HDR10 frame,
    for a calibration screen's test patches; it closes the batch so far. No effect on an SDR frame.
  - **Fixed: a crash toggling HDR on the Vulkan renderer.** `gpu_caps_probe()` made and destroyed a second Vulkan
    instance under NVIDIA Streamline's interposer; the next swapchain rebuild then called through a pointer that
    instance had left behind, at address 0. With the Vulkan renderer running, the probe asks its instance instead.
  - **Fixed: yellow read as red in HDR.** The overlay drew sRGB values straight into the HDR10 swapchain (it now has an
    HDR10 variant, chosen while `gpu_hdr_active()`), and the tonemap extended highlights per channel, which boosted a
    bright yellow's red far more than its green; it now brightens the graded colour by one factor.
## v0.16.0 — 2026-09-15

### Features

- **A loading screen can show the renderer's start-up as it happens.** `r3d_open(w, h, title)` opens
  the window and the graphics backend with nothing baked, and `r3d_load_count()` / `r3d_load_step(i)`
  run the rest - the sky and its light, the terrain, the shadow and screen targets, the scattered cover
  and actors, the grass - one step at a time, so a game can draw and present a frame between them.
  `r3d_init` is those same calls in a row and is unchanged for everything that uses it.
- **HDR10 output on the Vulkan renderer** — `r3d_hdr(on)` asks for an ST 2084 / BT.2020 swapchain where the
  display offers one.

  The tonemap's HDR10 variant keeps the SDR picture up to a 200-nit paper white and rolls highlights on to
  1000 nits; the overlay converts the interface to the same white; HDR metadata is set where the loader has
  the command. The screen and LDR images are 10-bit while it is on, and screenshots refuse rather than write
  a PQ image as SDR. OpenGL and the Vulkan SDR frame are unchanged. `R3D_HDR` overrides the setting.
- **Mesh-shader grass** — on a card with `VK_EXT_mesh_shader`, `r3d_mesh_grass(on)` draws each grass tile as one
  mesh-shader dispatch sized to that tile's blades, and a blade that is culled emits no vertices at all.

  - **`ludic-dev shaders`** — a variant whose first file is `*.mesh` compiles that stage as a Vulkan 1.3 mesh
    shader; its SPIR-V keeps the `.vert` name, so the manifest is unchanged.
  - **The seam** — `gpu_has_mesh()` and `gpu_draw_mesh_tasks(x, y, z)`; a mesh program's pipeline has no
    vertex input and its bindings the mesh stage. The device enables `meshShader` and `maintenance4`.

  Not yet faster: at 4K on an RTX 3070 Ti the grass pass takes 5.0 ms against the chunked path's 1.7, so
  `gpu_feature_implemented(GF_MESH_GRASS)` stays false and a game should not offer it as a finished setting.
- **More of the renderer's quality is a switch a game can offer.**

  - `sky_set_quality(width)`: the prefiltered sky light at 256, 512 or 1024 wide (half as tall),
    baked again at once.
  - `post_set_msaa(samples)`: 1, 2 or 4 samples for the scene on OpenGL, remaking the screen targets in
    place (`post_msaa_live()` is false on Vulkan, which has no sample counts yet); `post_free` now
    frees the multisampled framebuffer too.
  - `STREAM_BUDGET_US` is a variable: the microseconds a frame may spend generating streamed cover.
  - `r3d_fog_scale`: a multiplier over the fog density the daylight and the weather set.
- **NVIDIA DLSS super resolution and Reflex on the Vulkan renderer** — through NVIDIA Streamline 2.14.1.

  - **The loader** — on Windows `Vk.open()` takes `sl.interposer.dll` beside the executable in place of
    `vulkan-1.dll` when a program asks (`Vk.sl_prefer`), falling back to plain Vulkan without it; the `sl*`
    exports and feature functions are reachable from Ludic.
  - **render3d** — `r3d_dlss(mode)` upscales the lit HDR frame before bloom and the tonemap, jittered on a
    Halton cycle, with preset K in every mode (the default M cost 18 ms a frame at 4K on an RTX 3070 Ti);
    `r3d_dlss_render_w/h` give the size to render at. `r3d_reflex(mode)` sleeps each frame and marks
    simulation, submit and present. `R3D_DLSS`, `R3D_REFLEX`, `R3D_DLSS_PRESET`, `R3D_SL_LOG` for tests.
  - **Commands the interposer lacks** — it exports no `vkSetHdrMetadataEXT`, `vkCmdDrawMeshTasksEXT` or
    acceleration-structure command; `Vk.has` checks one and `vkGetDeviceProcAddr` reaches it.
- **Real OS threads behind `Job.*` and `Sync.*`** — `Job.parallel_for` runs work across every core.

  - **`fn name`** — an expression naming a top-level function as a value, for a worker's entry point.
    No closures: the data a worker needs is passed in.
  - **`Job.parallel_for(count, fn work, ctx)`** — `work(i, ctx)` for every `i` in `[0, count)`, split
    into chunks across a worker pool (one thread per core but one, pthreads or Win32) and the calling
    thread; returns when all are done. `Job.is_worker()` says whether code is on a pool thread.
  - **`Sync.*` is thread-safe** — mutexes are real mutexes, atomics are compare-and-swap, channels are
    guarded, and `Sync.cpu_count()` reports the machine's cores.
  - **A worker must not change the world** — `spawn` and `despawn` on a pool thread stop the program with
    a located message.
- **Texture filtering and shadow resolution as settings a game can change while it runs.**

  - `r3d_set_anisotropy(level)` sets the anisotropic filtering of every mipmapped texture already
    loaded, not only of later uploads, on OpenGL and Vulkan.
  - `shadow_set_res(size)` remakes the cascades' depth layers at 1024, 2048 or 4096 (`shadow_res`
    replaces the `SHADOW_RES` constant); the lighting reads the texel size from the map.
- **`app native "<dir>"` in `package.ludic`** — `ludic bundle` on Windows copies that directory's files beside
  the executable: native libraries loaded at run time (NVIDIA Streamline's DLLs, say) and their licence texts,
  which cannot live in the pack.

### Fixes

- **The meadow's grass draws on the Vulkan renderer again** — the chunked grass path uploaded its `vec4` tile
  table with `u_fv`, which on Vulkan copies one float per array element, so every tile had no blades.
  `u_f4v` uploads arrays of `vec4`.

### Performance

- **The sky's light is baked once at start, not twice.** A game that turns the sky at boot sets
  `sky_start_yaw` before `r3d_init`, and `sky_load` bakes the image-based light at that yaw; turning to
  a yaw the light is already baked at (`sky_set_yaw`) no longer bakes it again. Without it, nothing
  changes.
## v0.15.0 — 2026-09-15

### Features

- Vulkan for Ludic, and the start of a second renderer beside OpenGL.

  - **`Vk.*`**: every command of Vulkan 1.0-1.4 and of the extensions a modern renderer is
    built around (swapchain, HDR colour spaces, ray query and acceleration structures, opacity
    micromaps, mesh shaders, variable rate shading, memory budget, pipeline libraries, NVIDIA
    low latency, portability for MoltenVK), with every constant and every struct's size
    (`<Struct>_sizeof`) and field offsets (`<Struct>_<field>`). Generated from the Vulkan
    registry by **`ludic-dev vkgen`** into `runtime/native/vk_api.ludic` and `vk_thunks.ll`;
    structs are plain memory filled by name with `Vk.put_i32` / `put_i64` / `put_ptr`. Every
    size and offset was checked against the SDK's C headers (3128 facts). A C float is float
    bits in an int; 64-bit values and non-dispatchable handles are `long`.
  - **The loader is opened at run time**, never linked: `vk_win.ll` (`vulkan-1.dll`) and
    `vk_mac.ll` (`libvulkan.1.dylib`, MoltenVK). `Vk.open()` returning 0 means no Vulkan, and
    the program carries on. `ludicc` and `ludic build` link both files for any program that
    uses `Vk.*`.
  - `examples/rendering/vk_probe.ludic` reports what a machine's Vulkan can do;
    `vk_compute.ludic` runs a Slang compute shader (`vk_compute.slang`) and reads the picture
    back - on an RTX 3070 Ti and on an M4 Pro through MoltenVK, clean under the validation layer.
  - **render3d `gpu.ludic`**: the seam between the renderer and a graphics API. Render state
    and uniforms go through `gpu_*` / `u_*` and nowhere else (OpenGL frames unchanged);
    `R3D_GFX=gl|vk` or `gpu_request` chooses a backend, falling back to OpenGL with a reason;
    `gpu_caps_probe()` detects, on Windows, the Vulkan 1.3 floor, ray tracing, mesh shaders,
    the NVIDIA RTX generation, Reflex and HDR, for a settings screen to grey out what a machine
    cannot use (`R3D_CAPS=rtx50|rtx40|rtx30|amd|intel|none` pretends, for tests).
## v0.14.2 — 2026-09-14

### Fixes

- **`Input.mouse_dx` / `mouse_dy` no longer jump on the first frame or when the cursor mode changes.**
  The delta was the position minus the previous frame's, and the previous position started at 0,0,
  so the first frame reported the cursor's whole distance from the corner as motion, and switching
  between a locked cursor's virtual reticle and the real cursor did the same. A camera that adds
  `mouse_dy` to its pitch came up pointing at the ground with nobody touching the mouse. Both frames
  now report no motion; every other frame is unchanged, windowed or headless, on macOS and Windows.
## v0.14.1 — 2026-09-13

### Fixes

- **A rim from `outline_model` no longer stays on after the caller stops asking** — the queue
  was only emptied by the next `outline_model` call, so a game that highlights what the
  crosshair is on left the last highlighted tree outlined for good once the player looked
  away. `r3d_frame` now drops a batch nobody reopened this frame (`outline_frame`).
## v0.14.0 — 2026-09-13

### Features

- **Overlay text is UTF-8, and a font atlas can carry any script** — `ludic.render3d`'s `ov_text`,
  `ov_text_w` and `ov_text_wrap` decode UTF-8 instead of drawing bytes 32–126, so a game can show
  Turkish, German, Polish, Greek, Cyrillic or whatever its atlas holds.

  - `font.json` may list the atlas's code points in `"codes"` (atlas order). An atlas without it is
    read as before: consecutive code points from `"first"`, so existing ASCII fonts keep working.
  - A code point the atlas lacks draws as `?`; a control character as a space; a malformed or
    cut-off sequence as one `?`, so a string sliced mid-character still draws.
  - `overlay_font(dir)` loads or swaps the atlas at run time, for a language that brings its own font.
## v0.13.3 — 2026-09-13

### Performance

- **Dense forest renders faster** — a depth prepass for the near tree foliage in `ludic.render3d`.

  A crown of needle cards is many cut-out quads deep, and a shader that can `discard` turns
  early depth rejection off, so every card behind the front one ran the full lighting shader.
  In a dense stand at 3840x2160 that made the vegetation pass the largest in the frame. The near
  tree LODs now write depth first with `depth.frag` (the same alpha coverage test), the terrain
  beneath them is rejected before shading, and the lit pass draws them with no `discard` and an equal depth test. `R3D_NOPREPASS=1` restores the old path for comparison.
## v0.13.2 — 2026-09-13

### Fixes

- **`ludic build` links `http.ll` only into a program that uses `Http.*`.**

  The check that added it grepped the IR for `@hs_`, which every program's header declares,
  so the HTTP transport and Foundation were linked into everything. That cost nothing visible
  on macOS and failed the link on Linux, where `ludic build`, `ludic run` and a new project all
  broke in CI. It now looks for a call to `hs_send`.
## v0.13.1 — 2026-09-13

### Fixes

- **The toolchain links on Linux again** — CI builds, tests and publishes releases.

  The asset-pack boot finds the directory beside the executable with `_NSGetExecutablePath`,
  which Darwin's libc has and glibc does not, so every Linux link of the compiler seed failed
  from the release that added packs onward: CI's build, suite and C-free bootstrap jobs, and
  every `publish` run, so no release after v0.7.0 carried a Linux toolchain or was created by
  CI at all. `tools/ci/linux_stdio_shim.ll` now supplies it, over `/proc/self/exe`.
## v0.13.0 — 2026-09-13

### Features

- **Windows target** — `ludicc` builds and runs headless programs on Windows, and builds itself there.

  - **`--target <triple>`** — a triple naming `windows` selects the Windows runtime; without
    the flag the target is the host, read at run time from `OS=Windows_NT`. The IR still
    carries no triple, so clang assembles it for the machine it runs on.
  - **The libc surface, in IR** — on Windows the header emits `emit_win.ludic`, which defines
    the POSIX names the backend calls (`fopen`, `ftell`, `rename`, `opendir`, `mmap`,
    `fmemopen`, `uname`, …) over the UCRT and Win32. Three of them fixed silent breakage
    rather than link errors: `rename` onto an existing file (every `Fs.write_text` after the
    first), a 32-bit `ftell`, and text-mode `fopen` rewriting `\n` as `\r\n`.
  - **Known folders** — `Os.save_dir` / `config_dir` are `%APPDATA%\<app>`, `cache_dir` is
    `%LOCALAPPDATA%\<app>`, `temp_dir` is `%TEMP%`, all with forward slashes; a bundle's
    `home` line points at `%APPDATA%\<name>`.
  - **The driver** — finds `C:\Program Files\LLVM\bin\clang.exe` when clang is not on
    `%PATH%`, writes `.exe` outputs, speaks cmd.exe for its directory and cleanup commands,
    and reads `argv[0]`, `%PATH%` and `$LUDIC_HOME` with either separator.
  - **A window** — `win32.ll` is `cocoa.ll`'s contract over user32: the held-key set and frame
    key in Ludic codes, the mouse in framebuffer pixels with raw input for cursor mode 2,
    cursor hide/lock/confine that lets go when the window loses the foreground, XInput pads
    in SDL order with rescaled deadzones, and the software `win_present`. `win32_gl.ll` puts
    the WGL context on that window with vsync and borderless full screen; a headless build
    links `gl_win_nowin.ll` instead. The process is per-monitor DPI aware.
  - **Sound** — `audio_win.ll` is `audio.ll`'s contract over XAudio2: one source voice per
    clip, loops, volume, rate and a balance pan through the output matrix, RIFF WAVE in PCM or
    float. It reads a clip through the asset pack, so a bundled game's first `Audio.load`
    succeeds - AVAudioPlayer takes a filesystem path, which is why macOS cannot.
  - **The CLI on Windows** — `ludic build`, `ludic run` and `ludic-dev build` work from a Windows
    checkout. Every shell command the CLI issues runs through Git for Windows' bash
    (`$LUDIC_BASH` names another), `compile_app` links through `ludicc -o`, and a checkout
    bootstraps from the new `selfhost/ludicc.win.seed.ll`, which `ludic-dev reseed` now
    writes beside the macOS seed.
  - **`ludic bundle` on Windows** — `build/<name>/` holding a GUI-subsystem `<name>.exe`, the
    `game.lpak` and `packs.index`; an `.ico` beside `app icon` is compiled with `llvm-rc` and
    linked in. `ludicc` gains `--gui` (no console behind the window) and `--link <file>`.
  - **`Http.*` on Windows** — `http_win.ll` is `http.ll`'s contract over WinHTTP: a request
    built on the game thread, the exchange on a worker thread, TLS with the system's
    certificate checks, and response headers answered from the kept request handle.
  - **The splash and the window icon** — decoded by WIC from the bytes in the pack. The splash
    is a topmost borderless window at the artwork's own size in points times the display's
    scale; `App.set_icon` sets the title bar and taskbar icon of a build with no icon resource.
  - **`Gl.*` on Windows** — `gl_win.ll` makes a WGL 4.1 core context on a hidden window's DC,
    and `gl_thunks_win.ll` (generated by `ludic-dev glgen` beside `gl_thunks.ll`) calls
    every entry point through a table `@lgl_win_load` fills from `wglGetProcAddress`, falling
    back to `opengl32.dll` for the 1.1 functions it will not return. A headless GL program
    renders on the GPU there: `gl_triangle` matches the macOS frame to within one level per
    channel.

### Fixes

- **Backspace fires on macOS** — the Delete key reports `Key.Backspace` (8).

  AppKit gives the key marked delete (kVK_Delete, 51) the character `NSDeleteCharacter`, 127,
  which is what both the held-key set and the per-frame key received, so `Key.Backspace` never
  matched. `cocoa.ll` maps key code 51 to 8 in both.
- **Held arrow keys register** — `Key.Up`, `Key.Down`, `Key.Left` and `Key.Right` are 128-131.

  They folded to the codes of w, s, a and d, which is what the single per-frame key
  (`Input.key`) reports for an arrow. The held-key set has always stored an arrow under
  128-131, so `Input.key_down(Key.Up)` tested the W bit and `Input.move_i`'s arrow half never
  moved anything. `Input.key` keeps its WASD alias: a game comparing it with `'w'` still
  takes the arrows.
- **`ludic build` links `Http.*`** — a program that uses the HTTP client builds through the CLI.

  `compile_app` linked the OpenGL backend when a program named `@lgl_*` but never
  `runtime/native/http.ll` and Foundation for `@hs_*`, so a `Http.*` program failed to link
  under `ludic build` / `ludic run` while `ludicc -o` built it. It now links them the same way,
  windowed and headless.
## v0.12.1 — 2026-09-13

### Features

- **ludic.render3d: `r3d_fog_base`** — the height the height fog's density is measured from (default 0, the world's y = 0). Two maps sharing one height datum, one far lower than the other, no longer give the lower one many times thicker air.

### Fixes

- **ludic.render3d: lakes are ellipses** — a water body other than the reflecting one was drawn as the whole rectangle of its bounds, so the corners between that rectangle and the lake's carved ellipse showed sheets of water over dry ground. Those bodies are now clipped to the ellipse; the reflecting body (the sea) still fills its rectangle.
## v0.12.0 — 2026-09-13

### Features

- **ludic.render3d: replace the world at run time** — a game can swap its terrain, scatter, colliders, actors and water for another map's without restarting.

  - `terrain_reload(dem, emin, emax, base, ox, oz, ortho, half)` releases the current map's height field, survey, photograph and patch bounds and generates another at any `TERRAIN_HALF`; `terrain_unload()` is the release on its own.
  - `scatter_clear_all()` (with `stream_clear_all()`), `actor_clear_all()` and `col_reset()` empty the scene for the next map; `mesh_free()` releases a mesh's GL objects.
  - **Water bodies** — `water_body_add(level, cx, cz, ex, ez, reflect)` and `water_bodies_clear()` draw several still-water planes at their own levels; the first that reflects gets the planar reflection. `water_init` still means one reflecting plane.
  - **Fix:** the terrain's patch quadtree placed patches at a fixed 32 m leaf, so any `TERRAIN_HALF` other than 4096 put patch bounds in the wrong place; leaves now scale with the map.
  - **Fix:** `water_init` built a new mesh and compiled a new program on every call.
  - `terrain_sea(level)` separates the sea's level (the coast, the strand, the shoreline, forest and scree shading) from the carved lake's, so a lake can sit above the sea. Unset, the sea is the lake's level as before.
## v0.11.1 — 2026-09-12

### Fixes

- **`col_resolve` no longer throws a body across the map when it starts dead centre on a
  collider.** The degenerate branch — a point exactly on a circle's axis, where there is
  no direction to push it — chose a unit normal `(1, 0)` and then divided it by the
  clamped `d = 0.001` anyway, along with the real normals. The push came out a thousand
  times too large: a body standing exactly on a 0.5 m trunk was moved about 800 m instead
  of the 0.85 m that clears it.

  Off-centre the arithmetic was correct, and off-centre is how anything arrives at a
  trunk while walking, so it never showed up in play — only a teleport, a spawn or a
  world generator placing something on an existing collider could land on the axis.

  `(ex, ez) / d` is always a unit vector for `d > 0`, because `d` is its own length: there
  was never anything to clamp. The normal is now built once, explicitly, and the clamp is
  gone.
## v0.11.0 — 2026-09-12

### Features

- **`App.set_icon(path)`** — an icon for a binary that has no bundle to take one from.

  `ludic bundle` builds an `AppIcon.icns` and macOS reads it from the `.app`, so a
  shipped game has an icon. `ludic build` produces a bare executable, which has no
  bundle, no `CFBundleIconFile` and therefore no icon at all — macOS draws the generic
  green "exec" tile in the Dock. That is the build a developer runs all day and the one
  they see every session, so "my game has no icon" is true long before it ships.

  ```ludic
  App.set_icon("assets/app/icon.png")
  ```

  The path resolves through the pack first and the filesystem second, like every other
  asset, so the same call works packed and unpacked — it does not repeat `Audio.load`'s
  trick of taking a filesystem path only. An image that cannot be found or decoded
  leaves the current icon alone rather than clearing it, calling it in a bundled app is
  a harmless no-op, and a headless build compiles it away to nothing.
## v0.10.1 — 2026-09-11

### Fixes

- **`Os.save_dir` / `Os.config_dir` / `Os.cache_dir` follow the platform.** They were the
  macOS layout everywhere, so a game built on Linux wrote its saves to
  `~/Library/Application Support` — a directory that means nothing there. Naming the
  right directory is the entire reason a program calls these instead of building a path.

  | | macOS | Linux |
  | --- | --- | --- |
  | `save_dir` | `~/Library/Application Support/<app>` | `$XDG_DATA_HOME` or `~/.local/share/<app>` |
  | `config_dir` | `~/Library/Application Support/<app>` | `$XDG_CONFIG_HOME` or `~/.config/<app>` |
  | `cache_dir` | `~/Library/Caches/<app>` | `$XDG_CACHE_HOME` or `~/.cache/<app>` |

  An XDG variable that is set but empty falls back to the default, as the spec requires.
  macOS is unchanged to the byte — `save_dir` and `config_dir` stay the same directory
  there, because Apple's home for a config file that is not an `NSUserDefaults` plist is
  Application Support too, and a shipped game's settings must not move out from under it.
  On Linux XDG separates the two and so does this.

  One consequence worth stating plainly: a game already shipped on Linux was writing to
  the old macOS-shaped path, and this moves it. Those files are not migrated for you —
  they are wherever `~/Library/Application Support/<app>` ended up on that machine, and a
  game that has Linux players should move them once on startup.
## v0.10.0 — 2026-09-11

### Features

- **`.packignore`** — keep build artefacts out of the shipped asset pack.

  A pack root is packed wholesale, so everything a model or texture pipeline leaves
  beside its output ships too: preview renders, bake intermediates, the `.blend` a
  `.gltf` came from. Nothing errors and nothing looks wrong — the app is just bigger
  than the game. The only way out was naming every file in `package.ludic`, a list
  that goes stale the day someone adds a texture.

  Put a `.packignore` beside the assets instead. The rules are **gitignore's**, down
  to the parts people rely on without thinking about them: patterns anchored by a
  slash or floating without one, `preview/` for directories only, `*` and `?` stopping
  at a separator where `**` crosses it, `[a-z]` classes, `!` re-includes with the last
  line winning, a deeper file beating a shallower one, and no re-including out of an
  ignored directory.

  `ludic pack` reports what it left out, and `--no-ignore` packs everything so you can
  see what a rule costs. `ludic bundle` gathers the same way. `.packignore` itself is
  never packed, and the file only governs your own roots — a package's resources, such
  as the renderer's shaders, are added afterwards and cannot be excluded by accident.
## v0.9.1 — 2026-09-11

### Fixes

- **`outline_model`'s batch survives the whole frame.** A frame is drawn by more than one
  pass — a shadow map, a water reflection, the scene — and `actor_draw` runs in each of
  them. An Actor's rim survives that because it is a field on the actor; the queue did not,
  because the first pass to run emptied it, so a queued outline was drawn into whichever
  target happened to come first and was gone by the time the scene was drawn. Nothing
  appeared, with every uniform, matrix and mesh correct.

  A flush now *closes* the batch rather than clearing it, and the next `outline_model`
  opens a new one: every pass in a frame sees the same requests, and a caller still needs
  no frame hook.
## v0.9.0 — 2026-09-11

### Features

- **`Audio.play_at(id, gain:, pitch:, pan:)`** — fire a one-shot with its own gain, pitch
  and stereo position, leaving the master settings alone.

  `Audio.volume` and `Audio.pitch` are global: they are there so a player can turn the game
  down, and a game that used them to place a sound in the world would be fighting its own
  options screen. This is the per-voice version, and it is what distance attenuation is made
  of — a 3D game works out how far away a sound is and which side it is on, and says so.
  `gain` rides on top of the master volume, so the options screen still wins; `pan` runs
  -1 (hard left) to 1 (hard right).

  A loaded sound is still one player, so firing the same handle again restarts it rather
  than layering a second copy. Load a handle per variant when several need to overlap.
- **`ludic.render3d`: `outline_model(model, mat, width, r, g, b)`** — a rim around something
  that is not an Actor.

  An Actor has had an `outline` since the outline pass landed, and everything else in a
  scene had nothing: the pass walked the actor list and stopped. Instanced scatter was the
  gap that mattered, because a game that highlights whatever the crosshair is on could
  highlight every object in the world *except* the twenty thousand most common ones — the
  trees.

  `outline_model` queues a model at a transform from anywhere in the frame and the outline
  pass flushes it alongside the actors', which is what gets the depth test right: the rim has
  to be drawn after the scene it is tested against, and a caller does not control pass order.
  A layer whose vertex shader moves its instances — wind, or standing them on the drawn
  terrain — should be handed the transform that shader arrives at.
- **`ludic.render3d`: `terrain_coast(cx, cz, margin, fall)`** — the other way to make an
  island, and the one a real survey wants: the sea goes around the survey's **own edge**
  rather than being cut out of the middle of it.

  `terrain_island` measures a radius out from a centre, which suits a made-up map and
  drowns most of a real one — an 8 km mountain survey loses two thirds of itself to make an
  island of the rest. `terrain_coast` measures inward from the boundary instead: everything
  the data covers stays land, the outer `margin` metres go under water, and the `fall` metres
  inside that are scaled down into it. The band is wobbled by low-frequency noise, so what
  comes out is headlands and bays rather than the square the data arrived in.

  Both modes also gained a **strand**. Scaling alone hands a 500 m mountainside a 40-degree
  plunge into the sea, which is a cliff coast and nothing else; the last few metres of height
  either side of the water line are now compressed, which stretches them out horizontally
  into beach and shallows. Inland lakes are untouched — they have their own bed.
## v0.8.0 — 2026-09-10

### Features

- **A boot splash**, customised by the game. `app splash` in `package.ludic` names
  the artwork and `app splash_bg` the colour behind it; the runtime raises a
  borderless window from a constructor that runs before `main`, reading the image
  out of the asset pack, so it is on screen while the process is still starting
  rather than after the slow part it exists to cover. Nothing hides it
  automatically - only the game knows when its first real frame is ready, so the
  game calls `App.splash_hide()`.
- **Asset packs.** `ludic pack` writes every asset a game opens into one `.lpak`
  beside the binary, and the runtime mounts it before `main`. Nothing about how a
  game is written changes: the pack is spliced in at `file_open`, the one place
  every asset comes through, so `gltf_load`, `tex_load`, `Audio.load`,
  `Fs.read_text` and the renderer's own shader loads all find it without knowing
  it exists. `Fs.exists` and `Fs.size` consult the packs too. Entries are stored
  rather than compressed and the pack is `mmap`'d, so 165 MB of terrain costs one
  syscall at startup and pages in only what is touched. Several packs can be
  mounted in order, and a later one shadows an earlier one - which is how a patch
  replaces individual files without rewriting the base pack. See `docs/SHIPPING.md`.
- **`ludic bundle`** turns a built game into a real macOS `.app`: `Info.plist` and
  `PkgInfo` from the manifest, an `.icns` built from one source PNG at every size
  macOS asks for, the asset pack in `Contents/Resources`, and an ad-hoc signature
  so it launches on Apple silicon. Everything comes from `app` lines in
  `package.ludic`, so the command takes no arguments. A bundled game is also moved
  to `~/Library/Application Support/<name>` at startup, because Finder starts a
  `.app` with its working directory at `/` where no save could ever be written.
- **`ludic.render3d`: `terrain_island(cx, cz, r, fall)`** keeps land out to `r` and then
  scales the terrain down into the water over `fall` metres. Scaling rather than blending
  to a fixed bed is what makes the coastline come out of the terrain already there: low
  ground becomes beach and shallows, high ground becomes cliff. `r = 0` leaves the survey
  untouched.
- **`ludic.render3d`: a rim outline on an actor.** An actor gains `outline` (metres of
  rim) and `ocol` (its colour). The pass draws the model again with its vertices pushed
  along their normals and its front faces culled, so only the far side of the swollen
  shell survives - a silhouette exactly `outline` wide, depth-tested against the scene, so
  anything standing in front of the actor hides its rim too.
- **`ludic.render3d`: the moon has a phase.** One number, 0 new .. 0.5 full .. 1 new
  again, decides the disc's terminator, how much of its light reaches the ground, and
  where in the sky it rides - a full moon rises as the sun sets, a new moon travels with
  the sun and is never seen. A new moon is now a properly dark night, which is what makes
  a carried light worth having.

### Fixes

- **`ludic.render3d`: water read the window's size, not the frame it drew into.** The
  water shader's `u_screen` and the reflection target were sized from the drawable, but
  `gl_FragCoord` there runs over the scene target. They match only at a render scale of 1;
  below that the refraction and depth reads landed in the wrong corner of the frame and the
  lake showed a squashed copy of it instead of its own bed.
## v0.7.0 — 2026-09-10

### Features

- **A game can use the renderer from outside this repository.** `ludic.render3d` reads two
  things from disk at run time — its GLSL, and the scanned CC0 materials — and both were
  found only by a path relative to the working directory, so the renderer worked in a
  Ludic checkout and nowhere else. A game living in its own repository now needs to copy
  neither.

  **The shaders come from the package**, wherever the package is. They belong to
  `ludic.render3d` and ship with it, so the renderer looks for them beside the project
  first (a Ludic checkout, where they are under `packages/`) and then under the install
  root, `$LUDIC_HOME/packages/ludic.render3d` — the same place the compiler already
  resolves `import "ludic.render3d/r3d.ludic"` from. Nothing to vendor, and no version of
  the shaders that can drift from the version of the code that compiles them.

  **`ludic assets [--force]`** fetches the scanned materials and the HDRI sky into
  `assets/polyhaven/` of whatever project you run it in. The list of what to fetch is the
  renderer's own — the renderer decides which materials it wants — so it moved out of the
  repository's `assets/` and into the package as
  `packages/ludic.render3d/assets.manifest`, where it ships with the toolchain. A game
  does not keep its own copy of that list and so cannot fall out of step with the
  renderer's material set. `ludic dev fetch-assets` is the same command from a checkout.

  **A URL-shaped module built its binary into directories.** `project_name` took
  everything after the last dot of the manifest's module path, which for a package
  identified the way the package manager identifies them —
  `git.host.io/user/name` — is inside the *host*: the build wrote
  `build/io/user/name` instead of `build/name`. The last path segment comes first now, and
  a dot inside that segment still separates namespace from package, so `ludic.render3d`
  still builds as `render3d`.

  **The camping game has moved out** to its own repository —
  [Maroon Lake](https://git.workshopsoft.io/workshopsoft/maroon-lake) — taking
  `examples/rendering/valley.ludic`, `hiker.ludic`, `camp/`, and 175 MB of survey data and
  scanned kit with it. It was here as a demo of the renderer and became a game, and an
  engine repository should not be carrying a game's assets. It is now the first consumer
  of everything above, which is the point: what the renderer needs a game to be able to do,
  it can now do from outside. `examples/rendering/smooth.ludic` stays as the renderer's
  example in this tree.
- **OpenGL for Ludic, and a 3D renderer on it.** `Gl.*` binds the whole OpenGL 4.1
  core API — every `gl*` entry point of the platform `gl3.h` as `Gl.<snake_name>(…)`
  with every `GL_*` constant, generated by `ludic-dev glgen` with per-call ABI thunks
  (`runtime/native/gl_thunks.ll`; float/double parameters take `fixed`). Windowed
  builds get an `NSOpenGLContext` on the existing window at Retina resolution
  (`cocoa.ll`); headless builds render into an offscreen CGL context, so a program
  that uses `Gl.*` renders and screenshots identically under the test harness.
  `Gl.open / swap / screenshot / program / vao / floats …` cover the glue, and the
  IEEE-float helpers (`f_add`, `mem_put_f32`, …) let Q16.16 programs fill real
  float vertex and uniform data. `Gl.*` links `gl.ll + gl_thunks.ll + OpenGL.framework`
  only when used; every other build is byte-identical.

  The `ludic.render3d` package (`packages/ludic.render3d`) is a physically based
  renderer written on `Gl.*`: HDRI sky with image-based lighting (irradiance, GGX
  prefiltered, split-sum BRDF, sun extracted from the map), GPU-generated terrain
  with scanned PBR materials (stochastic anti-tiling, triplanar rock, slope/altitude
  splatting), cascaded shadow maps with PCF and world-unit biasing, a glTF loader
  for scanned models, instanced vegetation with baked impostors, procedural grass
  and lupines with wind and translucency, 4x MSAA with alpha-to-coverage, SSAO,
  still water, cloud shadows, aerial perspective, an HDR pipeline with bloom,
  auto-exposure, ACES tonemapping, grading, sharpening and grain. See
  `examples/rendering/smooth.ludic`, and the Maroon Lake game (git.workshopsoft.io/workshopsoft/maroon-lake) for a
  game built on it. The renderer's CC0 materials are fetched with `ludic assets`.

  **16-bit PNGs**: the renderer's texture loader keeps 16-bit samples (normal /
  displacement maps) and uploads them as `RGB16` / `R16`.

### Fixes

- **Resizing the window (or entering fullscreen) no longer empties the world.** It left
  `gl error 1286` — `GL_INVALID_FRAMEBUFFER_OPERATION` — on every frame from there on, with
  the terrain, the trees, the grass and the water gone and only the sky drawn.

  The sun-visibility pass added in `changes/terrain-perf.md` borrows the depth buffer the
  frame is about to be drawn with, so that rasterising it doubles as a depth prepass. It
  was storing that borrowed texture in its `Target`, and a `Target` deletes whatever its
  `depth` names when it is freed. On the first resize the sequence was: `post_free` deletes
  the frame's depth texture, `post_init` immediately makes the replacement — and GL hands
  back the name that was just freed — and then the visibility target, rebuilt for the new
  size, deleted that name believing it was its own. The scene framebuffer lost its depth
  attachment. What is left is a colour-only framebuffer, which is *complete*, so drawing
  carried on with no depth test at all: the sky is a fullscreen quad drawn last, and with
  nothing left to fail against it painted over the entire valley. The 1286s came from the
  passes whose own attachment now named a texture that no longer existed.

  A borrowed attachment is never written into the target now, and the frame's depth is
  attached afresh at the start of each pass — it is a different texture every time the
  screen-sized buffers are rebuilt, and one `glFramebufferTexture2D` per pass is cheaper
  than any scheme for noticing that it changed.

  `R3D_RESIZE_AT=<frame>` rebuilds every screen-sized buffer from that frame on, cycling
  through four drawable sizes every few frames. A window cannot be resized in a headless
  run, so this is the only way to reach the path; it reproduced the fault in one frame and
  now runs twenty resizes, with the fly camera and with the game, without an error.
- An upgrade keeps the package store. The installer replaces the whole install
  root, and `ludic add` caches packages in `~/.ludic/store` — so re-running the
  one-liner deleted every package a project had fetched. The store is carried
  across now; everything else in the root belongs to the toolchain and is replaced.

### Performance

- **Ground cover stops re-growing itself.** Walking a streamed world hitched, and the
  hitch got worse the longer you played. Measured in the Maroon Lake game, with a new hitch
  report rather than guessed at.

  **The chunk cache had a cliff, not a slope.** A stream cached 4096 chunks and then
  stopped remembering: past that the chunk was generated, used for one frame and thrown
  away, so every ring walk regenerated it, for the rest of the session. It arrives after
  enough of the map has been walked — six evictions' worth over seven kilometres, so an
  ordinary session reaches it — and it is the point where cover starts visibly re-growing
  as you turn. `stream_evict` now drops the half of the cache nobody has asked for in the
  longest time (chunks carry the walk that last wanted them) and rebuilds the index over
  what is left. Over a 7 km traversal: generation total **9073 ms → 2230 ms**, the worst
  single frame's generation **11.4 ms → 3.1 ms**, median frame 10.8 → 9.0 ms. With a cache
  deliberately sized to saturate early, the same run goes from 2748 frames generating to
  1548, and from a 13.3 ms median to 9.2. `R3D_NOEVICT` restores the old behaviour for
  comparison, `R3D_STREAM_CAP=<n>` sets the cache size.

  The other half of that hitch was in the game's own cover generator, and went with it to
  the Maroon Lake game's repository: its candidates were paying for a second noise field, four
  height samples and a path distance before the drift field that rules out most of the
  meadow — 2341 µs → 518 µs per chunk, bit-identical output. Worth repeating in any
  generator: a `stream_fill` is called for tens of thousands of candidates per chunk, so
  the order of its tests is most of its cost.

  **The hitch report** (`R3D_PROF=1`) is what found both. It prints the slowest frames of
  the run with what was in each: CPU versus GPU wait, cover generated, instance bytes
  uploaded, the game's own tick, and the renderer phase that took longest. Alongside it,
  per-chunk generation cost by stream and band, a census of what the caches hold, and a
  stutter figure — the frame time a run spent beyond 1.2x its own median — because a mean
  cannot show a hitch and a maximum is one unlucky frame.

  It also found two content bugs in the game it was measured on, which is the report doing
  its job: a cover stream whose placement rule never fires still pays full generation cost,
  and the census makes that visible — 3364 cached chunks holding zero instances.
- **The ground costs half what it did.** Measured in the Maroon Lake game, the terrain was 10.3 ms of
  a 22.2 ms frame; it is now 5.4 ms of 16.4 ms — 45 fps to 61 fps at 1080p, with the
  frame otherwise unchanged (every viewpoint tested stays above 54 dB PSNR against the
  old renderer, with no channel differing by more than 7/255).

  **Measure by frame time, not by the pass timers.** `R3D_PROF`'s per-pass
  `GL_TIME_ELAPSED` queries cannot be trusted on this driver: with the ground's shading
  work removed the terrain query fell from 10.5 ms to 1.3 ms while the frame time did
  not move at all. Every number above and below is a median real frame time, taken by
  switching one thing off (`prof_ft_report`); the pass timers are still printed, and are
  still useful for spotting a pass that appears out of nowhere, but they cannot size one.
  `R3D_NOTERRAIN` skips the ground, `R3D_TNEARONLY` / `R3D_TFARONLY` draw every patch
  with one tier's program, and `R3D_RES=<w>x<h>` renders at another size — the three
  switches that say whether a cost is the ground, which tier it is in, and whether it is
  pixels at all.

  **Each detail tier is its own program.** `terrain.frag` holds a detailed near tier and
  a cheap far one and chose between them per pixel, so every pixel of the valley walls
  was compiled — and scheduled — for a near path it never ran. CDLOD selection now knows
  which tiers a patch can contain: one that never comes within the split draws with
  `FAR_ONLY`, one wholly inside it with `NEAR_ONLY`, and only the ring of patches that
  straddle the band needs the program that holds both and cross-fades. Pixel-identical,
  and it makes the tiers separately measurable: the near tier costs 7.5 ms over a whole
  frame, the far tier 2.3 ms.

  **The sun visibility is its own pass** (`tersun.frag`). The same CDLOD patches are
  rasterised once into a screen-sized R8 buffer that holds nothing but each ground
  pixel's sun visibility, and `terrain.frag` fetches it by fragment coordinate. The pass
  costs 0.27 ms, shares the frame's depth buffer so it doubles as a depth prepass, and
  takes the cascade read out of the shader that covers the screen. It picks its tier —
  filtered PCF near, a single tap far — over the same cross-faded band the ground uses,
  so the boundary is not a contour you can find on the hillside.

  **Nothing is sampled for a weight of zero.** The ground sampled all four of its
  materials for every pixel and then blended three of them at zero: a meadow pixel took
  nine taps of triplanar rock, a cliff pixel nine taps of stochastic grass, and every
  pixel in the valley took the snow tile and the four noise fields behind the lake's
  shore wash — a wash that is a hairline along one shore within 120 m of the camera. The
  survey photograph's classification now runs first, because it is what decides which
  materials are present; each material block sits behind its own weight; the ridge field
  that ragged the snow line is skipped 160 m below it, where it cannot change anything;
  and inside the stochastic blend a cell's rotation, offset and rotated gradients are
  computed inside its own test, so a cell whose sharpened weight rounds away costs
  nothing. All of it exact where the weight is zero, and it is most of the win.

  Material sampling is what remains (2.8 ms of the 5.4): scanned 2K tiles taken at 16x
  anisotropy on ground seen at a grazing angle. `R3D_ANISO=<n>` sets the filter (the
  default is unchanged at 16; 4 is worth 1.0 ms and 1 is worth 1.7 ms).

  The shadow pass is 1.2 ms of the frame and has nothing to give: re-using the far
  cascades between frames — their windows are snapped to a 14 m and a 64 m grid — is
  worth 0.15 ms standing still and nothing while walking, so it is not in the tree.
## v0.6.1 — 2026-09-05

### Fixes

- **`ludic new` scaffolded a project that would not compile.** The project name went
  straight into the `program <Name>` identifier, so `ludic new my-game` wrote
  `program My-Game` — a subtraction — and the first `ludic run` failed with
  `expected '{', got '-'`. A name is now turned into a valid identifier
  (`my-game` → `MyGame`, `2048` → `Game2048`), and a name that cannot be a
  directory or a package is refused with the rule rather than mangled.

  Found while auditing every command's flags and arguments, along with:

  - **Unknown options are errors.** `ludic build --headles` silently built a
    windowed binary; `ludic build -o` with no path silently ignored it. Both now
    say what is wrong and exit non-zero.
  - **`ludic fmt` formats in place**, as its help always claimed — it was printing
    the file to stdout and changing nothing. `ludic fmt --check` reports drift
    without writing, for a hook or CI.
  - **`ludic test nosuch.ludic`** says the file does not exist instead of passing it
    to the compiler.
  - **`ludic build-lib`** reported failures as a shell syntax error (an
    interpolation written in a non-interpolating string), and its no-argument
    auto-detection picked up `package.lock.ludic` as a module to compile.
  - Error messages that still began with `x:` — the CLI's old name — now say
    `ludic:`.
## v0.6.0 — 2026-09-05

### Refactoring

- **`ludic` is only the language's command line now.** The toolchain's own tasks —
  building the compiler from its IR seed, the regression suites, the docs site,
  releases — moved out of it into a separate `ludic-dev` binary that is built from
  a checkout and is not part of an install.

  - **`ludic help` is what a user can actually do**: `new`, `run`, `build`, `test`,
    `add`, `fmt`, `lsp`, `doctor`, `upgrade`. No section about a repository they do
    not have. Typing `ludic dev …` says where those tasks went rather than failing
    as an unknown command.
  - **`ludic dev <task>` becomes `ludic-dev <task>`** for contributors; every task
    is otherwise unchanged. The bootstrap is now
    `bin/ludicc tools/ludic-cli/dev.ludic -o bin/ludic-dev && bin/ludic-dev build`.
  - The shipped binary drops from ~880 KB to ~190 KB, since none of the release,
    docs-generation or bootstrap machinery is linked into it any more.

### CI

- The docs deploy triggers on a change to `install.sh`. The site publishes the
  installer, but the workflow's path filter did not mention it — so a release that
  only fixed `install.sh` left the old script live at the URL the landing page
  tells people to pipe into `sh`.
## v0.5.2 — 2026-09-05

### Fixes

- The installer also covers a non-login interactive `bash` — the shell most Linux
  terminal emulators start, which reads only `~/.bashrc`. That file is now created
  when it is missing (its presence changes nothing else about how bash starts),
  while `~/.bash_profile` is still only appended to when it already exists, since
  creating that one would stop bash reading `~/.profile`.
## v0.5.1 — 2026-09-05

### Fixes

- `ludic version` reports the version of the toolchain it belongs to. It looked for
  `bin/ludicc` and `VERSION` beside the *current* directory, so it answered
  "(version unknown)" from a project — which is the only place a user ever runs it.
  It now resolves the compiler through the install root, like every other command.

  `install.sh` also now puts `ludic` on `PATH` for every shell, not just the one
  `$SHELL` names. The PATH edit lives in one file (`~/.ludic/env`) that each
  profile sources, and the profiles are chosen to cover what people actually open:
  `~/.profile` for sh and login bash, `~/.zshenv` because zsh never reads
  `~/.profile`, `~/.bashrc`/`~/.bash_profile` when they already exist, and fish's
  config when fish is installed. Re-running the installer does not add a second
  copy, and `--no-modify-path` still touches nothing.
## v0.5.0 — 2026-09-05

### Features

- **One command installs Ludic, and `ludic` is the command you use.** Getting
  started no longer means cloning the repository and learning a task runner called
  `x`.

  - **`curl -fsSL https://workshopsoft.pages.workshopsoft.io/ludic/install.sh | sh`** installs a complete
    toolchain — compiler, CLI, engine runtime, bundled `ludic.*` packages,
    formatter and language server — into `~/.ludic` and puts it on your `PATH`.
    Prebuilt artifacts are verified against a published checksum; where none
    exists for the platform, the installer bootstraps from the compiler's own IR
    seed with clang. Uninstalling is `rm -rf ~/.ludic`, and `ludic upgrade`
    re-runs the same script.
  - **`ludic` replaces `x`** and is the only command a user of the language meets:
    `ludic new` scaffolds a project that builds and plays as it stands, `ludic
    run` / `ludic build` compile it (`--headless` for a deterministic render),
    `ludic test` runs every `test` block in the project, and `ludic add` / `get` /
    `update` / `verify` / `vendor` drive packages. `ludic fmt` and `ludic lsp` are
    the formatter and language server, so an editor needs no path configuration.
    `ludic doctor` reports whether the install is complete and usable.
  - **The toolchain's own tasks moved under `ludic dev`** — `dev build`, `dev
    test`, `dev reseed`, `dev bootstrap-cfree`, `dev docs-gen`, `dev release` and
    the rest are unchanged apart from the namespace. `bin/x` is gone; the
    bootstrap is now `clang selfhost/ludicc.seed.ll -o bin/ludicc && bin/ludicc
    tools/ludic-cli/main.ludic -o bin/ludic`.
  - **An install root is a first-class layout.** The compiler derives it from its
    own location — the parent of its `bin/` directory — so `~/.ludic` and a repo
    checkout are the same shape, and `$LUDIC_HOME` is no longer needed to build a
    windowed game outside the repo. The bundled `ludic.*` packages resolve from
    `$LUDIC_HOME/packages`, so `import "ludic.core/components.ludic"` works with no
    `ludic_modules/` to set up. Release artifacts are complete install roots
    (`bin/` beside `runtime/`, `packages/` and `VERSION`) rather than bare
    binaries, and the installer ships with the documentation site it is served
    from.

### Fixes

- **Token cards are back on the docs site.** Clicking a keyword, type, builtin or
  namespace method in any code sample opens its summary card again. The card's
  styling had been left behind in `docs.css` during the site redesign, so on the
  landing page — which links only `base.css` and `site.css` — the card rendered
  unstyled at the foot of the document instead of beside the token. It now lives
  in `base.css` with the rest of the highlighter chrome, and is positioned
  `fixed`, matching the viewport coordinates the script computes, so a card opened
  on a scrolled reference page lands on its token rather than off it.
- Release checksums are one `.sha256` file per artifact instead of a single
  `SHA256SUMS`. A release is assembled from more than one host — a Linux runner
  cannot build the macOS toolchain — and `ludic dev publish` never overwrites an asset that
  is already attached, so a shared `SHA256SUMS` was written by whichever host
  published first and then never covered anything added afterwards. Per-artifact
  names compose across hosts. Verify one with
  `shasum -a 256 -c ludic-X.Y.Z-src.tar.gz.sha256`.

### Documentation

- CONTRIBUTING documents what a self-hosted Forgejo runner needs for CI to work at
  all: every workflow clones `${{ github.server_url }}`, which on a self-hosted
  instance is an internal address, so job containers must be able to resolve it.
  The runner's default is a fresh per-job network the Forgejo container is not on,
  which fails the clone — intermittently, because Docker forwards unresolved names
  to the host resolver, so CI can look healthy for a while before it stops.
- The README is rewritten around what a reader needs first: what the language is,
  a code sample, how to build it, and an honest status. Removed the repo-layout
  table and the Chrono Rift keybindings (a game manual in a language README), the
  nine links to wiki pages that no longer exist, and a "language at a glance"
  bullet describing a retired vocabulary — it advertised `system`, `reads`,
  `writes`, `requires` and `ensures`, none of which are keywords; the declaration
  keyword is `handler`.

### CI

- The commit-lint workflow survives a force-push. It linted
  `${{ github.event.before }}..${{ github.sha }}` without checking that `before`
  still resolves, so rewriting or garbage-collecting that commit failed the job
  with `fatal: Invalid revision range` on a push whose messages were all valid. It
  now falls back to linting the tip commit when `before` is gone.
- The docs deploy is serialised. Publishing is a force-push of an orphan `pages`
  branch, so two runs racing could land out of order and leave the site holding the
  older build — with both runs reporting success. A `pages-deploy` concurrency
  group with `cancel-in-progress` means a newer push cancels an older in-flight
  build instead of queueing behind it.
## v0.4.0 — 2026-09-05

### Features

- **Prefabs.** `prefab Grunt: Creature { Stats { hp: 30 }, Weapon { def_id: 1 } }` names a model with preset fields; `spawn Grunt { Position { x: 40 } }` spawns it, the spawn's own fields winning over the presets. Prefabs chain (`prefab Grunt: Foe` where `Foe` is a prefab) so shared presets live once. `spawn` is now also an expression yielding the new entity (`let e = spawn Grunt { … }`), and `Prefab.spawn(name: "Grunt")` spawns one chosen at runtime by name (-1 when none matches).
- **`countdown` fields.** A component field declared `frames_left: countdown = 0` is an `int` the engine steps toward 0 once per Update for every live entity carrying the component (never below 0). Roll timers, invulnerability frames, hit flashes and cooldowns need no hand-written "decrement each frame" handler: set the field, test it.
- A `machine` over an enum-typed store maps its states to the enum by name: with `enum HeroState { Idle, Rolling }` and `var hero_state: HeroState = HeroState.Idle`, `machine hero_state { state Idle { … } state Rolling { … } }` dispatches on `HeroState.Idle` / `HeroState.Rolling` — no `state Idle = HeroState.Idle` repetition, and a state that names no variant is a compile error. A bare enum is now a first-class `int`-sized type for `var`, params, fields and returns (`llty`), and `Enum.Variant` folds in a global initializer.
- A handler inside a scene `layer` may carry `@Queries(these: […], on: Model)`, so a scene can own its per-entity systems (`@Queries(these: [Particle]) handler AgeSparks phase Update { … }` runs once per matching entity only while that scene is active). Any other annotation on a layer handler is reported.
- A program-scope `var` may be initialized with any expression: `var run: Progress = new Progress`, `var speed: int = BASE_SPEED * 2`, `var origin: IVec2 = IVec2.zero()`. Initializers the compiler cannot fold run once at startup (`@L_init_globals`, after the runtime boots and before the `Start` phase), in declaration order. Previously such an initializer was silently replaced by `0` / `null`.
- Engine managers for what every action game hand-rolls: **`Fx.sparks` / `Fx.number` / `Fx.clear`** — engine-owned sparks and floating damage numbers, moved and aged each Update and drawn after the sprites, with no component, model, handler or draw call in the game; **`Audio.define(name:, path:)` + `Audio.play(name:)` / `Audio.play_music(name:)` / `Audio.named`** — a sound bank by name (the handle form still works); **`Camera.shake_for(amount:, frames:)`** — a timed shake the engine decays; **`Assets.enqueue`** now loads `.wav` / `.mp3` into the sound bank and `.ttf` / `.ttc` into a font table (**`Assets.font(name:)`**) alongside images, so one loading scene covers everything; **`Prop.count()`** — how many live entities carry a component.
- Every compiler diagnostic is reported as `file:line: error: message` — the file the line really lives in, even through imports — so editors can jump to it. Unexpected characters are errors (they used to be skipped silently), and defining one `function` twice is reported in source terms instead of failing in the IR assembler.
- Less to write for a game. **`Map` cell API** — `Map.get/set/fill/rect/border/random_cell/is_solid/is_solid_at/width/height`: a game edits the engine's tilemap in place and asks it what is solid (from the `Solids` config) instead of keeping its own grid. **`Sprite` does the small animation work**: `move_id` is the strip drawn while the entity moves, `face: 1` turns it toward its movement, and the `flash` / `blink` countdowns give a white hit flash and an invulnerability blink with no handler. **`scene X shows Menu`** — the engine opens the menu (and frees the cursor) on enter, draws it last in Overlay, and closes it on exit. **`import "dir/*.ludic"`** imports a directory in name order. **`IVec2.distance2/within/heading/along/step`** and **`Angle.diff_degrees`** cover the geometry every action game rewrites; **`List.sample`** draws distinct random picks; **`Input.move_i`** is the standard top-down movement intent; **`AimMode.Auto`** aims with the mouse, or the right stick while a pad is connected; **`Weapon.set_rate` / `Weapon.rate`** change a fire rate in place; projectiles now die on `Solids` tiles by themselves; **`Screen.bar`** draws a meter.
  Handlers inside a scene's layers are scene-qualified (`Play_Draw`), so two scenes may both name a handler `Draw`; `enable` / `disable` of a scene's own handler by its bare name still works from inside that scene.
- The engine's numeric parameters have names. ludic.core: `BodyPolicy { Platformer, TopDown }`, `BoundsPolicy { Clamp, Wrap, Bounce, Kill }`, `AnimMode { Loop, Once, PingPong }`; ludic.shooter: `AimMode { Mouse, RightStick, MoveDirection, NearestEnemy }`, `WeaponPattern { Single, Cone, Ring, Spiral }`; ludic.npcai: `BrainModel { StateMachine, Utility, BehaviourTree }`, `AiState { Patrol, Chase, Attack, Flee }`; ludic.gameplay: `StatKind { MaxHp, Attack, Defense, Speed }`, `ModifyOp { Flat, Percent }`; ludic.rpg: `StatusKind { Poison, Regen }`; the input runtime: `CursorMode { Normal, Hidden, Locked, Confined }`. `Body { policy: BodyPolicy.TopDown }` reads as what it is; the old integers still work. The input runtime also names the gamepad buttons: `PadButton { A, B, X, Y, LeftShoulder, RightShoulder, Back, Start }` for `Input.bind_pad(button:)`.
- The second "write less" round, all generic. **ludic.gameplay**: `Stats` carries the build stats every action game bolts on — `damage_pct`, `crit_pct`, `leech_pct` / `leech_hp`, `thorns`, `fire_rate_pct` — and `Combat.damage` applies them itself (a `Crit` event fires; thorns never reflect thorns); `Stats.add(e, stat, amount)` changes a base stat in place and `Stats.scale_hp(e, percent)` scales hp and max_hp; `StatKind` names every code. **ludic.shooter**: `Dash { frames, speed, cooldown_frames }` with `Dash.start(e, dx, dy)` / `Dash.active(e)` — a dodge roll with i-frames the package guards; `Melee { range, half_arc, damage, knockback, frames, cooldown_frames, arc }` with `Melee.swing(e)` (hits every hostile in the arc, knocks back, fires `MeleeHit`) / `Melee.ready` / `Melee.active`; projectiles drawn by the engine in their weapon's colour (`Weapon.set_color`); `TopDown { reticle, reticle_length }` draws the aim line and a mouse cross; the weapon system honours `Stats.fire_rate_pct`. **ludic.dungeon** (new package): `Dungeon.arena / open_arena / random_style / set_exit / entry_point / opposite / at_edge`, with `Side` and `RoomStyle` — arena rooms with mirrored cover, door lanes and exits by side, built into the engine tilemap. **Compiler**: `scene Splash lasts N then Next` (a timed scene), `button … goto: Scene` (a click changes scene, no listener to write). **Runtime**: `Map.random_cell_far`, `Sprite.draw_meter` (hearts / pips), `Assets.enqueue_dir`, `Collider.center`, `Prefs.max`. Also `scene X loads then Y` (the loading scene: pumped, drawn, `AssetsReady` fired), `Prop.despawn_all()`, `Map.to_tile`, and `Brain { hunt_blind }` in ludic.npcai (seek the nearest hostile without line of sight). `Prefab.spawn_at(name:, at:)` spawns and places; `Weapon.reset(id)` restores a definition (no pierce, no homing, its fire rate). Five regression examples cover the additions (`examples/library/prefabs`, `component_access`, `scene_menus`, `managers`, `combat_kit`). `Random.weighted(weights:)` draws an index by weight; `ui` widgets inherit `font` / `size` / `fg` / `align` from their panel; the input runtime names `MouseButton { Left, Right, Middle }`.
- `@ClearColor(expr)` takes any constant expression, so a named palette colour (`@ClearColor(COLOR_FLOOR)`) works as well as a hex literal.
- `Ai.seek` + path-aware `brain_seek` — when a Solids tilemap is present the NPC-AI routes a blocked straight line around obstacles with `Grid.a_star`, so foes flow around pillars instead of getting stuck.
- `Key.*` compile-time key constants (`Key.Space`, `Key.Escape`, `Key.A`, `Key.Up`, ...), folded like `Color.*`; and `Font.*` / `Ui.* / File.*` namespaces so `png_load`/`font_load`/file I/O are namespaced.
- `Os.pid()` returns the process id, for scratch files that concurrent runs of one tool must not share.
- `Overlay` render phase — runs after the engine Render systems (sprites, lights) and before present, so a game's HUD / menus are never painted under an actor. Byte-identical when unused.
- `Prop.of(entity)` and `Prop.has(entity)` — typed access to one entity's component from an entity handle, the same binding a query loop makes. `Hero.of(player).iframes = 20` reads and writes fields directly (no `World.prop_id` / `World.field_id` / `World.get` reflection chain); `Prop.has(e)` is true when `e` is in range, alive, and carries the property, so `-1` is a safe "no entity". A package that declares a real `prop_of` / `prop_has` function keeps it.
- `Solids.solid2` — an optional second solid glyph (e.g. a closed door) the move system also blocks.
- `Sprite.strip(sheet, col, row, count, rows)` — register N consecutive animation frames in one call (the base id for `SpriteAnim`).
- `Sprite` component draws atlas ids (#90) — `Sprite.atlas = 1` routes `esys_sprite` through `atlas_draw_ex` (scale/flip/tint) so atlas cells / multi-cell spans (tall characters) use the engine sprite-render system, not just the 16x16 table.
- `Ui.close()` — deactivate the retained UI (no menu open); the readable form of `Ui.open(id: -1)`.
- `[a, b, c]` list literals build a slice in place; the first element fixes the element type, later elements must match, and `[]` is an error (use `new []T`). Tables of records read as `[Row { … }, Row { … }]`.
- `ludic.prefs` package — `Prefs.*`, a human-readable `key=value` text store for scores / options (the right tool for "remember my best run"; a whole-world `Save.write` is not).
- `v.x` and `v.y` read the components of an `IVec2` value (a local, a global, a record field, or a call result) — the readable form of `IVec2.x(v)` / `IVec2.y(v)`. The compiler's static typing now also follows function return types, namespace calls, `Prop.of(e)` and record fields, so `@Computed` fields expand in those positions too.
- engine tilemap-render system (`TileSkin`, shipped from ludic.core) — one entity per glyph paints the whole `Map.*` grid each Render frame *before* sprites, so a game stops hand-looping the map. `esys_tileskin` registered ahead of `esys_sprite`.
- engine-driven retained UI — a program with a `ui` block has its navigation ticked by the frame loop automatically (from the frame key) and an activation now emits a `UiClicked { id }` event, so scenes react with `@On(UiClicked)` instead of polling `Ui.clicked`. New `Ui.*` namespace (`Ui.open/tick/clicked/set_text/render/build`).

### Fixes

- A `UI_Name` handle can be read from any code — a plain function, an `@On(UiClicked)` listener, a global initializer — not only from handlers and scene hooks. The widget table it indexes is now built on first use instead of when `@ui_build` is emitted, which came after functions and listeners and crashed the compiler on such a reference.
- A `var` declared twice — including a game `var` whose name the spliced engine runtime already uses (`ui_font`, `grid`, …) — is now a compile error naming the variable and, when it is the runtime's, saying so (`variable ui_font is also a variable of the engine runtime; choose another name`). Previously the two became one LLVM global and clang reported a redefinition in generated IR. The same check covers `property` names (`property Cell is also a property of the engine runtime; choose another name`); before, the first declaration silently won and field lookups failed with a confusing message.
- A `{` or `}` inside a string literal within an interpolation hole (`` `{f("{")}` ``) is text, not structure; the hole scanner used to miscount it.
- A windowed build that reaches the audio runtime indirectly — through the atlas / `Assets.*` preload queue (which feeds `.wav`/`.mp3` into the sound bank) or the engine sprite-render system, without any `Audio.*` call in the game — now links the native audio backend (`audio.ll` + AVFoundation). Previously `ludicc -o` failed at link with undefined `snd_*` symbols for any windowed game declaring a `Sprite` component; the import of `runtime/native/audio.ludic` now flags the backend link itself.
- Character literals accept the same escapes as strings (`'\''`, `'\\'` and `'\"'` were silently read as 0); an unterminated character literal is now an error.
- Hand-written runtime preludes (string, Os.*, Fs.*, Crypto.*, …) now live under their own `@lp_` symbol prefix, so a user `function` named `is_ws`, `str_eq`, `path_join` and the like no longer collides with them at link time.
- Named arguments now work on namespace functions (`@Namespace(Foo)` and `namespace Foo { export function … }`), not only on builtins and bare functions: `Weapon.def(name: "pistol", fire_rate: 9, damage: 14, speed: 8, spread: 0, pellets: 1, pattern: 0)` reorders to the declared parameter order like any other call. Previously every named call on a namespace function failed with "wrong number of arguments".
- The documented bootstrap works on a fresh clone. `bin/` is gitignored and not
  checked in, so `clang selfhost/ludicc.seed.ll -o bin/ludicc` — the first command
  in the README, in COMPILING, in CONTRIBUTING and on the site — failed with
  `ld: open() failed, errno=2 for 'bin/ludicc'`. Every copy now begins with
  `mkdir -p bin`, which is what CI had been doing all along.
- Unary minus keeps its operand type: `-f` on a `fixed` is a `fixed` (it was typed `int`, which broke mixed arithmetic and comparisons).
- `become Scene` now works from an `@On(Event)` listener, a global handler, or a plain function (#91). Code outside a scene's own layers cannot know the leaving scene at compile time, so the compiler emits `@L_scene_leave()` — a dispatch on the live scene id that runs its `on exit` — and calls it there. Previously a listener's `become` reused the last emitted handler's scene (or crashed), and a global handler's `become` skipped the leaving scene's `on exit` entirely.
- `ludic-fmt` keeps `rows[i]`, `new []int`, `s[a..b]`, `emit(…)`, `~x` and list-literal braces tight, and recognises `<< >> & | ^ ~` as operators.
- `ludic-fmt` no longer glues an opening parenthesis to a preceding operator: `let moving = (a or b)` stays as written instead of becoming `let moving =(a or b)`.
- `self()` inside an `@OnSpawn(Model)` or `@OnAttach(Property)` body is now the entity being constructed. Previously it was the entity of the innermost query loop — or the constant 0 when the spawn happened outside any loop — so a hook such as `@OnSpawn(Hero) handler Remember { player = self() }` silently recorded entity 0.
- `x += y` / `-=` / `*=` / `/=` now lower exactly like `x = x op y`: a Q16.16 `fixed` multiplies and divides through the 64-bit path, a string `+=` concatenates, and an `int` added to a `long` widens (they previously emitted raw integer arithmetic on the LLVM type).
- `x release` keeps a changeset's markdown intact. Bodies used to go through
  `tr '\n' ' '`, which flattened every multi-line changeset into one paragraph —
  nested bullets came out as inline `" - "` runs and a release read as a single
  unbroken wall of text. A section is now grouped by change type (**Features**,
  **Fixes**, **Performance**, …) with one bullet per changeset and continuation
  lines indented to stay inside it.

  - `x release --dry-run` renders the next section to stdout and writes nothing,
    so a release can be read before it is cut.
  - `x changelog-section <version>` prints one release's section from
    `CHANGELOG.md`; `x changelog-render` re-renders a section from a directory of
    changesets. The v0.1.0 and v0.3.0 sections were re-rendered with these.
- cursor `mode 3` (confined) now keeps the OS cursor **associated** (absolute position preserved) and hidden, instead of dissociating it like `mode 2` (lock/relative). Only true-lock `mode 2` uses relative deltas now; `win_mouse` reports the absolute position on `mode 3` and clamps it to the framebuffer. And `mode 3` now **physically confines** the cursor: each frame the platform layer warps it back to the window's content rect (`CGWarpMouseCursorPosition`) whenever it strays past the edge, so clicks can't land outside and the window keeps focus. This lets a top-down game hide + confine the cursor while `aim_mode 0` (mouse aim) keeps resolving to where the reticle points — previously any confine/lock mode silently broke absolute mouse aim, and a confined cursor still escaped the window (#89 follow-up).
- reserved words (`new`, `match`, `spawn`, ...) can no longer name a function — the compiler errors instead of miscompiling.
- the shooter aims / homes / fires from a body's **centre** (Position + Collider offset + half-size) instead of the Position anchor, so auto-aim and homing target what is drawn, not a corner.

### Documentation

- The generated site is redesigned around reading rather than launching: a warm
  paper ground with a serif display face, one ink-blue accent, and rules instead
  of floating cards. Colour is reserved for code. Dark mode is the same design
  with the ground inverted, driven entirely by tokens under one
  `prefers-color-scheme` block, and the landing page's scroll-reveal animations,
  gradient headline, glowing badge and emoji feature icons are gone.

  - Stylesheets are linked files (`base.css` + `site.css`/`docs.css`) instead of
    being inlined into all 900+ pages, which cuts the published site from 16 MB to
    5 MB and means a design change no longer requires regenerating to be seen.
  - Fonts are the platform's own; the site makes no webfont request.
  - `api.css` was dead — the generator never referenced it — and is removed along
    with `item.css`, which `docs.css` replaces.
  - A page no longer flashes its own title on every plain visit; only a deep link
    highlights its target, and under `prefers-reduced-motion` the highlight no
    longer stays on the element permanently.
  - The copy leads with what is verifiable — ahead-of-time compiled, an ECS in the
    syntax, deterministic fixed-point, no C in a build — and the "get started"
    steps now begin with the clang-plus-seed bootstrap, without which `bin/x` does
    not exist on a clean checkout.

### Build

- `x` no longer prints a clang warning on every build. Each `clang` invocation the
  task runner makes now passes `-Wno-override-module`, the same flag `ludicc`
  already passes for its own link step: the emitted IR names no target triple, so
  clang substitutes the host's and says so — four times per `x build`, with
  nothing to act on. (The comment in `selfhost/main.ludic` claimed the opposite,
  that the IR *does* carry a triple; it does not.)

### CI

- Releases are published by CI from a tag instead of by hand from a laptop. The
  new `release` workflow triggers on a `v*` tag, builds the toolchain from the IR
  seed, runs `x test`, `x test-tools` and `x bootstrap-cfree` against the tagged
  tree, and only then creates the Forgejo release. It refuses to publish when the
  tag and `VERSION` disagree or `CHANGELOG.md` has no section for that version.

  `x publish [vX.Y.Z]` is the command behind it and works locally too: it builds
  `dist/` (a source tarball from the tag, this host's toolchain, and a
  `SHA256SUMS` covering both — releases previously shipped no checksums) and takes
  the release notes from that version's `CHANGELOG.md` section, so the notes and
  the changelog cannot drift. Re-running it only adds assets the release is
  missing, which is how a macOS build gets attached to a Linux-built release.
## v0.3.0 — 2026-09-02

### Features

- **Tiled map support (#67–#74)** — load and draw [Tiled](https://www.mapeditor.org/) maps (TMX/TSX/TX and TMJ/TSJ/TJ), the design record from #66.

  - **P0 parsing primitives (#67)** — a minimal pure-Ludic XML reader (`Xml.*`) for the element/attribute/CDATA subset TMX/TSX/TX use; standard base64 decode/encode (`Base64.*`, RFC 4648), whose decoder ignores the whitespace Tiled wraps into `<data>`; and gzip framing (`z_gunzip`, RFC 1952) wrapping the existing DEFLATE inflater. zlib and the JSON reader already shipped. A curated, attributed golden corpus lands under `assets/tiled-fixtures/`.
  - **P0.5 TMX/TSX reader (#68)** — `Tiled.read` / `Tiled.read_tsx` map the native XML formats onto the *same* intermediate the JSON path produces — a `Value` tree in Tiled's JSON schema, with every tile layer's data decoded to a dense GID list (CSV, base64, base64+zlib, base64+gzip). A CSV `.tmx` and a base64+zlib `.tmj` of the same map read structurally identically; the in-repo Kenney `sampleMap.tmx` + external `sampleSheet.tsx` load with no manual JSON re-export.
  - **P1 core load + render (#69)** — the runtime `rt_tmap` model (heap-allocated to `w·h`, lifting the old `96×64` cap), the GID resolver (`Tiled.resolve` → tileset / local id / H·V·D flips), image-backed rendering (`Tiled.draw`, flips applied at blit), and the legacy-tilemap compatibility projection so `Grid.*`/`Path.*`/`esys_move` keep working. `Tiled.load` reads either format, resolves external tilesets + images, and auto-projects a `collision` layer. The Kenney sample loads and renders pixel-identically from `.tmx` and `.tmj`; the `grid` and `physics_tiles` demos now run off a loaded map.
  - **P2 collision & grid (#70)** — normalise three collision sources into the byte tilemap `esys_move`/`Grid.*`/`Path.*` read, in the design's priority order: per-tile `<objectgroup>` hitboxes, the `solid`/`oneway`/`trigger` property convention (`Tiled.collision_kind`/`Tiled.tile_shapes`), and the designated collision layer (`Tiled.project`, any non-zero GID solid) — or drive collision from a visual layer's per-tile metadata alone (`Tiled.collide`). The property convention and the collision-layer fallback produce the same feed; `Path.a_star` over a loaded map matches the hand-authored baseline.
  - **P3 animated tiles + tile objects (#71)** — a tileset `<animation>` advances deterministically as a pure function of the fixed 60/s engine frame clock (`Tiled.frame_gid`/`Tiled.animated`), so an animated GID resolves at draw to the current frame's GID with its flip flags preserved and reproduces frame-for-frame across runs; `Tiled.draw_anim` draws a map with animations advanced. Object-layer entries with a `gid` render the tile image (with their own flips), bottom-anchored, as placeable sprites.
  - **P4 objects, properties, templates, spawning (#72)** — all object shapes (rectangle / ellipse / point / polygon / polyline / text) and custom properties parse and are queryable (`Tiled.object`, `Tiled.object_shape`, `Tiled.prop`/`Tiled.prop_int`/`Tiled.prop_type`); class properties resolve their defaults against a project custom-type table (`Tiled.load_types` over `objecttypes.xml`); template instances inherit their `.tx`/`.tj` template's fields; and an object maps onto Ludic components on demand (`Tiled.spawn`/`Tiled.spawn_layer`, off by default, via the reflection ABI).
  - **P5 breadth (#73)** — image layers (parallax + repeat) and group layers (flattened, with recursive offset/opacity/tint/visible; `Tiled.layer_kind`/`Tiled.layer_offsetx`/`Tiled.layer_tint`); the isometric / staggered / hexagonal orientation coordinate transforms (`Tiled.cell_x`/`Tiled.cell_y`, driving the tile draw so cells land at the correct screen coords); and Wang-set GID resolution through the standard resolver (the terrain-corner authoring concept is editor-side and ignored).
  - **P6 scale (#74)** — infinite/chunked maps: `<chunk>` (TMX) and JSON `chunks[]` decode and flatten into the dense layer; `.world` stitching (`Tiled.world`/`Tiled.world_count`/`Tiled.world_map`) lists member maps at their offsets; and a self-contained pure-Ludic **zstd** decompressor (`z_zstd`, RFC 8878) for base64+zstd layers — frame + raw/RLE/compressed blocks, raw/RLE/direct-weight-Huffman literals, and the full FSE sequence path — decoding the low-entropy GID streams a tilemap produces (a high-entropy FSE-compressed-Huffman-weights block fails cleanly with -1 rather than emitting wrong bytes).
- Builtin NPC AI (#61) — the source package **ludic.npcai**, a perception → decision → action stack that plugs into the other controllers instead of re-implementing movement. The AI never moves a body directly: it writes the SAME intent fields the player controllers read (`want_x`/`want_y`/`want_fire`, `want_jump`), so an enemy gunner reuses the shooter's weapon/projectile/auto-aim systems verbatim (set the body's `TopDown.aim_mode = 3`) and a companion reuses the mover — friendly vs enemy is faction + goal, not different code. **Perception** (`Vision` + `Memory`, throttled `esys_perception` with faction filtering and optional `Grid` line-of-sight) remembers the nearest hostile and emits `TargetSpotted`/`TargetLost`. **Decision** offers three models writing one `Brain` intent — a finite-state machine (patrol/chase/attack/flee), a utility scorer, and a canonical behaviour tree — each decision veto-able via `cancellable DecisionMade`. **Steering** adds Reynolds flocking (separate/cohere), and a `Follower` component gives companion stances. Reuses ludic.gameplay Faction (who is hostile) + Stats (hp for flee). Fully deterministic: perception + replan are frame-throttled and fixed-order. Example: `examples/games/npcai_demo.ludic` — one enemy perceives, chases and shoots a target through the shooter controller, flees at low hp under the utility model, and a companion follows its leader.
- Builtin Platformer controller (#58) — the reference implementation of the six-lever extensibility contract, shipped as the source package **ludic.platformer**. Movement feel is all defaulted POD data (`Platformer { move_speed, jump_height, apex_frames, fall_gravity_mul, coyote_frames, jump_buffer_frames, air_jumps, policy, … }`); the controller is decomposed into small engine-owned sub-systems — input (Input phase), move/gravity/jump (FixedUpdate, before the shared `esys_move` sweep) and animation-state (LateUpdate, after it) — each independently switch-off-able with `disable system <fn>`. It owns movement *policy* only and reuses the engine Body/Collider swept-AABB collision. Jump feel derives gravity + impulse from height/apex, with coyote time, jump buffering, variable jump height and multi-jump; every jump decision emits a `cancellable JumpRequested` / `JumpPerformed` / `Landed` / `StateChanged` event, and a gravity `policy` enum (asymmetric / symmetric / floaty) is the formula hook. Ships the opt-in game-loop layer too (`scaffolding.ludic`): moving & crumbling platform blocks with rider carry, collectibles + `Score`, springs, hazards + a light `Life`/i-frames model, and checkpoint/goal triggers. Deterministic integer Q16.16 throughout. Examples: `examples/games/platformer_demo.ludic`, `examples/games/platformer_scaffolding.ludic`. Also fixes a latent codegen bug in `ludic_sweep_entity` (an SSA register name collided once a program declared ≥11 events).
- Builtin RPG systems suite (#59) — the source package **ludic.rpg**, seven independently-usable modules on the six-lever contract, with name-keyed data registries so a game or mod adds content with zero code. **A Movement** — one `Mover` with a `mode` selector (grid / free / grid-tween) and 4/8-axis, tilemap walkability, and `cancellable MoveRequested` (locked doors/ice) / `TileEntered` (encounters) / `Interacted` (the action-button raycast). **B Inventory** — a name-keyed item registry, per-owner counts, gold, `ItemUse` veto, and `Equipment` whose bonuses flow through the gameplay Stats modifier stack. **C Crafting** — a data-driven recipe + ingredient registry; `Craft.can`/`Craft.make` consume from the inventory. **D Quests** — quests + objectives whose progress is driven by `Quest.notify` (route any gameplay signal in), auto-completing when met, plus a global flag store for branching. **E Dialog** — an Ink/Yarn-style graph registry (nodes + choices) with a per-speaker `Dialog` component and `cancellable DialogChoice` for skill-check gating. **F Puzzles** — Sokoban `Pushable` + a switch / pressure-plate / gate signal graph (logic puzzles with no code). **G Status** — over-time poison/regen effects routed through the shared Combat pipeline. Everything is integer-deterministic, so save/load (world_save) and rollback hold. Example: `examples/games/rpg_demo.ludic` (21 self-checks across all seven modules).
- Builtin top-down Shooter controller (#60) — the source package **ludic.shooter**, conforming to the six-lever contract and built on the engine Body/Collider + ludic.gameplay Faction/Combat/Stats. `TopDown` decouples movement from aim (`aim_mode`: mouse / right-stick / move-direction / nearest-enemy auto-aim, with a `turn_rate` for tank-style rotation). Weapons are a name-keyed **registry** (`Weapon.def("shotgun", …)` — add a gun with zero code) with per-weapon fire-rate, damage, speed, spread, pellet count, pattern (single / spread cone / ring / spiral), plus data-driven pierce (`Weapon.set_pierce`) and homing (`Weapon.set_homing`); `esys_weapon` reads a `want_fire` intent so the **same** weapon fires for a player (input) and an NPC (AI). `Projectile` + `esys_projectile` is a self-contained deterministic pool: integrate, TTL, faction-filtered hit through `Combat.damage`, pierce, and homing that curves onto the nearest enemy — every step observable via `ProjectileSpawned` (mutable/veto) / `ProjectileHit` / `ProjectileExpired`. A budgeted `Spawner` wave director emits `SpawnRequested` / `WaveCleared`. Example: `examples/games/shooter_demo.ludic` (11 self-checks: movement, aim, faction damage, friendly-fire immunity, spread, kill, ring, homing, waves).
- Canonical engine-ABI components (#77) — the shared `Position` / `Body` / `Collider` / `Solids` bundles the engine-owned movement system (`esys_move`, #65) reads by name are now shipped from a base source package, **ludic.core**, instead of being re-declared by hand in every game and example. A game `import "ludic.core/components.ludic"` and the engine moves and collides its entities for free; extend by *composition* (attach your own components on the same model). AOT means the properties compile straight into the consumer's compile-time ECS with no ABI seam, and everything stays integer + Q16.16 deterministic (lockstep / replay / `world_save` hold). Example: `examples/library/core_components.ludic`.
- Cursor capture (#89) — `Input.cursor_mode(mode)` hides / locks / confines the OS mouse for a windowed game: `0` normal (visible, free), `1` hidden (hide the OS cursor while focused so a game draws its own reticle), `2` locked (hidden + dissociated — the mouse feeds *relative* motion through `Input.mouse_dx/dy`, and `Input.mouse_x/y` becomes a clamped virtual cursor, the FPS / twin-stick aim mode), `3` confined (dissociated but visible; the mouse cannot leave the window). The platform auto-releases (shows + reconnects the cursor) while the window is not key (Cmd-Tab) and on close, so the cursor is never left captured. Adds the native macOS implementation in `cocoa.ll` (`[NSCursor hide]/[unhide]`, ref-counted and toggled only on change; `CGAssociateMouseAndMouseCursorPosition`; `CGGetLastMouseDelta` for the relative virtual cursor) behind a new `win_cursor_mode` intrinsic; headless / non-windowed it is a no-op (DCE'd). Example: `examples/library/cursor_capture.ludic`.
- Declarative Render clear + present (#86) — `@ClearColor(0xRRGGBB)` makes the engine own the per-frame clear and flip: at the top of the Render phase it clears the framebuffer to the declared colour, and after the Render handlers run it presents the frame, so a game's Render handler no longer repeats `Screen.clear(color)` / `Screen.show()` and the clear colour is configured *declaratively* rather than in the handler body. Opt-in and backward-compatible: a program with no `@ClearColor` is byte-for-byte identical (it clears/presents itself, or the light system owns the present). Example: `examples/library/clear_color.ludic`.
- Deterministic camera zoom (#78) — `Camera.zoom(scale)` scales the whole view about the screen centre by a Q16.16 factor (`1.0` = none, `2.0` = 2x in, `0.5` = out). It rides on the same two framebuffer chokepoints (`rt_put_px` / `rt_fill_rect`) that already carry the camera offset, so it composes with `Camera.set`/`follow`/`shake`, and it is a *render-time* transform — the world coordinate types stay integer pixels + Q16.16 velocity, so lockstep, replay and `world_save` are untouched, and the zoom itself is deterministic. Gated by an internal `rt_cam_zoomed` flag so a game that never zooms renders byte-for-byte identically (golden renders unchanged); `Camera.zoom(1.0)` turns it back off. This is the concrete outcome of the #78 position-types investigation (`docs/RFC-POSITION-TYPES.md`), which rejected hardware floats for the deterministic coordinate core and identified zoom as the one genuinely-missing render feature. Example: `examples/library/camera_zoom.ludic` (pixel-readback verified).
- Directional int input (#79) — `Input.axis_i(neg, pos) -> int` returns a -1/0/1 movement intent (`+1` positive key held, `-1` negative, `0` neither or both) read from the multi-key device set, so turning WASD into movement no longer needs the `ki(key_down('d')) - ki(key_down('a'))` bool-to-int glue and feeds an int mover directly: `dx = Input.axis_i('a', 'd')`, `dy = Input.axis_i('w', 's')`. Complements `Input.axis` (fixed) / `Input.vector` (normalized). Example: `examples/library/input_movement.ludic`.
- Engine sprite-render system (#85) — the engine already auto-*ticks* SpriteAnim and Motion; it now auto-*draws* too. Declare a `Sprite` component (id + optional offx/offy/scale/flip/tint/hidden, shipped from **ludic.core**) on an entity with a `Position` and the engine draws it each Render frame — no hand-written Render handler querying positions and calling `draw_sprite` per entity, and no hand animation (when the entity also carries `SpriteAnim`, the current frame is added to the base id). Registered on the compile-time engine-system registry for the Render phase and spliced only when a game declares `Sprite`, so a game that never declares it compiles byte-identically; a game wanting a custom draw omits `Sprite` (or `disable system esys_sprite`). Also **deprecates the bare `draw_sprite` / `draw_sprite_scaled` globals** in favour of the namespaced `Screen.sprite` / `Screen.sprite_scaled`: a direct bare call now emits a one-time compile-time deprecation note (the bare form still lowers, since `Screen.sprite` uses it), and the in-repo `chronorift` demo is migrated to the namespaced calls. Example: `examples/library/sprite_render.ludic`.
- Entity-pool stats (#80). Ludic's ECS is already pool-based: the allocator recycles freed entity slots through a freelist (a `despawn`ed slot is reused by the next `spawn` before any new slot is taken), and component storage is fixed per-entity arrays — so spawning and despawning many entities per frame (bullet-hell / horde) does **no per-spawn heap allocation** and cannot fragment. Exposes that with a `Pool.*` namespace so a game can watch the reuse and budget against the cap: `Pool.live()` (entities alive now), `Pool.free()` (freed slots waiting to be reused), `Pool.reserved()` (high-water — slots ever allocated; stays flat across a steady spawn/despawn loop, the proof that slots are pooled not reallocated), and `Pool.capacity()` (the fixed entity cap). Zero-cost — they read the existing allocator counters inline. Example: `examples/library/pool.ludic`.
- Gameplay-controller foundation (#57) — the shared, cross-genre building blocks the builtin controllers stand on, shipped as the source package **ludic.gameplay**: a deterministic `Cooldown` frame timer (engine-ticked), a `Stats` attribute bundle with an unbounded timed **modifier stack** (`Stats.total` computes base+flat then percent on demand; expired modifiers self-despawn), a `Faction` friend/enemy/neutral relationship table (same-id-friendly / different-hostile by default), and a `Combat` damage pipeline whose `cancellable DamageAboutToApply` hook lets a game veto a hit *or rewrite the amount* (`Combat.set_amount`) and which emits `Damaged`/`Died`/`Healed`. Everything is integer-only so lockstep, replay and `world_save` snapshots hold. Also adds extensibility **lever 5** to the language: `disable system <esys_fn>` drops exactly one engine-owned system's tick at compile time, so a game can carry a well-known component but tick it with its own handler (byte-identical when nothing is disabled; the C-free bootstrap fixpoint is untouched). Example: `examples/library/gameplay_foundation.ludic`.
- Incremental asset preloading (#82). Assets used to load synchronously inside Boot/Start (`png_load`, `Audio.load`), stalling the first frame(s) as content grows, with no built-in loading phase. Adds an `Assets.*` preload queue: `Assets.enqueue(name, path)` queues a named image without loading it, `Assets.pump(max)` loads up to `max` queued assets per frame (returning how many it loaded), and `Assets.total` / `loaded` / `ready` / `progress` (0..100) drive a progress bar. A loading scene pumps a few assets per frame, draws `Assets.progress()`, and `become`s the play scene once `Assets.ready()`, so the game shows a responsive loading screen and only enters play once content is ready — the deterministic, no-threads form of async preloading (the work is spread across frames instead of stalling one, and the same enqueue+pump order loads identically every run). Loaded assets are reachable by name via `Assets.get` / `Sprite.named`. Builds on the #81 atlas. Example: `examples/library/preload.ludic`.
- Input Manager + automatic device-layer drive (#83). The generated frame loop now commits the input device layer itself — when a game uses any Input action-map / device method it calls `input_poll` each frame (reading the live key, recording/replaying, and rebuilding the held-key/mouse/gamepad state), so `Input.active` / `Input.key_down` / the mouse and pads read live **without the game calling `Input.poll` by hand** (previously the loop fed only `Input.key`, and the device layer read empty unless the game polled at the top of its Input phase). A game that uses no Input runtime keeps the plain `rt_poll` path, byte-identical. Adds the Input-Manager API on top: `Input.action(name, key)` ships a **default** binding (kept if already bound, so a player's `Input.rebind` or a loaded key-map is not clobbered); `Input.bind_pad(name, button)` makes an action **device-agnostic** (fires from keyboard *or* gamepad); and `Input.active` / `Input.just_pressed` / `Input.just_released` read the whole multi-key device layer with clean on-press / on-release edges (the deterministic, dispatch-free equivalent of event handlers — a handler polls the edge and reacts, so a replay fires identically). Examples: `examples/library/input_manager.ludic`, `examples/library/input_auto.ludic`.
- Namespace block form (#76) — `namespace Name { export function foo(…) … internal function bar(…) … }` declares a `Name.*` namespace once and controls its public surface declaratively, instead of annotating every function with `@Namespace(Name)` one at a time. Inside the block each `function short(…)` is emitted as `namelower_short`; an `export` function (the default) is callable as `Name.short(…)`, while an `internal` function is a private helper — emitted and callable by its short name from siblings in the block (calls are rewritten to the emitted name), but not part of the `Name.*` surface (`Name.internalOne()` is a compile error). It is the block sugar for the per-function `@Namespace` annotation, so a package's public API reads at a glance. A namespace declared the old per-function way is unchanged. Example: `examples/library/namespace_block.ludic`.
- Namespaced spritesheet / atlas API (#81). Sprite loading was a bare `png_load("floor0.png")` — one file per 16x16 sprite, with no way to load one sheet and address a cell by grid coords or name. Adds a `Sprite.*` / `Assets.*` runtime (over the variable-size image loader, so a cell is a sub-rect of the kept image and is **not** restricted to the 16x16 sprite table): `Sprite.sheet(path, cellw, cellh)` -> handle, `Sprite.cell(sheet, col, row)` and `Sprite.cell_span(sheet, col, row, cols, rows)` -> id (a sprite may span more than one cell — a tall character, a wide object), `Sprite.define(name, …)` / `Sprite.named(name)` to name and look up a cell, `Sprite.draw` / `Sprite.draw_scaled` (through the camera / zoom / clip, like `Screen.sprite`), `Sprite.width` / `height`, and `Assets.image(path)` / `Assets.load` / `Assets.get(name)`. Spliced on demand; a program that uses neither compiles byte-identically. Example: `examples/library/atlas.ludic`.
- Optional world boundaries (#84) — declare a single `Bounds` config entity (a rect `x, y, w, h` plus a policy, shipped from **ludic.core**) and the engine-owned world-bounds system keeps every moving `Body` inside the play area each frame, so a game no longer hand-clamps `Position`. Four policies: `0` clamp (walls), `1` wrap (toroidal), `2` bounce (clamp + flip the Body velocity on the axis that hit), `3` kill (despawn a body fully outside). It reads each body's `Collider` size so the whole box stays inside; off by default (no `Bounds` entity = open world). Registered on the engine-system registry for LateUpdate (after movement integrates) and spliced only when a game declares `Bounds`, so a game that never does compiles byte-identically. Also adds `World.despawn(entity)` — the reflective, by-id form of the `despawn` statement (runs `@OnDespawn` + frees the slot), which the kill policy uses and any system can call. Example: `examples/library/world_bounds.ludic`.
- Package manager (#63) — `x add` / `x get` / `x update` / `x verify` / `x vendor` bring third-party packages to Ludic with no new infrastructure. Dependencies are named by their git import path (URL-as-identity, no registry — a `git tag vX.Y.Z` is publishing), resolved by Go-style Minimum Version Selection, fetched into a content-addressed global store (`~/.ludic/store`, keyed by a file-content hash) and linked into each project under `ludic_modules/`. A `package.ludic` manifest declares dependencies, the provided `Foo.*` namespace(s), the kind (source or prebuilt) and, for prebuilt libs, the shipped targets; `package.lock.ludic` pins the resolved versions and content hashes for reproducible, verifiable builds. A source package's Ludic compiles into the consumer via a new module-root import fallback in the compiler (`import "git.workshopsoft.io/user/pkg/foo.ludic"` resolves against `$LUDIC_MODULES`, default `ludic_modules/`), so a package registers a namespace the same way the built-in stdlib does. Namespace collisions and missing prebuilt targets are hard errors. Existing programs compile byte-for-byte identically; the C-free bootstrap fixpoint is untouched. See docs/PACKAGES.md.
- Package-declarable namespaces & engine systems (#62) — the two hooks that made `Foo.*` stdlib namespaces and engine-owned systems compiler-hardcoded are now data-driven registries, so a package registers them with no compiler edit. `@Namespace(Name)` on a function opens a `Name.method(…)` namespace that dispatches to the bare `name_method` through the same generic path the built-in namespaces use (applied only after them, so it never shadows a core one). `@EngineSystem(Component, Phase)` registers an engine-owned system the frame loop runs each phase when the component is present — the package-declarable form of the built-in SpriteAnim/Motion/Light2D systems, reading components by name through the reflection ABI so an unused registration is byte-identical. Both annotations are keyword-free. The core stdlib keeps its optimized codegen (byte-identical output; the C-free bootstrap fixpoint is untouched) and packages ride the generic registry alongside it. This completes the packaging prerequisite for shipping gameplay-controller libraries (#58–#61) as real packages. See docs/PACKAGES.md.
- Prebuilt binary packages (#64) — a package can now ship a compiled artifact whose exported functions, systems and components a consumer uses without the source, over the stable reflection C-ABI. `x build-lib <module.ludic>` compiles a package's module to a per-target native dylib (`lib/<target>/`); a `kind prebuilt` dependency is fetched and linked like any other, and `x link-flags` prints the clang flags to link the module dylibs into a game (or `x app` does it in-repo). A module registers its dynamic components (`world_register_prop`) and its `@System(Phase)` functions with the host at load through a constructor, and the host dispatches every registered system each frame — the systems analogue of dynamic components. Binary packages are native-only and second-class ECS by design (source packages remain the portable, first-class, deterministic path); missing a build target is a hard error. See docs/PACKAGES.md.
- The engine runtime ships with the toolchain, not the project (#75). The compiler auto-splices `runtime/native/*` for any ECS game; a `runtime/...` import that is not found relative to the build is now resolved from the install root **`$LUDIC_HOME`** (default: the compiler binary's directory — where the platform `.ll` files already come from) *before* the package module root. So an external game that consumes the `ludic.*` packages no longer has to copy or symlink the engine runtime into its `ludic_modules/`; that directory holds only third-party packages, and the runtime is part of the toolchain install. In-repo builds are byte-identical (the runtime still resolves locally there, so the `$LUDIC_HOME` fallback never fires and the C-free bootstrap fixpoint is untouched).

### Fixes

- **Correct the element type of a slice indexed by a member-access expression.** `emit_index_addr` set the global `g_addr_ty` to the slice's element type *before* evaluating the index expression, so an index that was itself a struct-field access (`slice[obj.field]`) overwrote it — the load then came back typed as the field, and a following field access failed with "member access on non-aggregate". The slice branch now sets `g_addr_ty` last, matching the raw-pointer branches. Also de-duplicate the `@strcmp` declaration (centralised in the head prelude) so a program that pulls in both the world table and the filesystem prelude links.
- Input.key_pressed / key_released edges now fire (#87). In a frame-loop game the edges never triggered: the loop (since #83) commits the device layer once per frame via `input_drive`, but a game that *also* called `Input.poll` by hand committed a second time in the same frame, and `input_device_commit` copies `in_held` into `in_prev` at the top of every commit — so the second commit left `in_prev == in_held` and `key_pressed` (`held && !prev`) / `key_released` could never see a transition. Fixed with an `in_have_frame_driver` flag: the loop's `input_drive` sets it, and a manual `Input.poll` under the loop becomes a no-op that returns the frame's key instead of re-committing. An entry-driven harness has no loop, so the flag stays false and each `Input.poll` still commits a frame of input as before (record/replay and the #50 device tests are unchanged). Example: `examples/library/input_edge.ludic` (press edge on the down frame, release edge on the up frame).
- Windowed games no longer force-quit on Esc or 'q' (#88). The macOS platform layer (`runtime/native/cocoa.ll` `win_poll`) used to hard-code Escape (keycode 53) and the character 'q' as *quit* — storing `W_running = 0` so a shipped windowed game died the instant a player pressed Esc (a universal pause key) or typed 'q'. Those dev-loop conveniences are removed for windowed builds: **Escape is delivered to the game as key 27** and **'q' is an ordinary key**, consistently across both the single per-frame key (`@W_key`) and the `#50` held-key set (`ev_keyval` now maps Escape→27, not 'q'). A windowed game now owns Esc/pause and shuts down via `quit()` or the window close button (which still ends the run). The headless test driver (`rt_poll` in `core.ludic`) keeps its own `'q'` = quit for scripted golden runs, so nothing headless changes. Also stops forwarding consumed key events to `-sendEvent:`, which was triggering AppKit's system "funk" beep on every keystroke.

## v0.2.0 — 2026-09-01

The types-and-systems release. Ludic grows a real type system — sum types,
`option`/`result`, exact and arbitrarily-big numbers, string-keyed containers and
packed 2D value types — alongside an engine that auto-runs animation, motion and
lighting over components a game merely declares, a full input stack from
rebindable action maps to native gamepads, out-of-band Audio / HTTP / Jobs
standard libraries, and a built-in test framework with line coverage. Every
addition is gated and additive: a program that never touches a feature compiles
byte-for-byte identically, and the C-free bootstrap fixpoint is untouched.

### Language & types

- **feat**: Tagged-union enums (#56) — an `enum` variant may now carry a payload (`enum Tile { Empty, Wall, Door(int), Portal(int, int) }`), making it a sum type. Variants construct by name and `match` destructures them, binding each payload, with exhaustiveness and arity checked so adding a variant surfaces every site to update. Plain enums keep their zero-cost ordinal representation, byte-for-byte unchanged.
- **feat**: `result` + `try`/`else` (#46) — a fallible function returns `ok(payload)` or `err(message)`, and `try EXPR else { … }` recovers a value with the failure message bound to `error`. A plain branch on the tag: no exceptions, no stack unwinding. `is_ok`/`is_err` classify without unwrapping.
- **feat**: `option` (#53) — `some(v)` / `none()`, a maybe-a-value with no magic `-1` sentinel, read with `is_some`/`is_none`/`unwrap_or`.
- **feat**: `panic(msg)` + `assert(cond, msg)` (#8) — a clear, located `file:line: panic:` / `assertion failed:` message and a clean exit 1 instead of a raw segfault; the source location is baked in at compile time.
- **feat**: `IVec2` + `Rect` 2D value types (#1) — by-value spatial types that lower to packed integers, so they copy like scalars and never allocate: an integer 2D vector for grid coordinates and a Q16.16 axis-aligned rectangle for HUD boxes and hitboxes, both exact and platform-identical.
- **feat**: `BigInt` + `Decimal` exact numbers (#52) — arbitrary-precision integers and exact base-10 fixed-point for game economies, so an idle counter never overflows and `0.10 + 0.20` is exactly `0.30`. No `f32`/`f64`; deterministic.
- **feat**: `Huge` + `Angle` + `Percent` (#55) — a display-scale idle/incremental big number (`1.23e45`), an auto-wrapping radian angle over deterministic `Math.*` trig, and a `[0,1]`-clamped fraction for health, volume and interpolation `t`.
- **feat**: `Dict` + `Set` containers (#54) — string-keyed lookups over one open-addressing hash table (FNV-1a, linear probing, tombstones), for resource counts, registries, tags and visited tiles; O(1) average instead of a linear scan.
- **feat**: Value tree + reflection + JSON (#44) — a self-describing `Value` node, `Reflect.serialize`/`apply` to walk an entity's whole component set to and from it bit-exactly, and `Json.encode`/`parse` for compact, stable, diffable text. One-call save/load for entities and the backbone of data-driven tooling.

### Engine, animation & lighting

- **feat**: Engine-owned systems (#43) — the ECS hook that auto-runs a system each frame over a component a game merely declares, no `handler` wired: `SpriteAnim` advances sprite-sheet frames and `Motion` advances value tweens for free. Built on the reflection ABI, so it costs nothing in a game that declares neither.
- **feat**: Animation ergonomics (#48) — an ergonomic layer over those systems: `Anim.clip`/`Anim.play` for named spritesheet clips, `Anim.on_frame`/`fired` frame events, `Motion.to` one-call tweens, and fluent engine-advanced `Tween` handles (`to`/`chain`/`delay`/`parallel`/`stop`). All integer and deterministic under replay.
- **feat**: `Light.*` 2D lighting (#4) — a deterministic software light-accumulation pass over the framebuffer: `ambient` tinting, additive radial `point` lights with linear falloff, and hard shadows cast against rectangular occluders. Integer + Q16.16, identical every run and headless.
- **feat**: ECS-native lighting (#47) — a torch is now just an entity carrying `Light2D`, a wall an `Occluder`, and one `Ambient` sets the night tint; the engine runs the whole light pass at the end of the Render phase with no `Light.*` calls wired by hand.
- **feat**: Lighting render-quality tiers (#49) — cone/flashlight `spot` lights, a `falloff` exponent, `soft` penumbra shadows, colour `gel` cookies, normal-mapped surfaces (N·L) and a `time_of_day` day/night ramp, all on the same deterministic accumulation core and consumable via optional `Light2D` fields.

### Input

- **feat**: Action maps + record/replay (#7) — gameplay reads named, rebindable actions instead of physical keys, and the single per-frame `Input.poll` makes deterministic replay fall out for free: `Input.record` captures the tape and `Input.replay` feeds it back exactly — the seed of lockstep netcode.
- **feat**: Device layer (#50) — multiple simultaneous held keys, analog axes and a normalized vector, the mouse (position/delta/buttons/wheel), gamepads and touch, all injectable on every target (`Input.press`/`set_mouse`/`set_pad`/`set_touch`) and snapshotted whole into the replay tape.
- **feat**: Native hardware bindings (#51) — the device layer's macOS side wired into cocoa.ll: live cursor position, per-frame GameController polling into gamepad buttons/axes (SDL button order), and NSTouch routing, all DCE'd out of a headless build. No API changes.

### Standard library

- **feat**: `Audio.*` (#22) — sound effects and music over a new AVAudioPlayer backend: `load`/`play`/`play_music`/`stop`/`volume`/`pitch`/`is_playing`. Out-of-band (real-time, not part of the simulation) but frame-driven, so a replay fires the same sounds at the same frames; headless builds carry it as dead-stripped no-ops.
- **feat**: `Http.*` (#6) — a poll-based HTTP/HTTPS client for out-of-band data (leaderboards, cloud saves, remote config) that never blocks the frame, over an NSURLConnection transport with system TLS on by default. Pairs with `Json.parse`; the response parser is pure Ludic and tested offline.
- **feat**: Jobs, Promises & opt-in Sync (#14) — a layered concurrency library. `Job.*`/`Promise.*` are the safe default: cooperative futures pumped a little each frame so heavy work spreads out, combined with `Promise.all`/`race`. The advanced `Sync.*` tier adds mutexes, atomics and bounded channels. A deterministic cooperative scheduler — results are collected on the main thread and a Job never touches the world directly, so lockstep and replays stay bit-exact.

### Testing & tooling

- **feat**: Built-in test framework (#12) — a `test "name" { … }` block auto-discovered and run by a synthetic runner (no `entry` to write), with `expect`/`expect_eq`/`expect_near` assertions that report every failure and exit non-zero. `expect_near` carries the tolerance fixed-point game math needs.
- **feat**: Line coverage (#45) — compile with `--coverage` and the compiler instruments each statement with a per-line hit counter dumped at exit; `bin/x test --coverage` aggregates the dumps into a per-file report naming the unreached lines. Flag-gated and additive — an ordinary build stays byte-identical.

### Fixes

- **fix**: `const` of a non-int type is no longer miscompiled. A `const` reference lowered to its initializer's raw integer bits typed as `int`, so `const X: fixed = 10.0` computed as the raw Q16.16 value `655360` instead of `10.0` — silently corrupting fixed-point math (and, in one case, spinning an infinite loop). Const references now emit their initializer with its real type. Every existing const is an `int` literal, so the lowering there is byte-identical and the bootstrap fixpoint and golden renders are unchanged.

## v0.1.0 — 2026-08-30

### Features

- Editor tooling — `ludic-fmt` (formatter) and `ludic-lsp` (language server), plus VS Code and JetBrains integrations, all built by the toolchain.
- Namespaced standard library — Math, Text, List, Random, Time, Screen, Color, Ease, Collide, Memory, Vector, DateTime/Date/Duration/Clock, Unicode, Os, Fs/Path/Mime, Log, Noise, Hash, Crypto and Uuid, each deterministic where a game needs it.
- Native 2D backend — an ECS core with a deterministic fixed-point (Q16.16) runtime, a windowed Cocoa target on macOS and a headless PPM renderer that runs anywhere.
- Self-hosted, C-free toolchain — the compiler, runtime, task runner and editor tools are all written in Ludic and built from a checked-in LLVM-IR seed with clang alone; `x bootstrap-cfree` proves the compiler rebuilds itself byte-for-byte.
- Versioning and releases — SemVer with `ludicc --version`, a changeset-driven `CHANGELOG.md`, and `x release` to bump, tag, and publish a Forgejo release with source and toolchain artifacts.

### CI

- Continuous integration — Forgejo Actions workflows build the toolchain from the seed, run the regression + editor suites, assert the C-free bootstrap fixpoint, and lint commit messages on every push and pull request.
