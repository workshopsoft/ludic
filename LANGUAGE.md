# The Ludic Language — Reference

This documents the Ludic language **as actually implemented** by
`compiler/ludicc.c`. Ludic is an AI-first, statically-typed, ahead-of-time
compiled language for games: an ECS is built into the language, and programs
compile straight to machine code.

```
program.ludic ──ludicc──▶ program.ll ──▶ program.o ──▶ native exe / shared lib   (LLVM IR; no C)
```

`ludicc` lowers Ludic to **LLVM IR itself** and links the result — see
[COMPILING.md](COMPILING.md) for the pipeline, `module`/`export`, and
cross-targets. There is one backend: no C is generated, compiled or linked at
any point, and the runtime a program calls is itself written in Ludic.

## Program structure

A program is one `program` block containing declarations:

```ludic
# doc-check: skip — illustrative: elided import list
program Name {
  import ...        # pull declarations in from another file
  property ...     # a record of typed fields — a per-entity component, or a
                    # plain `new`-allocated record; its use decides which
  model ...     # a named entity KIND (bundle of properties)
  const ...         # compile-time constants
  fn ...            # functions
  extern fn ...     # bind a C library symbol (FFI)
  handler ...        # behavior, grouped into phases
}
```

## Multi-file programs (`import`)

```ludic
# doc-check: skip — paths resolve only inside the repo
program ChronoRift {
  import "chronorift/world.ludic"    # path is relative to THIS file
  import "chronorift/combat.ludic"
}
```

An imported file is a **fragment**: bare declarations, no `program` wrapper. Its
declarations are spliced into the importing program. Imports may appear inside
the `program` block or before it, they may nest (a fragment may import fragments),
and each resolved path is **include-guarded**, so importing the same file twice
(even via different chains) pulls it in once. Diagnostics report the true file:

```
error: line 1: unknown type 'nope' for field Pos.x
  chronorift/world.ludic:1 | property Pos { x: nope = 0 }
```

## Models (entity kinds)

An `model` names a *kind* of entity and the fixed set of properties it
carries. It replaces the empty "tag property" idiom: identity is stored as one
integer per entity, not a parallel boolean array.

```ludic
# doc-check: skip — composite: declarations and statements together
property Pos   { x: int = 0, y: int = 0 }
property Stats { hp: int = 10 }

model Player { Pos, Stats }        # Player IS a kind, not a property
model Enemy  { Pos, Stats }

spawn Player { Pos { x: 5 } }           # attaches every listed property
                                        # (seeding field defaults), then overrides
for (p, s) in query [Pos, Stats, {Player}] { ... }   # {Player} filters by kind
```

Use `{Name}` (tag position) to filter a query by model — an model can't
be *bound* to a variable since it has no fields of its own. Entity kind is part
of the saved snapshot.

## Text, fonts & images

The 5×7 bitmap `text` stays for zero-asset programs. For real typography, load a
TrueType font and draw UTF-8:

```ludic
let f = font_load("/Handler/Library/Fonts/Supplemental/Arial.ttf")
text_ttf(f, 20, 20, "Héllo — Καλημέρα — Привет", 0xffffff, 28)   # anti-aliased
let w = text_w(f, "measure me", 28)                              # pixel width
```

The runtime ships a from-scratch TrueType engine (sfnt tables, cmap 0/4/6/12,
simple + composite `glyf` outlines, quadratic Béziers, supersampled AA) and a
glyph cache — no external font library. Arbitrary-size PNGs load as images:

```ludic
let panel = image_load("assets/ui/panel.png")
draw_9slice(panel, x, y, w, h, 10)     # stretch edges/center, keep 10px corners
draw_image_scaled(icon, x, y, 32, 32)
```

## Retained UI (`ui`)

UI is declared as **data** — a widget tree. The engine owns layout (stacked
panels with padding / gap / alignment / grow), drawing (9-slice skins, images,
TrueType text, focus highlight) and keyboard focus + activation.

```ludic
ui MainMenu {
  panel id: Root w: 288 pad: 16 gap: 6 skin: "assets/ui/panel.png" inset: 10 align: center {
    label  text: "CHRONO RIFT" font: reg(R_FONT) size: 26 fg: 0xffe060 align: center
    button id: NewGame text: "New Game" font: reg(R_FONT) size: 16 w: 236
    button id: Quit    text: "Quit"     font: reg(R_FONT) size: 16 w: 236
  }
}
```

Widget types: `panel` (container + optional skin/bg/border), `col` / `row`
(pure stacks), `label`, `button` (focusable), `image`, `spacer`. Props are
evaluated at build time, so `font: reg(R_FONT)` reads a value the program set first.
Each `id: Name` mints a `UI_Name` handle (the `ui` block name too), used from
handlers:

```ludic
handler Boot phase Start {
  set_reg(R_FONT, font_load("…Arial.ttf"))
  ui_build()                 # construct the tree (loads skins/images)
  ui_open(UI_MainMenu)       # make it active, focus the first button
}
handler Nav phase Update {
  ui_tick(key())             # w/s move focus, space/enter activate
  if ui_clicked(UI_Quit) { quit() }
  ui_set_int(UI_HpLabel, hp)  # poke dynamic values by id
}
handler Draw phase Render { clear(0x0e0e16); ui_render(); present() }
```

See `examples/games/menu.ludic` for a complete title screen.

## Types

| Type | Meaning | LLVM IR type |
|------|---------|--------------|
| `int` | 32-bit integer | `i32` |
| `fixed` | Q16.16 fixed-point | `i32` |
| `bool` | boolean | `i32` |
| `entity` | entity handle | `i32` |
| `str` | string literal | `ptr` |
| `ptr` | raw address (runtime/FFI) | `ptr` |
| `byte` | pointer to bytes — `p[i]` reads/writes one byte | `ptr` |
| `words` | pointer to 32-bit words — `w[i]` reads/writes an `int` | `ptr` |
| `fixeds` | buffer of `fixed` values — `f[i]` reads/writes a `fixed` | `ptr` |
| `ptrs` | buffer of pointers — `p[i]` reads/writes a `ptr` | `ptr` |

