# Lifecycle events, expanded — a design doc

> **Status: LC0–LC1 shipped; LC2–LC6 are design.** The structural attach/detach
> pair and `@OnDetach` (§4, LC0), and reason-carrying `@OnDespawn` (§5, LC1), are
> implemented and tested ([`examples/detach.ludic`](examples/detach.ludic),
> [`examples/reason.ludic`](examples/reason.ludic), `bin/x test` checks). The
> extensions LC2–LC6 are research-informed proposals, not built. This document
> distills a survey of lifecycle models across seven systems (§3) into a roadmap
> for Ludic. §13 lists the open decisions.

---

## 1. Thesis

A game/ECS usually models lifetime as **create → destroy on a timeline**. A survey
of how other systems handle it — Unity (MonoBehaviour + DOTS), Unreal, Bevy,
flecs, EnTT, Godot, and non-game paradigms (actor model, declarative UI, RAII) —
shows that mature lifecycle designs model something richer than birth and death:

- **a reaction to a *reason*** — teardown that knows *why* it is ending (Unreal
  `EndPlay(reason)`, Erlang `terminate(Reason)`, Akka `preRestart(reason, msg)`);
- **paired setup/teardown *keyed on dependencies*** — an update is teardown-then-
  setup on a value change (React `useEffect`, Compose `DisposableEffect`);
- **a deterministic consequence of *scope / ownership*** — guaranteed, ordered,
  single-shot teardown (C++/Rust RAII, DI scoped lifetimes);
- **an edge on *query membership*** — fire when data starts/stops matching a
  composite condition (DOTS `OnStartRunning`, flecs `Monitor`).

Ludic's model is a good base: lifecycle hooks are `@`-annotations on handlers that
**desugar to ordinary code**, firing at fixed timeline moments, keeping the data
plain. This doc extends that base along the four axes above **without breaking the
desugars-to-code discipline** — every proposal lowers to plain branches and calls,
no hidden runtime.

**One structural advantage worth stating up front.** flecs and EnTT each carry
*two* lifecycle layers: a **memory** layer (ctor/dtor/move/copy — because C++
objects must be constructed and relocated as archetypes repack) and a **semantic**
layer (on_add/on_set/on_remove). Ludic's components are POD in packed `@S_`
arrays; there is nothing to construct, destruct, or move-relocate. **Ludic needs
only the semantic layer** — half the machinery, none of the "component isn't
movable" footguns. Keep it that way.

---

## 2. What Ludic has today

Seven hooks, each an annotation that desugars to a handler body at a timeline
moment ([LANGUAGE.md §Annotations](LANGUAGE.md)):

```
boot ─ @OnStart ─▶ spawn ─ @OnAttach(P), @OnSpawn(M) ─▶ … ─ @OnDetach(P)/@OnDespawn(M) ─▶ quit ─ @OnQuit
```

The lifecycle reads cleanest as a table of **paired setup/teardown** across five
scopes. Every cell is now filled — LC0 closed the one hole (`@OnDetach`):

| Scope | Setup | Teardown | Driven by |
|---|---|---|---|
| program | `@OnStart` | `@OnQuit` | boot / quit |
| entity | `@OnSpawn(M)` | `@OnDespawn(M)` | `spawn` / `despawn` |
| property (structural) | `@OnAttach(P)` | `@OnDetach(P)` ✅ | `attach` / `detach` |
| property (toggle) | `@OnEnable(P)` | `@OnDisable(P)` | `enable` / `disable` |
| scene | `on enter` | `on exit` | `become` |

Two things this table already gets right, which the survey flags as the frequent
mistakes to avoid:

- **The toggle pair is distinct from the structural pair.** Unity's clearest
  lesson is separating the *repeatable* enable/disable cycle (pooling, pausing,
  data kept) from the *once* create/destroy (data gone). Ludic has both, as
  distinct verbs: `disable` pauses and keeps data; `detach` structurally removes
  (a later `attach` re-seeds). This is exactly DOTS enableable-components vs
  structural add/remove, and Bevy `disabled` vs `Remove`.
