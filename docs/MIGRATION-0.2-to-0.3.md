# Migrating from Ludic 0.2 to 0.3

This guide covers everything that changed between **v0.2.0** and **v0.3.0** and how
to adopt it. It is organised as:

1. [TL;DR](#tldr) — is anything going to break?
2. [Behaviour changes to be aware of](#behaviour-changes) — the handful of things
   that behave differently, even though your code still compiles.
3. [Deprecations](#deprecations)
4. [New subsystems](#new-subsystems) — packages, controllers, Tiled maps.
5. [New engine & language features and how to adopt them](#new-features)
6. [External projects & packaging](#external-projects)
7. [Full change index](#change-index)

---

<a name="tldr"></a>
## 1. TL;DR — is anything going to break?

**No source changes are required. v0.2 programs compile unchanged on v0.3.**

Every addition in this release is additive and feature-gated: a program that does
not use a new feature compiles to byte-for-byte identical output, the golden
renders are unchanged, and the C-free bootstrap fixpoint is untouched. There are
**no removed APIs** and **no changed function signatures**.

There are, however, a few **runtime behaviour changes** (windowed input, and how
the frame loop drives input) and **one deprecation** (bare `draw_sprite`) that are
worth a five-minute read before you upgrade. They are covered next.

Upgrade steps:

```
# rebuild the toolchain from the new sources
bin/x build
# (optional) confirm everything still passes
bin/x test
# check the version
bin/x version        # -> ludic 0.3.0
```

---

<a name="behaviour-changes"></a>
## 2. Behaviour changes to be aware of

These compile without changes but *behave* differently. Most are improvements you
can lean into; a couple deserve a deliberate look.

### 2.1 Windowed games no longer quit on Esc or 'q'  (#88)

In 0.2 the macOS window layer hard-coded **Escape** and the character **'q'** as
*quit* — handy in the dev loop, fatal in a shipped game (a player pressing Esc to
pause, or typing 'q', killed the window).

In 0.3:

- **Escape** is delivered to your game as **key 27** (read it and do your own
  pause), and **'q'** is an ordinary key.
- A windowed game shuts down via `quit()` or the **window close button** (which
  still ends the run).
- The **headless** driver is unchanged: `'q'` still quits scripted / golden runs.

**Action:** if your dev loop relied on pressing Esc/'q' to close the window, use
**Cmd-Q** or the close button instead, or wire `if Input.key(...) == 27 { quit() }`
yourself. If you already handle Esc for a pause menu, it now works (it used to be
swallowed as a quit).

### 2.2 The frame loop now drives input automatically  (#83, #87)

In 0.2, a windowed **handler game** had to call `Input.poll()` at the top of its
Input phase for the multi-key device layer (`Input.key_down`, the mouse, gamepads)
to update — otherwise those read empty.

In 0.3 the generated frame loop commits the device layer itself once per frame (it
calls the input driver before your Input handlers). So:

- `Input.key_down` / `Input.mouse_*` / `Input.pad_*` / the new `Input.active` all
  read live **without** a manual `Input.poll()`.
- A manual `Input.poll()` you still have in a handler is now **redundant** — and,
  as of the edge-detection fix (#87), it is a **no-op under the loop** rather than
  a second commit, so it no longer breaks `Input.key_pressed` / `key_released`
  edges. You can delete it.
- **Entry-driven** programs (a `program … { entry { … } }` test harness that calls
  `Input.poll()` to step input by hand) are **unchanged** — there is no frame loop,
  so each `Input.poll()` still advances one frame of input exactly as before.

**Action:** in a handler game, remove any `Input.poll()` you were calling by hand;
it is done for you. Nothing breaks if you leave it.

Before (0.2):

```
handler Move phase Input {
  Input.poll()                       # required in 0.2
  if Input.key_down('d') { ... }
}
```

After (0.3):

```
handler Move phase Input {
  if Input.key_down('d') { ... }     # the loop already committed input
}
```

### 2.3 `Input.key_pressed` / `key_released` now actually fire  (#87)

If you had worked around edge detection never triggering (a game-side "previous
state" flag), you can drop the workaround — `Input.key_pressed` and
`Input.key_released` now fire on the transition frame. See §2.2 for the cause (a
double-commit when a game manually polled under the loop).

---

<a name="deprecations"></a>
## 3. Deprecations

### 3.1 Bare `draw_sprite` / `draw_sprite_scaled`  (#85)

The bare global sprite calls are deprecated in favour of the namespaced
`Screen.sprite` / `Screen.sprite_scaled`. A direct bare call now prints a one-time
compile-time note; the bare form still compiles (`Screen.sprite` lowers to it), so
this is a warning, not an error.

```
# 0.2 (deprecated in 0.3, still compiles with a note)
draw_sprite(id, x, y)
draw_sprite_scaled(id, x, y, 2)

# 0.3
Screen.sprite(id, x, y)
Screen.sprite_scaled(id, x, y, 2)
```

**Action:** replace bare `draw_sprite` / `draw_sprite_scaled` with the `Screen.*`
form. Or, better, adopt the engine sprite-render system (§5.6) and stop calling
draw per entity at all.

---

<a name="new-subsystems"></a>
## 4. New subsystems

These are the large additions in 0.3. They are opt-in — you reach for them, they
do not change existing programs.

### 4.1 Package manager  (#62, #63, #64)

Ludic gains a real package manager with no new infrastructure: dependencies are
named by their git import path (URL-as-identity — a `git tag vX.Y.Z` publishes,
there is no registry), resolved by Go-style Minimum Version Selection, fetched into
a content-addressed global store (`~/.ludic/store`), and linked per project under
`ludic_modules/`.

```
x add example.com/you/pkg          # add a dependency (latest tag)
x add example.com/you/pkg@1.2.0    # a specific version
x get                                       # resolve + fetch + link everything
x update [module]                           # bump to the latest published version
x verify                                    # rehash the store against the lock
x vendor                                    # copy deps into ./vendor for offline builds
```

A `package.ludic` manifest declares the deps, the `Foo.*` namespace(s) the package
provides, and its kind; `package.lock.ludic` pins resolved versions + content
hashes for reproducible builds. A **source** package's Ludic compiles straight into
your binary (no ABI seam); a **prebuilt** package ships a native dylib whose
functions/systems/components you use over the reflection C-ABI (`x build-lib`,
`x link-flags`). Packages register namespaces and engine systems with **no compiler
edit**, via the `@Namespace(Name)` and `@EngineSystem(Component, Phase)`
annotations. Full details in [docs/PACKAGES.md](PACKAGES.md).

### 4.2 Gameplay controllers  (#57–#61)

Five source packages ship complete, extensible gameplay systems built on the
engine's `Body`/`Collider` + `esys_move` and on a six-lever extensibility contract
(see [docs/CONTROLLERS.md](CONTROLLERS.md)):

| Package | What it gives you |
| --- | --- |
| **ludic.gameplay** | `Cooldown` timer, `Stats` + a timed modifier stack, a `Faction` table, and a `Combat` damage pipeline (cancellable + mutable amount). |
| **ludic.platformer** | Jump-feel `Platformer` (apex/coyote/buffer/variable-height/multi-jump), decomposed sub-systems, jump/land/state events, opt-in scaffolding (moving platforms, pickups, springs, hazards, checkpoints). |
| **ludic.shooter** | `TopDown` decoupled move + aim, a name-keyed `Weapon` registry, a deterministic `Projectile` pool (faction hits, pierce, ring/spiral, homing), a wave `Spawner`. |
| **ludic.npcai** | Perception → decision (FSM / utility / behaviour tree) → action, writing the *same intent fields the player controllers read*, plus flocking and a `Follower`. |
| **ludic.rpg** | Seven modules: grid/free/tween movement, inventory + equipment, crafting, quests + flags, an Ink/Yarn dialog graph, Sokoban + a signal graph, and status effects. |

Adopt one by importing it (in-repo the packages live under `packages/`; in a real
project `x add` them):

```
program MyGame {
  import "ludic.platformer/platformer.ludic"
  model Hero { Platformer, Position, Body, Collider }
  # ... the engine runs the controller's sub-systems for you
}
```

### 4.3 Tiled map support  (#66–#74)

Load and draw [Tiled](https://www.mapeditor.org/) maps — both XML (TMX/TSX/TX) and
JSON (TMJ/TSJ/TJ) — via a new `Tiled.*` runtime, standing on a pure-Ludic `Xml.*`
reader, `Base64.*`, gzip framing, and a self-contained pure-Ludic **zstd**
decompressor for base64+zstd layers.

```
let map = Tiled.load("assets/level.tmx")   # reads .tmx or .tmj, resolves tilesets + images
handler Draw phase Render {
  Tiled.draw_anim(map, cam_x, cam_y)        # animated tiles advance off the fixed frame clock
}
```

It covers layers (tile / image / group / object), all object shapes + custom
properties, templates, animated tiles, isometric/staggered/hexagonal orientations,
infinite/chunked maps and `.world` stitching, and projects a collision layer that
`esys_move` / `Grid.*` / `Path.*` read. Deterministic (animations are a pure
function of the 60/s frame clock).

---

<a name="new-features"></a>
## 5. New engine & language features and how to adopt them

### 5.1 Canonical components from `ludic.core`  (#77, #84, #85)

The engine-ABI components the movement / sprite / bounds systems read by name are
now shipped from a base package — import them instead of hand-declaring the
bundles in every game.

Before (0.2 — every game re-declared these):

```
property Position { x: int = 0, y: int = 0 }
property Body { vx: fixed = 0.0, vy: fixed = 0.0, gravity: fixed = 0.0, /* … */ }
property Collider { w: int = 0, h: int = 0, /* … */ }
```

After (0.3):

```
import "ludic.core/components.ludic"     # Position, Body, Collider, Solids, Sprite, Bounds
```

Extend by composition — attach your own components alongside on the same model.

### 5.2 Declarative Render: `@ClearColor`  (#86)

Drop the `Screen.clear(...)` / `Screen.show()` boilerplate: annotate a clear colour
and the Render phase clears to it and presents for you.

```
@ClearColor(0x101018)
handler Draw phase Render {
  # no Screen.clear, no Screen.show — the engine does both
  Screen.fill_rectangle(10, 10, 4, 4, 0xffcc00)
}
```

Opt-in: a program with no `@ClearColor` is byte-identical (it clears/presents
itself, or the light system owns the present).

### 5.3 Input Manager + ergonomic input  (#79, #83)

- **Default, rebindable, device-agnostic actions:**
  `Input.action(name, key)` ships a default binding (kept if already bound, so a
  player's `Input.rebind` or a loaded key-map isn't clobbered);
  `Input.bind_pad(name, button)` makes an action fire from keyboard *or* gamepad.
- **Held + edges over the whole device layer:** `Input.active(name)`,
  `Input.just_pressed(name)`, `Input.just_released(name)` — the deterministic,
  dispatch-free on-press / on-release (poll the edge; a replay fires it identically).
- **Directional intent without glue:** `Input.axis_i(neg, pos) -> int` returns a
  -1/0/1 movement intent, replacing the `ki(key_down('d')) - ki(key_down('a'))`
  boilerplate.

```
@OnStart handler Boot {
  Input.action("jump", ' ')
  Input.bind_pad("jump", 0)
}
handler Move phase Update {
  let dx = Input.axis_i('a', 'd')
  let dy = Input.axis_i('w', 's')
  if Input.just_pressed("jump") { ... }
}
```

### 5.4 `Camera.zoom`  (#78)

A deterministic Q16.16 render-time zoom about the screen centre, composing with
`Camera.set`/`follow`/`shake`:

```
Camera.zoom(2.0)     # 2x in;  1.0 = none (turns the zoom path back off);  0.5 = out
```

The world coordinate types stay integer px + Q16.16 velocity (hardware floats were
rejected to preserve lockstep/replay/save — see
[docs/RFC-POSITION-TYPES.md](RFC-POSITION-TYPES.md)). Byte-identical when unused.

### 5.5 Spritesheet / atlas API + async preload  (#81, #82)

Load one sheet and address cells by grid coords or name — including sprites that
span more than one cell — instead of one `png_load` per file:

```
let sheet = Sprite.sheet("assets/tiles.png", 16, 16)
let floor = Sprite.cell(sheet, 0, 0)
let boss  = Sprite.cell_span(sheet, 4, 2, 2, 2)   # a 32x32 sprite spanning 2x2 cells
Sprite.define("hero", sheet, 1, 3)                # name a cell
# ... later
Sprite.draw(Sprite.named("hero"), x, y)           # through camera / zoom / clip
```

And preload incrementally so the first frame doesn't stall — the loading-scene
pattern:

```
Assets.enqueue("hero", "assets/hero.png")
# in a loading scene, each frame:
Assets.pump(4)                                    # load up to 4 this frame
# draw Assets.progress() (0..100) as a bar; become the play scene when Assets.ready()
```

### 5.6 Engine sprite-render system  (#85)

The engine already auto-*ticks* SpriteAnim/Motion; it now auto-*draws* too. Declare
a `Sprite` component (from `ludic.core`) and the engine draws it each Render frame
from the entity's `Position` — no hand-written Render handler:

```
import "ludic.core/components.ludic"
spawn Player { Position { x: 40, y: 40 }, Sprite { id: hero } }
# ... no per-entity draw_sprite; the engine draws Sprite entities (adds the
#     SpriteAnim frame when present). Opt out by omitting Sprite / `disable system esys_sprite`.
```

### 5.7 World bounds  (#84)

Keep entities in a play area without hand-clamping `Position` — declare one
`Bounds` config entity:

```
import "ludic.core/components.ludic"
spawn Arena { Bounds { x: 0, y: 0, w: 320, h: 240, policy: 0 } }
# policy 0 clamp, 1 wrap, 2 bounce (flip velocity), 3 kill (despawn when fully outside)
```

Runs in LateUpdate (after movement). Off by default (no `Bounds` = open world). Also
adds `World.despawn(entity)` — the by-id reflective form of the `despawn` statement.

### 5.8 Entity-pool stats  (#80)

The ECS already recycles freed entity slots through a freelist (spawn/despawn does
no per-spawn allocation and cannot fragment). `Pool.*` exposes the counters:

```
Pool.live()       # entities alive now
Pool.free()       # freed slots waiting to be reused
Pool.reserved()   # high-water — flat across a steady spawn/despawn loop (proves reuse)
Pool.capacity()   # the fixed entity cap
```

### 5.9 `namespace` block form  (#76)

Declare a namespace once and control its public surface, instead of the
per-function `@Namespace(Name)`:

```
namespace Combat {
  export function amount() -> int { return base() + 5 }   # callable as Combat.amount()
  internal function base() -> int { return 10 }           # private helper (Combat.base() is a compile error)
}
```

`export` (the default) is the public surface; `internal` is a private helper
(emitted, callable by short name from siblings, but not part of `Name.*`). It is
sugar for `@Namespace`, so namespaces declared the old way are unchanged.

### 5.10 Cursor capture  (#89)

A windowed action game can hide/lock/confine the OS cursor:

```
Input.cursor_mode(2)   # 0 normal, 1 hidden, 2 locked (relative aim), 3 confined
```

Mode 2 (locked) hides the cursor and feeds relative motion through
`Input.mouse_dx/dy` with `Input.mouse_x/y` as a clamped virtual cursor. Auto-releases
on focus loss (Cmd-Tab) and on close. No-op headless.

---

<a name="external-projects"></a>
## 6. External projects & packaging

### 6.1 The engine runtime ships with the toolchain now  (#75)

In 0.2, an external game that consumed the `ludic.*` packages had to copy or
symlink the engine runtime (`runtime/native/*`) into its `ludic_modules/`, because
the compiler resolved the auto-spliced runtime through the module root.

In 0.3 the compiler resolves a `runtime/…` import it can't find locally from
**`$LUDIC_HOME`** (the toolchain install — where `cocoa.ll` already comes from),
*before* the module root. So:

- **Remove** any copy/symlink of `runtime/` from your project's `ludic_modules/`.
- **Set `LUDIC_HOME`** to the toolchain install (the repo root, or wherever `bin/`
  and `runtime/` live) when you build. `ludic_modules/` now holds only third-party
  packages.

In-repo builds are unaffected (the runtime resolves locally there).

### 6.2 Building against packages

Use `x add` to fetch packages, then `x get`. For an in-repo build against
`packages/`, point `LUDIC_MODULES` at it and `LUDIC_HOME` at the toolchain, e.g.:

```
LUDIC_HOME=/path/to/ludic LUDIC_MODULES=/path/to/ludic/packages \
  ludicc mygame.ludic -o mygame
```

Prebuilt (dylib) packages link via `x link-flags` (or `x app` in-repo).

---

<a name="change-index"></a>
## 7. Full change index

Everything in v0.3.0, by area. See `CHANGELOG.md` for the per-change detail.

**Packaging** — package manager (#63), prebuilt binary packages (#64),
package-declarable `@Namespace` / `@EngineSystem` registries (#62).

**Controllers** — ludic.gameplay (#57), ludic.platformer (#58), ludic.shooter
(#60), ludic.npcai (#61), ludic.rpg (#59).

**Tiled maps** — the full TMX/TSX/TMJ pipeline (#66–#74): XML/base64/gzip/zstd
primitives, readers, render, collision, animated tiles, objects/properties/
templates/spawning, image/group layers, iso/stagger/hex, infinite maps + worlds.

**Engine & rendering** — `Camera.zoom` (#78), `@ClearColor` auto-clear/present
(#86), the engine sprite-render system + `draw_sprite` deprecation (#85), world
bounds + `World.despawn` (#84), entity-pool stats (#80), the spritesheet/atlas API
(#81), async asset preload (#82), canonical `ludic.core` components (#77).

**Input** — the Input Manager + automatic device-layer drive (#83),
`Input.axis_i` (#79), the `key_pressed`/`key_released` edge fix (#87), cursor
capture (#89), and the windowed quit-key change (#88).

**Language** — the `namespace` block form (#76).

**Compiler / toolchain** — runtime resolves from `$LUDIC_HOME` (#75), and the
`emit_index_addr` element-type fix for `slice[obj.field]`.

---

*Questions or a migration snag? Open an issue at
<https://git.workshopsoft.io/workshopsoft/ludic/issues>.*
