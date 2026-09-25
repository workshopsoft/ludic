bump: major
type: feature
**No function writes a global: a module's changing data is a `state`.** `state Hiker { hips: int =
-1 }` is a record with exactly one instance, which no code can name; it reaches code as a parameter,
`h: mut Hiker` to change it or `h: Hiker` to read it, and the runtime supplies it at the entry points
(`entry (h: mut Hiker)`, a handler's, a listener's or a lifecycle hook's parameters, a scene's `on
enter (h: mut Hiker)`, a test's, a `ui` block's `Hiker.hips`, a function value - a system's, a port
bind's, a package's callback - an engine system, a namespace method's target and every call into the
runtime). A module-level `var` is refused; a module-level `let` is immutable all the way down. A
read-only state is checked where it is written - an assignment or a `push` through it or through a
local holding part of it, passing it where `mut` is wanted, a `machine` over its field - and so is a
module-level `let`. Each test block gets fresh states. A program's type named like one the runtime
declares (`property PadButton` beside the runtime's `enum PadButton`) is refused instead of failing
in clang.

`ludic migrate state [file|dir...] [--runtime] [--dry-run]` moves programs there: a var nothing
writes becomes a `let`, each module's other vars one state (`FishingState`, `Render3dState`,
`SceneDemoState`), every reference `fishing_st.name`, each function's states - to a fixed point over
what it calls - its leading parameters, `mut` where anything below it writes, and each entry point
declares them; the plans of every program given are merged before a file is edited. gpp's 35
mechanic packages, ludic.ui, ludic.render3d, every example, the docs' fences and the runtime were
moved with it. The toolchain's own programs build with `--globals` until they move too.

Outside the runtime, the drawable's size and scale, the screen's framebuffer and the tilemap's tile
size are read and set through its functions (`gl_width()`, `gl_set_drawable(w, h)`,
`gl_screen_fbo()`, `gl_pixel_scale()`, `rt_map_tile_size()`), and ludic.ui's render3d backend
installs itself through the `UiRenderers` registry.