Allocate raw buffers with `bytes(n)` (n bytes) or `words(n)` (n 32-bit words);
both return a pointer you index with `buf[i]` — retype the binding (`words` /
`fixeds` / `ptrs`) to pick the element size.

Numeric literals: `42` and `0x1affff` are `int`; a literal with a decimal
point (`1.5`) is `fixed`. Arithmetic on two `fixed` values lowers to
`fxmul`/`fxdiv`; mixing `int` and `fixed` promotes the `int`. Convert with
`fixed(i)` (int→fixed) and `floor(f)` (fixed→int).

## Properties, entities, queries

```ludic
# doc-check: skip — composite: declarations and statements together
property Pos { x: int = 0, y: int = 0 }   # typed fields with defaults
property Player { }                        # a tag (no fields)

spawn Hero {                                # create an entity
  Pos    { x: 10, y: 5 }
  Player { }
}
despawn self()                              # remove the current entity

# iterate every entity that has all listed properties:
for (p) in query [Pos, {Player}] { p.x = p.x + 1 }   # {Tag} filters, doesn't bind
for (a, b) in query [Pos, Vel] where a.x > 0 { ... }  # one var per non-tag term
```

Entities are integer handles; property storage and slot reuse are generated per
program. `self()` yields the entity of the innermost `query` loop.

## Handlers & phases

```ludic
@Queries(these: [Pos, Vel])   # the entities this handler operates on
@Writes(Pos)                  # declared data access (parsed and reserved; not
@Reads(Vel)                   # yet consumed by any analysis pass)
handler Move @deterministic phase FixedUpdate
{ Pos.x = Pos.x + Vel.dx }
```

Phases run in this order every frame: **`Start`** (once at boot), then each
frame **`Input` → `FixedUpdate` → `Update` → `LateUpdate` → `Render`**.
`@edge` in front of a `handler` marks one that touches the outside world.

Everything a handler declares beyond its `phase` is an `@annotation` — the
handler's query, its data access, and its modifiers all use one uniform channel
rather than a mix of prefix keywords and signature clauses. `@export fn …`
(a C-ABI-exported function), `@edge handler …`, `@deterministic`, `@pure`,
`@Reads(...)`, `@Writes(...)`. (`@export` sets the export flag; the others parse
but have no codegen effect in the self-hosted compiler yet.)

### Declaring a handler's query (`@Queries`)

`@Queries` declares the entities a handler works on. The body then runs **once
per matching entity**, with each property bound by its own name and `self()`
giving that entity — the query header lifts out of the body into an annotation:

```ludic
# doc-check: skip — illustrative handler
@Queries(these: [Battle{hp <= 0}, Pos], on: Enemy)
handler CleanBattle phase LateUpdate { despawn self() }
```

is the same program as

```ludic
handler CleanBattle phase LateUpdate {
  for (Battle, Pos) in query [Battle, Pos, {Enemy}] where Battle.hp <= 0 { despawn self() }
}
```

`these:` lists the bound properties; a `Prop{constraint}` qualifies its bare
field names to that property (`Battle{hp <= 0}` → `Battle.hp <= 0`). `on: Model`
adds a `{Model}` kind filter. A handler with no `@Queries` runs once per tick.
For a constraint that spans two properties (`Pos.x > Vel.dx`), or several kind
filters, write the loop out with an inline `for (…) in query […] where …`
instead — `@Queries` covers the common per-property case.

### Conditions

A query selects on more than *which* properties an entity has. `where` is an
ordinary expression evaluated with the bindings in scope, so entities can be
matched on their field values:

```ludic
# doc-check: skip — illustrative @Queries constraint
@Queries(these: [Battle{hp <= 0}, Stats{level > 3}])
```

The same `where` works on an inline `for (…) in query […]`; in `@Queries` the
equivalent is a per-property `Prop{constraint}`.

A constraint is evaluated **per candidate entity**, so it is the wrong place for
a guard that concerns the whole handler (re-reading `reg(R_MODE)` for every
entity). Keep whole-handler guards in the body of a handler with no `@Queries`,
wrapping an inline query — as `CleanBattle` does in
`examples/games/chronorift/combat.ludic`.

### Matching is lazy, not snapshotted

Both forms iterate entities by id and re-check the match as they reach each one;
there is no per-tick array of matched entities. Consequences worth knowing:

* `despawn` of the current entity, or of one already visited, is safe.
* An entity **spawned during the loop at a higher id is visited in the same
  tick**. Spawn into a later phase if you don't want that.

### Engine-owned systems

Some systems are run by the **engine**, not written as a `handler`. A game opts
in by declaring a well-known component and carrying it on a model; the compiler
inserts the matching system into the frame loop, so the component is ticked with
no handler wired. The systems stand on the by-name reflection ABI, so they never
compile against a fixed layout — a component with the right field names is
enough, and a game that declares none is byte-for-byte unchanged.

| Component | Phase | Effect |
|---|---|---|
| `SpriteAnim { ticks, fps, frames, mode, frame }` | `Update` | advances `frame` — spritesheet frame animation (`mode` 0 loop, 1 once, 2 ping-pong). Optional `event_frame`/`event_fired` fields arm a frame event (`Anim.on_frame` / `Anim.fired`) |
| `Motion { ticks, dur, from, to, ease, value, done }` | `Update` | advances `value` — value tween (`ease` 0 linear, 1 in, 2 out, 3 in-out), latches `done` |
| `Light2D { x, y, radius, color, intensity }` | `Render` | additive radial glow; the engine runs the whole 2D light pass and presents. Optional `direction`/`spread` (cone), `falloff`, `softness`, `gel` fields select the render-quality tiers |
| `Occluder { x, y, w, h }` | `Render` | a rectangular shadow caster the light pass carves out |
| `Ambient { color }` | `Render` | one entity tints the whole scene (night/cave) before lights accumulate |

