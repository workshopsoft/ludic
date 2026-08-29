# Networking, from primitives up — a design doc

> **Status: N0–N6 all shipped.** The whole stack is implemented and self-hosted,
> and — unlike the original N0/N1 which linked C hosts — every phase now runs as a
> self-contained **pure-Ludic** program (no `.c`, no foreign host): a built-in
> loopback transport fills the seam, and each `examples/net_*.ludic` drives and
> asserts itself from its own `entry`. See `bin/x test` (checks `net_echo` … `net_demo`)
> and `examples/net_demo.ludic` for a full RPC→authority→replicate→reconcile loop.
> clang remains only as the LLVM-IR assembler/linker (no C is compiled), the floor
> Rust and Swift stand on.
>
> _Historical note:_ **N0 + N1 shipped first; N2–N6 were design.** Two phases landed as `bin/x test`
> checks. **N0 (transport seam):** `extern fn` now lowers end to end — a direct
> `@<sym>` call plus a `declare`, no networking logic in the compiler — so the whole
> transport is two externs (`net_send`/`net_poll`) a host fills. Proven by
> [`examples/net_echo.ludic`](examples/net_echo.ludic) sending four bytes through
> the loopback host in [`tests/net_c/loopback.c`](tests/net_c/loopback.c) and
> polling them back (`4 10 20 30 42`). **N1 (snapshot-to-buffer):**
> `world_size()`/`world_save(buf)`/`world_load(buf, len)` generalize `save()`/`load()`
> from a file to a caller-owned memory buffer — the same block layout via `memcpy` —
> so the whole ECS world round-trips through bytes. Proven by
> [`examples/net_snapshot.ludic`](examples/net_snapshot.ludic) +
> [`tests/net_c/snapshot_mod.c`](tests/net_c/snapshot_mod.c) (snapshot, mutate,
> restore → `50 7 50`). Both are byte-identical when unused, so the offline dividend
> (§8) holds. This is a companion to
> [EVENTS-DESIGN.md](EVENTS-DESIGN.md), [LIFECYCLE-DESIGN.md](LIFECYCLE-DESIGN.md),
> and [SCENES-DESIGN.md](SCENES-DESIGN.md). Where the events work made Ludic
> *moddable*, this proposes making it *networked* — and it deliberately does **not**
> ship a multiplayer framework. Ludic is a language: it exposes the low-level
> mechanism (transport seam, world snapshot, generated serializers, ownership, a
> drivable sim) and a thin high-level *declarative* layer that lowers onto that
> mechanism, and it leaves the netcode *policy* (authority, prediction, relevancy)
> to the developer or a library. §14 lists the open decisions.

---

## 1. Thesis

Every networking model dies on one of two problems: **determinism** or **state
serialization**. Ludic already solves both, almost by accident.

- **Determinism** is designed in — seeded RNG, `fixed` (Q16.16) instead of floats,
  byte-identical golden renders, and (as of [EVENTS-DESIGN EV6](EVENTS-DESIGN.md))
  bounded, array-ordered event dispatch. A modded, event-driven Ludic game still
  replays identically. That is exactly the property lockstep multiplayer needs, and
  the reason Factorio's heavily-modded multiplayer stays in sync.
- **State serialization** already exists — `save()`/`load()` snapshot the *entire*
  ECS World to a byte buffer ([`selfhost/emit_save.ludic`](selfhost/emit_save.ludic)),
  and the world-table schema built for [EVENTS-DESIGN EV2](EVENTS-DESIGN.md) (prop →
  field → offset) is exactly the descriptor you serialize against.

So networking is not a new subsystem. It is a **fourth lens on the event + world
layer** — the same layer modding used. And it obeys the same two-altitude rule as
everything else in Ludic:

> **Low-level is freedom; high-level is developer experience; they are the same
> feature at two altitudes.** `@Queries` lowers to a query loop, `scene` lowers to a
> machine, `@Public @OnSpawn` lowers to `emit`. Networking's high-level annotations
> lower to a transport seam, generated serializers, and a drivable sim — and the
> primitives stay exposed underneath for anyone the sugar doesn't fit.

