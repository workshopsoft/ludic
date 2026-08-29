# iOS & Android — a design doc

> **Status: all design, nothing shipped.** Ludic builds windowed on macOS
> (`runtime/native/cocoa.ll`) and has a documented — but currently un-reimplemented
> — wasm32 web target. iOS and Android are not buildable today, and the
> cross-compile plumbing that would target them died with the C driver. This doc
> lays out the whole path so we can decide the shape before building any of it. The
> headline decision (§7): render on the **GPU via `extern fn` FFI**, not the CPU
> framebuffer. §11 lists the open decisions.

---

## 1. Where we are

A Ludic program compiles to LLVM IR, then clang assembles and links it. The
platform story has **two independent axes**, and it's essential not to conflate
them:

| Axis | What it is | State today |
|---|---|---|
| **Target** (triple + toolchain) | how IR becomes a runnable binary for an OS/arch | barely plumbed — no `--target`, no emitted `target triple`, host-only |
| **Platform runtime** (window/input/present) | one file implementing the 5-function window protocol | well-factored — `cocoa.ll` is ~328 lines, swappable |

**What exists:**

- The window seam is exactly five functions — `win_open` / `win_poll` /
  `win_present` / `win_running` / `win_close` — declared by the compiler
  ([emit_head.ludic:58](selfhost/emit_head.ludic:58)) and lowered as intrinsics
  ([emit_intrin2.ludic:39](selfhost/emit_intrin2.ludic:39)). The runtime calls them
  through `rt_*` wrappers ([core.ludic:48](runtime/native/core.ludic:48),
  [:103](runtime/native/core.ludic:103), [:217](runtime/native/core.ludic:217)).
  `COMPILING.md` states the intent plainly: a new platform is "another `.ll` file
  with the same five entry points and no compiler change."
- **`extern fn` FFI is real and live** — `extern function c_hypot(a: fixed, b: fixed) ->
  fixed = "hypot_fx"` ([LANGUAGE.md:565](LANGUAGE.md:565)), with a full pipeline:
  parse ([parse_game.ludic:236](selfhost/parse_game.ludic:236)) → call lowering to a
  direct `call @<sym>` ([emit_expr.ludic:168](selfhost/emit_expr.ludic:168)) →
  `declare` emission ([emit_head.ludic:105](selfhost/emit_head.ludic:105)). Working
  examples: [examples/net_echo.ludic:12](examples/net_echo.ludic:12),
  [examples/lib/arena.ludic:14](examples/lib/arena.ludic:14). This is the single
  most important fact in this document — see §7.

**What's missing (all of it must be built):**

| Gap | Why mobile needs it |
|---|---|
| `--target <triple>` flag + emitted `target triple`/`datalayout` | iOS = `aarch64-apple-ios`, Android = `aarch64-linux-android`; both are cross-compiles |
| per-target `size_t` width (i32/i64) | already a known wasm trap; every allocation sizing depends on it |
| **OS-owned frame loop** (`ludic_boot`/`ludic_frame`/`ludic_alive`/`ludic_teardown`) | iOS (CADisplayLink) and Android (Choreographer) own the loop — you cannot `while(alive)` |
| per-platform window shim + touch input | UIKit/`CAMetalLayer`, Android `Surface`/NDK; input is touch, not a keycode |
| SDK sysroot + packaging + signing | `.app` bundle / `.apk`, not a bare executable |

The frame-loop gap is shared with the web target — `tools/ludic-web/run.mjs`
already expects `ludic_boot`/`ludic_frame`, but the self-hosted emitter only
produces a monolithic `@main` ([emit_game.ludic:685](selfhost/emit_game.ludic:685)).
So the wasm path is half-broken for the same reason mobile can't exist yet.

---

## 2. Design principles

1. **Two axes, kept separate.** "Add a platform" = a cross-compile *target* plus a
   platform *runtime*. Muddling them is why this looks bigger than it is. Most of
   the compiler work (§4, §5) is target plumbing that serves web, iOS, and Android
   at once; the per-OS work (§6) is genuinely small by design.