- **Hooks are typed annotations, not magic-named methods.** MonoBehaviour matches
  `Awake`/`Update` by *string name* via reflection — a typo silently never runs.
  Ludic's `@OnSpawn(Enemy)` is a checked reference; a wrong name is a compile
  error. Preserve this.

What's missing is everything past "what happened": **why** it happened, **which
values changed**, **when composite conditions begin/end to hold**, and
**dependency-keyed** setup/teardown. That is the roadmap.

---

## 3. Research digest — the one idea to steal from each

| System | The transferable idea |
|---|---|
| **Unity MonoBehaviour** | Two-phase init with a global barrier (all `Awake` before any `Start`); repeatable enable-pair vs once create-pair. |
| **Unity DOTS** | *Data-driven activation*: `RequireForUpdate` + `OnStartRunning`/`OnStopRunning` — a system edge-triggers when its query starts/stops matching. Enableable components = cheap "logically off." |
| **Unreal** | *Reason-carrying teardown*: `EndPlay(EEndPlayReason)` — one teardown, branch on `Destroyed`/`LevelTransition`/`Quit`/…; forces enumerating every death path (no silent deaths). Provenance-tagged construction. |
| **Bevy** | Full structural event set Add/Insert/**Replace**/Remove/Despawn with strict order; **Replace exposes the old value before drop**. Hooks (type-level, singular, invariant) vs observers (plural, reactive). Declarative `before`/`after`/`chain` ordering. State `OnEnter`/`OnExit`/`OnTransition`. |
| **flecs** | `Monitor` observers fire on *composite query membership* start/stop. Events fire on **real transitions**, not every API call. Deferred-by-default with explicit sync points. |
| **EnTT** | `patch` as the *explicit mutation channel* that fires `on_update` (solves "raw writes are invisible"). Opt-in signals — zero cost when unused. |
| **Godot** | Tree membership *is* the lifecycle driver; enter top-down, **`_ready` bottom-up** (dependencies initialized first); `queue_free()` deferred safe-delete; `process_mode` pause inherited down the tree. |
| **Actor model (OTP/Akka)** | Lifecycle driven by *failure + supervision*: reason-carrying `terminate`, **restart as a state distinct from create/destroy** (stable identity, reset transient state), supervision trees, `code_change` = live state migration. |
| **Declarative UI (React/SwiftUI/Compose)** | *Paired setup/teardown keyed on a dependency list* — cleanup co-located with setup so it can't leak; an update **is** keyed teardown-then-setup; lifetime follows *identity*. |
| **RAII / Rust `Drop` / DI scopes** | *Scope = lifetime*: deterministic, reverse-construction-order, single-shot, no-resurrection teardown, guaranteed even on early exit; lifetime-mismatch checking (no long-lived thing holding a short-lived handle). |

Two recurring **footguns** the whole survey warns against, to design *out* of Ludic:

1. **Silent order-dependent reactivity.** Bevy's removal buffers are cleared at
   end-of-frame, so a detector that runs before the mutator *misses removals
   entirely*. If Ludic adds change/removal reactivity, make it either push-based
   (fire at the mutation site — Ludic's natural style) or loudly order-checked.
2. **Invisible in-place writes.** flecs `on_set` and EnTT `on_update` don't fire
   on a raw pointer write — you must call `modified()`/`patch`. Ludic can dodge
   this entirely (see LC2): the compiler *sees* every write site.

---

## 4. LC0 — structural attach/detach + `@OnDetach` ✅ *shipped*

The one missing cell in §2's table. `attach P on e { overrides }` adds a property
to a **live** entity (seeding fields, firing `@OnAttach`); `detach P on e` removes
it (firing `@OnDetach`, which reads the outgoing value, before the has-flag
clears). Both fire only on a **real transition** (flecs/Bevy idempotent-add
semantics): re-attaching a present property or detaching an absent one is a no-op.

Lowering: `attach` guards on the has-flag and, when absent, reuses the existing
`emit_init_component` (seed + `@OnAttach`); `detach` guards on presence, clears the
flag, and fires `@OnDetach` with the property bound by name — the same binding the
`@OnDisable` path already uses. No new runtime; POD data stays in `@S_` storage.
See [`examples/detach.ludic`](examples/detach.ludic).

---

## 5. LC1 — reason-carrying teardown ✅ *shipped (`@OnDespawn`)*

The highest-conviction idea in the survey: it appears independently in Unreal
(`EndPlay`), Erlang (`terminate`), and Akka (`preRestart`), and Bevy has an open
issue asking for it. **Teardown should know *why*.** A destructor frequently needs
to branch — save on `Quit` but not on a scene swap, skip network cleanup when the
whole program is exiting.

`@OnDespawn` gains an optional bound **reason**:

```ludic
# doc-check: skip
# EndReason { Despawned, SceneExit, Quit } — the compiler owns this enum

@OnDespawn(Enemy, reason: r) handler Clean {
  match r {
    EndReason.Quit => {}                 # app closing — don't bother dropping loot
    _              => drop_loot(Health.hp)
  }
}
```

**What shipped.** The lowering is exactly the cheap desugars-to-code shape the
survey promises. The despawn hook compiles to `@on_despawn_<Model>(i32 %e, i32
%reason)`; when the hook writes `reason: r`, `r` is bound as an int local reading
`%reason`. Each teardown *site* passes a constant `EndReason`:

- `despawn e` passes `Despawned` (0) — an in-world death.
- **program shutdown** passes `Quit` (2): a generated `@L_despawn_all(reason)`
  walks the live set at `done:` (before `@OnQuit`, matching the timeline) and
  fires every survivor's `@OnDespawn`. This makes **"no silent deaths"** real —
  an entity that outlives the run still gets its destructor, and can branch on
  `Quit` to skip work that only matters mid-game. Emitted only when the program
  has `@OnDespawn` hooks, so despawn-free programs are byte-for-byte unchanged.
- `SceneExit` (1) is reserved: a scene tearing down its owned entities
  (SCENES-DESIGN E1) will pass it once scene-owned entities land.

`EndReason` is compiler-owned (resolved in `enum_ordinal`), so `EndReason.Quit`
works without a user declaration; a user enum of the same name still shadows it.
Backward-compatible: the `reason:` binding is optional, and `@OnDespawn` without
it is unchanged. `@OnDetach` and scene `on exit` do **not** yet take reasons
(§13.1). See [`examples/reason.ludic`](examples/reason.ludic).

---

## 6. LC2 — value-change hooks `@OnChange(P)` *(a compile-time win)*

Every reactive ECS wants "fire when a component's value changes" (flecs `on_set`,
EnTT `on_update`, Bevy `Changed<T>`), and every one hits the same footgun: a raw
in-place write is invisible, so you must route mutations through a special channel
(`modified()`, `patch`) or you miss changes.

**Ludic can sidestep the footgun because it is an AOT compiler that sees every
write site.** A field store `Health.hp = …` is a statement the compiler lowers; if
`Health` carries an `@OnChange`, the compiler can emit the hook call *right after
the store*. No dirty bits, no end-of-frame flush, no missed-write class of bugs —
the thing that is a runtime hazard everywhere else is resolved at compile time.

```ludic
# doc-check: skip
@OnChange(Health) handler Bar { hud_set_health(Health.hp) }   # after any write to a Health field
```

Open question (§7): fire on *every* write (Bevy's `DerefMut` semantics — simple,
may over-fire) or guard with a value compare (fire only on actual change — needs
the old value, à la Bevy `Replace`). The compiler has the old value in hand at the
store site, so the value-compare form is feasible and is the more useful default.

---

## 7. LC3 — query-membership edges `@OnStartMatch` / `@OnStopMatch`

DOTS `OnStartRunning`/`OnStopRunning` and flecs `Monitor` fire when an entity
**starts or stops matching a composite query** — not a single component, but a
whole condition (`{Position, Velocity, moving}`). This is strictly more expressive
than per-property `@OnAttach`, which can't see "the entity now has *both* and is
alive." It's the natural ECS form of enter/exit.

```ludic
# doc-check: skip
@OnStartMatch(these: [Position, Velocity{dx != 0 or dy != 0}], on: Actor)
handler BeginMoving { play("footstep_loop.wav") }

@OnStopMatch(these: [Position, Velocity{dx != 0 or dy != 0}], on: Actor)
handler StopMoving  { stop("footstep_loop.wav") }
```

Cost: unlike LC1/LC2 this needs runtime state — a per-entity shadow bit per
monitored query ("did it match last tick?"), checked once per frame, edge-
triggering the hook on a change. flecs does this by evaluating the query against
the entity's previous and current archetype. Ludic would keep a `@M_<query>` bit
array parallel to `@H_`. Medium cost; a genuinely differentiated feature.

---

## 8. LC4 — keyed effects (paired setup/teardown on a dependency list)

The declarative-UI headline, and the biggest reach. React `useEffect`, Compose
`DisposableEffect`, and SwiftUI `.task` all express: *while this thing exists (or
while key K holds), set up a resource; when it leaves or K changes, tear it down*
— with cleanup **co-located** with setup so it can't leak, and an *update* defined
as keyed teardown-then-setup. This collapses create/update/destroy into one
primitive.

```ludic
# doc-check: skip — sketch
@Effect(on: Enemy, keys: [Sprite.id]) handler Body {
  let tex = image_load(Sprite.id)
  dispose { image_drop(tex) }        # runs on despawn OR when Sprite.id changes
}
```

Semantics: the setup runs on spawn (and whenever a listed key changes, after the
previous `dispose`), and `dispose` runs on despawn (and before each keyed re-run).
It unifies `@OnAttach`/`@OnDetach`/`@OnChange` into one leak-proof unit. Lowering
needs somewhere to stash the effect's captured teardown state and last key values
per entity — a per-effect side table, re-checked in a phase. Design only; the
syntax and storage model are open. This is where Ludic could feel genuinely modern
relative to every ECS surveyed (none of which have it).

---

## 9. LC5 — deferred structural changes with commit points

DOTS `EntityCommandBuffer`, flecs `defer_begin/end`, and Godot `queue_free()` all
make structural change **deferred with an explicit commit point**, so mutating
while iterating is safe and batched. Ludic's `spawn`/`despawn` are immediate today,
but *already* iteration-safe by a different route — matching is lazy per entity id
([LANGUAGE.md](LANGUAGE.md) "Matching is lazy, not snapshotted"), so despawning the
current entity is defined. A `defer { … }` block (or `despawn e at LateUpdate`)
that queues structural changes to a phase boundary would add batching and a single
predictable commit point, and is the prerequisite for safe parallel handlers
(the `reads`/`writes` scheduling in SCENES-DESIGN). Design only; lower priority
than LC1–LC3 because the immediate path is already safe.

---

## 10. LC6 — supervision, restart-as-a-state, live migration

The furthest-out cluster, from the actor model and OTP: lifecycle driven by
**failure**, not just create/destroy. Three ideas, all tied to Ludic's eventual
hot-reload / bytecode-VM roadmap rather than the near term:

- **Restart as a distinct state** between create and destroy — preserve an
  entity's identity, reset its transient components, re-run setup (respawn,
  hot-reload). Akka's "stable external ref, replaced internal state."
