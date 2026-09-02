# Builtin gameplay controllers

Ludic ships a layer of **ready-made gameplay controllers** — the "drop this in and
you have a platformer / shooter / RPG / NPC" starting point — as external, versioned
**source packages** (see [PACKAGES.md](PACKAGES.md)). Because Ludic is AOT, a source
package compiles straight into your game's compile-time ECS: there is no ABI seam and
the whole thing stays deterministic, so lockstep, input replay and `world_save`
snapshots hold across every controller.

This is the direction decided in issue #57 and implemented in #58–#61.

## The design thesis: mechanism vs. policy

The engine ships **mechanism**; the developer owns **policy**. A controller is a thin
spine of mechanism (integrate velocity, resolve a tile collision, advance a cooldown)
with **named decision points** where policy is injected. Every controller ships a
sensible default so it works out of the box, and exposes every decision so the default
can be observed, tuned, vetoed or replaced.

**Every builtin controller is a _base, not a cage_.** If a part of a controller can't
be reached by at least one of the six levers below, that is a design bug in the
controller.

## The six extension levers

1. **Data override** — every controller `property` is POD with sane defaults, so
   behaviour is configured by spawning with overrides, no subclassing:
   ```
   spawn Hero { Platformer { jump_height: 5, apex_frames: 10, air_jumps: 1 } }
   ```
2. **Composition** — controllers are small property bundles, never god-objects. A game
   adds its own `property`/`handler` to the same model; engine systems resolve fields
   by name through the reflection ABI and no-op when a field is absent.
3. **Phase ordering** — engine systems run at a defined point in their phase. A handler
   in `Update` runs before the movement sweep; a handler in `LateUpdate` runs after
   collision resolved. That is pre/post-processing around any engine tick, deterministic
   and same-order every frame.
4. **Event hooks** — every meaningful decision emits an event, and the consequential
   ones are `cancellable`. `@On(JumpRequested) { cancel }` vetoes; a mutable channel
   (e.g. `Combat.set_amount`) rewrites a value. Open to in-language games and foreign
   mods over the same EV0–EV7 bus.
5. **Sub-system disable + replace** — each controller is decomposed into independently
   disable-able engine systems. `disable system esys_platformer_move` drops exactly one
   tick so a game can carry the component but drive it with its own handler, keeping the
   rest of the controller intact.
6. **Policy selection** — where a behaviour is a *formula* (gravity curve, aim mode,
   AI decision model, damage calc), the controller exposes a `policy`/`mode`/`model`
   enum field the system switches on, plus a cancellable/mutable event for the fully
   custom case. Ludic has no closures; the enum-field-plus-event pair is the honest,
   deterministic substitute.

## The packages

| Package | Issue | What it gives you |
| --- | --- | --- |
| **ludic.core** | #77 | The canonical engine-ABI components the movement system reads by name — `Position`, `Body`, `Collider`, `Solids` — so a game imports them instead of hand-declaring the bundles. Extend by composition (attach your own components alongside). |
| **ludic.gameplay** | #57 | The shared foundation: `Cooldown` timer, `Stats` + a timed modifier stack, a `Faction` friend/enemy/neutral table, and a `Combat` damage pipeline (`cancellable DamageAboutToApply` with a mutable amount, `Damaged`/`Died`/`Healed`). |
| **ludic.platformer** | #58 | Jump-feel `Platformer` (apex/coyote/buffer/variable-height/multi-jump), decomposed input/move/gravity/jump/anim sub-systems, `JumpRequested`/`Landed`/`StateChanged` events, a gravity policy enum, and opt-in scaffolding (moving/crumble platforms with rider carry, pickups+`Score`, springs, hazards+`Life`, checkpoints/goal). |
| **ludic.shooter** | #60 | `TopDown` decoupled move + aim (mouse / stick / move-dir / nearest-enemy auto-aim), a name-keyed `Weapon` registry (fire-rate/spread/pellets/pattern + data-driven pierce/homing), a deterministic `Projectile` pool (faction-filtered hits through `Combat`, pierce, ring/spiral patterns, homing), and a budgeted wave `Spawner`. |
| **ludic.npcai** | #61 | Perception → decision → action: `Vision`/`Memory` (throttled, faction + optional LOS), three decision models (FSM, utility, behaviour tree) writing one `Brain` intent with a `cancellable DecisionMade` hook, Reynolds flocking steering, and a `Follower` companion. The AI writes the *same intent fields the player controllers read*, so an enemy reuses the shooter's weapon and a companion reuses the mover. |
| **ludic.rpg** | #59 | Seven independently-usable modules: movement (grid/free/tween), inventory + equipment, crafting, event-driven quests + flags, an Ink/Yarn dialog graph, Sokoban puzzles + a switch/plate/gate signal graph, and over-time status effects. Content is name-keyed data registries — a mod adds items/recipes/quests/dialog with zero code. |

## Using a controller

The genre packages build on the engine's `Body`/`Collider` + `esys_move` (swept-AABB
tile collision, in `runtime/native/systems_move.ludic`) and on `ludic.gameplay`. In a
real project you `x add` them; in this repo the packages live under `packages/` and a
game compiles against them with `LUDIC_MODULES`:

```
LUDIC_MODULES=packages ludicc examples/games/platformer_demo.ludic -o platformer
```

Worked, self-checking examples for every controller live in `examples/games/`
(`platformer_demo`, `platformer_scaffolding`, `shooter_demo`, `npcai_demo`, `rpg_demo`)
and `examples/library/gameplay_foundation.ludic`; each is a deterministic regression
case in `x test`.

## What we deliberately do NOT do

- **No inheritance / virtual overrides.** Extension is composition + events + policy
  fields, not subclassing — determinism-safe and replayable.
- **No hidden global singletons.** Controller state lives in components (per-entity) or
  explicit module registries the game owns, so save/load and rollback capture it.
- **No float.** Everything is Q16.16 fixed / integer, so lockstep and replay hold.