2. **The OS owns the loop — so we must too.** Mobile, like the browser, forbids an
   inline frame loop. Rather than special-case mobile, adopt the frame-driven model
   *everywhere* the OS demands it, from one emitter change. This is the keystone.
3. **The GPU is an ABI to call, not a program to compile.** `extern fn` already
   binds C libraries; bind GL ES / Metal the same way. No IR-per-API (the `cocoa.ll`
   route — 328 lines for *five* functions), no per-symbol intrinsics. The roadmap
   reaches this conclusion independently ([LUANTI-ROADMAP.md:1083](LUANTI-ROADMAP.md:1083),
   [:1375](LUANTI-ROADMAP.md:1375)).
4. **The 2D stack stays byte-identical.** The framebuffer graphics
   (`rt_fb` + all `rt_*`/`image`/`truetype`/`ui` primitives) keep working
   unchanged. GPU rendering is *additive*: 2D composites as one texture on top of
   GPU 3D. Nothing above the window seam is rewritten.

---

## 3. Core model

Everything below reduces to plumbing one new flag through the compiler and swapping
two runtime files per OS. The mental model:

```
ludicc app.ludic --target aarch64-apple-ios -o app
       │
       ├─ emit_head:  target triple / datalayout / size_t width   (§4)
       ├─ emit_game:  ludic_boot/frame/alive/teardown  not @main   (§5)
       ├─ link:       runtime/ios/uikit.ll  + gfx3d.ldylib         (§6, §7)
       └─ package:    .app bundle + codesign                       (§8)
```

The game source and the entire ECS/graphics/UI stack compile **unchanged** for
every target. Only the head declarations, the entry-point shape, the linked
platform file, and the packaging step vary.

---

## 4. Extension M1 — the target axis: `--target`, triple, `size_t`

Today [main.ludic:66](selfhost/main.ludic:66) parses `--windowed`/`--headless`/
`--emit-llvm`/… and nothing selects an arch; the IR carries no `target triple`, so
native inherits clang's host default and the only explicit triple in the tree is
`wasm32-unknown-unknown` ([runtime/web/wasm.ll:23](runtime/web/wasm.ll:23)).

Proposal: a `--target <triple>` flag that drives three things.

```
ludicc app.ludic --target aarch64-apple-ios          -o app
ludicc app.ludic --target aarch64-apple-ios-simulator -o app   # x86_64 host → arm64 sim varies
ludicc app.ludic --target aarch64-linux-android       -o libapp.so
```

- **Emit the triple + datalayout.** `emit_header`
  ([emit_head.ludic:37](selfhost/emit_head.ludic:37)) gains a `target triple = …`
  / `target datalayout = …` line, chosen from a small table keyed on `--target`.
  Absent the flag, emit nothing (host default) — keeps existing native builds
  byte-identical.
- **Per-target `size_t` width.** wasm32 already needs `i32` sizes; the same helper
  discipline (`ll_size_t`/`ll_widen`/`ll_narrow`, per the web-backend notes) applies
  to any 32-bit target. iOS/Android arm64 are LP64 like macOS, so `i64` — but the
  flag must *select* the width, not assume the host's.
- **Toolchain construction.** The linker command
  ([main.ludic:130](selfhost/main.ludic:130)) becomes target-conditional: an SDK
  sysroot (`-isysroot`/`--sysroot`), the platform `.ll`, and target-specific link
  flags (§8). `$LUDIC_CC` still overrides; add `$LUDIC_SYSROOT_<target>` for the
  SDK path so CI and local machines can differ.

This axis is **shared with reviving wasm** — do it once, three targets benefit.

---

## 5. Extension M2 — the OS-owned frame loop (the keystone)

