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
| [ludic.anim](ludic.anim/README.md) | glTF animation clips sampled and cross-faded onto a render3d Skin (uses `ludic_render3d`) |
| [ludic.character](ludic.character/README.md) | a third-person walking body: gait, steps and slopes, a jump, wading, swimming, sitting, a safe put-down, the orbit camera |
| [ludic.clock](ludic.clock/README.md) | the hour, the day, the moon and a calendar of seasons |
| [ludic.crafting](ludic.crafting/README.md) | recipes: what goes in and out, where and how long, making, refunding, hold-to-make |
| [ludic.effects](ludic.effects/README.md) | timed modifiers that run down in game time (a meal's warmth, a drink's legs) |
| [ludic.fire](ludic.fire/README.md) | a camp fire: fuel, the rain on it, warmth at a distance, whether it will cook |
| [ludic.fishing](ludic.fishing/README.md) | a rod at the water: cast, bite, the reel's fight, the landing; species as an open registry |
| [ludic.i18n](ludic.i18n/README.md) | a game in any language: gettext `.po` files, patterns with holes, plurals, a mod folder, a font per language |
| [ludic.inventory](ludic.inventory/README.md) | a pack: a count per kind, with room the game decides |
| [ludic.needs](ludic.needs/README.md) | a body's warmth, food, water and energy, and the countdown to a collapse |
| [ludic.settings](ludic.settings/README.md) | a game's settings as data: one store, a fact per change, ranges, a safe set |
| [ludic.shop](ludic.shop/README.md) | vendors: prices by standing and weekly demand, stock, buying and selling |
| [ludic.steps](ludic.steps/README.md) | chapters of steps (kind, param, need), progress, and a party's shares pooled |
| [ludic.telemetry](ludic.telemetry/README.md) | events queued, batched to a PostHog-shaped endpoint, backed off when offline |
| [ludic.things](ludic.things/README.md) | the placed things of a world and their kinds (an open registry), queries, facts, a save |
| [ludic.tracks](ludic.tracks/README.md) | prints and sign animals leave, their age, and reading them |
| [ludic.update](ludic.update/README.md) | a Velopack-installed game updating itself a frame at a time |
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

## The builtin controllers

| | |
| --- | --- |
| [ludic.gameplay](ludic.gameplay/) | the shared foundation of the builtin gameplay controllers |
| [ludic.platformer](ludic.platformer/) | the Platformer controller |
| [ludic.shooter](ludic.shooter/) | the top-down Shooter controller |
| [ludic.rpg](ludic.rpg/) | the RPG systems suite |
| [ludic.dungeon](ludic.dungeon/) | arena rooms for a room-to-room roguelite |
| [ludic.npcai](ludic.npcai/) | NPC AI: perception, decision, action |
