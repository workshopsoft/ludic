# Scenes, expanded — a design doc

> **Status: S0 shipped; S1–S6 are design.** The base construct — `scene` /
> `layer` / `on enter` / `on exit` / `become`, lowered to the implicit machine of
> §3 and §9 — is implemented and tested ([`examples/scenes.ludic`](examples/scenes.ludic),
> a `test.sh` check). The extensions in §4–§8 (scene-owned entities, richer
> layers, the overlay stack, scene-local state, transition parameters) are still
> design targets. This document reaches deliberately past the thin sketch so we
> can decide the shape before building each one. §11 lists the open decisions.

---

## 1. Where we are

A Ludic program is almost always several mutually-exclusive states — a title
screen, the overworld, a battle, a pause menu. Two ways to write that exist in
the language today, and a third is sketched:

| Approach | Status | Cost |
|---|---|---|
| Mode register consulted at the top of every handler (`if reg(R_MODE) == …`) | works | a guard re-read per handler per frame; state is a magic number; nothing scopes to it |
| `machine`/`state`/`become` over a register | works | dispatch on the register each frame; still one flat register, no per-state handlers or lifecycle |
| `scene`/`layer`/`on enter`/`on exit` | **sketch only** | — |

The sketch ([`examples/scenes.ludic`](examples/scenes.ludic)) specs:

- Exactly **one scene active**; the `start` scene runs first.
- A scene's handlers run only while it is active; handlers outside any scene are
  global.
- **Layers group handlers; declaration order is draw order** — within a phase,
  globals first, then the active scene's layers in written order.
- `on enter` / `on exit` are lifecycle hooks (not phases).
- `become Name` runs the old scene's `on exit`, switches, runs the new `on enter`
  — two direct calls and a store, no dispatch table.

That's a good spine. The problem is it's specced as **sugar over a mode
register**: it tidies the syntax but adds little the register didn't already
have. The compiler knows *much* more at a scene boundary than a register does,
and this doc is about spending that knowledge.

---

## 2. Design principles

1. **The scene boundary is a compile-time fact — use it.** The set of handlers,
   layers, and owned state for each scene is known statically. Transitions should
   be direct calls and a single store, never a table walk. (The sketch already
   promises this; the extensions must preserve it.)
2. **Structure, not registers.** Anything you'd track with a hand-managed
   register alongside the mode — which entities belong to this state, which layers
   are drawn, what's paused — should be expressible *as* scene structure and
   enforced by the compiler.
3. **Reuse the machinery we already have.** Layers pausing, scenes tearing down
   their entities, and hooks firing are all expressible in terms of
   `enable`/`disable` (cheap flag flips), `despawn`, and the lifecycle-hook
   lowering. Scenes should *compose* those, not introduce a parallel runtime.
4. **One active-scene path stays hot; overlays are the exception, not the rule.**
   The common case (one full-screen scene at a time) must lower to the cheapest
   possible dispatch. Richer shapes (a pause menu over a frozen world) are opt-in
   and pay only for what they use.

---

## 3. Core model (firmed up from the sketch)