A native build emits `@main` with the frame loop inline — an `rt_init`, then a
`loop:`/`done:` block calling `rt_poll`/`rt_running`
([emit_game.ludic:685](selfhost/emit_game.ludic:685)). **iOS and Android cannot run
this.** UIKit calls back into your code once per display refresh (CADisplayLink);
Android's Choreographer does the same; the browser's `requestAnimationFrame` already
does. In all three the OS owns the loop and calls *you*.

Proposal: emit four exported functions instead of an inline-loop `@main`, exactly
as `COMPILING.md` already describes and `run.mjs` already expects:

```
ludic_boot()      →  rt_init            (once)
ludic_frame()     →  rt_poll · systems · rt_present   (per OS callback)
ludic_alive() → i1 →  rt_running                       (OS asks: keep going?)
ludic_teardown()  →  rt_shutdown        (once)
```

- **`@main` becomes the composed default, not the only shape.** For host desktop
  and headless, the compiler synthesizes an `@main` that *calls* the four in an
  inline loop — so native/headless output is unchanged in behavior. For
  OS-owned-loop targets (`--target` is wasm/ios/android, or a new
  `--loop=external` mode), emit only the four exports and no driving `@main`.
- **One emitter change, three targets fixed.** This simultaneously un-breaks the
  web target (whose runner already calls these) and unlocks both mobile OSes. It is
  the highest-leverage change in this doc.
- **State stays where it is.** The four functions close over the same globals
  `rt_init`/`rt_poll`/`rt_running`/`rt_shutdown` already touch
  ([core.ludic:48](runtime/native/core.ludic:48)); no new runtime state, no heap.

---

## 6. Extension M3 — the per-OS window shim + touch input

Each OS gets one platform file implementing the five-function seam, modeled on
`cocoa.ll` but rewritten for its UI toolkit. This is the part the codebase is
explicitly built for.

