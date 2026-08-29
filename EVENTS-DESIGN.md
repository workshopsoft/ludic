# Events & modding, expanded — a design doc

> **Status: EV0 fully shipped; EV1 (spawn/despawn), EV2 (first cut) and EV3
> shipped; EV4–EV7 are design.** Implemented, self-hosted to the C-free fixpoint,
> and each a `bin/x test` check:
> - **EV0** — `event`/`@On`/`emit` lowered to `@ev_<E>` dispatch (compile-time
>   listeners), **plus the foreign C ABI** (`ludic_on_<E>`, the `%Ev_<E>` payload
>   struct, a fixed-capacity listener array), proven by a C mod in
>   [`tests/mod_c/mod.c`](tests/mod_c/mod.c) binding
>   [`examples/mod_host.ludic`](examples/mod_host.ludic). Byte-identical when no
>   event is declared. ([`examples/events.ludic`](examples/events.ludic))
> - **EV1** — public events across the **whole architecture**, every scope shipped:
>   **program** (`@Public @OnStart`/`@OnQuit` → `program_start`/`program_quit`,
>   [`examples/program_events.ludic`](examples/program_events.ludic)); **models**
>   (`@Public @OnSpawn`/`@OnDespawn` → `model_<M>_spawn`/`_despawn`,
>   [`examples/promote.ludic`](examples/promote.ludic)); **properties** (`@Public
>   @OnAttach`/`@OnDetach`/`@OnEnable`/`@OnDisable` → `prop_<P>_attach` etc.,
>   [`examples/prop_events.ludic`](examples/prop_events.ludic)); **scenes** (a
>   `public` scene → `scene_<S>_enter`/`_exit`,
>   [`examples/scene_events.ludic`](examples/scene_events.ludic)); and **layers** (a
>   `public` layer + `enable/disable layer L` → `layer_<L>_show`/`_hide`,
>   [`examples/layer_events.ludic`](examples/layer_events.ludic)) — which also
>   landed **SCENES E2 layer toggle** (`@LE_<L>` flag gating a layer's handlers).
> - **EV2 / EV2b** — the world table: the reflection ABI, generated from the
>   compile-time schema, so a mod reads, writes, scans, identifies, **and creates**
>   entity state **by name** without compiling against the game. `ludic_prop_id` /
>   `ludic_field_id` / `ludic_get` / `ludic_set` / `ludic_has` (read/write —
>   [`world_mod.c`](tests/mod_c/world_mod.c)); `ludic_entity_count` / `ludic_kind` /
>   `ludic_model_id` (scan and identify — [`world_scan.c`](tests/mod_c/world_scan.c));
>   `ludic_spawn(model_id)` (create, reusing the compiler's own spawn lowering —
>   [`world_spawn.c`](tests/mod_c/world_spawn.c)); `get`/`set` address each field by
>   its real struct offset, correct for `int`/`fixed`/`byte`/`ptr` and mixed layouts
>   ([`world_mixed.c`](tests/mod_c/world_mixed.c)); and iterate
>   (`ludic_query_next`, [`world_query.c`](tests/mod_c/world_query.c)). Emitted only
>   for an ECS program that declares events, so event-free games stay byte-exact.
>   The world table is complete: read, write, scan, identify, create, iterate.
> - **EV3** — `cancellable` events, the `cancel` verb, and `emit E(…)` as an
>   expression returning the veto flag. ([`examples/cancel.ludic`](examples/cancel.ludic))
> - **EV5** — leak-proof scoped listeners: `ludic_off_<E>(token)` (explicit
>   unregister; dispatch skips tombstoned slots), `ludic_on_entity_<E>(entity, cb)`
>   (entity-scoped), and a generated `ludic_sweep_entity` called from `despawn` that
>   nulls every listener the dying entity owned — a listener can't leak past its
>   entity. Proven by [`tests/mod_c/scoped_mod.c`](tests/mod_c/scoped_mod.c).
> - **EV6** — re-entrant `emit` is depth-bounded (`@ev_depth` vs `EV_DEPTH_CAP`): a
>   listener may emit another event, but an event cycle traps as an early return
>   instead of hanging the frame. Dispatch order was already deterministic (array,
>   registration order). Proven by [`examples/recurse.ludic`](examples/recurse.ludic).
>
> - **EV7 (schema opening)** — a mod defines a brand-new component at runtime:
>   `ludic_register_prop(name, nfields)` mallocs flat `[MAX_ENT × nfields × i32]`
>   storage + a has-flag array and returns a prop id past the compile-time range;
>   `ludic_attach_dyn`/`ludic_detach_dyn` toggle it on an entity; `get`/`set`/`has`/
>   `prop_id` fall through to the dynamic registry for ids ≥ the compile-time count.
>   A mod adds entirely new data to entities by name, with per-entity isolation.
>   Proven by [`tests/mod_c/world_dyn.c`](tests/mod_c/world_dyn.c). (EV7's other
>   half — networking's local/remote event split — has no substrate in Ludic yet.)
>
> Still design: EV4 (the scripting-shim bridge — deferred to keep the suite
> interpreter-free) and EV7 networking. This is a companion to
> [LIFECYCLE-DESIGN.md](LIFECYCLE-DESIGN.md) and [SCENES-DESIGN.md](SCENES-DESIGN.md).
> Where those docs extend Ludic's *internal, compile-time* lifecycle, this one
> proposes the *external, runtime* layer that turns those same lifecycle moments
> into a public event surface — the foundation a game can hand to mods written in
> Ludic, JS/TS, Lua, or anything with a C ABI. It distills a survey of modding and
> event systems (§3) into a phased roadmap (EV0–EV7, §12–§13). §14 lists the open
> decisions.

---

## 1. Thesis

Ludic already has a lifecycle. `@OnSpawn(Enemy)`, `@OnDetach(Sprite)`, scene
`on enter`, `@OnDespawn(M, reason: r)` — every one is a **compile-time,
closed-world, zero-cost** hook that desugars to a direct call at a fixed site.
That is the right design for the *game author*, who is compiled together with the
game. It is exactly the wrong design for a *mod author*, who is not.

A modding event system is the mirror image of the lifecycle layer along three axes:

| | Lifecycle hooks (today) | Modding events (this doc) |
|---|---|---|
| World | **closed** — all handlers known at compile time | **open** — mods add listeners after compilation |
| Binding | **static** — a checked symbol, a direct call | **dynamic** — registered at load, dispatched at runtime |
| Language | **in-language** — Ludic, compiled together | **cross-language** — JS/TS/Lua/native over an ABI |

The instinct would be to build a second, parallel system. **The design that keeps
Ludic's discipline builds one system seen from two sides.** A lifecycle hook is a
*private* view of a moment; a public event is the *same moment* exposed across the
ABI. The author promotes a hook to an event; the compiler keeps its zero-cost
direct calls **and** emits one guarded `bus_emit` at the very same site. Nothing
exposed → nothing emitted → goldens stay byte-identical, exactly like `has_ecs`
and the `g_ondespawn` shutdown walk.

**The Luanti dividend.** The gap analysis (`LUANTI-ROADMAP.md`) found that ~57k of
Luanti's lines exist only to bridge C++ and Lua, and that its mod predicates are
*runtime strings* it must re-interpret every call. Ludic pays neither tax. The
reflection surface a mod needs — "what properties exist, what fields, at what
offsets" — is a **compile-time fact**; the compiler can *generate* the bridge
instead of a human hand-writing 57k lines, and it is always in sync with the game
it describes. A mod itself written in Ludic and compiled to a shared library binds
that surface with **zero marshalling**; a Lua mod binds the same surface through
its FFI. One ABI, every language.

---

## 2. What Ludic has today, and why it can't reach a mod

The lifecycle table from [LIFECYCLE-DESIGN.md §2](LIFECYCLE-DESIGN.md), every cell
filled, every cell a zero-cost desugar:

| Scope | Setup hook | Teardown hook | Fire site the compiler already owns |
|---|---|---|---|
| program | `@OnStart` | `@OnQuit` | boot / shutdown |
| entity | `@OnSpawn(M)` | `@OnDespawn(M, reason)` | `spawn` / `despawn` / shutdown-walk |
| property (structural) | `@OnAttach(P)` | `@OnDetach(P)` | `attach` / `detach` |
| property (toggle) | `@OnEnable(P)` | `@OnDisable(P)` | `enable` / `disable` |
| scene | `on enter` | `on exit` | `become` (and `push`/`pop`, SCENES E3) |

Two more fire sites are proposed but unbuilt, and both are natural events:
`@OnChange(P)` (LC2 — a value-change hook the compiler can emit right after every
write site) and `@OnStartMatch`/`@OnStopMatch` (LC3 — query-membership edges).

Every one of these is a place the compiler **already writes a call**. The problem
is purely that the call is *closed*: its targets are fixed at compile time, so a
mod loaded at runtime has no way to be one of them. The entire job of this doc is
to add, at each of these sites, an **opt-in second exit** to an open runtime list —
without touching the closed path's cost when no one opts in.

What a mod additionally needs, that no hook provides:

- a **stable name** for each event that survives recompilation (a mod compiled
  against v1 must still bind in v1.1);
- a way to **read and write game state** it did not compile against (the world
  table, §9);
- a way to **veto or rewrite** an action before it commits, not just observe it
  after (cancellable events, §8);
- a **loader** — mods enable, disable, and unload, and their listeners must vanish
  cleanly when they do (§10).

---

## 3. Research digest — the one idea to steal from each

The lifecycle doc surveyed engines for *internal* lifecycle. This surveys systems
for their *modding and event* surface — how untrusted, separately-authored code
plugs into a running game.

| System | The transferable idea |
|---|---|
| **Bukkit / Spigot** (Minecraft) | The canonical **cancellable event**: `Cancellable.setCancelled(true)` vetoes the action; `EventPriority` orders listeners; `@EventHandler(ignoreCancelled=true)` opts out of already-vetoed events. Events are *classes*, checked at bind time — not strings. |
| **Fabric** (Minecraft) | `Event<T>` backed by an **invoker over a plain array** of callbacks — deterministic registration order, no reflection at dispatch, phases for ordering. The closest existing design to what Ludic wants: fast, ordered, array-backed. |
| **Factorio** | **Deterministic** modded events for multiplayer lockstep: `script.on_event(defines.events.X)`, numeric event ids, `raise_event` for custom events, **filtered** subscriptions. Proof that a heavily-modded game can still replay bit-for-bit. |
| **Minetest / Luanti** | `register_on_*` + a string-keyed global (`minetest.*`) world API. The thing to beat: its predicates are runtime strings, and its C++↔Lua bridge is 57k hand-written lines. |
| **Godot** | **Signals as a first-class language construct**: `signal hurt(amount)`, `emit_signal`, `connect`. Decoupled, per-object, declared where the data lives. |
| **DOM events** | The **two-phase dispatch** vocabulary: capture → target → bubble, `preventDefault` (veto the default action) vs `stopPropagation` (halt the chain), and *passive* listeners that promise not to cancel (so dispatch can skip the veto check). |
| **Node `EventEmitter`** | The dead-simple baseline `on`/`emit` — and its footguns: untyped string names (a typo silently never fires) and **listener leaks** (a listener on a dead object keeps it alive). Design both out. |
| **flecs / Bevy observers** | **ECS-native reactive events**: an event *targeted at an entity*, observers that fire on component add/set/remove, deferred so mutation-during-iteration is safe. The correct shape for an ECS. |
| **Blender `bpy.app.handlers`** | Named application-level handler lists a script appends to, with a `persistent` flag controlling survival across file loads — the "engine lifecycle exposed to scripts" model, and the lesson that *survival scope* must be explicit. |
| **Roblox** | `BindableEvent` (local) vs `RemoteEvent` (across the network boundary) — the same event abstraction, one flag deciding whether it crosses a trust/latency boundary. Relevant the day Ludic has networking. |

Five **footguns** the survey warns against, to design *out* of Ludic from the start:

1. **Untyped string events.** Node/DOM let any string be an event; a typo never
   fires and never errors. Ludic's core events are compiler-checked symbols; only
   genuinely-dynamic *mod-defined* events use interned strings, and those must be
   *registered* before use (§6), so an unknown name is a load-time error, not a
   silent no-op.
2. **Listener leaks.** A listener bound to an entity that despawns must die with
   it. Ludic ties listener lifetime to the scope it names (§10) — entity-scoped
   listeners are swept by the same despawn walk that already runs.
3. **Nondeterministic dispatch order.** Hash-map iteration over listeners breaks
   replay and save-load. Ludic dispatches in a **defined order** (priority, then
   registration order) so a modded game stays deterministic — a hard constraint,
   not a nicety, given Ludic's deterministic-by-design rng and byte-identical
   goldens.
4. **Re-entrancy / mutate-during-dispatch.** A listener that emits another event,
   or despawns the entity mid-dispatch, is the flecs "command during iteration"
   hazard. Ludic defers structural changes made inside dispatch to the next sync
   point (ties to LIFECYCLE LC5), and bounds re-entrant emit depth.
5. **Cancellation ambiguity.** If two listeners disagree, who wins? Ludic's rule
   (§8): **one veto wins and is sticky**; later listeners see the cancelled state
   and, unless they opted into `ignoreCancelled`, are skipped.

---

## 4. The two layers, named

To talk about this precisely the doc fixes two words:

- A **hook** is the existing compile-time construct: an `@`-annotation or scene
  clause that desugars to a direct call. Closed, zero-cost, author-only. Unchanged.
- An **event** is the new runtime construct: a named, ABI-visible moment that any
  registered listener — in any language — may observe or (if cancellable) veto.

An event is *fed by* a hook site. Promoting is additive: the hook keeps firing its
compile-time listeners as direct calls; the event is an extra, guarded emission at
the same site. **Author code never pays for the bus it doesn't expose, and mod
code never sees a hook it wasn't given.**

---

## 5. EV0 — the event bus core

The minimum viable layer: declare an event, emit it, and have both in-language and
foreign listeners receive it — with zero cost when a program declares no events.

**Declaring a custom event.** A first-class declaration, mirroring `property`:

```ludic
# doc-check: skip — sketch
event PlayerHurt { entity: int, amount: int }     # a payload is a flat POD record
event WaveCleared { }                             # payloads may be empty
```

**Emitting.** A statement, mirroring `spawn`/`emit_signal`:

```ludic
# doc-check: skip — sketch
emit PlayerHurt(entity: e, amount: dmg)
```

**Listening in-language** (author code, or a *native* Ludic mod) reuses the
annotation channel, mirroring `@OnSpawn`:

```ludic
# doc-check: skip — sketch
@On(PlayerHurt) handler FlashRed { hud_flash(0xFF0000) }
```

**Listening across the ABI** (a JS/TS/Lua mod) goes through the stable C ABI:

```c
/* the entire foreign-facing event ABI — four functions */
uint32_t ludic_event_id(const char *name);                 /* intern → stable id  */
uint32_t ludic_on(uint32_t event, int32_t prio, ludic_cb cb, void *ctx);
void     ludic_off(uint32_t token);
void     ludic_emit(uint32_t event, void *payload);         /* mod-raised events   */
/* cb: void (*)(void *ctx, void *payload) — payload is the flat POD record */
```

**Lowering — the discipline holds.** An exposed event's emit site becomes:

```
;  emit PlayerHurt(entity: e, amount: dmg)   lowers to:
   1. build the payload record on the stack   (POD, no heap)
   2. call each compile-time @On(PlayerHurt) handler directly   ; zero-cost path
   3. if g_listeners[EV_PlayerHurt].count != 0:                 ; one branch
        loop the runtime listener list, calling each cb(ctx, &payload)
```

- **A program that declares no `event` emits none of this.** A `has_events` flag
  (exactly like `has_ecs`, `g_ondespawn`) gates the whole subsystem; a game with no
  public events is byte-for-byte identical to today. This is the non-negotiable
  invariant every phase preserves.
- The compile-time `@On` handlers are direct calls appended to the site — a native
  listener costs the same as a lifecycle hook. Only *foreign* listeners walk the
  runtime list, and an event with zero foreign listeners is a single count check.
- The runtime list is a **compiler-owned, fixed-capacity buffer** per event
  (like the scene stack in SCENES E3) — not heap, not a hash map. `ludic_on` is an
  index bump; `ludic_off` tombstones a slot. Deterministic order falls out of the
  array (§7 of SCENES' "no dispatch tables" spirit, honestly bent — see §11).

---

## 6. EV1 — promoting hooks to events (the taxonomy)

Custom `event`s (EV0) cover author-raised signals. The **lifecycle** events —
spawn, despawn, attach, scene enter — should not require the author to hand-write
an `emit` in every `@OnSpawn`. Instead, a hook is promoted with one annotation:

```ludic
# doc-check: skip — sketch
@Public @OnSpawn(Enemy) handler Init { Health.hp = Health.max }
# now firing this hook ALSO emits the public event  model.Enemy.spawn
```

`@Public` on a lifecycle hook tells the compiler to add the guarded `bus_emit` at
that hook's existing site, with a **generated payload** built from what the hook
already binds (the entity id, the model/property fields, the `EndReason`). The
result is a uniform event namespace across the whole architecture — precisely the
"events for properties, models, scenes, layers, game" the request asks for:

| Scope | Public event name | Payload | Fed by |
|---|---|---|---|
| program | `program.start` / `program.quit` | `{}` | `@OnStart` / `@OnQuit` |
| phase | `phase.<Name>.pre` / `.post` | `{ frame }` | the phase scheduler |
| model | `model.<M>.spawn` / `.despawn` | `{ entity, reason? }` | `@OnSpawn` / `@OnDespawn` |
| property (structural) | `prop.<P>.attach` / `.detach` | `{ entity, <fields> }` | `@OnAttach` / `@OnDetach` |
| property (toggle) | `prop.<P>.enable` / `.disable` | `{ entity }` | `@OnEnable` / `@OnDisable` |
| property (value) | `prop.<P>.change` | `{ entity, field, old, new }` | `@OnChange` (LC2) |
| query (membership) | `query.<Q>.enter` / `.exit` | `{ entity }` | `@OnStartMatch`/`@OnStopMatch` (LC3) |
| scene | `scene.<S>.enter` / `.exit` / `.push` / `.pop` | `{}` | `on enter`/`on exit`, `push`/`pop` |
| layer | `layer.<L>.show` / `.hide` | `{}` | layer toggle (SCENES E2) |

- **Names are stable strings, ids are fast integers.** `model.Enemy.spawn` is the
  public contract; the compiler assigns it a numeric id and registers the mapping
  in a generated init. A mod compiled against the string binds by id at load — so
  reordering declarations doesn't break a shipped mod (unlike raw
  decl-order numbering, which is fine for the *closed* scene machine but wrong for
  an *open* ABI).
- **Opt-in per hook, not global.** Only `@Public` hooks emit. A game exposes the
  slice of its lifecycle it wants moddable and pays for nothing else.
- **`@Public` composes with everything.** A `@Public @OnDespawn(Enemy, reason: r)`
  emits `model.Enemy.despawn` with the `EndReason` in the payload — mods can tell a
  scene-exit death from a real one, the LC1 dividend extended to the mod boundary.

---

## 7. EV2 — the world table (reflection for mods)

The user's "game table": the stable, versioned surface a mod uses to **read and
write game state it never compiled against**. Minetest's `minetest.*`, Factorio's
`game.*`, but *generated* rather than hand-written.

Because Ludic's data is packed POD in `@S_` arrays whose layout the compiler knows
exactly, the compiler can emit a **schema** (property id → field ids → offset +
type) plus a small accessor ABI over it:

```c
/* the world table — reflection + mutation over the live ECS */
uint32_t ludic_prop_id(const char *name);                 /* "Health" → id      */
uint32_t ludic_field_id(uint32_t prop, const char *name); /* ("Health","hp")→id */
int64_t  ludic_get(int32_t entity, uint32_t prop, uint32_t field);
void     ludic_set(int32_t entity, uint32_t prop, uint32_t field, int64_t v);
bool     ludic_has(int32_t entity, uint32_t prop);
int32_t  ludic_spawn(uint32_t model);                     /* → entity           */
void     ludic_despawn(int32_t entity);
uint32_t ludic_query(uint32_t *props, int n);             /* → iterator handle  */
int32_t  ludic_query_next(uint32_t iter);                 /* → entity or -1     */
```

- **Generated from the compile-time schema, so it never drifts.** Add a field to
  `Health`, recompile, and the schema updates; a mod that asked for
  `("Health","hp")` still resolves. This is the entire Luanti bridge, minus the
  hand-written 57k lines and minus the runtime-string re-interpretation.
- **`ludic_set` respects the semantic layer.** Writing a field routes through the
  same path a native write does, so `@OnChange`/`prop.change` (LC2) fires for a
  mod's write exactly as for the author's — mods can't silently corrupt invariants
  that hooks are meant to maintain.
- **Mods can register content, within limits.** A mod may `ludic_on` existing
  events and `ludic_emit` custom ones; **defining a new `property`/`model` is a
  harder call** (it needs storage the closed `@S_` arrays didn't reserve). The
  pragmatic first cut: models and properties are closed (author-defined), and mods
  extend *behavior* (listeners, custom events, world reads/writes) but not the
  *schema*. Opening the schema to mods is EV-late (§13, open decision 4).

---

## 8. EV3 — cancellable and mutable events

Observation alone (Node, Blender) can't stop a mod from turning damage off — the
modding headline is that a listener runs **before** the action and can veto or
rewrite it. Events split into two kinds, distinguished at declaration:

- **notifications** — fired *after* the fact, observe-only, can't change anything.
  Cheap, un-ordered-safe, the default. `model.Enemy.spawn` after the spawn.
- **decisions** — fired *before* the action, listeners may **cancel** it or
  **mutate** the payload; the caller reads the verdict and branches. Marked
  `cancellable` (Bukkit `Cancellable`, DOM `preventDefault`).

```ludic
# doc-check: skip — sketch
event cancellable BeforeHurt { entity: int, amount: int }   # a decision event

# an author (or native mod) listener that halves fire damage and vetoes lethal hits:
@On(BeforeHurt, prio: 100) handler Armor {
  BeforeHurt.amount = BeforeHurt.amount / 2         # mutate the payload…
  if BeforeHurt.amount >= Health.hp { cancel }      # …or veto the whole action
}

# the fire site consults the verdict:
let dmg = emit? BeforeHurt(entity: e, amount: raw)  # emit? returns the (maybe-mutated) payload
if !cancelled(dmg) { Health.hp -= dmg.amount }
```

Rules, chosen from the survey to remove the ambiguity footgun:

- **Priority, then registration order.** `prio:` (default 0) orders listeners
  high-to-low; ties break by registration order. Deterministic, replay-safe.
- **One veto wins and is sticky.** Once a listener calls `cancel`, the event is
  cancelled for the rest of the chain; later listeners still run (so they can react
  to the cancellation) unless declared `ignoreCancelled`, which skips them.
- **`stopPropagation` is separate from `cancel`.** DOM's distinction: `cancel`
  vetoes the *action*, `halt` stops the *chain*. Keep both; they answer different
  questions.
- **Passive listeners.** A listener declared `@On(E, passive)` promises not to
  cancel or mutate — the dispatcher can call it after the decision is settled, and
  a foreign listener that lies is a load-time capability error (§10), not a
  mid-frame surprise.
- **Mutation is bounded to the payload.** A decision listener rewrites *the payload
  record*, never arbitrary world state, so the caller's branch is the only place
  the change takes effect — no spooky action at a distance.

---

## 9. EV4 — the mod ABI & the language-agnostic bridge

"Agnostic JS/TS/Lua or their own" resolves cleanly once EV0–EV3 exist, because the
contract is **the C ABI, not any one language.** Two mod tiers bind the *same* four
event functions (§5) and the same world table (§7):

**Tier 1 — native mods (Ludic → shared library).** A mod is a `.ludic` file
compiled to a `.dylib`/`.so`/`.wasm` with `extern fn` bindings
([LANGUAGE.md §Functions & FFI](LANGUAGE.md)). It binds the ABI with **zero
marshalling** — payloads are the same POD records the host builds — and its `@On`
handlers can even be *inlined by the same compiler* if the mod is compiled with the
game. This is the tier Luanti can't offer and the one that makes Ludic's modding
fast: a compiled predicate where Luanti has a re-interpreted string.

**Tier 2 — scripted mods (JS/TS/Lua/…).** The game embeds a scripting runtime
(QuickJS, Lua, Wasm) and registers a thin per-language shim that:

1. calls `ludic_event_id("model.Enemy.spawn")` once at load to resolve the id;
2. calls `ludic_on(id, prio, trampoline, script_fn)` where `trampoline` is a
   single C function that marshals the POD payload into the script runtime's values
   and invokes `script_fn`;
3. exposes the world table (§7) as idiomatic bindings (`world.get(e, "Health",
   "hp")` in Lua, `world.get(e, "Health", "hp")` in TS).

The host writes **one trampoline per language**, not one per event — the schema
(§7) drives the marshalling generically. A Lua mod and a TS mod differ only in
their shim; the game core is identical. This is the structural win the Luanti gap
analysis pointed at: the bridge cost is *O(languages)*, not *O(events × languages)*
hand-written, because the schema is generated.

```
                         ┌─────────────── the stable C ABI ───────────────┐
   Ludic game core ──────┤ ludic_on / ludic_emit / ludic_get / ludic_set  ├────── generated schema
   (emits at hook sites) └────────────────────┬───────────────────────────┘        (prop→field→offset)
                                               │
              ┌────────────────────────────────┼────────────────────────────────┐
              │                                 │                                 │
      Tier 1: native mod              Tier 2: Lua shim                   Tier 2: JS/TS shim
      (.dylib, zero marshalling)      (one trampoline)                  (one trampoline)
```

---

## 10. EV5 — mod lifecycle, scoping & leak-proofing

A mod is not eternal; it loads, enables, disables, and unloads, and its listeners
must vanish with it — the Node listener-leak footgun, solved structurally.

- **Every registration returns a token** (`ludic_on → token`), and a mod's tokens
  are tracked under its **mod handle**. Unloading a mod calls `ludic_off` on all of
  them at once — a mod can't leak a listener past its own life.
- **Listeners may be scoped to a game object.** `ludic_on_entity(entity, …)` binds
  a listener that the **existing despawn walk** sweeps when that entity dies — the
  same `@L_despawn_all` loop LC1 already emits, extended to drop entity-scoped
  listeners. An entity-scoped listener on a dead entity is impossible by
  construction, not by discipline.
- **Scene-scoped listeners** ride SCENES E1: a listener registered while a scene is
  active is dropped by that scene's synthesized `on exit`, alongside its owned
  entities. Overlay push/pop (SCENES E3) scopes listeners to the overlay's life.
- **Survival is explicit** (Blender's `persistent` lesson): a listener is
  program-, mod-, scene-, or entity-scoped, chosen at registration. There is no
  implicit "lives forever" — the default is the narrowest scope that makes sense
  (mod), and wider survival is opt-in and visible.
- **Capabilities gate what a scripted mod may touch** (§14, open decision 6). A mod
  manifest declares the events and world-table properties it needs; the loader
  grants ids only for those. A mod that never asked for `Health` cannot `ludic_set`
  it — an untrusted-code boundary the closed lifecycle layer never needed but an
  open mod ABI must have.

---

## 11. EV6 — determinism, re-entrancy & the one honest compromise

Ludic is deterministic by design — deterministic rng, byte-identical PPM goldens,
save-load of the whole World. A modding layer is the classic place that determinism
goes to die (hash-ordered listeners, mods reading wall-clock, emit storms). Holding
the line is a **feature**, and the same one that makes Factorio's modded multiplayer
lockstep-correct.

- **Dispatch order is total and defined** — priority, then registration order, over
  an *array*, never a hash map. Two mods loaded in the same order dispatch in the
  same order on every machine.
- **Emit is synchronous by default, deferred on demand.** `emit E` runs listeners
  now (push-at-the-site, Ludic's natural style — the LIFECYCLE footgun-1 fix).
  Structural changes a listener requests (spawn/despawn/attach) **defer to the next
  sync point** (LIFECYCLE LC5's `defer`), so mutate-during-dispatch is safe and
  batched. Re-entrant `emit` inside a listener is allowed but **depth-bounded** (a
  compile-time cap, trap on overflow) so an event cycle can't hang a frame.
- **Foreign listeners are the determinism boundary.** A native (Tier 1) listener is
  as deterministic as any handler. A scripted (Tier 2) listener is only as
  deterministic as the script — so the sandbox (§10) can **deny nondeterministic
  capabilities** (wall-clock, unseeded rng, filesystem) to a mod that must stay in
  a deterministic session (multiplayer, replays). Single-player mods can opt out.

**The one honest compromise.** SCENES-DESIGN's principle is "no dispatch tables —
the active-scene path is a register read and a static branch." The runtime
listener list *is* a dispatch table, walked at runtime. This doc owns that: it is
the **deliberate, opt-in exception**, justified because open-world extension is the
entire point of a mod ABI and cannot be resolved at compile time by definition.
The mitigations keep it honest — it is (a) gated behind `has_events` so unused it
costs nothing, (b) an array not a hash map so it stays deterministic, (c) fed by
compile-time-checked names so the *closed* side stays typed, and (d) reached only
after the zero-cost direct calls to compile-time `@On` handlers. Ludic pays for a
dispatch table exactly when, and only when, a game chooses to be moddable.

---

## 12. Lowering summary

Everything above reduces to constructs Ludic already has or honestly-scoped
additions to them:

| Construct | Lowers to |
|---|---|
| `event E { … }` | a generated payload record type + a reserved event id + a `has_events` bump |
| `emit E(…)` | build POD payload · direct-call each `@On(E)` handler · `if count: walk runtime list` |
| `@On(E)` handler | a compile-time listener: a direct call appended to `E`'s emit site (zero-cost) |
| `@Public @OnX(…)` | the existing hook's site, plus a guarded `bus_emit` of a payload built from the hook's bindings |
| public event name | a stable string interned to an integer id in a generated registry init |
| the runtime listener list | a compiler-owned fixed-capacity array per event; `ludic_on` = index bump, `ludic_off` = tombstone |
| the world table | a generated schema (prop→field→offset/type) + accessor ABI over the live `@S_` arrays |
| `cancellable` / `cancel` | a verdict field on the payload; the emit site branches on it |
| entity/scene-scoped listener | dropped by the existing despawn walk / synthesized `on exit` (LC1 / SCENES E1) |
| deferred structural change in a listener | LIFECYCLE LC5's `defer` queue, flushed at the sync point |

No heap for native payloads, no hash map, no per-event hand-written bridge. The
active game path is unchanged unless it opts in; the opt-in cost is one branch per
exposed event plus the listeners a mod actually registers.

---

## 13. Design principles distilled

1. **One system, two sides.** A public event is a lifecycle hook seen from across
   the ABI. Don't build a parallel event runtime; promote the sites you already
   have.
2. **Opt-in or invisible.** No `event`, no `@Public` → byte-identical goldens.
   `has_events` gates the world the way `has_ecs` gates the ECS.
3. **Closed stays typed; only the open edge is dynamic.** Core events are
   compiler-checked symbols; string names exist only at the genuinely-runtime mod
   boundary, and even there must be registered (no silent typos).
4. **Generated bridge, never hand-written.** The world table and payload marshalling
   come from the compile-time schema, so they never drift and cost O(languages),
   not O(events × languages). This is the Luanti dividend — spend it.
5. **Deterministic dispatch is a feature.** Array order, not hash order; deny
   nondeterministic capabilities to mods in deterministic sessions. Modded replay
   and modded multiplayer depend on it.
6. **Lifetime follows scope, explicitly.** Every listener names its scope
   (program/mod/scene/entity); the existing teardown walks sweep it. No implicit
   immortality, no leaks.
7. **One ABI, every language.** The C ABI is the contract. Native mods bind it with
   zero marshalling; scripted mods bind it through one trampoline per language.
   Ludic never blesses a single scripting language.
8. **Only the semantic layer, still.** Mods observe and decide; they do not get
   ctor/dtor/move hooks Ludic doesn't have. POD in, POD out.

---

## 14. Suggested implementation order

Each phase is independently shippable and testable, matching how the repo phases
work (and how LIFECYCLE/SCENES sequence).

- **EV0 — the bus core.** ✅ *Compile-time half shipped.* `event` / `emit` / `@On`
  with the `g_events`-gated zero-cost lowering: an event compiles to a `@ev_<E>`
  function whose body is its listeners in declaration order (payload bound by
  name as params), and `emit E(…)` is a direct call. Verified byte-identical for
  event-free programs, self-hosted to the C-free fixpoint. Still open in EV0: the
  foreign C ABI (`ludic_on`/`ludic_emit`) and its runtime listener array, so a
  mod in another language can join the same dispatch. Implementation notes: AST
  `N_EVENT`/`S_EMIT`; `parse_event` + `@On` annotation + `emit` statement (guarded
  by an identifier-lookahead so a bare `emit(...)` call still parses); registries
  `g_events`/`g_onlisten` (emit_core); `emit_event_fns` (emit_game); `emit_emit`
  (emit_stmt). [`examples/events.ludic`](examples/events.ludic) is a `bin/x test` check.
- **EV1 — `@Public` hook promotion.** ✅ *All scopes shipped.* `@Public` on a
  lifecycle hook fires a public event at that hook's site (payload: entity, plus
  `EndReason` for despawn); `find_event(name)` doubles as the "is this hook
  public?" gate. Covered: program (`@OnStart`/`@OnQuit` → `program_start`/`_quit`),
  models (`@OnSpawn`/`@OnDespawn`), properties
  (`@OnAttach`/`@OnDetach`/`@OnEnable`/`@OnDisable` → `prop_<P>_…`). Scenes and
  layers use a `public` block modifier instead of an annotation:
  `scene_<S>_enter`/`_exit` at the synthesized scene functions, and
  `layer_<L>_show`/`_hide` at the layer-toggle site. Building layer events also
  delivered **SCENES E2 layer toggle**: `enable/disable layer L` flips an `@LE_<L>`
  flag that gates that layer's handlers, emitted only for toggled layers so
  untouched scene programs stay byte-identical.
- **EV2 / EV2b — the world table.** ✅ *Read/write/scan/identify/create shipped.*
  The generated reflection ABI (§7), dispatching a runtime prop/model id to the
  right `@S_`/`@H_`/`@L_kind` storage: read/write (`prop_id`/`field_id`/`get`/`set`/
  `has`), scan/identify (`entity_count`/`kind`/`model_id`), and create
  (`spawn(model_id)`, which reuses the compiler's own spawn lowering — defaults,
  `@OnSpawn`, and the spawn event). `get`/`set` address each field by its real
  struct offset (constant struct GEP), correct for `int`/`fixed`/`byte`/`ptr`
  fields and mixed layouts alike. Emitted only for an ECS program that declares
  events (gated on `has_ecs() && g_events`), so event-free games are byte-identical.
  A `ludic_query_next(prop, from)` cursor iterates live entities that have a
  property. The world table is complete: read, write, scan, identify, create,
  iterate.
- **EV3 — cancellable events.** ✅ *Shipped.* `event cancellable E`, the `cancel`
  verb, and `emit E(…)` as an expression yielding the veto flag; the flag is a
  trailing field of `%Ev_<E>`, so a foreign listener vetoes by setting it. Priority
  ordering and `ignoreCancelled`/`halt` (§8) remain open. The modding headline —
  observation becomes control.
- **EV4 — the scripting bridge.** One reference shim (Lua *or* QuickJS) over the
  ABI, proving the O(languages) claim end to end.
- **EV5 — mod lifecycle & scoping.** ✅ *Shipped.* A parallel owner array `@evO_<E>`
  (-1 = program-scoped, ≥0 = owning entity); `ludic_on_<E>` and
  `ludic_on_entity_<E>` register with the right owner; `ludic_off_<E>(token)`
  tombstones a slot to null and dispatch skips null slots; `ludic_sweep_entity`,
  called from `emit_despawn` when the program has events, nulls every listener a
  despawning entity owned. Scene-scoped listeners (drop on `on exit`) remain the
  same shape applied at the scene teardown — a follow-on.
- **EV6 — determinism & re-entrancy.** ✅ *Depth bound shipped.* `@ev_depth`
  increments on each `@ev_<E>` entry and decrements on exit; past `EV_DEPTH_CAP`
  (32) a dispatch returns immediately (a cancellable event returns "not
  cancelled"), so an event cycle can't hang. Dispatch order was already
  deterministic (array, registration order). Still design: deferred structural
  changes at a sync point (LC5) and capability gating for deterministic sessions.
- **EV7 — schema-opening & networking.** ✅ *Schema-opening shipped.* A mod defines
  a new component at runtime: `ludic_register_prop(name, nfields)` allocates flat
  `[MAX_ENT × nfields × i32]` storage + a has-flag array (capacity 32 dynamic
  components) and returns a prop id past the compile-time range;
  `ludic_attach_dyn`/`ludic_detach_dyn` toggle presence; `get`/`set`/`has`/`prop_id`
  fall through to the dynamic registry for a prop id ≥ the compile-time component
  count. Per-entity storage is isolated (`world_dyn.c`). This is the first genuinely
  *dynamic* `@S_` storage — a deliberate departure from the closed dense arrays, so
  it lives entirely behind the ABI (the game's own components stay static and
  byte-identical). Dynamic components use integer fields addressed by index (no
  field-name schema). *Still design:* the local/remote event split (Roblox's
  lesson) waits on Ludic having a networking substrate.

EV0–EV1 deliver "the whole architecture emits public events." EV2–EV3 are where a
mod becomes able to *change the game*. EV4 proves the language-agnostic claim.
EV5–EV7 are hardening and reach.

---

## 15. Open decisions

1. **`emit` verb & payload identity.** Is `emit E(…)` the only spelling, or does a
   `signal`-style per-property declaration (Godot) read better for the common case?
   Are payloads always fresh POD records, or can an emit borrow an existing property
   in place (cheaper, but aliases live storage)?
2. **`@Public` granularity.** Per-hook (proposed), per-model (`@Public model
   Enemy`), or a program-level "expose all lifecycle" switch for prototyping? Does
   `@Public` belong on the hook or on the `model`/`property`/`scene` it concerns?
3. **Name scheme stability.** Dotted strings (`model.Enemy.spawn`) interned to ids —
   confirmed. Open: are ids stable across recompiles of the *same* source (needed
   for save-compatibility of a listener table), and how does a renamed model
   migrate a shipped mod?
4. **Schema opening (EV2/EV7).** Do mods stay behavior-only (listeners + custom
   events + world reads/writes over author-defined schema), or can a mod define new
   `property`/`model`? The latter needs dynamic `@S_` storage — a real departure
   from the closed dense arrays (`LUDIC_MAX_ENT 1024`). Probably EV7.
5. **Cancellation surface.** Keep `cancel` (veto action) and `halt` (stop chain)
   distinct (DOM), or collapse to one? Is `ignoreCancelled` per-listener or a
   priority-band convention?
6. **Sandbox model.** Capability manifest per mod (proposed) — at what granularity
   (per event? per property? per world-table verb)? What is denied by default in a
   deterministic session, and who declares a session deterministic?
7. **Re-entrancy bound.** Compile-time constant emit-depth cap (trap on overflow),
   or a runtime budget? What is the default depth, and is an event cycle a warning
   or an error?
8. **Scripting runtime, in or out of scope.** Does Ludic *ship* an embedded runtime
   (QuickJS/Lua) as a blessed default, or only the ABI and reference shims, leaving
   the runtime to the game? (Bias: ship the ABI + one reference shim; bless no
   language.)

---

*Companion to [LIFECYCLE-DESIGN.md](LIFECYCLE-DESIGN.md) (the hook sites this layer
promotes) and [SCENES-DESIGN.md](SCENES-DESIGN.md) (scene/layer/overlay events and
scoped-listener teardown). Grounded in the Luanti gap analysis (`LUANTI-ROADMAP.md`):
the generated bridge is how Ludic avoids the 57k-line C++↔Lua tax. Supersedes
nothing until the compiler work in §12 lands.*