```ludic
# doc-check: skip — illustrative engine-owned system
property SpriteAnim { ticks: int = 0, fps: int = 0, frames: int = 0, mode: int = 0, frame: int = 0 }
model Hero { Pos, SpriteAnim }
# spawn a walking 6-frame clip at 10 fps; the engine advances SpriteAnim.frame
spawn Hero { Pos { x: 0, y: 0 }  SpriteAnim { fps: 10, frames: 6, mode: 0 } }
```

An **ergonomic layer** sits over the animation components: register named clips
with `Anim.clip("run", frames, fps, mode)` and (re)start one with
`Anim.play(entity, "run")` (or `Anim.play(entity, fps, frames, mode)`); arm frame
events with `Anim.on_frame` / read them with `Anim.fired`; start a value tween in
one call with `Motion.to(entity, from, to, dur, ease)`. Standalone **fluent tween
handles** — `Tween.to` / `Tween.chain` / `Tween.delay`, read with `Tween.value` /
`Tween.done` / `Tween.parallel` and cancelled with `Tween.stop` — sequence
multi-step motion the engine advances each tick, beyond a single `Motion`.

A `Light2D` / `Occluder` reads its position from a `Position { x, y }` component
on the same entity when the entity carries one, else from its own `x` / `y`
fields — so "Position + Light2D" and a self-positioned light both work. With
`Light2D` present the engine owns the frame flip: a draw handler renders the
scene and does **not** call `Screen.show`. Beyond the radial core the light pass
carries the render-quality tiers — `Light.spot` cones, a `Light.falloff`
exponent, `Light.soft` shadows (penumbra), `Light.gel` colour cookies,
normal-mapped surfaces (`Light.normal` + `Light.height`), and a
`Light.time_of_day` day/night ramp — every one deterministic.

### Input actions & deterministic replay