- **Supervision / failure escalation** — a subsystem owner declares a policy for
  child faults (restart one / restart the group / escalate to reload the scene)
  instead of defensive inline checks. Ludic has no failure model yet, so this
  waits on one.
- **Live state migration** (`code_change`) — a hook that transforms an entity's
  persistent state across a code/schema version, so hot-reload evolves data
  instead of destroying it. Directly relevant to a self-hosting language.

---

## 11. Design principles distilled from the footguns

1. **No silent deaths.** Enumerate every teardown reason (LC1). If the compiler
   must name the reason at each site, it can't forget a path.
2. **Fire on real transitions, not API calls.** Idempotent add/remove — LC0
   already does this; keep it for every future hook.
3. **Keep "paused" and "gone" distinct.** `disable`/`enable` (data kept) vs
   `detach`/`attach` (structural) — already true; don't let a future feature blur
   them.
4. **Prefer compile-time resolution to runtime tracking.** LC2 turns the
   universal "invisible write" footgun into a compile-time hook emission because
   Ludic sees write sites. Reach for this wherever a runtime dirty-bit is the
   obvious-but-worse option.
5. **If reactivity is order-dependent, make it loud.** Never silently drop events
   at a frame boundary (Bevy's removal-buffer trap). Ludic's push-at-the-site
   style avoids this by default.
6. **Deterministic teardown order.** When a scope tears down many things (a scene
   unloading its owned entities — SCENES-DESIGN E1), define the order (reverse of
   creation, RAII-style) rather than leaving it unspecified.
7. **Only the semantic layer.** POD components mean no ctor/dtor/move hooks. Don't
   grow a memory-lifecycle layer Ludic doesn't need.

---

## 12. Suggested implementation order

- **LC0 — attach/detach + `@OnDetach`.** ✅ Done. Closes the structural pair.
- **LC1 — reason-carrying teardown.** ✅ Done for `@OnDespawn` (an `i32 %reason`
  param + a constant at each site, plus a shutdown despawn-all for `Quit`).
  `@OnDetach` / `on exit` reasons remain open (§13.1).
- **LC2 — `@OnChange(P)`.** Compile-time hook emission at write sites — a
  Ludic-specific win over every ECS's invisible-write footgun. **Recommended next.**
- **LC3 — `@OnStartMatch`/`@OnStopMatch`.** First feature needing runtime shadow
  state; the expressive ECS enter/exit.
- **LC4 — keyed effects.** The modern, leak-proof unification. Design first.
- **LC5 — deferred structural changes.** Batching + parallel-safety; the immediate
  path is already iteration-safe, so lower urgency.
- **LC6 — supervision / restart / migration.** Waits on a failure model and the
  hot-reload roadmap.

---

## 13. Open decisions

1. **Reason enum (LC1):** *resolved for `@OnDespawn`* — ships `Despawned`,
   `SceneExit`, `Quit` as a compiler-owned `EndReason`, passed as an optional
   `reason:` binding (not a separate annotation). Still open: `SceneExit` has no
   firing site until scene-owned entities (SCENES-DESIGN E1); should `@OnDetach`
   and scene `on exit` take reasons too, and if so with which reason values?
2. **`@OnChange` (LC2):** fire on every write (simple, over-fires) or only on an
   actual value change (needs the old value at the store site)? Per-field or
   whole-property granularity?
3. **Membership edges (LC3):** where do the shadow bits live, and is the check
   per-frame or event-driven off attach/detach/spawn? Cost budget.
4. **Keyed effects (LC4):** syntax (`@Effect` annotation vs an `effect { … dispose
   { … } }` statement), and where per-entity teardown/key state is stored.
5. **Ordering:** none of this addresses intra-phase handler ordering (Bevy
   `before`/`after`, flecs `DependsOn`). Worth a separate proposal; declarative
   relational ordering over priority integers, per the survey.

---

*Companion to [LANGUAGE.md §Annotations](LANGUAGE.md) and
[SCENES-DESIGN.md](SCENES-DESIGN.md) (scene-owned entities and reasons intersect at
LC1/LC5). Supersedes nothing until the compiler work in §12 lands.*