The developer writes **one simulation**, declares *what* replicates, *who* owns
each entity, and *where* each handler runs — and never branches on `is_server()`
in ordinary code. The compiler lowers the declarations; a networking *runtime*
(the seam-filler, like `rt_*` for windowing) supplies the transport and the tick.

---

## 2. Two altitudes, one system

| Altitude | Who writes it | Surface |
|---|---|---|
| **High-level (DX)** | the developer, declaratively | `@Sync` (field/property/model), `@Owned`, `@Server`/`@Predicted`, directional remote events |
| **Lowering** | the compiler | per-model serializers, role-guarded dispatch, remote-event send/recv, ownership storage |
| **Runtime seam** | a networking library (blessed or custom) | binds the socket, sets `role`, drives the replication tick |
| **Low-level (freedom)** | power users, when the sugar doesn't fit | `net_send`/`net_poll`, `world_save`/`world_load`, generated `serialize_*`/`apply_*`, `owner()`, the drivable sim |

Everyone lives at the top row for normal games; the bottom row stays open for
someone building something no framework could express. The split that keeps this a
*language* and not a *framework*: **annotations and their lowering are the language;
the replication driver and the transport are a library.** It is precisely the
events story — `@On`/`emit` are the language, the *modding system* is library code —
applied again.

---

## 3. Research digest — the one idea to steal from each