```ludic
# doc-check: skip — illustrative
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

Unchanged from the sketch, made precise:

- **Scenes number themselves by declaration order**, exactly like `machine`
  states — `Title` is `0`, `Overworld` is `1`. The active scene lives in one
  implicit register (`__scene`). This makes `scene` a `machine` the compiler
  writes for you, which is the right mental model and the right lowering.
- **A layer handler may not use phase `Start`.** `Start` runs once at boot,
  before any scene is entered; scene setup goes in `on enter`.
- **Global handlers still run every frame**, before any scene's layers, in every
  phase. A scene's layers run only while it is active.

Everything below is new.

---

## 4. Extension E1 — scene-owned entities (scoped lifetime)

The single biggest thing a mode register cannot do: **own the entities that only
make sense in this state, and tear them down automatically on exit.** Today a
battle scene spawns combatants in `on enter` and must remember to despawn every
one in `on exit` — miss one and it leaks into the overworld.

Proposal: entities spawned *by a scene's handlers or `on enter`* are tagged with
that scene, and `on exit` despawns them by default.

```ludic
# doc-check: skip
scene Battle {
  on enter { spawn Foe; spawn Foe; spawn Foe }   # tagged @Battle
  # on exit: implicit `despawn all @Battle` — no manual cleanup
  layer World { handler Fight phase Update { … } }
}
```

- Implemented as an implicit **scene tag** (a `{Battle}`-style kind bit) added at
  `spawn` time while a scene is active, plus a generated `despawn`-by-tag in the
  synthesized `on exit`. Reuses the existing tag-filter and despawn-hook
  machinery — no new runtime.
- **Opt out** for entities that should outlive the scene: `spawn Foe persist` (or
  spawn it from a global handler). Persisted entities keep their data across the
  transition, matching how `disable` keeps field data.
- Composes with `@OnDespawn(Model)`: the destructor hook fires for each
  scene-owned entity as it's torn down, so `drop_loot`-style cleanup still runs.

**Open:** does a re-`become Battle` get fresh entities (fresh tag generation) or
resume the old ones? Default: fresh. See §9.

---

## 5. Extension E2 — layers are more than draw order

The sketch uses layers only to order `Render`. Layers are the natural unit for
three more things, all built on the existing `enable`/`disable` flag flips:

1. **Per-layer toggle.** `disable Hud` / `enable Hud` flips one flag; the layer's
   handlers stop running and drawing. This is `disable Handler` generalized to a
   named group — same one-flag-flip cost.

2. **Pause vs. tear-down.** A layer can keep drawing while its *update* handlers
   are suspended:

   ```ludic
   # doc-check: skip
   scene Overworld {
     layer World { handler Move phase Update { … } handler Draw phase Render { … } }
     layer Hud   { handler DrawHud phase Render { … } }
   }
   ```

   When a pause menu opens over the Overworld (see E3), `World`'s `Update`
   handlers suspend but its `Render` handler still paints the frozen world behind
   the menu. Today that requires a `if !paused` guard in every update handler;
   with layers it's structural.

3. **Layer lifecycle hooks.** `on show` / `on hide` per layer, mirroring scene
   `on enter`/`on exit`, for the toggle points. (Naming TBD — could fold into the
   `@OnEnable`/`@OnDisable` annotations, which already exist for properties.)

---

## 6. Extension E3 — the scene *stack* (the headline)

The sketch says "exactly one scene is active." That's the right default and the
wrong constraint. The states a mode register handles *worst* are the ones that
**overlay without replacing**: a pause menu over live gameplay, a dialog box, an
inventory screen, a confirmation prompt. With one register you either lose the
underlying state or hand-roll a "previous mode" variable and restore it.

Proposal: keep "one *base* scene," but allow scenes to be **pushed as overlays**.

```ludic
# doc-check: skip
scene Overworld {
  layer World { handler Move phase Update { … } handler Draw phase Render { … } }
  layer Hud   { handler DrawHud phase Render { … } }

  on enter { … }
  handler PauseKey phase Input { if pressed(KEY_ESC) { push Pause } }
}

