# Examples

A curated tour of Ludic, grouped by intent. Every example here is exercised by
the test suite (`bin/ludic dev test` / `bin/ludic dev selfhost-test`), so nothing in this
directory silently rots.

Run any program straight from the repository root (so `assets/` resolves):

```sh
bin/ludic build examples/games/snake.ludic              # compile + open a real window
bin/ludic build examples/games/snake.ludic --headless   # render one frame to build/out.ppm
bin/ludic examples/lang/offline_rewards.ludic     # compile + run a plain program
```

## `games/` — complete, windowed games

| Example | What it shows |
|---|---|
| [`games/snake.ludic`](games/snake.ludic) | A full game from primitives: input, grid, growth, collision, score. |
| [`games/menu.ludic`](games/menu.ludic) | A retained-UI title screen — the UI declared as data. |
| [`games/chronorift.ludic`](games/chronorift.ludic) | A 2D co-op JRPG: overworld, dungeon, random encounters, turn battle, boss, save. The entry file `import`s the modules under [`games/chronorift/`](games/chronorift/). |

## `rendering/` — drawing primitives

| Example | What it shows |
|---|---|
| [`rendering/draw_prims.ludic`](rendering/draw_prims.ludic) | The extended `Screen.*` primitives — line, circle, triangle, fill, sprite. |

## `ecs/` — the entity-component world

| Example | What it shows |
|---|---|
| [`ecs/hello.ludic`](ecs/hello.ludic) | The smallest program that exercises the ECS pipeline. |
| [`ecs/world_get.ludic`](ecs/world_get.ludic) | Reflection: read/write a component by name. |
| [`ecs/world_scan.ludic`](ecs/world_scan.ludic) | Reflection: scan the world and identify each entity. |
| [`ecs/world_query.ludic`](ecs/world_query.ludic) | Reflection: iterate the world by property. |
| [`ecs/world_spawn.ludic`](ecs/world_spawn.ludic) | Reflection: a mod spawns a fresh entity by model id. |
| [`ecs/world_mixed.ludic`](ecs/world_mixed.ludic) | Reflection: get/set through real struct offsets. |
| [`ecs/world_dyn.ludic`](ecs/world_dyn.ludic) | Reflection: register a brand-new component at runtime. |

## `events/` — the event bus

| Example | What it shows |
|---|---|
| [`events/events.ludic`](events/events.ludic) | EV0: the event-bus core — declare, `emit`, `@On`. |
| [`events/mod_events.ludic`](events/mod_events.ludic) | Two listeners on one event, driven from a mod. |
| [`events/cancel.ludic`](events/cancel.ludic) | EV3: cancellable (decision) events. |
| [`events/recurse.ludic`](events/recurse.ludic) | EV6: re-entrant `emit` is depth-bounded — no runaway cycle. |
| [`events/promote.ludic`](events/promote.ludic) | EV1: `@Public` promotes a lifecycle hook to a public event. |
| [`events/prop_events.ludic`](events/prop_events.ludic) | EV1 for properties: attach/detach events. |
| [`events/scene_events.ludic`](events/scene_events.ludic) | EV1 for scenes: on-enter / on-exit events. |
| [`events/program_events.ludic`](events/program_events.ludic) | EV1 for the program scope: start/quit events. |
| [`events/layer_events.ludic`](events/layer_events.ludic) | EV1 for layers + a `public` layer's show/hide events. |
| [`events/scoped.ludic`](events/scoped.ludic) | A despawned entity drops out of subsequent event work. |

## `networking/` — deterministic multiplayer (N0–N6)

Each maps to a stage of [the Networking design](https://git.workshopsoft.io/workshopsoft/ludic/wiki/Design/Networking); all run
over the compiler's built-in loopback transport with zero foreign code.

| Example | What it shows |
|---|---|
| [`networking/net_echo.ludic`](networking/net_echo.ludic) | N0: the transport seam. |
| [`networking/net_snapshot.ludic`](networking/net_snapshot.ludic) | N1: whole-world snapshot to a memory buffer. |
| [`networking/net_sync.ludic`](networking/net_sync.ludic) | N2: `@Sync` replication codegen. |
| [`networking/net_owner.ludic`](networking/net_owner.ludic) | N3: entity ownership. |
| [`networking/net_rpc.ludic`](networking/net_rpc.ludic) | N4: remote events / RPCs. |
| [`networking/net_roles.ludic`](networking/net_roles.ludic) | N5: handler roles + the drivable sim. |
| [`networking/net_demo.ludic`](networking/net_demo.ludic) | N6: a networked game end to end, in pure Ludic. |
| [`networking/net_rt.ludic`](networking/net_rt.ludic) | A blessed server-authoritative replication runtime. |

## `lang/` — language & standard-library tour

| Example | What it shows |
|---|---|
| [`lang/annotations.ludic`](lang/annotations.ludic) | The annotation-first style: `@Queries` / `@Computed` / `@OnSpawn` / `@Handles`. |
| [`lang/qdecl.ludic`](lang/qdecl.ludic) | `@Queries` desugaring to the query system. |
| [`lang/lifecycle.ludic`](lang/lifecycle.ludic) | The whole game lifecycle as `@`-hooks, in firing order. |
| [`lang/detach.ludic`](lang/detach.ludic) | Structural attach/detach + `@OnAttach` / `@OnDetach`. |
| [`lang/reason.ludic`](lang/reason.ludic) | Reason-carrying teardown (`@OnDespawn`: Despawned vs Quit). |
| [`lang/toggle.ludic`](lang/toggle.ludic) | enable/disable at the three ECS scopes. |
| [`lang/scenes.ludic`](lang/scenes.ludic) | One active scene at a time, handlers grouped into layers. |
| [`lang/strings.ludic`](lang/strings.ludic) | Strings as values: compare, join, interpolate, slice. |
| [`lang/operators.ludic`](lang/operators.ludic) | Compound assignment on every type, unary minus, char escapes, list literals. |
| [`lang/rng_demo.ludic`](lang/rng_demo.ludic) | The `Random.*` extensions (value/int/sign). |
| [`lang/time_demo.ludic`](lang/time_demo.ludic) | `Time.frame` / `elapsed` / `delta`. |
| [`lang/offline_rewards.ludic`](lang/offline_rewards.ludic) | A worked idle-game example over the Time/Date/Duration stdlib. |

## `library/` — building and linking a shared library

A how-to for compiling a `.ludic` module to a native `.dylib`/`.so`/`.dll` and
linking a second program against it via `extern fn`:

```sh
bin/ludicc examples/library/combat.ludic --shared -o build/libcombat.dylib
bin/ludicc examples/library/arena.ludic  -o build/arena -Lbuild -lcombat
```

| Example | What it shows |
|---|---|
| [`library/combat.ludic`](library/combat.ludic) | Exported functions callable across the C ABI. |
| [`library/arena.ludic`](library/arena.ludic) | A program that links against the shared library. |