| System | The transferable idea |
|---|---|
| **Quake / QuakeWorld** | The founding pattern: **client-side prediction + server reconciliation**, and delta-compressed snapshots against the last acked baseline. Predict locally, correct from the authority. |
| **Source (Valve)** | **Entity interpolation** (render remote entities slightly in the past, smoothly) paired with **lag compensation** (the server rewinds to the shooter's view for hit detection). Interpolation and rewind are two halves of one clock discipline. |
| **Unity NGO** (GameObject) | `NetworkVariable<T>` with **read/write permissions** + `OnValueChanged`; ownership as `OwnerClientId`. Also the **anti-pattern to avoid**: `IsServer`/`IsOwner` branching sprinkled through gameplay code. |
| **Unity Netcode for Entities** (ghosts) | The model Ludic is closest to: **replication is a compile-time property of components and fields** — `[GhostField]`, `[GhostComponent]`, `GhostOwner`, and `Predicted`/`Interpolated` ghost modes — with serializers *generated* from the ECS schema. |
| **Mirror / FishNet** | The community-ergonomic take: `SyncVar` with change **hooks**, and clean **directional RPCs** — `Command` (client→server) / `ClientRpc` (server→clients). |
| **GGPO / rollback** | Save state → predict → on misprediction **restore and re-simulate**. Its one hard requirement is *cheap, complete state snapshot/restore* — which Ludic already has in `save()`/`load()`. |
| **Factorio** | Fully **deterministic lockstep** for heavy mod multiplayer: only *inputs* cross the wire; the whole sim is reproduced. Proof that determinism (EV6) is the enabler, not a nicety. |
| **Photon Quantum** | A shipping product that *is* deterministic-ECS-rollback. Validates the exact combination — ECS + determinism + rollback — Ludic is already positioned for. |
| **Roblox** | The **local/remote split** (`BindableEvent` vs `RemoteEvent`), server-authority by default, and engine-replicated properties: "some state just replicates, and RPCs are directional events." |

Six **footguns** the survey warns against, to design *out* from the start:

1. **Role branching everywhere.** `if (IsServer)` scattered through gameplay is the
   NGO readability tax. Fix: **role is a handler annotation** (`@Server`/`@Predicted`),
   never a runtime branch in ordinary code.
2. **Float nondeterminism.** Lockstep breaks the instant the networked sim touches
   `f32` across platforms. Fix: the determinism contract (§11) — the networked sim
   stays `int`/`fixed`.
3. **Replicating pointers / heap refs.** A `ptr` field holds a machine-local
   address; it cannot cross the wire. Fix: **the compiler rejects `@Sync` on a
   non-POD-scalar field** — a checked guarantee, not a convention.
4. **Sending everything every tick.** Fix: `@Sync` is **opt-in at the field level**
   (only marked fields replicate), plus change-driven dirty tracking (`@OnChange`,
   [LIFECYCLE LC2](LIFECYCLE-DESIGN.md)) so an unchanged field costs nothing.
5. **Hidden authority.** Magic "the server decides" behavior is unclear and
   unauditable. Fix: **explicit** `@Server`/`@Predicted`; unmarked code runs
   everywhere by definition.
6. **Schema-less snapshots.** A raw state blob with no version desyncs silently on a
   version mismatch. Fix: the **world-table schema is the versioned descriptor** the
   serializer is generated against.

---

## 4. What Ludic already has

The substrate is unusually complete for an engine that has never networked:

- **A deterministic simulation** — seeded RNG, `fixed` math, ordered ECS iteration,
  EV6-bounded event dispatch. Lockstep's precondition.
- **World snapshot/restore** — `save()`/`load()` serialize the whole World
  ([emit_save.ludic](selfhost/emit_save.ludic)); today to a file, trivially
  retargetable to a memory buffer. Rollback's precondition.
- **A reflective world table** — `ludic_get`/`set`/`has`/`query`/`register_prop`
  and the prop→field→offset schema (EV2/EV2b). The apply-and-serialize substrate.
- **An event bus with a foreign ABI and POD payloads** (EV0). Directional remote
  events (RPCs) are one flag on this.
- **The `rt_*` seam pattern** — the compiler already emits calls to
  `rt_init`/`rt_poll`/`rt_present` that a runtime library fills. Networking's
  transport and role registers plug into the identical seam.

What is missing is small and named: a transport seam, snapshot-to-*buffer*,
generated per-field serializers, ownership storage, role-guarded dispatch, and a
developer-drivable loop. Each is a phase in §13.

---

## 5. The low-level primitives (the freedom layer)

Unopinionated, composable, host- or developer-owned. A power user builds any model
directly from these; the high-level layer (§6) is sugar over them.

| Primitive | Signature (sketch) | Enables |
|---|---|---|
| **Transport seam** | `extern function net_send(peer: int, buf: pointer, len: int)` · `extern function net_poll(buf: pointer, cap: int) -> int` | any model; host binds UDP (native) or WebRTC/WebSocket (wasm), or a loopback for tests |
| **World snapshot ↔ buffer** | `world_save(buf: pointer) -> int` · `world_load(buf: pointer, len: int)` | rollback, replication, join/resync — generalizes `save()`/`load()` off the filesystem |
| **Generated serializers** | `serialize_<Model>(e: entity, buf: pointer) -> int` · `apply_<Model>(e: entity, buf: pointer, len: int)` | per-model, touch only the `@Sync` fields; emitted from the schema |
| **Ownership** | `owner(e: entity) -> int` · `set_owner(e: entity, id: int)` | authority checks, per-entity owner metadata (an `@L_owner` array, like `@L_kind`) |
| **Role registers** | `is_server() -> bool` · `is_owner(e: entity) -> bool` · `local_id() -> int` | the runtime sets these; role-guarded dispatch reads them |
| **Drivable sim** | `tick_fixed()` · `tick_render()` · seed get/set | a developer-owned loop for prediction/rollback (also: replay, headless tests, AI) |
| **Remote-event serde** | `emit`-site serialize + `net_send`; inbound bytes rebuild + re-`emit` | RPCs |

Transport is the one that needs *no* language work at all — a developer can already
`extern fn` a socket library and link it, exactly as the windowing layer is linked.
The language's genuine contributions are snapshot-to-buffer, the generated
serializers, ownership storage, and the drivable loop.

```ludic
# doc-check: skip — the freedom layer, a hand-rolled replication tick
entry {
  while running() {
    if is_server() {
      for (Transform) in query [Transform, Owned] {
        let n = serialize_Player(self(), buf)     # compiler-generated
        net_send(ALL, buf, n)                       # developer's transport
      }
    } else {
      let n = net_poll(buf, CAP)
      if n > 0 { apply_Player(target_of(buf), buf, n) }
    }
    tick_render(); present()
  }
}
```

This *works*, but it is deliberately not how most games should be written — it puts
serialization and role branching in the developer's face. That is what §6 fixes.

---

## 6. The high-level DX layer (the default)

The developer declares **what** replicates, **who** owns, and **where** handlers
run. No serialization, no transport, no `is_server()` in ordinary code.

### 6.1 `@Sync` — what replicates, at three granularities

Replication is **opt-in at the field level**: a field crosses the wire only when it
is explicitly marked. There is no `@NoSync` — the surface is purely additive.

Two independent switches, and **both must be on** for a field to replicate:

1. **A field is *replicable*** iff it is `@Sync`-marked — directly
   (`@Sync hp: int`), or via `@Sync property P { … }` (a shorthand that marks
   *every* field of `P` replicable). *Only marked fields — never all-by-default.*
2. **A component *participates* in a model** iff the model marks it `@Sync`
   (`@Sync Transform` inside the `model`). Participation is decided **per model
   use-site**, so the same property syncs in one model and not another.

A field of an entity replicates **iff it is replicable AND its component
participates in that entity's model.**

```ludic
# doc-check: skip — the three levels
@Sync property Position { x: int, y: int }        # every field of Position is replicable
property Health   { @Sync hp: int, max: int }      # only hp is replicable; max never is
property Transform { @Sync x: int, @Sync y: int, angle: int }  # x, y replicable; angle not

@Owned model Player {          # entities carry a network owner
  @Sync Transform              # participates → replicates x, y (not angle)
  @Sync Health                 # participates → replicates hp (not max)
  @Sync Position               # participates → replicates x, y
}

model Prop {                   # a non-owned decoration
  Transform                    # not @Sync here → Transform does NOT replicate — the
                               #   "non-synced Transform sometimes" case, for free
}
```

- **Checked, not silent.** `@Sync` on a `ptr`/non-POD-scalar field is a **compile
  error** ("networked fields must be POD scalars" — footgun 3). A model that
  `@Sync`es a component with *zero* replicable fields is a **compile warning**
  (participation that replicates nothing).
- **Per-field direction** rides the same annotation as an argument, mirroring how
  `@Queries(these:…, on:…)` takes args: `@Sync(to: owner) hp: int` replicates a
  field only to the entity's owner (Unity's `SendToOwner`). Default is `to: all`.