- **iOS — `runtime/ios/uikit.ll` (or a thin `.m` shim).** `win_open` creates a
  `UIWindow` + a `UIViewController` whose view is a `CAMetalLayer`/`MTKView`;
  `win_present` presents the current drawable; the loop is driven by M2's
  `ludic_frame` from a `CADisplayLink`, so `win_poll`/`win_running` adapt to the
  callback model rather than a spin. Hand-written IR against `objc_msgSend` is
  possible (it's how `cocoa.ll` works) but a small compiled `.m` linked in is more
  maintainable for UIKit's larger surface — an open decision (§11).
- **Android — `runtime/android/ndk.ll` + a Kotlin/Java `Activity` host.** The
  native code is a `.so` loaded by an `Activity`; the window is an
  `ANativeWindow`/`Surface` obtained via `GameActivity`/NDK, GPU via EGL + GL ES.
  Frames are driven by Choreographer through JNI into `ludic_frame`.
- **Touch input changes the input seam.** `win_poll()` returns a single `int`
  keycode today ([emit_intrin2.ludic:41](selfhost/emit_intrin2.ludic:41),
  [core.ludic:217](runtime/native/core.ludic:217)) — insufficient for touch, which
  needs `(x, y, phase, id)`. Options: (a) a parallel `win_poll_touch() -> ptr`
  draining an event queue, or (b) widen the input model to a small event struct for
  all platforms. This is the one place mobile forces a decision above the window
  seam. Proposed: add touch as a **separate** seam so keyboard platforms stay
  untouched and byte-identical.

Everything above the seam — framebuffer, PNG sprites, TrueType, retained UI — is
portable Ludic and compiles unchanged.

---

## 7. Extension M4 — GPU rendering via `extern fn` (the headline)

Today **all** drawing writes into one CPU framebuffer: `rt_fb`, a
`words(320*240)` buffer of `0x00RRGGBB` i32 pixels
([core.ludic:23](runtime/native/core.ludic:23)), written by every primitive
(`rt_clear`/`rt_fill_rect`/glyphs/`rt_blend_px`/`tt_blit`/UI) and handed whole to
`win_present`. `cocoa.ll` blits it through CoreGraphics —
`CGBitmapContextCreate`→`CGImage`→`CGContextDrawImage` inside `@ludic_drawRect`
([cocoa.ll:94](runtime/native/cocoa.ll:94)). There is no GPU context anywhere.

Because **`extern fn` already exists**, binding the GPU is ordinary runtime code —
no new language feature, no new intrinsic:

```ludic
# doc-check: skip — runtime/native/gfx3d.ludic, illustrative
extern function gl_gen_textures(n: int, out: ptr) -> void      = "glGenTextures"
extern function gl_tex_image_2d(t: int, w: int, h: int, px: ptr) -> void = "gl_tex_image_2d"
extern function gl_draw_elements(mode: int, count: int, ty: int, idx: ptr) -> void = "glDrawElements"
```

Two phases, additive:

1. **Framebuffer-as-texture (drop-in).** Keep the entire 2D stack. `rt_present`
   ([core.ludic:103](runtime/native/core.ludic:103)) uploads `rt_fb` as one texture
   and draws a full-screen quad. The `win_present(fb,w,h)` signature is unchanged;
   only the pixel-delivery core of the platform file differs (texture upload instead
   of CoreGraphics blit). This is the minimum viable GPU path and gets mobile on
   screen with zero changes above the seam.
2. **True GPU 3D (additive).** Geometry goes straight to GL/Metal via `gfx3d.ludic`
   `extern fn` calls; the CPU framebuffer is reused only for the 2D UI overlay,
   composited as a texture on top. New GPU-draw entry points live in `gfx3d.ludic`
   as `extern fn`s — the five-function window protocol does **not** widen.

Language-level cost is narrow and already scoped by the roadmap:

- **`f32`** (roadmap gate G-04) for vertex/matrix data — the *only* hard language
  dependency ([LUANTI-ROADMAP.md:1087](LUANTI-ROADMAP.md:1087)).
- Optional vector operator overloading for `v3f`/`m4` ergonomics (G-29,
  [:1107](LUANTI-ROADMAP.md:1107)) — a "nicer, not necessary."

The roadmap's own decision is explicit: FFI over IR-per-API, because "`cocoa.ll`
is 327 lines for *five* window functions — OpenGL has hundreds of entry points"
([LUANTI-ROADMAP.md:1375](LUANTI-ROADMAP.md:1375)).

---

## 8. Extension M5 — packaging, SDKs, and signing

The current driver is one `clang` call ([main.ludic:130](selfhost/main.ludic:130))
producing a bare binary. Mobile output is a bundle, and this is where most
real-world friction lives — it is deliberately the *last* phase.

- **iOS.** Cross-compile with the iPhoneOS SDK sysroot → an executable, wrap in an
  `App.app` bundle with an `Info.plist`, `codesign` with a development identity,
  install to simulator/device. Simulator is the cheap inner loop
  (`aarch64-apple-ios-simulator`); device needs a provisioning profile. ludicc
  should emit the binary and shell a packaging step (or emit a manifest a small
  script consumes), not learn Xcode's project format.
- **Android.** Cross-compile with the NDK → `libapp.so`, drop it into a minimal
  Gradle/Kotlin `Activity` shell, build the `.apk`/`.aab`, sign with a keystore.
  The `Activity` is fixed boilerplate that ships in the repo (`runtime/android/`),
  parameterized by app name/id.
- **Keep the compiler out of it.** Both flows are "produce native code + assemble a
  package around it." The compiler's job ends at the object/`.so`; a `--package`
  step or an external `build-mobile.sh` owns the bundle. This mirrors how ludicc
  already drives clang without becoming a build system.

---

## 9. Lowering / build summary

| Construct | Reduces to |
|---|---|
| `--target <triple>` (M1) | a triple/datalayout line in `emit_header` + a `size_t`-width choice + target-conditional link command |
| OS-owned loop (M2) | emit `ludic_boot`/`ludic_frame`/`ludic_alive`/`ludic_teardown`; host/headless get a synthesized `@main` calling them |
| window shim (M3) | one `.ll`/shim per OS implementing the same five `win_*` intrinsics; no compiler change |
| touch input (M3) | a **new, separate** input seam (`win_poll_touch`), so keycode platforms stay byte-identical |
| framebuffer→texture (M4.1) | `rt_present` uploads `rt_fb` as a texture + full-screen quad; `win_present` signature unchanged |
| GPU 3D (M4.2) | `extern fn` calls in `runtime/native/gfx3d.ludic` — data in `prog`, zero compiler edits, needs only `f32` |
| packaging (M5) | binary/`.so` unchanged; an external `--package`/script builds `.app`/`.apk` and signs |

No new allocator, no new dispatch, no per-API intrinsics. The game and the 2D
graphics stack compile identically for every target; only head declarations, the
entry-point shape, the linked platform file, and packaging vary.

---

## 10. Suggested implementation phases

Each is independently shippable and testable, matching how the repo phases work.

- **M0 — target axis** (M1) + **revive the OS-owned loop** (M2). *Do these first
  and together* — they're the shared compiler plumbing, they un-break the existing
  web target (proving the frame-loop split against `run.mjs`/`bin/x test` before any
  mobile SDK is involved), and they need no mobile toolchain. This is the floor.
- **M1 — iOS simulator, framebuffer-as-texture** (M3 iOS shim + M4.1). First pixels
  on a phone, GL/Metal binding proven, no signing/device friction yet.
- **M2 — iOS device** (M5 iOS packaging + signing).
- **M3 — Android** (M3 Android shim + M4.1 + M5 Android packaging), reusing every
  M0 change.
- **M4 — `f32` + GPU 3D** (M4.2), gated on roadmap G-04; the additive 3D path over
  `gfx3d.ludic`.
- **M5 (later) — touch-input model** hardening (M3), gesture/multitouch, once a real
  app exercises it.

M0 is the honest prerequisite and the highest-leverage work — it serves three
targets and revives a fourth. M1 is the first thing anyone can *see*.

---

## 11. Open decisions

1. **Loop selection:** does `--target ios/android/wasm` *imply* the external loop,
   or is there an explicit `--loop=external` flag? (Proposed: implied by target,
   with the flag as an override for headless testing.)
2. **iOS shim language:** hand-written `.ll` against `objc_msgSend` like `cocoa.ll`,
   or a small compiled `.m`? (Proposed: `.m` — UIKit's surface is too large for
   maintainable IR, and Metal setup is verbose.)
3. **Touch seam shape:** a separate `win_poll_touch` queue, or a unified event
   struct replacing the keycode `win_poll` on all platforms? (Proposed: separate,
   to keep desktop/web byte-identical.)
4. **GPU API baseline:** GL ES 3.0 everywhere (Android native, iOS via ANGLE/Metal
   translation), or Metal on iOS + GL ES on Android from day one? (Proposed: GL ES
   3.0 first for a single codepath; Metal later.)
5. **Android host:** ship a fixed Kotlin `GameActivity` in `runtime/android/`, or
   generate it per app? (Proposed: fixed boilerplate, parameterized by name/id.)
6. **Packaging home:** a `--package` step inside ludicc, or an external
   `build-mobile.sh`? (Proposed: external script; keep the compiler out of bundle
   formats.)
7. **`size_t` for arm64:** confirm iOS/Android arm64 are LP64 (`i64`) in the width
   table, and that the `ll_size_t` discipline covers every new size-taking call.
8. **Simulator arch:** how to handle `aarch64-apple-ios-simulator` vs. x86_64 sim on
   Intel hosts in the target table.

---

*Companion to [COMPILING.md](COMPILING.md) (§ toolchain, the wasm frame-loop
split), [LANGUAGE.md §"Functions & FFI"](LANGUAGE.md:560) (`extern fn`), and
[LUANTI-ROADMAP.md](LUANTI-ROADMAP.md) (G-04 `f32`, G-28 GPU FFI, G-29 3D math).
Supersedes nothing until the M0 compiler work lands.*