Beyond the raw `Input.key()` (this frame's key code), gameplay can read **named
actions** instead of physical keys, so a key is rebindable and a control scheme
is data. `Input.bind(action, key)` binds a key; `Input.down(action)` /
`Input.pressed(action)` read it (held vs one-shot edge); `Input.rebind(action,
from, to)` remaps it at runtime. `Input.poll()` is the single per-frame input
read the actions sit on — which is what makes **deterministic replay** fall out:
`Input.record()` captures the polled key each frame and `Input.replay()` feeds
the tape back, so a run reproduces exactly (the seed of lockstep netcode). All
integer and deterministic. See `examples/library/input_actions.ludic`.

Everything is integer and deterministic (the frame clock ticks at a fixed 60/s),
so animation, motion and lighting reproduce exactly under replay and lockstep
netcode. See `examples/library/anim_ecs.ludic` and `examples/library/light_ecs.ludic`.

## Annotations

Declarations carry `@annotations` in front of them — `@export`, `@edge`, `@pure`,
`@deterministic` — one uniform channel rather than a set of prefix keywords. Two
annotations replace a clause with a decorator.

**`@Queries` — a handler's query as a decorator.** Instead of the `query (v) […]`
clause, a handler annotates its query, with each property's constraints written
inline and the model given as `on:`:

```ludic
# doc-check: skip — composite: a handler plus its property/model declarations
property Transform { x: int = 0, scale: int = 1 }
property Velocity  { dx: int = 0, dy: int = 0 }
model Actor { Transform, Velocity }

@Queries(these: [Transform{scale > 0}, Velocity{dx > 0 or dy > 0}], on: Actor)
handler Move phase Update {
  Transform.x = Transform.x + Velocity.dx      # each property is bound by its name
}
```

It desugars to the ordinary loop

```ludic
# doc-check: skip — the desugaring of the @Queries above
for (Transform, Velocity) in query [Transform, Velocity, {Actor}]
    where Transform.scale > 0 and (Velocity.dx > 0 or Velocity.dy > 0) { … }
```

— each listed property becomes a binding **named after itself**, a
`Prop{constraint}` block reads its bare names as fields of `Prop`, and `on: Model`
adds a `{Model}` tag filter. The body runs once per matching entity.

**`@Computed` — a derived field.** A property field marked `@Computed` is **not
stored**; `x.field` expands inline to its expression with the bare names read as
fields of `x`. It reads like a field but costs nothing at runtime — no getter, no
storage — so it doesn't reattach behavior to data:

```ludic
# doc-check: skip — a property with a derived field
property Velocity {
  dx: int = 0
  dy: int = 0
  @Computed speed2: int = dx * dx + dy * dy    # v.speed2  ==  v.dx*v.dx + v.dy*v.dy
}
```

**Lifecycle hooks.** A game's timeline has fixed moments, and each is a handler
annotation. They fire in this order and each reduces to ordinary code, so the
data stays plain and behaviour stays in handlers:

```
boot ── @OnStart ─▶ spawn ── @OnAttach(P), @OnSpawn(M) ─▶ … ── @OnDespawn(M) ─▶ quit ── @OnQuit
```

- **`@OnStart` / `@OnQuit`** — the *program*. `@OnStart` runs once at boot (it is
  the `Start` phase); `@OnQuit` runs once at shutdown, after the frame loop stops
  and before the process exits — the place to `save()` or clean up.
- **`@OnSpawn(Model)` / `@OnDespawn(Model)`** — an *entity*. Both bind the model's
  properties by name; `@OnSpawn` is a constructor, `@OnDespawn` a destructor.
  Despawn doesn't statically know an entity's model, so despawn hooks compile to
  functions dispatched on the entity's kind. `@OnDespawn` may take an optional
  **reason**: `@OnDespawn(Enemy, reason: r)` binds `r` to an `EndReason` the
  compiler passes at each teardown site — `EndReason.Despawned` for an in-world
  `despawn`, `EndReason.Quit` when the program exits. At shutdown every still-live
  entity's `@OnDespawn` fires with `Quit` (no silent deaths), so teardown can
  branch on *why* it is ending — save on `Quit`, drop loot otherwise.
- **`@OnAttach(Property)` / `@OnDetach(Property)`** — a *property* attached to or
  removed from an entity, with the property bound by name. `@OnAttach` fires once
  the fields are seeded (a per-property constructor); `@OnDetach` fires when the
  property is removed, *before* its has-flag clears, so the body can read the
  outgoing value (a per-property destructor). They pair with the `attach` /
  `detach` statements below.

```ludic
# doc-check: skip — lifecycle hooks
@OnStart          handler Boot  { seed(1) }
@OnSpawn(Enemy)   handler Init  { Health.hp = Health.max }     # constructor
@OnDespawn(Enemy) handler Clean { drop_loot(Health.hp) }       # destructor
@OnDespawn(Enemy, reason: r) handler End {                    # destructor that knows why
  match r { EndReason.Quit => save() ;  _ => drop_loot(Health.hp) }
}
@OnAttach(Sprite) handler Load  { Sprite.id = image_load("goblin.png") }
@OnDetach(Sprite) handler Free  { image_drop(Sprite.id) }      # paired teardown
@OnQuit           handler Save  { save() }                     # once, at shutdown
```

**Enable / disable — pause, don't destroy.** `enable` and `disable` are statements
that flip something on or off without destroying it. There are three scopes:

- **`disable P on e` / `enable P on e`** — one *property* on one entity. Disabling
  clears the entity's has-flag, so queries stop matching it, but the field values
  stay in storage — a later `enable` restores them untouched. `@OnDisable(P)` and
  `@OnEnable(P)` are handler annotations that run at the toggle point with the
  property bound by name (like a one-entity `@OnSpawn`).
- **`disable Model` / `enable Model`** — a whole *model*. Its entities drop out of
  every query while disabled; the entities and their data are left alone.
- **`disable Handler` / `enable Handler`** — a *handler*. It stops being called
  each phase while disabled, and resumes on `enable`.

Each toggle is one global flag flip (or one has-flag store), so nothing is copied
or freed — enable/disable is cheap and fully reversible.

**Attach / detach — add, don't just resume.** Where `enable`/`disable` *pause* a
property that already belongs to an entity, `attach`/`detach` change what the
entity *has*:

- **`attach P on e` / `attach P on e { field: v, … }`** — add property `P` to a
  live entity, seeding its fields from the defaults plus any overrides, and fire
  `@OnAttach(P)`. It fires only on a real transition: attaching a property the
  entity already has is a no-op.
- **`detach P on e`** — remove `P`, firing `@OnDetach(P)` (which still reads the
  outgoing value) before the has-flag clears. Also a no-op if `P` is absent.

The distinction mirrors DOTS's enableable components vs structural add/remove, or
Bevy's disable vs `Remove`: `disable` is a reversible pause that keeps the data;
`detach` is a structural removal (a following `attach` re-seeds fresh fields).

```ludic
# doc-check: skip — enable/disable + attach/detach
@OnDisable(Shield) handler Down { play("shield_break.wav") }
@OnEnable(Shield)  handler Up   { play("shield_up.wav") }
@OnAttach(Shield)  handler Grab { play("shield_get.wav") }
@OnDetach(Shield)  handler Drop { play("shield_drop.wav") }

disable Shield on self()          # pause: this entity loses its shield; data kept
enable  Shield on self()          # resume: shield back, amount unchanged
attach  Shield on self() { amount: 3 }   # structural: give it a fresh shield
detach  Shield on self()          # structural: take the shield away entirely
disable Gravity                   # a whole model sits out every query
disable AiThink                   # a handler stops running each phase
```

See [`examples/lang/toggle.ludic`](examples/lang/toggle.ludic) for the three enable/disable
scopes, [`examples/lang/detach.ludic`](examples/lang/detach.ludic) for the structural
attach/detach pair, and [`examples/lang/reason.ludic`](examples/lang/reason.ludic) for
reason-carrying teardown. The rest of the lifecycle roadmap (value-change hooks,
query-membership edges, keyed effects) is in
[the Lifecycle design](https://git.workshopsoft.io/workshopsoft/ludic/wiki/Design/Lifecycle).

**`@Handles` — the handlers a program drives.** Written in front of the
`program`, `@Handles(Move)` names the handlers it uses. It parses and reads as
documentation; every declared handler still runs (registration is implicit).

See [`examples/lang/annotations.ludic`](examples/lang/annotations.ludic) (queries, computed
fields, one hook) and [`examples/lang/lifecycle.ludic`](examples/lang/lifecycle.ludic) (the
whole timeline), plus [`examples/lang/toggle.ludic`](examples/lang/toggle.ludic)
(enable/disable). Scenes and their `on enter` / `on exit` lifecycle blocks are
implemented — see "Scenes & layers" below. (An annotation spelling,
`@OnEnter(Scene)` / `@OnExit(Scene)`, is a designed but not-yet-built convenience
— see [the Scenes design](https://git.workshopsoft.io/workshopsoft/ludic/wiki/Design/Scenes); today the hooks are written as `on
enter { … }` inside the `scene`.)

## Events & modding (`event`, `emit`, `@On`)

Where lifecycle hooks are the *closed, in-language* reactions the game author
compiles in, **events are the open, runtime surface a game exposes to mods** —
code loaded after compilation, in any language with a C ABI. The two share their
fire sites; an event is a hook seen from across the ABI. A program that declares
no `event` is compiled byte-for-byte as before.

- **`event E { field: T = default, … }`** declares a public event carrying a flat
  POD payload (fields may be empty). **`@On(E) handler Name { … }`** registers an
  in-language listener whose body reads the payload fields by name. **`emit
  E(field: v, …)`** fires it — every listener runs, in declaration order, as a
  direct call. It all desugars to a `@ev_<E>` function; there is no interpreter.

```ludic
# doc-check: skip — illustrative
event Hurt { entity: int, amount: int }
@On(Hurt) handler Flash { hud_flash(amount) }     # payload bound by name
emit Hurt(entity: e, amount: 5)                    # fires every listener
```

- **The foreign ABI.** Each event also generates `int ludic_on_<E>(void (*cb)(Ev*))`
  and a payload struct `%Ev_<E>`, so a mod in C / Lua / JS (over its FFI) registers
  a callback and is dispatched to right after the native listeners — the closed and
  open halves, one dispatch. Native listeners cost a direct call; foreign ones one
  indirect call over a fixed-capacity array (registration order = dispatch order,
  so a modded game stays deterministic). See [`examples/mod_host.ludic`](examples/mod_host.ludic)
  and the C mod in [`tests/mod_c/mod.c`](tests/mod_c/mod.c).

- **`@Public` promotes a lifecycle hook to an event, across the whole
  architecture.** The game's own lifecycle becomes moddable with no hand-written
  `emit`, at every scope:
  - **program** — `@Public @OnStart`/`@OnQuit` → `program_start` / `program_quit`
    (the top-level mod entry/exit points). See [`examples/events/program_events.ludic`](examples/events/program_events.ludic).
  - **models** — `@Public @OnSpawn(Enemy)`/`@OnDespawn(Enemy)` →
    `model_Enemy_spawn` / `model_Enemy_despawn` (entity, + `EndReason` on despawn).
    See [`examples/events/promote.ludic`](examples/events/promote.ludic).
  - **properties** — `@Public @OnAttach/@OnDetach/@OnEnable/@OnDisable(P)` →
    `prop_<P>_attach` / `_detach` / `_enable` / `_disable`. See [`examples/events/prop_events.ludic`](examples/events/prop_events.ludic).
  - **scenes** — a `public` scene → `scene_<S>_enter` / `scene_<S>_exit`. See [`examples/events/scene_events.ludic`](examples/events/scene_events.ludic).
  - **layers** — a `public` layer, with `enable layer L` / `disable layer L`
    flipping the layer on and off (its handlers stop while hidden) →
    `layer_<L>_show` / `layer_<L>_hide`. See [`examples/events/layer_events.ludic`](examples/events/layer_events.ludic).

- **`cancellable` events are decisions, not just notifications.** A listener on a
  `cancellable` event may `cancel` it (a foreign listener sets the payload's
  trailing `cancelled` flag); `emit E(…)` used as an *expression* yields that flag,
  so the caller applies the action only when it wasn't vetoed — the Bukkit/DOM
  `preventDefault` shape. See [`examples/events/cancel.ludic`](examples/events/cancel.ludic).

```ludic
# doc-check: skip — illustrative
event cancellable BeforeHurt { amount: int }
@On(BeforeHurt) handler Armor { if amount > 10 { cancel } }
if emit BeforeHurt(amount: dmg) == 0 { hp = hp - dmg }   # apply only if not vetoed
```

The full modding roadmap — the world-table reflection ABI, scoped/leak-proof
listeners, and the sandbox — is in [the Events design](https://git.workshopsoft.io/workshopsoft/ludic/wiki/Design/Events).

## Records (`property`), arrays and slices

There is one record keyword, `property` — a named set of typed fields with
defaults. How a property is *stored* follows from how it is *used*, so the same
declaration covers both ECS components and the plain records a program keeps
outside the ECS:

- listed in a `model` (or attached by `spawn`) → a **component**, stored in the
  engine's per-entity arrays and bound in queries;
- constructed with **`new`** → a **heap record**, addressed by a pointer.

A program that only declares `property` records and functions — never a `model`
or `handler` — is not an ECS program at all: it gets no entity storage or
runtime, just the record layouts and `new`. (This is exactly how the Ludic
compiler is written in itself.)

```ludic
property Tok { kind: int = 0, line: int = 0, next: Tok }

handler Lex phase Update {
  let t = new Tok        # allocates; every field seeded from its default
  t.kind = 1
}
```

A `new` record has **reference semantics**: the value is a pointer to the
object, so assigning or passing one shares it rather than copying.

```ludic
property Tok { kind: int = 0, line: int = 0, next: Tok }

function bump(t: Tok) -> void { t.kind = t.kind + 1 }

handler Share phase Update {
  let a = new Tok
  let b = a              # b and a are the SAME object
  b.kind = 9
  print(a.kind)      # 9
  bump(a)                # the mutation is visible to the caller
  print(a.kind)      # 10
}
```

Fields chain, so a record can refer to its own type and be walked without
temporaries — which is what an AST or a linked list needs:

```ludic
handler Walk phase Update {
  let a = new Tok
  let b = new Tok
  a.next = b
  print(a.next.kind)
  a.next.kind = 42       # chains on the left of an assignment too
}
```

Two array forms. `[]T` is the growable slice (below) and is implemented. `[T; N]`
is a **fixed array** — stored inline and zeroed — and is a design target: the
self-hosted compiler's `ptype` parses `[]T` but **not** `[T; N]` yet, so the
snippet below does not compile today. Programs use `[]T` slices for now.

```ludic
# doc-check: skip — [T; N] fixed arrays are not yet implemented (design target)
var table: [int; 8]      # module-level storage
handler S phase Update {
  let buf: [int; 4]      # a local; no initializer needed
  buf[0] = 10
  table[2] = buf[0]
}
```

`[]T` is a **growable slice** — a pointer to a header holding data, length and
capacity. `push` appends, doubling the storage when it is full; because the
header never moves, an append is visible to everything holding that slice.

```ludic
handler Collect phase Update {
  let toks = new []Tok
  push(toks, new Tok)
  for i in 0 .. len(toks) { print(toks[i].kind) }
}
```

Indexing works as both a value and an assignment target, and composes with
fields: `toks[i].kind = T_ID` is a single address computation.

## Functions & FFI

```ludic
function heal(amount: int) -> int { return amount * 2 }

extern function c_hypot(a: fixed, b: fixed) -> fixed = "hypot_fx"   # bind a C symbol
```
`extern fn … = "symbol"` declares a foreign function and binds it to a symbol
resolved at link time; pass `-L`/`-l` to ludicc to link its library. This is how
Ludic calls anything with a C ABI — including a shared library built from
another `.ludic` file (see `examples/library/`).

## Statements

`let x = expr` / `var x = expr` · `x = expr` (`+= -= *= /=`) · `if cond { }` /
`if/else` (the `else` is optional) · `while cond { }` · `for i in a .. b { }`
(numeric range) · `for (…) in query […] { }` · `break` · `continue` · `return` ·
`spawn` · `despawn` · `enable` / `disable` (a property `on e`, a model, or a
handler) · `attach` / `detach` (a property `on e`) · `match` · `machine`.

### Bindings: `let`, `var`, `const`

A binding's keyword states whether it can be reassigned, the way Rust and Swift
use them — not its scope (position decides that: inside a body it is a local,
at the top level it is module state).

- **`let x = e`** — an *immutable* binding. `x = …` afterward is a compile error
  (`cannot assign to immutable 'x'`). Reach for `let` by default.
- **`var x = e`** — a *mutable* binding: `x`, `x += 1`, … reassign it. Use it for
  loop accumulators and anything that genuinely changes.
- **`const NAME = e`** — a compile-time constant (folded, no storage).

Immutability is of the **binding**, not the object. A `let` that holds a record
or slice still lets you mutate *through* it — the reference itself just cannot be
repointed:

```ludic
# doc-check: skip — illustrative bindings
let n = new Node       # immutable binding…
n.kind = 1             # …but mutation through it is fine
n = new Node           # ERROR: cannot assign to immutable 'n'

var total = 0
for i in 0 .. 10 { total += i }   # a var is the right tool for an accumulator
```

**Statements are separated by a newline or `;`** (both lex to the same separator
token). Two statements may not sit adjacent with only spaces between them — the
compiler reports `expected newline or ';' between statements`. Write one
statement per line, or, to pack several onto a line, separate them with `;`:

```ludic
# doc-check: skip — a bare statement block, not a whole declaration
let x = 1
x = x + 1                     # one per line, the usual form
let y = 1; y = y + 1          # or `;`-separated on one line
```

`break` and `continue` apply to the innermost enclosing loop, and work in all
three loop forms — `while`, the numeric `for`, and the ECS query loop, where
`continue` advances to the next matching entity. Using either outside a loop is
a compile error.

## Pattern matching & state machines

`match` replaces `if`-ladders on one value. Arms list one or more literal
patterns (or `_` for the default) and a body:

```ludic
match tile {
  'T', '#' => return SPR_TREE       # multiple patterns per arm
  'D'      => return SPR_DOOR
  _        => return SPR_GRASS      # optional default
}
```

`machine` turns a register into an explicit state machine: it dispatches on the
register's value to the matching `state`, and `become` transitions to a named
state (no more `if phase == N` chains). See the co-op battle in
`examples/games/chronorift/combat.ludic`:

```ludic
# doc-check: skip — illustrative: elided bodies
machine R_PHASE {
  state KnightMenu { … if is_confirm(k) { …attack…  become KnightResolve } }
  state KnightResolve { … become MageMenu }
  state EnemyTurn { … become KnightMenu }
}
```

States **number themselves by declaration order** (`KnightMenu` is `0`,
`KnightResolve` is `1`, …) — no magic constants. (An explicit `state Name = expr`
is still accepted when a state needs a specific value.) A `machine <reg>` reads
`reg(<reg>)` to pick the state; `become Name` compiles to `set_reg(<reg>, <Name's
value>)`. Both lower to plain branches (and `match` runs on the native LLVM
backend too).

## Enums

`enum` names a set of related integer values so a magic-number space — a menu
selection, a mode, a machine state — reads as names instead of literals:

```ludic
# doc-check: skip — composite: a declaration plus its uses
enum Action { Attack, Guard, Item, Flee }        # Attack = 0, Guard = 1, …

match reg(R_CUR) { Action.Attack => attack()  Action.Guard => guard()  _ => wait() }
if reg(R_MODE) == Mode.Battle { … }
```

A variant is a **compile-time `int`** accessed as `Enum.Variant` (`Action.Guard`
is `1`), numbered from `0` by declaration order, so it works anywhere an int does
— `match` patterns, comparisons, `set_reg`. Enums are a naming layer over `int`:
there is no distinct enum runtime type yet, so an enum value lives in an ordinary
`int` or register (and is saved with it). See `examples/games/chronorift/combat.ludic`,
whose battle menus dispatch on `KnightAct`/`MageAct` instead of `0..3`.

## Expressions

Precedence (high to low): `postfix(. [] ())  →  unary(- ~ not)  →
* / %  <<  >>  &  →  + -  |  ^  →  compar(< <= > >= == !=)  →  and  →  or`.
The bitwise operators bind **tighter than comparison** (Go-style), so
`flags & MASK == 0` means `(flags & MASK) == 0` — no parentheses needed.

Operators are built-in only (no overloading). The boolean operators are spelled
**`and` / `or` / `not`**; `&&` and `||` are not Ludic operators, and a bare `!` is
rejected with a diagnostic naming the fix (`!=` is unaffected). Bitwise operators
are **`& | ^ << >> ~`** (`>>` is a logical/unsigned shift).

**Strings are values.** `a + b` concatenates two strings, and `a == b` / `a != b`
compare them **by content** (not by pointer). `"go" + dir == "goleft"` works as
written. (Under the hood these call a small emitted string runtime; a `==`/`!=`
against `null` is still a pointer test.)

**Interpolation is the readable way to build them.** A backtick string
`` `text {expr} text` `` embeds any expression in `{…}` — numbers, bools and
`fixed` values become text automatically, strings pass through — and desugars to
the `+` chain above:

```ludic
# doc-check: skip — illustrative interpolation
let msg = `hello {name}, you have {count + 1} messages`
# == "hello " + name + ", you have " + str(count + 1) + " messages"
```

`str(x)` is the same conversion on its own. Write a literal brace as `{{` / `}}`.

**Slicing.** `s[a..b]` is a fresh substring of the bytes `[a, b)`, and `len(s)`
is a string's byte length — so `path[0..len(path) - 6]` trims an extension and
`s[i]` still indexes a single byte. `expr with { field: … }`
is not implemented; records appear only in `spawn`. Char literals (`'w'`) are
`int` code points; colors are hex ints (`0xff8800`). `null` is the null-pointer
literal; test any pointer/record/slice with `x == null` / `x != null` (an unset
`Node`/`ptr` field reads back as `null`).

## Builtins (the standard library / runtime surface)

```
# math      min max abs clamp                       (int)
# rng       seed(i)  rng_range(lo,hi)->int  rng_chance(pct)->bool   (deterministic)
# fixed     fixed(i)->fixed   floor(f)->int
# tilemap   map_size(w,h)  map_row(y,str)  tile(x,y)->int
# 2D draw   clear(color)  fill_rect(x,y,w,h,color)  frame_rect(...)  put_px(x,y,color)
#           draw_sprite(id,x,y)  draw_sprite_scaled(id,x,y,scale)  present()
# text      text(x,y,str,color,scale)  text_int(x,y,n,color,scale)   (5x7 bitmap)
# fonts     font_load(path)->id                                       (TrueType .ttf/.ttc)
#           text_ttf(font,x,y,utf8,color,px)  text_w(font,utf8,px)->int  text_h(font,px)->int
# images    image_load(path)->id   draw_image(id,x,y)   draw_image_scaled(id,x,y,w,h)
#           draw_9slice(id,x,y,w,h,inset)
# UI        ui_build()  ui_open(id)  ui_tick(key)  ui_render()
#           ui_clicked(id)->bool  ui_set_text(id,str)  ui_set_int(id,n)
#           ui_focus(id)  ui_focused()->int  ui_visible(id,bool)
# assets    png_load(path)->id           (decodes a PNG; returns a 16x16 sprite id)
# input     key()->int                   (current frame's key code, 0 if none)
# state     reg(i)->int   set_reg(i,v)     (64 integer resources shared by handlers)
# entity    self()->entity
# save      save()   load()->bool         (binary snapshot of the whole ECS World)
# control   quit()   print(x)          (a value + newline)
# convert   str(x) -> str            (int/bool/fixed -> text)
# length    len(x) -> int            (elements of a slice, or bytes of a string)
# process   arg_count()->int   arg(i)->str          (the command line; argv[0] included)
#           exit(code)   run(cmd)   getenv(name)   read_char()->int
#           file_stderr()->ptr  file_stdout()->ptr (handles for file_write)
```

## Tooling

```bash
ludicc app.ludic -o build/app         # native binary (windowed for a game)
ludicc app.ludic --headless -o app       # headless build (renders out.ppm; reads stdin)
ludicc app.ludic --emit-llvm -o app.ll   # stop at LLVM IR
ludic  app.ludic                       # compile AND run (forwards the exit code)
```

`ludicc` (compile) and `ludic` (compile-and-run) are one multi-call binary built
by `bin/x build-cli`. **[COMPILING.md](COMPILING.md) is the authoritative CLI
reference** — the full flag set (`-o`, `--windowed`, `--headless`, `--emit-llvm`,
`--save-temps`, `--run`), the `LUDIC_HOME` / `LUDIC_CC` environment variables,
and the IR-to-stdout bootstrap contract (no `-o`, invoked as `ludicc`) that
`bin/x app` / `bin/x reseed` rely on. The default mode is auto: a file with `handler`s
links windowed, otherwise headless; an explicit flag always wins.

The retired C driver's `--shared`, `--fmt`, `-c`, cross-compile (`--target`) and
wasm modes are **not** on the self-hosted toolchain (see "Not yet implemented").
Source formatting now lives in the standalone `bin/ludic-fmt` (below), not a
compiler flag.

The self-hosted compiler is intentionally permissive: it has no separate
validation pass yet, so unknown types lower to `ptr` and call arity is not
checked. Diagnostics are limited to parse-level errors
(`ludicc(self): parse error: …`); richer static checks (unknown identifiers,
duplicate types, unknown fields, arity) are future work.

### Editors

```bash
bin/x tools                            # -> bin/ludic-fmt, bin/ludic-lsp
bin/ludic-fmt -w src/                 # format in place (keeps comments)
bin/ludic-fmt --check .               # CI: exit 1 if anything is unformatted
bin/ludic-lsp --stdio                 # the language server, for any editor
```

`ludic-fmt` is the source formatter: it works on tokens, so comments and blank
lines survive and no file is ever rewritten into another. `ludic-lsp` speaks
LSP 3.17 and supplies completion, diagnostics, hover, go-to-definition,
find-usages, rename, formatting, outlines, folding and inlay hints — the same
binary for every editor. Both also understand ```` ```ludic ```` fences inside
Markdown, so documentation gets the same highlighting and checking as source.

Plugins for VS Code and JetBrains IDEs, plus configuration for Neovim, Helix,
Emacs, Sublime and Zed, are in `tools/editors/` — see
[tools/editors/README.md](tools/editors/README.md).

## Working programs

- `examples/games/chronorift.ludic` — a co-op JRPG (overworld, dungeon, boss, shop,
  save) using CC0 Kenney sprites. Split across `chronorift/*.ludic` via `import`,
  built on models.
- `examples/games/menu.ludic` — a retained-UI title screen (9-slice panel, TrueType
  labels, focusable buttons).
- `examples/games/snake.ludic` — Snake, no assets — same compiler, proving generality.

```bash
bin/x app examples/games/snake.ludic && ./build/snake
```

## Not yet implemented

Units on quantities (`9.8 m/s^2`), `with` record-update expressions, a bytecode
VM + hot-reload, and the live agent bridge — these appear in the design docs but
are future work.

- **`reads` / `writes` clauses** — parsed and reserved on the handler node, but no
  analysis pass consumes them.
- **`[T; N]` fixed arrays** — documented above, but `ptype` parses only `[]T`
  slices; fixed inline arrays are not accepted yet. Use `[]T` slices.
- **CLI: `--shared`, `--fmt`, and the wasm/cross target** — these were features of
  the retired C driver; the self-hosted `ludicc` does not carry them (source
  formatting lives in `bin/ludic-fmt` instead). Output-path and IR flags are in
  flux as the CLI front-end is rebuilt — check `ludicc` usage for the current set.

Records (`property` used with `new`) and array types, `break`/`continue`, and
argv/stderr — once listed here as near-term — are now implemented and
self-hosting; their lowerings are in
[the Bootstrap deep-dive](https://git.workshopsoft.io/workshopsoft/ludic/wiki/Bootstrap) §4.

## Scenes & layers

> **Implemented (S0).** `scene`, `layer`, and the `on enter` / `on exit` hooks
> compile; [`examples/lang/scenes.ludic`](examples/lang/scenes.ludic) runs and is checked
> by `bin/x test`. A scene lowers to a `machine` the compiler writes for you: one
> implicit active-scene register, states numbered by declaration order, and
> `become` as two direct calls plus a store. Richer scene features (the overlay
> stack, scene-owned entities, scene-local state, transition parameters) are
> designed in [the Scenes design](https://git.workshopsoft.io/workshopsoft/ludic/wiki/Design/Scenes) and not built yet.

A program is usually several mutually-exclusive states — a title screen, the
overworld, a battle — and the usual way to write that is a mode register
consulted at the top of every handler. `scene` makes it structure instead:

```ludic
# doc-check: skip — illustrative: elided bodies
scene Title start {
  on enter { ui_open(UI_Menu) }
  on exit  { ui_visible(UI_Menu, 0) }

  layer Main {
    handler Choose phase Update {
      if ui_clicked(UI_NewGame) { become Overworld }
    }
  }
}

scene Overworld {
  on enter { spawn_party() }

  layer World { handler Move phase Update { … } }
  layer Hud   { handler Draw phase Render { … } }
}
```

- Exactly **one scene is active**. The one marked `start` runs first (or the
  first declared, if none is marked); its `on enter` fires once at boot, right
  after the `Start` phase.
- A scene's handlers only run while it is active. Handlers declared outside any
  scene are global and run every frame regardless.
- **Layers group handlers and declaration order is draw order**: within a phase,
  global handlers run first, then the active scene's layers in the order they
  were written — so `Hud`'s `Render` paints over `World`'s.
- `on enter` / `on exit` are lifecycle hooks, not phases. Scene setup goes in
  `on enter`; a layer handler may not use phase `Start`.
- `become Name` transitions: the current scene's `on exit` runs, the active scene
  becomes `Name`, and its `on enter` runs. Inside a layer handler the compiler
  knows which scene is leaving, so a transition costs two direct calls and a
  store — there is no dispatch table.
- **The active scene is snapshotted per phase.** A `become` mid-phase runs its
  `on exit`/`on enter` immediately, but the switch of *which layers dispatch*
  takes effect at the next phase boundary — so exactly one scene's layers run in
  any single phase, and a `become` in `Update` is visible to that same frame's
  `Render`.

[`examples/lang/scenes.ludic`](examples/lang/scenes.ludic) is a runnable, tested example
of these rules.

## Queries in a handler signature

When a handler's whole body is one query loop, the loop header lifts into a
`@Queries` annotation (see "Declaring a handler's query" above):

```ludic
# doc-check: skip — illustrative handler
@Queries(these: [Battle{hp <= 0}, Pos], on: Foe)
handler CleanBattle phase LateUpdate { despawn self() }
```

This is exactly equivalent to wrapping the body in
`for (Battle, Pos) in query [Battle, Pos, {Foe}] where Battle.hp <= 0 { … }` —
same lowering, same semantics. The body runs once per matching entity and
`self()` is that entity. `examples/lang/qdecl.ludic` is a working example.

Mutation during iteration follows the same rules as an inline query, because it
is the same loop: entities are visited by ascending id, `despawn` of the current
or an already-visited entity is safe, and an entity **spawned mid-loop at a
higher id is visited in the same tick**. If you need the tick's matches frozen,
collect them yourself.