### 6.2 Roles — where a handler runs

The role is a **declarative annotation on the handler**, never a runtime branch.
Unmarked code is the shared, deterministic simulation and runs everywhere.

| Annotation | Runs where | Meaning |
|---|---|---|
| *(none)* | everywhere | shared, deterministic simulation |
| **`@Server`** | the authority only | server-authoritative logic; clients receive the result via `@Sync` |
| **`@Predicted`** | the owning client (speculatively) **and** the server (authoritatively) | responsive local control, auto-reconciled against the server |

`@Predicted` is **explicit** — the developer opts an owned entity's control handlers
into prediction; the language does not silently predict. The name states the netcode
role (owner-predicts + server-authoritative + reconcile), not the machine, and
matches Unity's `GhostMode.Predicted` so the concept transfers.

`@Interpolated` — how a *non-owned* synced component is smoothed between snapshots on
a remote client — is a **presentation** concern on the component, kept separate from
these sim-handler roles rather than muddying them.

### 6.3 Ownership

```ludic
# doc-check: skip
@Owned model Player { @Sync Transform; @Sync Health }   # every Player entity has a network owner
```

`@Owned` gives the model an owner slot (the `@L_owner` array); `owner(e)` /
`set_owner(e, id)` read and assign it (the authority assigns). `is_owner(e)` and
`@Predicted` dispatch read it. Ownership gates who may write `@Sync(to: owner)`
fields and who runs `@Predicted` handlers.

### 6.4 RPCs are directional remote events

RPCs are the event bus with a direction flag — no new concept:

```ludic
# doc-check: skip
@ToServer  event Fire  { dir: int }              # client → server (a request)
@ToClients event Boom  { x: int, y: int }        # server → clients (a broadcast)

@Server @On(Fire) handler DoFire { spawn Bullet { dir: Fire.dir } }   # authority handles the request
@On(Boom) handler Vfx { spawn Explosion { x: Boom.x, y: Boom.y } }    # every client reacts
```

`@ToServer`/`@ToClients` mark an `event` remote; the compiler serializes its POD
payload (already flat — [EVENTS-DESIGN EV0](EVENTS-DESIGN.md)) and routes it through
the transport seam in the declared direction, re-`emit`ting it on the far side into
the ordinary event dispatch.