scene Pause overlay {          # `overlay` = pushed, not swapped
  on enter { dim_backdrop() }
  layer Menu {
    handler Nav phase Update {
      if pressed(KEY_ESC) { pop }          # back to Overworld, untouched
    }
    handler Draw phase Render { ui_render() }
  }
}
```

- `push Name` runs `Name`'s `on enter` and makes it the top scene **without**
  running the base scene's `on exit`. `pop` runs the overlay's `on exit` and
  returns to whatever was beneath.
- **Update belongs to the top of the stack; render walks the whole stack bottom
  to top.** So `Pause`'s `Menu` layer draws over `Overworld`'s frozen `World` and
  `Hud`. This is the default that makes pause menus "just work." An overlay that
  should let the layer beneath keep updating opts in with `push Name passthrough`.
- **The stack is a small fixed-capacity array of scene ids** (say 8) in a
  compiler-owned buffer — not heap, not a linked structure. `push`/`pop` are an
  index bump and an `on enter`/`on exit` call. Depth overflow is a compile-time
  or trap decision (§9).
- `become` still exists and still means "swap the base scene" (full `on exit` →
  `on enter`, stack cleared). `push`/`pop` are the overlay verbs. Keeping the two
  distinct is what lets the common single-scene path stay a single register.

This is the extension that turns `scene` from "nicer mode register" into
something with no clean equivalent in the register world.

---

## 7. Extension E4 — scene-local state

A scene almost always has state that exists only while it's active — a battle's
turn counter, a menu's cursor index. Today that's a global register that other
scenes could stomp. Proposal: **`var` / `const` declared inside a `scene` is
scoped to it**, storage shared across scenes that are never simultaneously active
(the compiler can overlap their storage since only one base scene runs at a
time — an arena-per-scene, or a union).

```ludic
# doc-check: skip
scene Battle {
  var turn = 0                  # visible only inside Battle; reset by `on enter` if desired
  layer World { handler Step phase Update { turn += 1 } }
}
```

- Reads/writes lower to a fixed offset in the scene's state block, no register
  indirection.
- Overlay scenes (E3) that *can* be live simultaneously with their base cannot
  share storage — the compiler keeps their blocks distinct. Base scenes that
  never coexist share.

---

## 8. Extension E5 — parameterized transitions, and the reserved annotations

**Parameters on transitions.** `become`/`push` can carry arguments that the
target's `on enter` binds — so a battle knows which foes, a dialog knows which
line:

```ludic
# doc-check: skip
scene Battle {
  on enter (foe_kind: int, count: int) { for i in 0 .. count { spawn_foe(foe_kind) } }
}
# elsewhere:
become Battle(FOE_GOBLIN, 3)
```

Lowers to argument stores into the scene's state block (E4) immediately before
the `on enter` call. No variadic runtime; the arity is checked at compile time.

**The already-reserved annotation form.** [LANGUAGE.md:374](LANGUAGE.md:374)
reserves `@OnEnter` / `@OnExit` as handler annotations "waiting on scene support."
This doc adopts them as the annotation spelling of `on enter` / `on exit`,
mirroring how `@OnStart` is the annotation form of `phase Start`:

```ludic
# doc-check: skip
@OnEnter(Battle) handler Setup { … }     # == Battle's `on enter`
@OnExit(Battle)  handler Teardown { … }
```

Both spellings desugar to the same synthesized scene-lifecycle function; a scene
may use either, not both, for a given hook.

**`reads`/`writes` + scenes (forward-looking).** The `reads`/`writes` clauses are
parsed but unconsumed ([LANGUAGE.md:717](LANGUAGE.md:717)). Once an analysis pass
exists, a scene's layers declare which state they touch, and the scheduler can run
independent layers of the active scene in parallel within a phase — the scene
boundary gives the pass a natural scope to reason about. Noted as a destination,
not part of the first cut.

---

## 9. Lowering summary

Everything above reduces to existing runtime concepts:

| Construct | Lowers to |
|---|---|
| active base scene | one implicit register `__scene`, states numbered by decl order — literally a compiler-written `machine` |
| `become Name` | `on exit` call · `set __scene` · `on enter` call (two direct calls + store, as the sketch promises) |
| scene layers in a phase | the phase scheduler, after global handlers, dispatches on `__scene` to that scene's layer handlers in declaration order |
| `push`/`pop` (E3) | fixed-capacity scene-id array + index; render walks it, update reads its top |
| scene-owned entities (E1) | implicit kind tag at `spawn`; generated `despawn`-by-tag in synthesized `on exit`; reuses despawn hooks |
| layer toggle / pause (E2) | the same one-flag-flip as `disable Handler`, keyed per layer |
| scene-local `var` (E4) | fixed offsets in a per-scene state block; non-coexisting scenes share storage |
| transition args (E5) | arg stores into the state block before the `on enter` call |
| `@OnEnter`/`@OnExit` (E5) | the same synthesized lifecycle functions as `on enter`/`on exit` |

No heap, no dispatch tables, no new allocator. The active-scene path is a
register read and a static branch; the stack adds a small array only for programs
that push overlays.

---

## 10. Suggested implementation phases

Each is independently shippable and testable, matching how the repo phases work.

- **S0 — parse & lower the sketch.** ✅ **Done.** `scene`/`layer`/`on enter`/`on
  exit`/`become` lowered to the implicit `machine`; the active scene is
  snapshotted per phase so exactly one scene's layers dispatch in any phase.
  [`examples/scenes.ludic`](examples/scenes.ludic) compiles, runs, and is checked
  by `test.sh`. This is the floor everything else builds on.
- **S1 — `@OnEnter`/`@OnExit` annotation form** (E5, cheap once S0 exists).
- **S2 — layer toggle & pause** (E2) on top of the existing `enable`/`disable`.
  ✅ *Toggle shipped* (via EVENTS-DESIGN EV1 layers): `enable layer L` / `disable
  layer L` flips an `@LE_<L>` flag that gates the layer's handlers (emitted only
  for toggled layers, so untouched scene programs stay byte-identical), and a
  `public` layer fires `layer_<L>_show`/`_hide` — see
  [`examples/layer_events.ludic`](examples/layer_events.ludic). Still open: the
  *pause* half (keep drawing while `Update` handlers suspend) and `on show`/`on
  hide` blocks.
- **S3 — the scene stack** (E3): `push`/`pop`/`overlay`/`passthrough`. The big one.
- **S4 — scene-owned entities** (E1) and **scene-local state** (E4).
- **S5 — transition parameters** (E5).
- **S6 (later) — `reads`/`writes` scheduling** (E5), gated on the analysis pass.

S0–S1 deliver the sketch as promised; S2–S3 are where the "great potential"
actually lands; S4–S5 are ergonomics; S6 is a performance destination.

---

## 11. Open decisions

1. **Re-entering a scene:** fresh entities/state, or resume? (Default proposed:
   `become` = fresh, `push`/`pop` = the pushed scene is fresh each push, the base
   underneath is untouched.)
2. **Stack depth:** compile-time cap with an error on overflow, or a runtime trap?
   What capacity (8? configurable)?
3. **`passthrough` granularity:** does a passthrough overlay let *all* lower
   layers update, or can it name which phases fall through?
4. **Layer hook naming:** `on show`/`on hide`, or reuse `@OnEnable`/`@OnDisable`?
5. **Scene-local storage sharing:** union non-coexisting scenes automatically, or
   require an explicit opt-in so the sharing is visible in source?
6. **Global handlers and overlays:** do globals run once per frame regardless of
   stack depth (proposed: yes), or per active scene?
7. **`become` from inside an overlay:** does it clear the stack (proposed: yes) or
   is it an error while overlays are pushed?

---

*Companion to [LANGUAGE.md §"Scenes & layers"](LANGUAGE.md) and the ordering
sketch in [`examples/scenes.ludic`](examples/scenes.ludic). Supersedes nothing
until the compiler work in §10 lands.*
