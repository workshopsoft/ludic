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
| [ludic.avatar](ludic.avatar/README.md) | character customisation as data: bodies, named morphs with ranges, heritage blended, parts by slot (layering, hiding and conflicts by rule), palettes, decals, outfits and poses as clips, unlock rules; an avatar per player with validation, randomize, a compact id-based wire text, and a view port the renderer and animation layer bind |
| [ludic.abilities](ludic.abilities/README.md) | abilities, spells and skills as data: cost through a resource port, cast time, cooldowns, charges, targeting, effect chains through ports, channels, learnable levels, a hotbar |
| [ludic.compass](ludic.compass/README.md) | bearing marks on a strip: gathered from registered providers, gated by tier, sorted by priority, bearings, distances and a radar |
| [ludic.clock](ludic.clock/README.md) | the hour, the day, the moon and a calendar of seasons; the day's length, night, moon and calendar as a `ClockSettings` row |
| [ludic.crowd](ludic.crowd/README.md) | the ambient population of a living city: peds spawned round the players by the hour and district (deterministic per cell, in budgets), full/mid/far tiers, walking through a nav port and waiting at crossings, schedules and scenarios, friends in groups, reactions as a `@Machine` (alert, flee, panic, cower, fight, call the police as a fact), witnesses, a host-owned population with a cheap delta for clients, no allocation |
| [ludic.crafting](ludic.crafting/README.md) | recipes: what goes in and out, where and how long, making, refunding, hold-to-make |
| [ludic.crash](ludic.crash/README.md) | what a game does about last time's crash: the runtime's crash handler writes a record (signal, address, backtrace, loaded images), found at the next start, rotated, offered to show and - with the player's consent - to send through ludic.telemetry for the studio to symbolize |
| [ludic.crews](ludic.crews/README.md) | gangs and crews: ranks with permissions, a bank, relations (ally, neutral, rival, war) as rules, `@PerMap` territories, influence from kills, presence and jobs with decay, turf wars as a `@Machine` (peace, contested, war, cooldown), bounties and rivalries; host-authoritative |
| [ludic.effects](ludic.effects/README.md) | timed modifiers that run down in game time (a meal's warmth, a drink's legs) |
| [ludic.fire](ludic.fire/README.md) | a camp fire: fuel, the rain on it, warmth at a distance, whether it will cook |
| [ludic.zones](ludic.zones/README.md) | where the world is simulated: a disc per player from their fog, merged into clusters |
| [ludic.devlink](ludic.devlink/README.md) | an editor's live link into a running dev build: loopback UDP, one request a frame, core verbs as ports, a game's or package's own verbs declared with their argument shapes |
| [ludic.fishing](ludic.fishing/README.md) | a rod at the water: cast, bite, the reel's fight, the landing; species as an open registry |
| [ludic.furniture](ludic.furniture/README.md) | player housing interiors: furniture as rows (footprint, `@Asset`/`@Node`, category, price, floor / wall / ceiling / surface, stackable), placed in an instance the game keys, on a grid or free, checked against bounds, other furniture by true shape, the world's geometry through a port and a per-instance budget; stock bought and sold, move / rotate / remove carrying what stands on a piece, facts, saved per instance key |
| [ludic.hints](ludic.hints/README.md) | a rail of what is true now, most urgent first, each a card that teaches it and can be muted by key |
| [ludic.i18n](ludic.i18n/README.md) | a game in any language by keys: gettext `.po` files (en.po the English), holes, plurals, a mod folder, a font per language |
| [ludic.inventory](ludic.inventory/README.md) | a pack: a count per kind, with room the game decides |
| [ludic.loot](ludic.loot/README.md) | weighted loot tables (nested, guaranteed, rolls), rarity tiers by level and luck, affixes, uniques dropped once, seeded rolls, drops as facts |
| [ludic.launcher](ludic.launcher/README.md) | a game's first screen as data and ludic.ui components: play or continue, news, the update's progress, a crashed-last-time slot, language, links, quit; ports for what it asks, facts for what the player did |
| [ludic.liveops](ludic.liveops/README.md) | live operations: freemode events on a schedule the session seed decides (players, cooldowns, areas, hours and days weighting), live modifiers (double XP and money, discounts, featured content) from dated, rotating or remotely fetched rows, seasons with tiers, daily and weekly objectives drawn from the seed; host-authoritative, rewards as facts |
| [ludic.minimap](ludic.minimap/README.md) | a map's logic: the explored fog over a grid and its land share, the player's marks, and the view (world to map and back, zoom, pan, the camp, you, focus) |
| [ludic.melee](ludic.melee/README.md) | attacks as data on animation clips: hit windows and shapes, combos by input window, blocking and parrying, poise and stagger, a fighter's phase as a `@Machine` |
| [ludic.needs](ludic.needs/README.md) | a body's warmth, food, water and energy, and the countdown to a collapse |
| [ludic.npc](ludic.npc/README.md) | the other people in a place: a routine by the hour, walking round what is in the way, facing a player who comes near, lines as data, a guest's copy |
| [ludic.phone](ludic.phone/README.md) | an in-world phone on ludic.ui: apps as rows, a state machine (away, raised, in an app) worked by key or pad, contacts and calls as facts, message threads, toasts and notifications, and built-in contacts / messages / jobs / map / shop / settings / camera / notifications components with stories; the game's jobs, waypoint and shop come through ports |
| [ludic.physics](ludic.physics/README.md) | rigid bodies, removable still shapes (also as `ColliderShapes` rows), queries and buoyancy over Jolt Physics (a native library, phase 16) |
| [ludic.nav](ludic.nav/README.md) | a navmesh per kind of walker and the ways across it, over Recast & Detour (a native library, phase 17) |
| [ludic.photo](ludic.photo/README.md) | a camera's photographs: what is in the frame, a grade on size, framing, light and the moment, the roll, its worth, the best of each subject |
| [ludic.procgen](ludic.procgen/README.md) | deterministic seeded generators as data, in integer math an editor reproduces exactly: room-and-corridor dungeons, tile maps from edge-socket rules (wave function collapse), scatter within regions; a golden file and a second implementation; the save is the seeds |
| [ludic.property](ludic.property/README.md) | housing and businesses: kinds (interior map, garage, storage and upgrade slots), `@PerMap` sites, upgrades, buy, sell, rent and trade through a purse port, access lists, an interior instance per visit through a load port (multi-map interiors), storage of items and vehicles, passive income and business loops as a `@Machine`; host-authoritative |
| [ludic.progression](ludic.progression/README.md) | XP and levels from curves (a table or a formula) and awards per activity, unlocks by level (free or bought), skills that grow with use and export stat modifiers through a port, roles with tracks of their own and prestige, a live-multiplier port, host-authoritative, saved |
| [ludic.respawn](ludic.respawn/README.md) | death to respawn as rules: per-map points, a rule per cause (nearest, checkpoint, home, start; cost, free deaths, wait, untouchable window), checkpoints, facts |
| [ludic.roads](ludic.roads/README.md) | a road network as per-map data (nodes, spline roads with lanes and limits, turn rules), shortest and fastest routes, and traffic that follows lanes with spacing and takes turns at junctions and signals, through ports for the cars' bodies |
| [ludic.save](ludic.save/README.md) | versioned save files: a migration chain the game declares, torn writes told apart, a backup, a newer file refused and read-only |
| [ludic.settings](ludic.settings/README.md) | a game's settings as data: one store, a fact per change, ranges, a safe set |
| [ludic.shop](ludic.shop/README.md) | vendors: prices by standing and weekly demand, stock, buying and selling |
| [ludic.steam](ludic.steam/README.md) | the Steamworks runtime as a mechanic: a start-up state machine, the user, friends and rich presence, lobbies, achievements, stats and leaderboards from data rows, Steam Cloud beside `ludic.save`, Steam Input by action, DLC, the timeline, Steam's relay as a `ludic.net` socket option, dev verbs, and a fake Steam for tests |
| [ludic.steps](ludic.steps/README.md) | chapters of steps (kind, param, need), progress, and a party's shares pooled |
| [ludic.telemetry](ludic.telemetry/README.md) | events queued, batched to a PostHog-shaped endpoint, backed off when offline |
| [ludic.things](ludic.things/README.md) | the placed things of a world and their kinds (an open registry), queries, facts, a save |
| [ludic.tracks](ludic.tracks/README.md) | prints and sign animals leave, their age, and reading them |
| [ludic.travel](ludic.travel/README.md) | waypoints a player discovers and fast-travels between: unlock rules, cost in coins and hours, the load through a port, map markers as data |
| [ludic.update](ludic.update/README.md) | a Velopack-installed game updating itself a frame at a time |
| [ludic.vehicles](ludic.vehicles/README.md) | each player's boat and horse: called to berths and bays, owner and rider, riding, getting off onto a safe spot; kinds' numbers and seats as `VehicleSpecs` and `VehicleSeats` rows |
| [ludic.vitals](ludic.vitals/README.md) | per-actor pools as data (health, armour, stamina, a shield, fuel: maximum, regeneration and its delay, absorption order), damage types, hit zones and resistances per class, the damage pipeline, alive/downed/dead/respawned as a `@Machine`, untouchable windows, host-authoritative damage with predicted feedback; one-line port adapters for melee, abilities, weapons and respawn |
| [ludic.weapons](ludic.weapons/README.md) | firearms and throwables as data: fire modes, rate, range falloff, spread and recoil from a seed per shot, hitscan with penetration or projectiles with blasts, magazines and reloads, ammo types, stacking attachments, skins, loadouts and a weapon wheel; clips named for the animation layer; the host validates a guest's shot with a lag-compensation hook |
| [ludic.wallet](ludic.wallet/README.md) | money carried: earned, spent, lost, every change a fact |
| [ludic.wanted](ludic.wanted/README.md) | heat against a subject: crimes as weighted rows, decay out of sight, responses per level as data, the phases a `@Machine` table, facts for the game's AI |
| [ludic.weather](ludic.weather/README.md) | spells of weather described as data (`WeatherKinds` and `WeatherSettings` rows): odds, wetness, wind, storms, a forecast |
| [ludic.wildlife](ludic.wildlife/README.md) | a valley's animals: ranges, their day, senses and alert, feeding, lures, spawning |
| [ludic.build](ludic.build/README.md) | structures on a grid: footprints and rotation, placement rules as data (tags, adjacency, spacing, limits, tech), costs through a bank port, construction by workers as a `@Machine` |
| [ludic.harvest](ludic.harvest/README.md) | resource nodes, gatherers that carry, drop-offs, and the gather-carry-drop loop as a `@Machine`; the stockpile and walking are ports |
| [ludic.produce](ludic.produce/README.md) | production queues per building: items with time, cost, supply and tech, queue limits, rally points, refunds as data |
| [ludic.rts](ludic.rts/README.md) | command and control: selection and control groups, an order queue per unit (move, attack, gather, build, patrol, stop, hold as data), formations, stances |