### 6.5 The whole game, high-level

```ludic
# doc-check: skip — read top to bottom: you always know where each line runs
program Shooter {
  @Sync property Position { x: int, y: int }
  property Health { @Sync hp: int, max: int }

  @Owned model Player { @Sync Position; @Sync Health }
  model Bullet { Position }

  handler Physics phase FixedUpdate { … }        # no tag → shared, identical everywhere
  @Predicted handler Move phase Input { … }        # owner predicts, server authoritative
  @Server    handler Death phase Update { … }      # authority only; clients get the result via @Sync

  @ToServer event Fire { dir: int }
  @Server @On(Fire) handler DoFire { spawn Bullet { … } }
}
```

No `is_server()`, no `net_send`, no serializer — yet every line's role is legible,
and every replicated field is explicitly opted in.

---

## 7. Lowering summary

Everything above reduces to the §5 primitives, gated so an un-networked build is
unchanged:

| High-level | Lowers to |
|---|---|
| `@Sync` field / `@Sync C` in a model | a per-model `serialize_<M>` / `apply_<M>` over the replicable-and-participating fields, + a `sync manifest` a runtime reads |
| `@Sync(to: owner)` | a field tag in the manifest; the serializer branches on `owner(e) == peer` |
| `@Owned` | an `@L_owner` array + `owner()`/`set_owner()`, like `@L_kind` |
| `@Server` / `@Predicted` handler | the handler's dispatch wrapped in a role guard the runtime's role register drives (the `rt_*` seam pattern) |
| `@ToServer` / `@ToClients event` | payload serialize + `net_send(direction, …)` at the `emit` site; inbound bytes rebuild + re-`emit` |
| `world_save`/`world_load` to buffer | the existing `save()`/`load()` snapshot machinery, retargeted from a file handle to a memory buffer |
| drivable `tick_fixed`/`tick_render` | the phase runners the compiler already generates for the frame loop, exposed as callables when a game owns its `entry` loop |

No heap, no hidden runtime beyond the honestly-named transport/role seams a
networking library fills — the same relationship windowing already has.

---

## 8. The offline dividend

Because these are **opt-in-cost annotations** — serializers *generated*, nothing
*run* until a networking runtime is spliced — a build with no runtime is
**byte-identical to single-player**, and every role guard collapses to "run here."
You build the game offline, drop in a runtime, and the same annotated code starts
replicating. That is Unity's "offline mode adjustable," achieved by the same
opt-in-cost invariant the whole event system already holds.

---

## 9. The one genuinely hard corner

Determinism holds beautifully for `int`/`fixed` simulations, which makes lockstep
and rollback cheap. It **breaks for `f32` across platforms** — so **3D/voxel +
lockstep stays the hard corner** (3D wants floats; the Luanti analysis flagged that
`fixed` saturates at ±32768). No language sleight-of-hand fixes this; the
determinism contract (§11) states it plainly, and a developer choosing lockstep for
a 3D game has to accept it (or choose state replication, §10's other branch, where
per-frame determinism is not required).

---

## 10. Two model families, both reachable — neither built in

The language commits to **neither**; both are library policy over the §5 primitives.

- **Deterministic lockstep / rollback** — exchange only inputs; reproduce the sim;
  on misprediction, `world_load` a snapshot and re-`tick_fixed`. Plays to Ludic's
  determinism, and GGPO-cheap because snapshot/restore already exists. Best for
  2D/integer/fixed games.
- **State replication** — the authority `world_save`s (or per-`@Sync` serializes),
  delta-encodes against the last acked snapshot per peer, ships the diff; peers
  `apply_*` it and interpolate/predict. Heavier, but needed when the sim can't be
  deterministic (float physics, 3D).

A **blessed reference runtime** (§13, N6) can ship one of these so `@Sync` games
work out of the box — the way [`tests/mod_c/mod.c`](tests/mod_c/mod.c) proved the
event ABI — while the seams stay open for others.

---

## 11. The determinism contract (what the language must guarantee)

For a developer to *trust* lockstep, the language must promise, document, and where
possible *enforce*:

1. **`fixed`/`int` math is bit-identical across platforms.** The networked sim must
   avoid `f32` (footgun 2). *(Enforcement: at least a documented rule; ideally a
   `@Sync`/`@Server`-reachable-code float lint.)*
2. **ECS iteration order is stable** — query order is declaration/id order, and
   EV6 already fixes event-dispatch order. No hash-map iteration in the sim path.
3. **RNG is deterministic from a shared seed** — `seed()` exists; the seed must be
   synchronized at session start (library policy) and never re-seeded from
   wall-clock mid-sim.
4. **Networked components are POD scalars** — no `ptr`/heap fields cross the wire
   (footgun 3). *Enforced:* `@Sync` on a non-scalar field is a compile error.
5. **Entity ids agree across peers** — lockstep gets this free from determinism;
   replication needs an id-mapping table (library policy).

This contract is the language's real networking responsibility. Most of it is
*already true*; the work is stating and enforcing it, not inventing it.

---

## 12. Design principles

1. **Mechanism in the language, policy in the library.** Expose serializers,
   transport seam, ownership, snapshot, drivable sim. Never bake in authority,
   prediction, or matchmaking.
2. **Role is declared, not branched.** `@Server`/`@Predicted` on handlers; unmarked
   code runs everywhere. No `is_server()` in ordinary gameplay.
3. **Replication is explicit and opt-in.** Only `@Sync`-marked fields cross the
   wire; participation is decided per model. Nothing replicates by surprise.
4. **Opt-in cost.** Un-networked builds are byte-identical; the sim runs offline
   with the same code.
5. **Determinism is a promise the language keeps.** Enforce the POD-scalar rule;
   document the float/iteration/seed rules; keep the sim reproducible.
6. **Two altitudes, always.** The high-level lowers to primitives that stay
   callable. The sugar is the default; the freedom layer is never removed.
7. **Reuse, don't reinvent.** Snapshot = generalized `save()`; RPC = directional
   `event`; serializer = generated from the EV2 schema; role seam = the `rt_*`
   pattern. Networking is the fourth lens, not a parallel stack.

---

## 13. Suggested implementation order

Each phase is independently shippable and testable, matching how the repo phases
work (and how EVENTS-DESIGN sequenced EV0–EV7).

- **N0 — transport seam + loopback. ✅ SHIPPED.** The `net_send`/`net_poll` extern
  seam and a loopback host stub; an echo test. The floor; needed almost no compiler
  work — just finishing `extern fn`: a call lowers to a direct `@<sym>` call and the
  header emits a matching `declare`, so any C/Rust/Zig library (a socket, here the
  loopback) binds through the same seam windowing uses. `find_extern` (emit_core),
  the extern branch in emit_expr's call path, `emit_extern_decls` (emit_head).
  ([`examples/net_echo.ludic`](examples/net_echo.ludic),
  [`tests/net_c/loopback.c`](tests/net_c/loopback.c) → `4 10 20 30 42`.)
- **N1 — snapshot-to-buffer. ✅ SHIPPED.** Generalized `save()`/`load()` to a memory
  buffer: `world_size()` (exact snapshot bytes), `world_save(buf) -> int`,
  `world_load(buf, len)`. The same fixed block list (entity count, freelist, alive,
  kind, vars, per-component `@S_`/`@H_`) now feeds a file (fwrite/fread) *or* a buffer
  (memcpy over a threaded i64 offset), chosen by `g_snap_mode` in emit_save.ludic;
  no rt_ hook (the ECS world only). The rollback/replication substrate.
  ([`examples/net_snapshot.ludic`](examples/net_snapshot.ludic),
  [`tests/net_c/snapshot_mod.c`](tests/net_c/snapshot_mod.c) → `50 7 50`.)
- **N2 — `@Sync` codegen. ✅ SHIPPED.** The three-level annotations → generated
  per-model `serialize_<M>`/`apply_<M>` + by-kind dispatchers (`ludic_serialize`/
  `apply`/`sync_size`, and the `serialize`/`apply`/`sync_size` builtins); the
  POD-scalar compile error and the empty-participation warning. The declarative
  core. ([`examples/net_sync.ludic`](examples/net_sync.ludic) → `12 3 4 50 999`,
  emit in [`selfhost/emit_net.ludic`](selfhost/emit_net.ludic).)
