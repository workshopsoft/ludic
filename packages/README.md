# packages

The Ludic packages that ship with the toolchain, found by `import "ludic.<name>"` from
`$LUDIC_HOME/packages` (or a project's `ludic_modules`). Each has a README of its own.
`ludic test packages` runs every package's tests, each test block in a process of its own.

## The mechanic packages

A mechanic says `module ludic_<name> uses ludic_base` and so reaches nothing else; it asks the game
through ports (`bind ClockWorld { ... }`), reports through queues of facts, and saves its own
section. The rules are in [ludic.base](ludic.base/README.md).

| | |
| --- | --- |
| [ludic.base](ludic.base/README.md) | the shared vocabulary: Tick and phases, `Queue<T>`, rng streams, the save tree, the system runner (`Systems`, an open registry) |
| [ludic.aim](ludic.aim/README.md) | what the crosshair is on: a forgiving ray against cylinders, the ground in front, reach floors, which thing the use key means |
| [ludic.anim](ludic.anim/README.md) | glTF animation clips sampled and cross-faded onto a render3d Skin (uses `ludic_render3d`); ozz-animation underneath as a native library (phase 19) |
| [ludic.character](ludic.character/README.md) | a third-person walking body: gait, steps and slopes, a jump, wading, swimming, sitting, a safe put-down, the orbit camera |
| [ludic.audio](ludic.audio/README.md) | world sounds with a gain, pan and pitch from a listener port, flat interface sounds, packed clips loaded, the one door to `Audio.*` |
| [ludic.compass](ludic.compass/README.md) | bearing marks on a strip: gathered from registered providers, gated by tier, sorted by priority, bearings, distances and a radar |
| [ludic.clock](ludic.clock/README.md) | the hour, the day, the moon and a calendar of seasons |
| [ludic.crafting](ludic.crafting/README.md) | recipes: what goes in and out, where and how long, making, refunding, hold-to-make |
| [ludic.effects](ludic.effects/README.md) | timed modifiers that run down in game time (a meal's warmth, a drink's legs) |
| [ludic.fire](ludic.fire/README.md) | a camp fire: fuel, the rain on it, warmth at a distance, whether it will cook |
| [ludic.zones](ludic.zones/README.md) | where the world is simulated: a disc per player from their fog, merged into clusters |
| [ludic.devlink](ludic.devlink/README.md) | an editor's live link into a running dev build: loopback UDP, one request a frame, verbs as ports |
| [ludic.fishing](ludic.fishing/README.md) | a rod at the water: cast, bite, the reel's fight, the landing; species as an open registry |
| [ludic.hints](ludic.hints/README.md) | a rail of what is true now, most urgent first, each a card that teaches it and can be muted by key |
| [ludic.i18n](ludic.i18n/README.md) | a game in any language: gettext `.po` files, patterns with holes, plurals, a mod folder, a font per language |
| [ludic.inventory](ludic.inventory/README.md) | a pack: a count per kind, with room the game decides |
| [ludic.minimap](ludic.minimap/README.md) | a map's logic: the explored fog over a grid and its land share, the player's marks, and the view (world to map and back, zoom, pan, the camp, you, focus) |
| [ludic.needs](ludic.needs/README.md) | a body's warmth, food, water and energy, and the countdown to a collapse |
| [ludic.npc](ludic.npc/README.md) | the other people in a place: a routine by the hour, walking round what is in the way, facing a player who comes near, lines as data, a guest's copy |
| [ludic.physics](ludic.physics/README.md) | rigid bodies, removable still shapes, queries and buoyancy over Jolt Physics (a native library, phase 16) |
| [ludic.nav](ludic.nav/README.md) | a navmesh per kind of walker and the ways across it, over Recast & Detour (a native library, phase 17) |
| [ludic.photo](ludic.photo/README.md) | a camera's photographs: what is in the frame, a grade on size, framing, light and the moment, the roll, its worth, the best of each subject |
| [ludic.save](ludic.save/README.md) | versioned save files: a migration chain the game declares, torn writes told apart, a backup, a newer file refused and read-only |
| [ludic.settings](ludic.settings/README.md) | a game's settings as data: one store, a fact per change, ranges, a safe set |
| [ludic.shop](ludic.shop/README.md) | vendors: prices by standing and weekly demand, stock, buying and selling |
| [ludic.steps](ludic.steps/README.md) | chapters of steps (kind, param, need), progress, and a party's shares pooled |
| [ludic.telemetry](ludic.telemetry/README.md) | events queued, batched to a PostHog-shaped endpoint, backed off when offline |
| [ludic.things](ludic.things/README.md) | the placed things of a world and their kinds (an open registry), queries, facts, a save |
| [ludic.tracks](ludic.tracks/README.md) | prints and sign animals leave, their age, and reading them |
| [ludic.update](ludic.update/README.md) | a Velopack-installed game updating itself a frame at a time |
| [ludic.vehicles](ludic.vehicles/README.md) | each player's boat and horse: called to berths and bays, owner and rider, riding, getting off onto a safe spot |
| [ludic.wallet](ludic.wallet/README.md) | money carried: earned, spent, lost, every change a fact |
| [ludic.weather](ludic.weather/README.md) | spells of weather described as data: odds, wetness, wind, storms, a forecast |
| [ludic.wildlife](ludic.wildlife/README.md) | a valley's animals: ranges, their day, senses and alert, feeding, lures, spawning |

## Engine and UI

| | |
| --- | --- |
| [ludic.render3d](ludic.render3d/) | the physically based 3D renderer over OpenGL and Vulkan (named `ludic_render3d` under `uses`) |
| [ludic.ui](ludic.ui/) | components: templates, stylesheets, layout, input and focus (`module ludic_ui`) |
| [ludic.lab](ludic.lab/README.md) | the visual lab: a scene on a lit plate, fixed cameras, PNG shots and a contact sheet |
| [ludic.core](ludic.core/) | the canonical engine-ABI components |
| [ludic.prefs](ludic.prefs/) | a small `key=value` store for preferences and records |
| [ludic.nativeecho](ludic.nativeecho/README.md) | the worked example of a package carrying a native library: a C sum over a slice, callbacks drained as facts |

## Native libraries

A package may carry a C or C++ library (`native` lines in its `package.ludic`,
[docs/PACKAGES.md](../docs/PACKAGES.md#native-libraries---a-source-package-that-carries-a-cc-library-phase-15)).
The library is never bound directly: a thin C shim in the package's `native/shim/` is, and every
shim keeps the same shape so the Ludic side stays safe.

- **Only `int`, `long`, `float` and opaque handles cross.** A Ludic `float` is a C `float`, a
  `long` an `int64_t`, a `pointer` a `void *`. No struct is passed by value, no C++ type, no
  exception: the shim catches and turns it into a return code.
- **A handle is the library's pointer, kept in the package's state and never exported.** The
  game names what the package hands it - an int id - and the package maps it to the handle.
- **Nothing calls back into Ludic.** No function pointer crosses the boundary. What a library
  reports through a callback (a contact, a finished path, a mixed buffer) the shim records in a
  buffer of its own, and the package drains it after the call returns (`ne_scan` then
  `ne_drain`), pushing each record onto its facts queue. A record that did not fit is counted,
  not dropped silently.
- **Bulk data crosses as a slice the package owns.** A `[]float` or `[]int` passed where the
  shim takes a pointer is its data; the package makes it once and reuses it (L7), and passes its
  length beside it.
- **Errors are return codes.** 0 is success and a negative number says what failed; nothing
  aborts, nothing prints.
- **Threads a library starts stay inside C** (a job system, an audio device). The Ludic side is
  called on the game's thread only.
- **The symbols are prefixed** with the package's short name (`ne_`, `jph_`), exported explicitly
  (`__attribute__((visibility("default")))`, `__declspec(dllexport)`), and everything else is
  hidden.

`native/build.sh` builds `lib/<target>/` from the pinned upstream source and the shim through
[tools/native/lib.sh](../tools/native/lib.sh); run it on the Mac and, in Git Bash, on the PC.
The package's tests run the real library - there is no fake for it.

## The builtin controllers

| | |
| --- | --- |
| [ludic.gameplay](ludic.gameplay/) | the shared foundation of the builtin gameplay controllers |
| [ludic.platformer](ludic.platformer/) | the Platformer controller |
| [ludic.shooter](ludic.shooter/) | the top-down Shooter controller |
| [ludic.rpg](ludic.rpg/) | the RPG systems suite |
| [ludic.dungeon](ludic.dungeon/) | arena rooms for a room-to-room roguelite |
| [ludic.npcai](ludic.npcai/) | NPC AI: perception, decision, action |