## Engine and UI

| | |
| --- | --- |
| [ludic.render3d](ludic.render3d/) | the physically based 3D renderer over Vulkan (named `ludic_render3d` under `uses`); a map's painted ground layers and still water as `GroundLayers` and `WaterBodies` rows |
| [ludic.ui](ludic.ui/) | components: templates, stylesheets, layout, input and focus (`module ludic_ui`) |
| [ludic.lab](ludic.lab/README.md) | the visual lab: a scene on a lit plate, fixed cameras, PNG shots and a contact sheet |
| [ludic.core](ludic.core/) | the canonical engine-ABI components |
| [ludic.prefs](ludic.prefs/) | a small `key=value` store for preferences and records |
| [ludic.nativeecho](ludic.nativeecho/README.md) | the worked example of a package carrying a native library: a C sum over a slice, callbacks drained as facts |
| [ludic.steamworks](ludic.steamworks/README.md) | the real backend of `ludic.steam`: the SDK's flat API through bindings generated from the developer's own `steam_api.json` and a small shim; nothing of Valve's SDK is in the repository (a native library built from an SDK you may not redistribute) |

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

**A library you may not redistribute.** The Steamworks SDK is Valve's, under an agreement that keeps it out
of an open toolchain, so [ludic.steamworks](ludic.steamworks/README.md) carries none of it: `native/build.sh`
reads the developer's own copy (`STEAMWORKS_SDK`), a checked-in generator writes the bindings from its
`steam_api.json` into a git-ignored `gen/`, the shim is compiled against its headers into a git-ignored
`lib/<target>/`, and the SDK's runtime library is copied beside it. The shim keeps the rules above; the
mechanic that uses it, [ludic.steam](ludic.steam/README.md), is tested on a fake and needs no SDK, so the
suite runs without one. See [docs/PACKAGES.md](../docs/PACKAGES.md#a-native-library-you-may-not-redistribute).

## The builtin controllers

| | |
| --- | --- |
| [ludic.gameplay](ludic.gameplay/) | the shared foundation of the builtin gameplay controllers |
| [ludic.platformer](ludic.platformer/) | the Platformer controller |
| [ludic.shooter](ludic.shooter/) | the top-down Shooter controller |
| [ludic.rpg](ludic.rpg/) | the RPG systems suite |
| [ludic.dungeon](ludic.dungeon/) | arena rooms for a room-to-room roguelite |
| [ludic.npcai](ludic.npcai/) | NPC AI: perception, decision, action |