- **N3 — ownership. ✅ SHIPPED.** `@Owned` + the `@L_owner_arr` array +
  `owner()`/`set_owner()`/`is_owner()`; owners are part of the world snapshot.
  ([`examples/net_owner.ludic`](examples/net_owner.ludic) → `-1 7 0 1`.)
- **N4 — remote events (RPCs). ✅ SHIPPED.** `@ToServer`/`@ToClients` on `event`s →
  payload serialize (`[event id][fields]`) + directional `net_send` + `net_pump()`
  far-side re-`emit`. ([`examples/net_rpc.ludic`](examples/net_rpc.ludic) → `0 8`.)
- **N5 — roles + drivable sim. ✅ SHIPPED.** `@Server`/`@Predicted` role-guarded
  dispatch driven by the `@L_role` register (`set_role`/`is_server`/`local_id`);
  the opt-in `entry`-owns-the-loop with `tick_fixed()`/`tick_render()`. Together
  these let prediction/rollback be written in developer/library code.
  ([`examples/net_roles.ludic`](examples/net_roles.ludic) → `1 102`.)
- **N6 — a blessed reference netcode runtime. ✅ SHIPPED.** A Ludic library
  ([`examples/net_rt.ludic`](examples/net_rt.ludic)) — server-authoritative state
  replication over the primitives — plus a full end-to-end demo, proving the seams
  the way the C mod proved the event ABI, but in pure Ludic over the built-in
  transport. Library policy, swappable for lockstep+rollback.
  ([`examples/net_demo.ludic`](examples/net_demo.ludic) → `5 999 5`.) A built-in
  loopback transport (N0) means all of this needs **no foreign code at all**.

N0–N2 deliver "state can be declared, serialized, and moved." N3–N4 add ownership
and RPCs. N5 unlocks prediction. N6 is a batteries-included default that others can
replace. The **determinism contract (§11)** is cross-cutting — documented from N0,
enforced incrementally.

---

## 14. Open decisions

1. **Field direction vocabulary.** `@Sync(to: owner)` / `@Sync(to: all)` confirmed
   in spirit; is `to:` the right key, and do we also want `to: server` (a field only
   the authority reads)? How does per-field direction interact with `@Predicted`?
2. **Blessed runtime, or seams only?** Events chose "seams + reference mod, bless
   nothing." Networking's DX may justify shipping one reference runtime (N6). One,
   or none?
3. **Authority default.** Server-authoritative with `@Predicted` opt-in is the safe,
   Unity-ish default. Confirm, or keep the language authority-neutral and leave even
   that to the runtime?
4. **Drivable loop shape.** Whole-frame `tick()` vs the `tick_fixed()`/`tick_render()`
   split; how a developer-owned `entry` loop coexists with scenes, the `rt_*` hooks,
   and the auto-loop (opt-in via presence of an `entry` block?).
5. **Snapshot granularity.** Full `world_save` vs per-`@Sync` serialize vs a
   generated delta between two snapshots — which does the language provide, and which
   is library work?
6. **Float determinism enforcement.** A documented rule only, or a real lint that
   flags `f32` reachable from `@Server`/`@Predicted`/`@Sync` code paths?
7. **Ownership at component granularity.** Unity's DOTS allows per-component owner
   send-rules. Is `@Owned` per-*entity* enough, or do we need per-component owners
   (a real complexity jump)?
8. **Networking substrate for the remote half of EVENTS EV7.** This doc's directional
   remote events (N4) *are* the local/remote split EVENTS-DESIGN EV7 deferred for
   "no networking substrate." N4 is that substrate — the two docs meet here.

---

*Companion to [EVENTS-DESIGN.md](EVENTS-DESIGN.md) (remote events are directional
events; serializers reuse the EV2 world-table schema; EV7's deferred local/remote
split lands here as N4), [LIFECYCLE-DESIGN.md](LIFECYCLE-DESIGN.md) (`@OnChange`/LC2
is the dirty-tracking primitive for delta replication), and
[SCENES-DESIGN.md](SCENES-DESIGN.md). Supersedes nothing until the compiler work in
§13 lands.*
