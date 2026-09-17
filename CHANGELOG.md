# Changelog

All notable changes to the Ludic toolchain, newest first. Each section is
generated from the changesets under changes/ by `ludic dev release`, grouped by
change type. Preview the next one with `ludic dev release --dry-run`.

A released section may carry a hand-written summary paragraph above its groups
(v0.2.0 has one); the generated bullets below it are not edited by hand.

## v0.21.0 — 2026-09-17

### Features

- **A launcher's runtime** — start a program, step aside while it runs, and download large
  files with a progress bar.

  - **`Process.*`** — `Process.spawn(path, args)` starts a program directly (no shell) with this
    process's environment and working directory and returns at once; `Process.poll(h)` is `-1`
    while it runs, then its exit code (`128 + signal` for a signal death, `137` after
    `Process.kill`); `Process.free` lets a handle go. `posix_spawn` on macOS
    (`runtime/native/process.ll`); `CreateProcessW` on Windows (`process_win.ll`), with each
    argument quoted by the MSVC rules and no console window. Linked only into a program that
    uses `Process.*`.
  - **`Http.save_to(h, path)`** — before `Http.send`, streams the response body straight into a
    file (written at `path` itself, created on send) instead of memory; `Http.text` of such a
    request is empty and `Http.body_len` is the bytes written. **`Http.received(h)`** and
    **`Http.expected(h)`** (the `Content-Length`, or `-1`) are live while it is pending. macOS
    streams through an `NSURLSession` with a delegate built at run time, Windows through the
    WinHTTP read loop. Freeing a pending request now cancels it and parks its slot until the
    worker has let go, rather than freeing what the worker is still writing.
  - **`App.window_hide()` / `App.window_show()`** — take the game's window off the screen and
    bring it back without closing it or its GL / Vulkan surface; the run goes on while it is
    hidden. No-ops headless and before there is a window.

### Fixes

- A game's window takes the title it asks for. The runtime opens a game's window before `main`,
  titled with the `program` name, and `Gl.open` / render3d's `gl_open` and `gvk_open` attached
  to it without passing their title on, so a `program Valley` that opened "Maroon Lake" showed
  "Valley". `win_set_title` (cocoa.ll `setTitle:`, win32.ll `SetWindowTextW`, UTF-8 to UTF-16)
  now retitles it, and a second `win_open` on macOS retitles the open window instead of making
  another, as it already did on Windows.
## v0.20.0 — 2026-09-17

### Features

- The JetBrains plugin (1.6.0) has a Ludic tool window for the package, like the Gradle one:
  - an overview of the package (what it is, entry, version, dependencies, scripts, hooks, app);
  - its commands, scripts and hooks, run by double-click, with each command's hooks shown;
  - its dependencies against package.lock.ludic: the locked version, whether it is fetched
    and linked, the indirect ones, and Fetch, Update, Verify, Vendor, Add and Remove;
  - the app preview the `app` lines describe, and the asset roots with missing ones marked.
  The bar over package.ludic now appears only when something needs doing (fetch, or no
  toolchain), instead of carrying every command.
## v0.19.0 — 2026-09-17

### Features

- `Udp.*`: polled IPv4 datagrams - the transport under a game's own netcode. `Udp.open(port)`
  binds a non-blocking socket (port 0 picks one, `Udp.port` says which), `Udp.send` sends one
  datagram to an address and port, and `Udp.recv` drains what arrived without ever blocking;
  `Udp.from_ip` / `Udp.from_port` name the sender. `Udp.ip` / `Udp.ip_text` convert addresses,
  `Udp.resolve` looks a host name up and `Udp.local_ip` is the address a player on the same
  network would dial. BSD sockets on macOS (`runtime/native/udp.ll`), Winsock on Windows
  (`udp_win.ll`, linked with ws2_32), linked only into a program that uses `Udp.*`.
## v0.18.1 — 2026-09-16

### Fixes

- The release build links libm on Linux, which `float`/`double` code needs (glibc keeps
  `sinf`, `sqrtf` and the rest there). 0.18.0's release job stopped on this before
  publishing, so 0.18.1 is the first published build with float types, barrel imports,
  package scripts and hooks, and the JetBrains 1.5.0 support.
## v0.18.0 — 2026-09-16

### Features

- Run a single test by name: a compiled test program takes the test's exact name as its
  first argument (`./tests "adds"`), and `ludic test` gains `--test NAME` to pass it through.
  A name that matches no test is reported and fails the run. `ludic test --verbose` (`-v`)
  prints every test's `ok`/`FAIL` line, framed by `RUN <file>` … `PASS|FAIL <file>`, which is
  what editor test views parse.
- The JetBrains plugin covers much more of the IDE:
  - Run configurations for `ludic run`/`build`/`test` (plus any other `ludic` command), with
    gutter run buttons on `program` and on every `test "name"` block.
  - Test results appear in the IDE's test tree, with navigation back to each test block.
  - `file.ludic:line` locations are clickable in every console.
  - Smart indentation on Enter and when typing a closing bracket; quotes pair up.
  - A Color Scheme page and a Code Style page.
  - Live templates, New Ludic File templates, and a Ludic project in File | New | Project.
  - A Tools | Ludic menu, and a warning when the toolchain is missing.
  - `package.ludic` is treated as a package manifest:
    - a banner offers Fetch, Update, Verify, Run, Test, Build and Bundle, and warns when the lock is
      missing or older than the manifest;
    - gutter actions on `package` and `require` lines;
    - completion and quick documentation for directives and `app` keys;
    - its own icon.
  - `script` and `hook` lines complete and are validated; each script has a run button, the
    package banner has script shortcuts, and Tools | Ludic | Run Script… lists them all.
  - The toolchain's and the project's packages are listed under External Libraries.
  - The Structure view, parameter info and code-block navigation now come from `ludic-lsp`.
  - The plugin is now 1.5.0 and requires IntelliJ Platform 2024.2 or newer and LSP4IJ 0.21.
  - Fixed: Enter no longer inserts an extra `}`, and Comment Line no longer writes two spaces.
- `float` and `double`: IEEE floating point with ordinary operators, so renderer math reads
  `a * b + c` instead of `f_add(f_mul(a, b), c)`.
  - Decimal literals take their type from context (`let s: float = 0.1` is exactly 0.1), and
    stay `fixed` elsewhere, so existing programs keep their meaning.
  - `int`/`long` promote; `float(x)`, `double(x)`, `int(x)`, `long(x)` and `fixed(x)` convert.
  - `floats(n)` / `doubles(n)` buffers; float fields, globals, constants and parameters.
  - `Math.*` computes in float when given one; `string`/`print`/interpolation write the
    shortest round-tripping decimal; `float_bits` / `float_from_bits` expose the IEEE pattern.
  - `@deterministic` code may not use floats (it is now checked).
- `import "camp"` imports a directory through its barrel, `camp/index.ludic` (a fragment
  listing the directory's own imports). A directory without one is a clear error. Packages
  resolve the same way: `import "ludic.render3d"` reads `ludic.render3d/index.ludic`.
- `ludic-lsp` navigates like the compiler resolves:
  - Package imports (`import "ludic.render3d/r3d.ludic"`) resolve from `ludic_modules/` and the
    toolchain's `packages/`, so their names hover, complete and jump. Import strings are links.
  - `var` locals are tracked (declaration, usages, rename).
  - Hover shows the declared or inferred type of locals, parameters and globals.
  - Hover and go-to-definition on built-ins, built-in types and namespaces show the reference
    page, with a link to the online docs. Release archives now ship `docs/language` for this.
  - Go to type declaration (`textDocument/typeDefinition`) is supported.
  - Signature help carries per-parameter ranges and follows named arguments.
  - Completion inside a call offers the parameter names not given yet, `Namespace.` offers its
    members, and results are ranked: locals first, then globals, built-ins and keywords.
- `package.ludic` gains `entry`, scripts and lifecycle hooks:
  - `entry "src/game.ludic"` names the program `ludic run`/`build`/`bundle` compile. Without
    it, the one file under `src/` that declares a `program` is used.
  - `script "dev" "ludic run --headless"` defines a command: `ludic dev` (or `ludic script dev`)
    runs it with any extra arguments, and `ludic scripts` lists them.
  - `hook before|after <command> "…"` wraps `build`, `run`, `test`, `bundle`, `pack`, `get`, …
    or a script. A failing `before` hook stops the command; `after` hooks run only on success.
  - Quoted manifest values accept `\"` and `\\` escapes.

### Fixes

- **`==` / `!=` on records is identity again** — only two strings compare by content.

  Every pointer-typed comparison used to be lowered to a C-string content compare,
  so two distinct records (properties, slices, enums) compared their bytes up to
  the first zero byte: `a == b` could be true for different objects that shared a
  leading field, depending on layout. References now compare by identity
  (`icmp eq ptr`); `string` (and untyped `pointer`/`pointers` text) still compares by content,
  and comparing a `string` with a non-string reference is a compile error.
## v0.17.0 — 2026-09-16

### Features

- **Renderer switches stay out of shipped games** — every `R3D_*` environment switch in
  `ludic.render3d` (debug views, feature kills, file writers, hardware fakes, the Windows
  feature overrides) now goes through one gate: a headless build honours them as before, a
  windowed build only when `R3D_DEV` is set to anything but `0`. See `docs/SHIPPING.md`.

### Fixes

- **A lake can be the water that mirrors the world** — a reflecting body is clipped to its
  ellipse like any other unless it is an unbounded sea, so a map whose reflection belongs to
  its lake no longer floods every hollow in the survey with that lake's level; and the
  terrain's wet shore, forest and scree gates read the carved lake's line inside its outline
  (`u_lake`), the rule the grass already used, so a lake above the sea keeps its wet bank and
  no forest is painted down its bed.

  `terrain_lake_carve(false)` keeps a lake's line, outline and shore but skips carving its
  bed, for a height map that already carries a shaped one.
## v0.16.2 — 2026-09-15

### Fixes

- **Keys are physical positions on Windows and macOS, whatever the layout** - `Input.key_down('w')`
  is the key above S on every keyboard.

  - **Windows** keyed the held set by the character the active layout gave a virtual key, so
    a game's WASD belonged to whatever the layout put there: on AZERTY W and A were other
    keys, and with an input method on (Chinese, Japanese, Korean) every letter arrived as
    VK_PROCESSKEY and no letter key worked at all. The typing block is now read from the
    scancode; the arrows, the numpad and the F-keys still go by virtual key, and the frame
    key (`Input.key`, typing) keeps the layout's character.
  - **macOS** did the same through `charactersIgnoringModifiers`; it now reads `keyCode`.
  - **`Input.key_label(key)`** names a key for the player in their own layout - `'w'` shows
    as "W" on QWERTY and "Z" on AZERTY - so a game that shows its bindings never shows a
    key the player cannot find. Windows reads the layout; headless, macOS and the browser
    give the US character.
## v0.16.1 — 2026-09-15

### Features

- **HDR calibration, and two HDR fixes** — the HDR10 picture follows the player's display instead of one fixed curve.

  - **`r3d_hdr_calibrate(peak, paper, black)`** — nits as float bits: the brightest the display shows (100-10000),
    where the picture's and the interface's white sit (80-1000, never above the peak) and how far the darkest shade is
    lifted (0-5, fading out by paper white). The tonemap's and the overlay's HDR10 variants read them, and the display's
    HDR metadata is sent again with the new peak. The defaults are the old constants: 1000, 200 and 0.
  - **`ov_hdr_nits(nits)` / `ov_hdr_paper()`** — what the overlay draws next is at that many nits on an HDR10 frame,
    for a calibration screen's test patches; it closes the batch so far. No effect on an SDR frame.
  - **Fixed: a crash toggling HDR on the Vulkan renderer.** `gpu_caps_probe()` made and destroyed a second Vulkan
    instance under NVIDIA Streamline's interposer; the next swapchain rebuild then called through a pointer that
    instance had left behind, at address 0. With the Vulkan renderer running, the probe asks its instance instead.
  - **Fixed: yellow read as red in HDR.** The overlay drew sRGB values straight into the HDR10 swapchain (it now has an
    HDR10 variant, chosen while `gpu_hdr_active()`), and the tonemap extended highlights per channel, which boosted a
    bright yellow's red far more than its green; it now brightens the graded colour by one factor.
## v0.16.0 — 2026-09-15

### Features

- **A loading screen can show the renderer's start-up as it happens.** `r3d_open(w, h, title)` opens
  the window and the graphics backend with nothing baked, and `r3d_load_count()` / `r3d_load_step(i)`
  run the rest - the sky and its light, the terrain, the shadow and screen targets, the scattered cover
  and actors, the grass - one step at a time, so a game can draw and present a frame between them.
  `r3d_init` is those same calls in a row and is unchanged for everything that uses it.
- **HDR10 output on the Vulkan renderer** — `r3d_hdr(on)` asks for an ST 2084 / BT.2020 swapchain where the
  display offers one.

  The tonemap's HDR10 variant keeps the SDR picture up to a 200-nit paper white and rolls highlights on to
  1000 nits; the overlay converts the interface to the same white; HDR metadata is set where the loader has
  the command. The screen and LDR images are 10-bit while it is on, and screenshots refuse rather than write
  a PQ image as SDR. OpenGL and the Vulkan SDR frame are unchanged. `R3D_HDR` overrides the setting.
- **Mesh-shader grass** — on a card with `VK_EXT_mesh_shader`, `r3d_mesh_grass(on)` draws each grass tile as one
  mesh-shader dispatch sized to that tile's blades, and a blade that is culled emits no vertices at all.

  - **`ludic-dev shaders`** — a variant whose first file is `*.mesh` compiles that stage as a Vulkan 1.3 mesh
    shader; its SPIR-V keeps the `.vert` name, so the manifest is unchanged.
  - **The seam** — `gpu_has_mesh()` and `gpu_draw_mesh_tasks(x, y, z)`; a mesh program's pipeline has no
    vertex input and its bindings the mesh stage. The device enables `meshShader` and `maintenance4`.

  Not yet faster: at 4K on an RTX 3070 Ti the grass pass takes 5.0 ms against the chunked path's 1.7, so
  `gpu_feature_implemented(GF_MESH_GRASS)` stays false and a game should not offer it as a finished setting.
- **More of the renderer's quality is a switch a game can offer.**

  - `sky_set_quality(width)`: the prefiltered sky light at 256, 512 or 1024 wide (half as tall),
    baked again at once.
  - `post_set_msaa(samples)`: 1, 2 or 4 samples for the scene on OpenGL, remaking the screen targets in
    place (`post_msaa_live()` is false on Vulkan, which has no sample counts yet); `post_free` now
    frees the multisampled framebuffer too.
  - `STREAM_BUDGET_US` is a variable: the microseconds a frame may spend generating streamed cover.
  - `r3d_fog_scale`: a multiplier over the fog density the daylight and the weather set.
- **NVIDIA DLSS super resolution and Reflex on the Vulkan renderer** — through NVIDIA Streamline 2.14.1.

  - **The loader** — on Windows `Vk.open()` takes `sl.interposer.dll` beside the executable in place of
    `vulkan-1.dll` when a program asks (`Vk.sl_prefer`), falling back to plain Vulkan without it; the `sl*`
    exports and feature functions are reachable from Ludic.
  - **render3d** — `r3d_dlss(mode)` upscales the lit HDR frame before bloom and the tonemap, jittered on a
    Halton cycle, with preset K in every mode (the default M cost 18 ms a frame at 4K on an RTX 3070 Ti);
    `r3d_dlss_render_w/h` give the size to render at. `r3d_reflex(mode)` sleeps each frame and marks
    simulation, submit and present. `R3D_DLSS`, `R3D_REFLEX`, `R3D_DLSS_PRESET`, `R3D_SL_LOG` for tests.
  - **Commands the interposer lacks** — it exports no `vkSetHdrMetadataEXT`, `vkCmdDrawMeshTasksEXT` or
    acceleration-structure command; `Vk.has` checks one and `vkGetDeviceProcAddr` reaches it.
- **Real OS threads behind `Job.*` and `Sync.*`** — `Job.parallel_for` runs work across every core.

  - **`fn name`** — an expression naming a top-level function as a value, for a worker's entry point.
    No closures: the data a worker needs is passed in.
  - **`Job.parallel_for(count, fn work, ctx)`** — `work(i, ctx)` for every `i` in `[0, count)`, split
    into chunks across a worker pool (one thread per core but one, pthreads or Win32) and the calling
    thread; returns when all are done. `Job.is_worker()` says whether code is on a pool thread.
  - **`Sync.*` is thread-safe** — mutexes are real mutexes, atomics are compare-and-swap, channels are
    guarded, and `Sync.cpu_count()` reports the machine's cores.
  - **A worker must not change the world** — `spawn` and `despawn` on a pool thread stop the program with
    a located message.
- **Texture filtering and shadow resolution as settings a game can change while it runs.**

  - `r3d_set_anisotropy(level)` sets the anisotropic filtering of every mipmapped texture already
    loaded, not only of later uploads, on OpenGL and Vulkan.
  - `shadow_set_res(size)` remakes the cascades' depth layers at 1024, 2048 or 4096 (`shadow_res`
    replaces the `SHADOW_RES` constant); the lighting reads the texel size from the map.
- **`app native "<dir>"` in `package.ludic`** — `ludic bundle` on Windows copies that directory's files beside
  the executable: native libraries loaded at run time (NVIDIA Streamline's DLLs, say) and their licence texts,
  which cannot live in the pack.

### Fixes

- **The meadow's grass draws on the Vulkan renderer again** — the chunked grass path uploaded its `vec4` tile
  table with `u_fv`, which on Vulkan copies one float per array element, so every tile had no blades.
  `u_f4v` uploads arrays of `vec4`.

### Performance

- **The sky's light is baked once at start, not twice.** A game that turns the sky at boot sets
  `sky_start_yaw` before `r3d_init`, and `sky_load` bakes the image-based light at that yaw; turning to
  a yaw the light is already baked at (`sky_set_yaw`) no longer bakes it again. Without it, nothing
  changes.
## v0.15.0 — 2026-09-15

### Features

- Vulkan for Ludic, and the start of a second renderer beside OpenGL.

  - **`Vk.*`**: every command of Vulkan 1.0-1.4 and of the extensions a modern renderer is
    built around (swapchain, HDR colour spaces, ray query and acceleration structures, opacity
    micromaps, mesh shaders, variable rate shading, memory budget, pipeline libraries, NVIDIA
    low latency, portability for MoltenVK), with every constant and every struct's size
    (`<Struct>_sizeof`) and field offsets (`<Struct>_<field>`). Generated from the Vulkan
    registry by **`ludic-dev vkgen`** into `runtime/native/vk_api.ludic` and `vk_thunks.ll`;
    structs are plain memory filled by name with `Vk.put_i32` / `put_i64` / `put_ptr`. Every
    size and offset was checked against the SDK's C headers (3128 facts). A C float is float
    bits in an int; 64-bit values and non-dispatchable handles are `long`.
  - **The loader is opened at run time**, never linked: `vk_win.ll` (`vulkan-1.dll`) and
    `vk_mac.ll` (`libvulkan.1.dylib`, MoltenVK). `Vk.open()` returning 0 means no Vulkan, and
    the program carries on. `ludicc` and `ludic build` link both files for any program that
    uses `Vk.*`.
  - `examples/rendering/vk_probe.ludic` reports what a machine's Vulkan can do;
    `vk_compute.ludic` runs a Slang compute shader (`vk_compute.slang`) and reads the picture
    back - on an RTX 3070 Ti and on an M4 Pro through MoltenVK, clean under the validation layer.
  - **render3d `gpu.ludic`**: the seam between the renderer and a graphics API. Render state
    and uniforms go through `gpu_*` / `u_*` and nowhere else (OpenGL frames unchanged);
    `R3D_GFX=gl|vk` or `gpu_request` chooses a backend, falling back to OpenGL with a reason;
    `gpu_caps_probe()` detects, on Windows, the Vulkan 1.3 floor, ray tracing, mesh shaders,
    the NVIDIA RTX generation, Reflex and HDR, for a settings screen to grey out what a machine
    cannot use (`R3D_CAPS=rtx50|rtx40|rtx30|amd|intel|none` pretends, for tests).
## v0.14.2 — 2026-09-14

### Fixes

- **`Input.mouse_dx` / `mouse_dy` no longer jump on the first frame or when the cursor mode changes.**
  The delta was the position minus the previous frame's, and the previous position started at 0,0,
  so the first frame reported the cursor's whole distance from the corner as motion, and switching
  between a locked cursor's virtual reticle and the real cursor did the same. A camera that adds
  `mouse_dy` to its pitch came up pointing at the ground with nobody touching the mouse. Both frames
  now report no motion; every other frame is unchanged, windowed or headless, on macOS and Windows.
## v0.14.1 — 2026-09-13

### Fixes

- **A rim from `outline_model` no longer stays on after the caller stops asking** — the queue
  was only emptied by the next `outline_model` call, so a game that highlights what the
  crosshair is on left the last highlighted tree outlined for good once the player looked
  away. `r3d_frame` now drops a batch nobody reopened this frame (`outline_frame`).
## v0.14.0 — 2026-09-13

### Features

- **Overlay text is UTF-8, and a font atlas can carry any script** — `ludic.render3d`'s `ov_text`,
  `ov_text_w` and `ov_text_wrap` decode UTF-8 instead of drawing bytes 32–126, so a game can show
  Turkish, German, Polish, Greek, Cyrillic or whatever its atlas holds.

  - `font.json` may list the atlas's code points in `"codes"` (atlas order). An atlas without it is
    read as before: consecutive code points from `"first"`, so existing ASCII fonts keep working.
  - A code point the atlas lacks draws as `?`; a control character as a space; a malformed or
    cut-off sequence as one `?`, so a string sliced mid-character still draws.
  - `overlay_font(dir)` loads or swaps the atlas at run time, for a language that brings its own font.
## v0.13.3 — 2026-09-13

### Performance

- **Dense forest renders faster** — a depth prepass for the near tree foliage in `ludic.render3d`.

  A crown of needle cards is many cut-out quads deep, and a shader that can `discard` turns
  early depth rejection off, so every card behind the front one ran the full lighting shader.
  In a dense stand at 3840x2160 that made the vegetation pass the largest in the frame. The near
  tree LODs now write depth first with `depth.frag` (the same alpha coverage test), the terrain
  beneath them is rejected before shading, and the lit pass draws them with no `discard` and an equal depth test. `R3D_NOPREPASS=1` restores the old path for comparison.
## v0.13.2 — 2026-09-13

### Fixes

- **`ludic build` links `http.ll` only into a program that uses `Http.*`.**

  The check that added it grepped the IR for `@hs_`, which every program's header declares,
  so the HTTP transport and Foundation were linked into everything. That cost nothing visible
  on macOS and failed the link on Linux, where `ludic build`, `ludic run` and a new project all
  broke in CI. It now looks for a call to `hs_send`.
## v0.13.1 — 2026-09-13

### Fixes

- **The toolchain links on Linux again** — CI builds, tests and publishes releases.

  The asset-pack boot finds the directory beside the executable with `_NSGetExecutablePath`,
  which Darwin's libc has and glibc does not, so every Linux link of the compiler seed failed
  from the release that added packs onward: CI's build, suite and C-free bootstrap jobs, and
  every `publish` run, so no release after v0.7.0 carried a Linux toolchain or was created by
  CI at all. `tools/ci/linux_stdio_shim.ll` now supplies it, over `/proc/self/exe`.
## v0.13.0 — 2026-09-13

### Features

- **Windows target** — `ludicc` builds and runs headless programs on Windows, and builds itself there.

  - **`--target <triple>`** — a triple naming `windows` selects the Windows runtime; without
    the flag the target is the host, read at run time from `OS=Windows_NT`. The IR still
    carries no triple, so clang assembles it for the machine it runs on.
  - **The libc surface, in IR** — on Windows the header emits `emit_win.ludic`, which defines
    the POSIX names the backend calls (`fopen`, `ftell`, `rename`, `opendir`, `mmap`,
    `fmemopen`, `uname`, …) over the UCRT and Win32. Three of them fixed silent breakage
    rather than link errors: `rename` onto an existing file (every `Fs.write_text` after the
    first), a 32-bit `ftell`, and text-mode `fopen` rewriting `\n` as `\r\n`.
  - **Known folders** — `Os.save_dir` / `config_dir` are `%APPDATA%\<app>`, `cache_dir` is
    `%LOCALAPPDATA%\<app>`, `temp_dir` is `%TEMP%`, all with forward slashes; a bundle's
    `home` line points at `%APPDATA%\<name>`.
  - **The driver** — finds `C:\Program Files\LLVM\bin\clang.exe` when clang is not on
    `%PATH%`, writes `.exe` outputs, speaks cmd.exe for its directory and cleanup commands,
    and reads `argv[0]`, `%PATH%` and `$LUDIC_HOME` with either separator.
  - **A window** — `win32.ll` is `cocoa.ll`'s contract over user32: the held-key set and frame
    key in Ludic codes, the mouse in framebuffer pixels with raw input for cursor mode 2,
    cursor hide/lock/confine that lets go when the window loses the foreground, XInput pads
    in SDL order with rescaled deadzones, and the software `win_present`. `win32_gl.ll` puts
    the WGL context on that window with vsync and borderless full screen; a headless build
    links `gl_win_nowin.ll` instead. The process is per-monitor DPI aware.
  - **Sound** — `audio_win.ll` is `audio.ll`'s contract over XAudio2: one source voice per
    clip, loops, volume, rate and a balance pan through the output matrix, RIFF WAVE in PCM or
    float. It reads a clip through the asset pack, so a bundled game's first `Audio.load`
    succeeds - AVAudioPlayer takes a filesystem path, which is why macOS cannot.
  - **The CLI on Windows** — `ludic build`, `ludic run` and `ludic-dev build` work from a Windows
    checkout. Every shell command the CLI issues runs through Git for Windows' bash
    (`$LUDIC_BASH` names another), `compile_app` links through `ludicc -o`, and a checkout
    bootstraps from the new `selfhost/ludicc.win.seed.ll`, which `ludic-dev reseed` now
    writes beside the macOS seed.
  - **`ludic bundle` on Windows** — `build/<name>/` holding a GUI-subsystem `<name>.exe`, the
    `game.lpak` and `packs.index`; an `.ico` beside `app icon` is compiled with `llvm-rc` and
    linked in. `ludicc` gains `--gui` (no console behind the window) and `--link <file>`.
  - **`Http.*` on Windows** — `http_win.ll` is `http.ll`'s contract over WinHTTP: a request
    built on the game thread, the exchange on a worker thread, TLS with the system's
    certificate checks, and response headers answered from the kept request handle.
  - **The splash and the window icon** — decoded by WIC from the bytes in the pack. The splash
    is a topmost borderless window at the artwork's own size in points times the display's
    scale; `App.set_icon` sets the title bar and taskbar icon of a build with no icon resource.
  - **`Gl.*` on Windows** — `gl_win.ll` makes a WGL 4.1 core context on a hidden window's DC,
    and `gl_thunks_win.ll` (generated by `ludic-dev glgen` beside `gl_thunks.ll`) calls
    every entry point through a table `@lgl_win_load` fills from `wglGetProcAddress`, falling
    back to `opengl32.dll` for the 1.1 functions it will not return. A headless GL program
    renders on the GPU there: `gl_triangle` matches the macOS frame to within one level per
    channel.

### Fixes

- **Backspace fires on macOS** — the Delete key reports `Key.Backspace` (8).

  AppKit gives the key marked delete (kVK_Delete, 51) the character `NSDeleteCharacter`, 127,
  which is what both the held-key set and the per-frame key received, so `Key.Backspace` never
  matched. `cocoa.ll` maps key code 51 to 8 in both.
- **Held arrow keys register** — `Key.Up`, `Key.Down`, `Key.Left` and `Key.Right` are 128-131.

  They folded to the codes of w, s, a and d, which is what the single per-frame key
  (`Input.key`) reports for an arrow. The held-key set has always stored an arrow under
  128-131, so `Input.key_down(Key.Up)` tested the W bit and `Input.move_i`'s arrow half never
  moved anything. `Input.key` keeps its WASD alias: a game comparing it with `'w'` still
  takes the arrows.
- **`ludic build` links `Http.*`** — a program that uses the HTTP client builds through the CLI.

  `compile_app` linked the OpenGL backend when a program named `@lgl_*` but never
  `runtime/native/http.ll` and Foundation for `@hs_*`, so a `Http.*` program failed to link
  under `ludic build` / `ludic run` while `ludicc -o` built it. It now links them the same way,
  windowed and headless.
## v0.12.1 — 2026-09-13

### Features

- **ludic.render3d: `r3d_fog_base`** — the height the height fog's density is measured from (default 0, the world's y = 0). Two maps sharing one height datum, one far lower than the other, no longer give the lower one many times thicker air.

### Fixes

- **ludic.render3d: lakes are ellipses** — a water body other than the reflecting one was drawn as the whole rectangle of its bounds, so the corners between that rectangle and the lake's carved ellipse showed sheets of water over dry ground. Those bodies are now clipped to the ellipse; the reflecting body (the sea) still fills its rectangle.
## v0.12.0 — 2026-09-13

### Features

- **ludic.render3d: replace the world at run time** — a game can swap its terrain, scatter, colliders, actors and water for another map's without restarting.

  - `terrain_reload(dem, emin, emax, base, ox, oz, ortho, half)` releases the current map's height field, survey, photograph and patch bounds and generates another at any `TERRAIN_HALF`; `terrain_unload()` is the release on its own.
  - `scatter_clear_all()` (with `stream_clear_all()`), `actor_clear_all()` and `col_reset()` empty the scene for the next map; `mesh_free()` releases a mesh's GL objects.
  - **Water bodies** — `water_body_add(level, cx, cz, ex, ez, reflect)` and `water_bodies_clear()` draw several still-water planes at their own levels; the first that reflects gets the planar reflection. `water_init` still means one reflecting plane.
  - **Fix:** the terrain's patch quadtree placed patches at a fixed 32 m leaf, so any `TERRAIN_HALF` other than 4096 put patch bounds in the wrong place; leaves now scale with the map.
  - **Fix:** `water_init` built a new mesh and compiled a new program on every call.
  - `terrain_sea(level)` separates the sea's level (the coast, the strand, the shoreline, forest and scree shading) from the carved lake's, so a lake can sit above the sea. Unset, the sea is the lake's level as before.
## v0.11.1 — 2026-09-12

### Fixes

- **`col_resolve` no longer throws a body across the map when it starts dead centre on a
  collider.** The degenerate branch — a point exactly on a circle's axis, where there is
  no direction to push it — chose a unit normal `(1, 0)` and then divided it by the
  clamped `d = 0.001` anyway, along with the real normals. The push came out a thousand
  times too large: a body standing exactly on a 0.5 m trunk was moved about 800 m instead
  of the 0.85 m that clears it.

  Off-centre the arithmetic was correct, and off-centre is how anything arrives at a
  trunk while walking, so it never showed up in play — only a teleport, a spawn or a
  world generator placing something on an existing collider could land on the axis.

  `(ex, ez) / d` is always a unit vector for `d > 0`, because `d` is its own length: there
  was never anything to clamp. The normal is now built once, explicitly, and the clamp is
  gone.
## v0.11.0 — 2026-09-12

### Features

- **`App.set_icon(path)`** — an icon for a binary that has no bundle to take one from.

  `ludic bundle` builds an `AppIcon.icns` and macOS reads it from the `.app`, so a
  shipped game has an icon. `ludic build` produces a bare executable, which has no
  bundle, no `CFBundleIconFile` and therefore no icon at all — macOS draws the generic
  green "exec" tile in the Dock. That is the build a developer runs all day and the one
  they see every session, so "my game has no icon" is true long before it ships.

  ```ludic
  App.set_icon("assets/app/icon.png")
  ```

  The path resolves through the pack first and the filesystem second, like every other
  asset, so the same call works packed and unpacked — it does not repeat `Audio.load`'s
  trick of taking a filesystem path only. An image that cannot be found or decoded
  leaves the current icon alone rather than clearing it, calling it in a bundled app is
  a harmless no-op, and a headless build compiles it away to nothing.
## v0.10.1 — 2026-09-11

### Fixes

- **`Os.save_dir` / `Os.config_dir` / `Os.cache_dir` follow the platform.** They were the
  macOS layout everywhere, so a game built on Linux wrote its saves to
  `~/Library/Application Support` — a directory that means nothing there. Naming the
  right directory is the entire reason a program calls these instead of building a path.

  | | macOS | Linux |
  | --- | --- | --- |
  | `save_dir` | `~/Library/Application Support/<app>` | `$XDG_DATA_HOME` or `~/.local/share/<app>` |
  | `config_dir` | `~/Library/Application Support/<app>` | `$XDG_CONFIG_HOME` or `~/.config/<app>` |
  | `cache_dir` | `~/Library/Caches/<app>` | `$XDG_CACHE_HOME` or `~/.cache/<app>` |

  An XDG variable that is set but empty falls back to the default, as the spec requires.
  macOS is unchanged to the byte — `save_dir` and `config_dir` stay the same directory
  there, because Apple's home for a config file that is not an `NSUserDefaults` plist is
  Application Support too, and a shipped game's settings must not move out from under it.
  On Linux XDG separates the two and so does this.

  One consequence worth stating plainly: a game already shipped on Linux was writing to
  the old macOS-shaped path, and this moves it. Those files are not migrated for you —
  they are wherever `~/Library/Application Support/<app>` ended up on that machine, and a
  game that has Linux players should move them once on startup.
## v0.10.0 — 2026-09-11

### Features

- **`.packignore`** — keep build artefacts out of the shipped asset pack.

  A pack root is packed wholesale, so everything a model or texture pipeline leaves
  beside its output ships too: preview renders, bake intermediates, the `.blend` a
  `.gltf` came from. Nothing errors and nothing looks wrong — the app is just bigger
  than the game. The only way out was naming every file in `package.ludic`, a list
  that goes stale the day someone adds a texture.

  Put a `.packignore` beside the assets instead. The rules are **gitignore's**, down
  to the parts people rely on without thinking about them: patterns anchored by a
  slash or floating without one, `preview/` for directories only, `*` and `?` stopping
  at a separator where `**` crosses it, `[a-z]` classes, `!` re-includes with the last
  line winning, a deeper file beating a shallower one, and no re-including out of an
  ignored directory.

  `ludic pack` reports what it left out, and `--no-ignore` packs everything so you can
  see what a rule costs. `ludic bundle` gathers the same way. `.packignore` itself is
  never packed, and the file only governs your own roots — a package's resources, such
  as the renderer's shaders, are added afterwards and cannot be excluded by accident.
## v0.9.1 — 2026-09-11

### Fixes

- **`outline_model`'s batch survives the whole frame.** A frame is drawn by more than one
  pass — a shadow map, a water reflection, the scene — and `actor_draw` runs in each of
  them. An Actor's rim survives that because it is a field on the actor; the queue did not,
  because the first pass to run emptied it, so a queued outline was drawn into whichever
  target happened to come first and was gone by the time the scene was drawn. Nothing
  appeared, with every uniform, matrix and mesh correct.

  A flush now *closes* the batch rather than clearing it, and the next `outline_model`
  opens a new one: every pass in a frame sees the same requests, and a caller still needs
  no frame hook.
## v0.9.0 — 2026-09-11

### Features

- **`Audio.play_at(id, gain:, pitch:, pan:)`** — fire a one-shot with its own gain, pitch
  and stereo position, leaving the master settings alone.

  `Audio.volume` and `Audio.pitch` are global: they are there so a player can turn the game
  down, and a game that used them to place a sound in the world would be fighting its own
  options screen. This is the per-voice version, and it is what distance attenuation is made
  of — a 3D game works out how far away a sound is and which side it is on, and says so.
  `gain` rides on top of the master volume, so the options screen still wins; `pan` runs
  -1 (hard left) to 1 (hard right).

  A loaded sound is still one player, so firing the same handle again restarts it rather
  than layering a second copy. Load a handle per variant when several need to overlap.
- **`ludic.render3d`: `outline_model(model, mat, width, r, g, b)`** — a rim around something
  that is not an Actor.

  An Actor has had an `outline` since the outline pass landed, and everything else in a
  scene had nothing: the pass walked the actor list and stopped. Instanced scatter was the
  gap that mattered, because a game that highlights whatever the crosshair is on could
  highlight every object in the world *except* the twenty thousand most common ones — the
  trees.

  `outline_model` queues a model at a transform from anywhere in the frame and the outline
  pass flushes it alongside the actors', which is what gets the depth test right: the rim has
  to be drawn after the scene it is tested against, and a caller does not control pass order.
  A layer whose vertex shader moves its instances — wind, or standing them on the drawn
  terrain — should be handed the transform that shader arrives at.
- **`ludic.render3d`: `terrain_coast(cx, cz, margin, fall)`** — the other way to make an
  island, and the one a real survey wants: the sea goes around the survey's **own edge**
  rather than being cut out of the middle of it.

  `terrain_island` measures a radius out from a centre, which suits a made-up map and
  drowns most of a real one — an 8 km mountain survey loses two thirds of itself to make an
  island of the rest. `terrain_coast` measures inward from the boundary instead: everything
  the data covers stays land, the outer `margin` metres go under water, and the `fall` metres
  inside that are scaled down into it. The band is wobbled by low-frequency noise, so what
  comes out is headlands and bays rather than the square the data arrived in.

  Both modes also gained a **strand**. Scaling alone hands a 500 m mountainside a 40-degree
  plunge into the sea, which is a cliff coast and nothing else; the last few metres of height
  either side of the water line are now compressed, which stretches them out horizontally
  into beach and shallows. Inland lakes are untouched — they have their own bed.
## v0.8.0 — 2026-09-10

### Features

- **A boot splash**, customised by the game. `app splash` in `package.ludic` names
  the artwork and `app splash_bg` the colour behind it; the runtime raises a
  borderless window from a constructor that runs before `main`, reading the image
  out of the asset pack, so it is on screen while the process is still starting
  rather than after the slow part it exists to cover. Nothing hides it
  automatically - only the game knows when its first real frame is ready, so the
  game calls `App.splash_hide()`.
- **Asset packs.** `ludic pack` writes every asset a game opens into one `.lpak`
  beside the binary, and the runtime mounts it before `main`. Nothing about how a
  game is written changes: the pack is spliced in at `file_open`, the one place
  every asset comes through, so `gltf_load`, `tex_load`, `Audio.load`,
  `Fs.read_text` and the renderer's own shader loads all find it without knowing
  it exists. `Fs.exists` and `Fs.size` consult the packs too. Entries are stored
  rather than compressed and the pack is `mmap`'d, so 165 MB of terrain costs one
  syscall at startup and pages in only what is touched. Several packs can be
  mounted in order, and a later one shadows an earlier one - which is how a patch
  replaces individual files without rewriting the base pack. See `docs/SHIPPING.md`.
- **`ludic bundle`** turns a built game into a real macOS `.app`: `Info.plist` and
  `PkgInfo` from the manifest, an `.icns` built from one source PNG at every size
  macOS asks for, the asset pack in `Contents/Resources`, and an ad-hoc signature
  so it launches on Apple silicon. Everything comes from `app` lines in
  `package.ludic`, so the command takes no arguments. A bundled game is also moved
  to `~/Library/Application Support/<name>` at startup, because Finder starts a
  `.app` with its working directory at `/` where no save could ever be written.
- **`ludic.render3d`: `terrain_island(cx, cz, r, fall)`** keeps land out to `r` and then
  scales the terrain down into the water over `fall` metres. Scaling rather than blending
  to a fixed bed is what makes the coastline come out of the terrain already there: low
  ground becomes beach and shallows, high ground becomes cliff. `r = 0` leaves the survey
  untouched.
- **`ludic.render3d`: a rim outline on an actor.** An actor gains `outline` (metres of
  rim) and `ocol` (its colour). The pass draws the model again with its vertices pushed
  along their normals and its front faces culled, so only the far side of the swollen
  shell survives - a silhouette exactly `outline` wide, depth-tested against the scene, so
  anything standing in front of the actor hides its rim too.
- **`ludic.render3d`: the moon has a phase.** One number, 0 new .. 0.5 full .. 1 new
  again, decides the disc's terminator, how much of its light reaches the ground, and
  where in the sky it rides - a full moon rises as the sun sets, a new moon travels with
  the sun and is never seen. A new moon is now a properly dark night, which is what makes
  a carried light worth having.

### Fixes

- **`ludic.render3d`: water read the window's size, not the frame it drew into.** The
  water shader's `u_screen` and the reflection target were sized from the drawable, but
  `gl_FragCoord` there runs over the scene target. They match only at a render scale of 1;
  below that the refraction and depth reads landed in the wrong corner of the frame and the
  lake showed a squashed copy of it instead of its own bed.
## v0.7.0 — 2026-09-10

### Features

- **A game can use the renderer from outside this repository.** `ludic.render3d` reads two
  things from disk at run time — its GLSL, and the scanned CC0 materials — and both were
  found only by a path relative to the working directory, so the renderer worked in a
  Ludic checkout and nowhere else. A game living in its own repository now needs to copy
  neither.

  **The shaders come from the package**, wherever the package is. They belong to
  `ludic.render3d` and ship with it, so the renderer looks for them beside the project
  first (a Ludic checkout, where they are under `packages/`) and then under the install
  root, `$LUDIC_HOME/packages/ludic.render3d` — the same place the compiler already
  resolves `import "ludic.render3d/r3d.ludic"` from. Nothing to vendor, and no version of
  the shaders that can drift from the version of the code that compiles them.

  **`ludic assets [--force]`** fetches the scanned materials and the HDRI sky into
  `assets/polyhaven/` of whatever project you run it in. The list of what to fetch is the
  renderer's own — the renderer decides which materials it wants — so it moved out of the
  repository's `assets/` and into the package as
  `packages/ludic.render3d/assets.manifest`, where it ships with the toolchain. A game
  does not keep its own copy of that list and so cannot fall out of step with the
  renderer's material set. `ludic dev fetch-assets` is the same command from a checkout.

  **A URL-shaped module built its binary into directories.** `project_name` took
  everything after the last dot of the manifest's module path, which for a package
  identified the way the package manager identifies them —
  `git.host.io/user/name` — is inside the *host*: the build wrote
  `build/io/user/name` instead of `build/name`. The last path segment comes first now, and
  a dot inside that segment still separates namespace from package, so `ludic.render3d`
  still builds as `render3d`.

  **The camping game has moved out** to its own repository —
  [Maroon Lake](https://git.workshopsoft.io/workshopsoft/maroon-lake) — taking
  `examples/rendering/valley.ludic`, `hiker.ludic`, `camp/`, and 175 MB of survey data and
  scanned kit with it. It was here as a demo of the renderer and became a game, and an
  engine repository should not be carrying a game's assets. It is now the first consumer
  of everything above, which is the point: what the renderer needs a game to be able to do,
  it can now do from outside. `examples/rendering/smooth.ludic` stays as the renderer's
  example in this tree.
- **OpenGL for Ludic, and a 3D renderer on it.** `Gl.*` binds the whole OpenGL 4.1
  core API — every `gl*` entry point of the platform `gl3.h` as `Gl.<snake_name>(…)`
  with every `GL_*` constant, generated by `ludic-dev glgen` with per-call ABI thunks
  (`runtime/native/gl_thunks.ll`; float/double parameters take `fixed`). Windowed
  builds get an `NSOpenGLContext` on the existing window at Retina resolution
  (`cocoa.ll`); headless builds render into an offscreen CGL context, so a program
  that uses `Gl.*` renders and screenshots identically under the test harness.
  `Gl.open / swap / screenshot / program / vao / floats …` cover the glue, and the
  IEEE-float helpers (`f_add`, `mem_put_f32`, …) let Q16.16 programs fill real
  float vertex and uniform data. `Gl.*` links `gl.ll + gl_thunks.ll + OpenGL.framework`
  only when used; every other build is byte-identical.

  The `ludic.render3d` package (`packages/ludic.render3d`) is a physically based
  renderer written on `Gl.*`: HDRI sky with image-based lighting (irradiance, GGX
  prefiltered, split-sum BRDF, sun extracted from the map), GPU-generated terrain
  with scanned PBR materials (stochastic anti-tiling, triplanar rock, slope/altitude
  splatting), cascaded shadow maps with PCF and world-unit biasing, a glTF loader
  for scanned models, instanced vegetation with baked impostors, procedural grass
  and lupines with wind and translucency, 4x MSAA with alpha-to-coverage, SSAO,
  still water, cloud shadows, aerial perspective, an HDR pipeline with bloom,
  auto-exposure, ACES tonemapping, grading, sharpening and grain. See
  `examples/rendering/smooth.ludic`, and the Maroon Lake game (git.workshopsoft.io/workshopsoft/maroon-lake) for a
  game built on it. The renderer's CC0 materials are fetched with `ludic assets`.

  **16-bit PNGs**: the renderer's texture loader keeps 16-bit samples (normal /
  displacement maps) and uploads them as `RGB16` / `R16`.

### Fixes

- **Resizing the window (or entering fullscreen) no longer empties the world.** It left
  `gl error 1286` — `GL_INVALID_FRAMEBUFFER_OPERATION` — on every frame from there on, with
  the terrain, the trees, the grass and the water gone and only the sky drawn.

  The sun-visibility pass added in `changes/terrain-perf.md` borrows the depth buffer the
  frame is about to be drawn with, so that rasterising it doubles as a depth prepass. It
  was storing that borrowed texture in its `Target`, and a `Target` deletes whatever its
  `depth` names when it is freed. On the first resize the sequence was: `post_free` deletes
  the frame's depth texture, `post_init` immediately makes the replacement — and GL hands
  back the name that was just freed — and then the visibility target, rebuilt for the new
  size, deleted that name believing it was its own. The scene framebuffer lost its depth
  attachment. What is left is a colour-only framebuffer, which is *complete*, so drawing
  carried on with no depth test at all: the sky is a fullscreen quad drawn last, and with
  nothing left to fail against it painted over the entire valley. The 1286s came from the
  passes whose own attachment now named a texture that no longer existed.

  A borrowed attachment is never written into the target now, and the frame's depth is
  attached afresh at the start of each pass — it is a different texture every time the
  screen-sized buffers are rebuilt, and one `glFramebufferTexture2D` per pass is cheaper
  than any scheme for noticing that it changed.

  `R3D_RESIZE_AT=<frame>` rebuilds every screen-sized buffer from that frame on, cycling
  through four drawable sizes every few frames. A window cannot be resized in a headless
  run, so this is the only way to reach the path; it reproduced the fault in one frame and
  now runs twenty resizes, with the fly camera and with the game, without an error.
- An upgrade keeps the package store. The installer replaces the whole install
  root, and `ludic add` caches packages in `~/.ludic/store` — so re-running the
  one-liner deleted every package a project had fetched. The store is carried
  across now; everything else in the root belongs to the toolchain and is replaced.

### Performance

- **Ground cover stops re-growing itself.** Walking a streamed world hitched, and the
  hitch got worse the longer you played. Measured in the Maroon Lake game, with a new hitch
  report rather than guessed at.

  **The chunk cache had a cliff, not a slope.** A stream cached 4096 chunks and then
  stopped remembering: past that the chunk was generated, used for one frame and thrown
  away, so every ring walk regenerated it, for the rest of the session. It arrives after
  enough of the map has been walked — six evictions' worth over seven kilometres, so an
  ordinary session reaches it — and it is the point where cover starts visibly re-growing
  as you turn. `stream_evict` now drops the half of the cache nobody has asked for in the
  longest time (chunks carry the walk that last wanted them) and rebuilds the index over
  what is left. Over a 7 km traversal: generation total **9073 ms → 2230 ms**, the worst
  single frame's generation **11.4 ms → 3.1 ms**, median frame 10.8 → 9.0 ms. With a cache
  deliberately sized to saturate early, the same run goes from 2748 frames generating to
  1548, and from a 13.3 ms median to 9.2. `R3D_NOEVICT` restores the old behaviour for
  comparison, `R3D_STREAM_CAP=<n>` sets the cache size.

  The other half of that hitch was in the game's own cover generator, and went with it to
  the Maroon Lake game's repository: its candidates were paying for a second noise field, four
  height samples and a path distance before the drift field that rules out most of the
  meadow — 2341 µs → 518 µs per chunk, bit-identical output. Worth repeating in any
  generator: a `stream_fill` is called for tens of thousands of candidates per chunk, so
  the order of its tests is most of its cost.

  **The hitch report** (`R3D_PROF=1`) is what found both. It prints the slowest frames of
  the run with what was in each: CPU versus GPU wait, cover generated, instance bytes
  uploaded, the game's own tick, and the renderer phase that took longest. Alongside it,
  per-chunk generation cost by stream and band, a census of what the caches hold, and a
  stutter figure — the frame time a run spent beyond 1.2x its own median — because a mean
  cannot show a hitch and a maximum is one unlucky frame.

  It also found two content bugs in the game it was measured on, which is the report doing
  its job: a cover stream whose placement rule never fires still pays full generation cost,
  and the census makes that visible — 3364 cached chunks holding zero instances.
- **The ground costs half what it did.** Measured in the Maroon Lake game, the terrain was 10.3 ms of
  a 22.2 ms frame; it is now 5.4 ms of 16.4 ms — 45 fps to 61 fps at 1080p, with the
  frame otherwise unchanged (every viewpoint tested stays above 54 dB PSNR against the
  old renderer, with no channel differing by more than 7/255).

  **Measure by frame time, not by the pass timers.** `R3D_PROF`'s per-pass
  `GL_TIME_ELAPSED` queries cannot be trusted on this driver: with the ground's shading
  work removed the terrain query fell from 10.5 ms to 1.3 ms while the frame time did
  not move at all. Every number above and below is a median real frame time, taken by
  switching one thing off (`prof_ft_report`); the pass timers are still printed, and are
  still useful for spotting a pass that appears out of nowhere, but they cannot size one.
  `R3D_NOTERRAIN` skips the ground, `R3D_TNEARONLY` / `R3D_TFARONLY` draw every patch
  with one tier's program, and `R3D_RES=<w>x<h>` renders at another size — the three
  switches that say whether a cost is the ground, which tier it is in, and whether it is
  pixels at all.

  **Each detail tier is its own program.** `terrain.frag` holds a detailed near tier and
  a cheap far one and chose between them per pixel, so every pixel of the valley walls
  was compiled — and scheduled — for a near path it never ran. CDLOD selection now knows
  which tiers a patch can contain: one that never comes within the split draws with
  `FAR_ONLY`, one wholly inside it with `NEAR_ONLY`, and only the ring of patches that
  straddle the band needs the program that holds both and cross-fades. Pixel-identical,
  and it makes the tiers separately measurable: the near tier costs 7.5 ms over a whole
  frame, the far tier 2.3 ms.

  **The sun visibility is its own pass** (`tersun.frag`). The same CDLOD patches are
  rasterised once into a screen-sized R8 buffer that holds nothing but each ground
  pixel's sun visibility, and `terrain.frag` fetches it by fragment coordinate. The pass
  costs 0.27 ms, shares the frame's depth buffer so it doubles as a depth prepass, and
  takes the cascade read out of the shader that covers the screen. It picks its tier —
  filtered PCF near, a single tap far — over the same cross-faded band the ground uses,
  so the boundary is not a contour you can find on the hillside.

  **Nothing is sampled for a weight of zero.** The ground sampled all four of its
  materials for every pixel and then blended three of them at zero: a meadow pixel took
  nine taps of triplanar rock, a cliff pixel nine taps of stochastic grass, and every
  pixel in the valley took the snow tile and the four noise fields behind the lake's
  shore wash — a wash that is a hairline along one shore within 120 m of the camera. The
  survey photograph's classification now runs first, because it is what decides which
  materials are present; each material block sits behind its own weight; the ridge field
  that ragged the snow line is skipped 160 m below it, where it cannot change anything;
  and inside the stochastic blend a cell's rotation, offset and rotated gradients are
  computed inside its own test, so a cell whose sharpened weight rounds away costs
  nothing. All of it exact where the weight is zero, and it is most of the win.

  Material sampling is what remains (2.8 ms of the 5.4): scanned 2K tiles taken at 16x
  anisotropy on ground seen at a grazing angle. `R3D_ANISO=<n>` sets the filter (the
  default is unchanged at 16; 4 is worth 1.0 ms and 1 is worth 1.7 ms).

  The shadow pass is 1.2 ms of the frame and has nothing to give: re-using the far
  cascades between frames — their windows are snapped to a 14 m and a 64 m grid — is
  worth 0.15 ms standing still and nothing while walking, so it is not in the tree.
## v0.6.1 — 2026-09-05

### Fixes

- **`ludic new` scaffolded a project that would not compile.** The project name went
  straight into the `program <Name>` identifier, so `ludic new my-game` wrote
  `program My-Game` — a subtraction — and the first `ludic run` failed with
  `expected '{', got '-'`. A name is now turned into a valid identifier
  (`my-game` → `MyGame`, `2048` → `Game2048`), and a name that cannot be a
  directory or a package is refused with the rule rather than mangled.

  Found while auditing every command's flags and arguments, along with:

  - **Unknown options are errors.** `ludic build --headles` silently built a
    windowed binary; `ludic build -o` with no path silently ignored it. Both now
    say what is wrong and exit non-zero.
  - **`ludic fmt` formats in place**, as its help always claimed — it was printing
    the file to stdout and changing nothing. `ludic fmt --check` reports drift
    without writing, for a hook or CI.
  - **`ludic test nosuch.ludic`** says the file does not exist instead of passing it
    to the compiler.
  - **`ludic build-lib`** reported failures as a shell syntax error (an
    interpolation written in a non-interpolating string), and its no-argument
    auto-detection picked up `package.lock.ludic` as a module to compile.
  - Error messages that still began with `x:` — the CLI's old name — now say
    `ludic:`.
## v0.6.0 — 2026-09-05

### Refactoring

- **`ludic` is only the language's command line now.** The toolchain's own tasks —
  building the compiler from its IR seed, the regression suites, the docs site,
  releases — moved out of it into a separate `ludic-dev` binary that is built from
  a checkout and is not part of an install.

  - **`ludic help` is what a user can actually do**: `new`, `run`, `build`, `test`,
    `add`, `fmt`, `lsp`, `doctor`, `upgrade`. No section about a repository they do
    not have. Typing `ludic dev …` says where those tasks went rather than failing
    as an unknown command.
  - **`ludic dev <task>` becomes `ludic-dev <task>`** for contributors; every task
    is otherwise unchanged. The bootstrap is now
    `bin/ludicc tools/ludic-cli/dev.ludic -o bin/ludic-dev && bin/ludic-dev build`.
  - The shipped binary drops from ~880 KB to ~190 KB, since none of the release,
    docs-generation or bootstrap machinery is linked into it any more.

### CI

- The docs deploy triggers on a change to `install.sh`. The site publishes the
  installer, but the workflow's path filter did not mention it — so a release that
  only fixed `install.sh` left the old script live at the URL the landing page
  tells people to pipe into `sh`.
## v0.5.2 — 2026-09-05

### Fixes

- The installer also covers a non-login interactive `bash` — the shell most Linux
  terminal emulators start, which reads only `~/.bashrc`. That file is now created
  when it is missing (its presence changes nothing else about how bash starts),
  while `~/.bash_profile` is still only appended to when it already exists, since
  creating that one would stop bash reading `~/.profile`.
## v0.5.1 — 2026-09-05

### Fixes

- `ludic version` reports the version of the toolchain it belongs to. It looked for
  `bin/ludicc` and `VERSION` beside the *current* directory, so it answered
  "(version unknown)" from a project — which is the only place a user ever runs it.
  It now resolves the compiler through the install root, like every other command.

  `install.sh` also now puts `ludic` on `PATH` for every shell, not just the one
  `$SHELL` names. The PATH edit lives in one file (`~/.ludic/env`) that each
  profile sources, and the profiles are chosen to cover what people actually open:
  `~/.profile` for sh and login bash, `~/.zshenv` because zsh never reads
  `~/.profile`, `~/.bashrc`/`~/.bash_profile` when they already exist, and fish's
  config when fish is installed. Re-running the installer does not add a second
  copy, and `--no-modify-path` still touches nothing.
## v0.5.0 — 2026-09-05

### Features

- **One command installs Ludic, and `ludic` is the command you use.** Getting
  started no longer means cloning the repository and learning a task runner called
  `x`.

  - **`curl -fsSL https://workshopsoft.pages.workshopsoft.io/ludic/install.sh | sh`** installs a complete
    toolchain — compiler, CLI, engine runtime, bundled `ludic.*` packages,
    formatter and language server — into `~/.ludic` and puts it on your `PATH`.
    Prebuilt artifacts are verified against a published checksum; where none
    exists for the platform, the installer bootstraps from the compiler's own IR
    seed with clang. Uninstalling is `rm -rf ~/.ludic`, and `ludic upgrade`
    re-runs the same script.
  - **`ludic` replaces `x`** and is the only command a user of the language meets:
    `ludic new` scaffolds a project that builds and plays as it stands, `ludic
    run` / `ludic build` compile it (`--headless` for a deterministic render),
    `ludic test` runs every `test` block in the project, and `ludic add` / `get` /
    `update` / `verify` / `vendor` drive packages. `ludic fmt` and `ludic lsp` are
    the formatter and language server, so an editor needs no path configuration.
    `ludic doctor` reports whether the install is complete and usable.
  - **The toolchain's own tasks moved under `ludic dev`** — `dev build`, `dev
    test`, `dev reseed`, `dev bootstrap-cfree`, `dev docs-gen`, `dev release` and
    the rest are unchanged apart from the namespace. `bin/x` is gone; the
    bootstrap is now `clang selfhost/ludicc.seed.ll -o bin/ludicc && bin/ludicc
    tools/ludic-cli/main.ludic -o bin/ludic`.
  - **An install root is a first-class layout.** The compiler derives it from its
    own location — the parent of its `bin/` directory — so `~/.ludic` and a repo
    checkout are the same shape, and `$LUDIC_HOME` is no longer needed to build a
    windowed game outside the repo. The bundled `ludic.*` packages resolve from
    `$LUDIC_HOME/packages`, so `import "ludic.core/components.ludic"` works with no
    `ludic_modules/` to set up. Release artifacts are complete install roots
    (`bin/` beside `runtime/`, `packages/` and `VERSION`) rather than bare
    binaries, and the installer ships with the documentation site it is served
    from.

### Fixes

- **Token cards are back on the docs site.** Clicking a keyword, type, builtin or
  namespace method in any code sample opens its summary card again. The card's
  styling had been left behind in `docs.css` during the site redesign, so on the
  landing page — which links only `base.css` and `site.css` — the card rendered
  unstyled at the foot of the document instead of beside the token. It now lives
  in `base.css` with the rest of the highlighter chrome, and is positioned
  `fixed`, matching the viewport coordinates the script computes, so a card opened
  on a scrolled reference page lands on its token rather than off it.
- Release checksums are one `.sha256` file per artifact instead of a single
  `SHA256SUMS`. A release is assembled from more than one host — a Linux runner
  cannot build the macOS toolchain — and `ludic dev publish` never overwrites an asset that
  is already attached, so a shared `SHA256SUMS` was written by whichever host
  published first and then never covered anything added afterwards. Per-artifact
  names compose across hosts. Verify one with
  `shasum -a 256 -c ludic-X.Y.Z-src.tar.gz.sha256`.

### Documentation

- CONTRIBUTING documents what a self-hosted Forgejo runner needs for CI to work at
  all: every workflow clones `${{ github.server_url }}`, which on a self-hosted
  instance is an internal address, so job containers must be able to resolve it.
  The runner's default is a fresh per-job network the Forgejo container is not on,
  which fails the clone — intermittently, because Docker forwards unresolved names
  to the host resolver, so CI can look healthy for a while before it stops.
- The README is rewritten around what a reader needs first: what the language is,
  a code sample, how to build it, and an honest status. Removed the repo-layout
  table and the Chrono Rift keybindings (a game manual in a language README), the
  nine links to wiki pages that no longer exist, and a "language at a glance"
  bullet describing a retired vocabulary — it advertised `system`, `reads`,
  `writes`, `requires` and `ensures`, none of which are keywords; the declaration
  keyword is `handler`.

### CI

- The commit-lint workflow survives a force-push. It linted
  `${{ github.event.before }}..${{ github.sha }}` without checking that `before`
  still resolves, so rewriting or garbage-collecting that commit failed the job
  with `fatal: Invalid revision range` on a push whose messages were all valid. It
  now falls back to linting the tip commit when `before` is gone.
- The docs deploy is serialised. Publishing is a force-push of an orphan `pages`
  branch, so two runs racing could land out of order and leave the site holding the
  older build — with both runs reporting success. A `pages-deploy` concurrency
  group with `cancel-in-progress` means a newer push cancels an older in-flight
  build instead of queueing behind it.
## v0.4.0 — 2026-09-05

### Features

- **Prefabs.** `prefab Grunt: Creature { Stats { hp: 30 }, Weapon { def_id: 1 } }` names a model with preset fields; `spawn Grunt { Position { x: 40 } }` spawns it, the spawn's own fields winning over the presets. Prefabs chain (`prefab Grunt: Foe` where `Foe` is a prefab) so shared presets live once. `spawn` is now also an expression yielding the new entity (`let e = spawn Grunt { … }`), and `Prefab.spawn(name: "Grunt")` spawns one chosen at runtime by name (-1 when none matches).
- **`countdown` fields.** A component field declared `frames_left: countdown = 0` is an `int` the engine steps toward 0 once per Update for every live entity carrying the component (never below 0). Roll timers, invulnerability frames, hit flashes and cooldowns need no hand-written "decrement each frame" handler: set the field, test it.
- A `machine` over an enum-typed store maps its states to the enum by name: with `enum HeroState { Idle, Rolling }` and `var hero_state: HeroState = HeroState.Idle`, `machine hero_state { state Idle { … } state Rolling { … } }` dispatches on `HeroState.Idle` / `HeroState.Rolling` — no `state Idle = HeroState.Idle` repetition, and a state that names no variant is a compile error. A bare enum is now a first-class `int`-sized type for `var`, params, fields and returns (`llty`), and `Enum.Variant` folds in a global initializer.
- A handler inside a scene `layer` may carry `@Queries(these: […], on: Model)`, so a scene can own its per-entity systems (`@Queries(these: [Particle]) handler AgeSparks phase Update { … }` runs once per matching entity only while that scene is active). Any other annotation on a layer handler is reported.
- A program-scope `var` may be initialized with any expression: `var run: Progress = new Progress`, `var speed: int = BASE_SPEED * 2`, `var origin: IVec2 = IVec2.zero()`. Initializers the compiler cannot fold run once at startup (`@L_init_globals`, after the runtime boots and before the `Start` phase), in declaration order. Previously such an initializer was silently replaced by `0` / `null`.
- Engine managers for what every action game hand-rolls: **`Fx.sparks` / `Fx.number` / `Fx.clear`** — engine-owned sparks and floating damage numbers, moved and aged each Update and drawn after the sprites, with no component, model, handler or draw call in the game; **`Audio.define(name:, path:)` + `Audio.play(name:)` / `Audio.play_music(name:)` / `Audio.named`** — a sound bank by name (the handle form still works); **`Camera.shake_for(amount:, frames:)`** — a timed shake the engine decays; **`Assets.enqueue`** now loads `.wav` / `.mp3` into the sound bank and `.ttf` / `.ttc` into a font table (**`Assets.font(name:)`**) alongside images, so one loading scene covers everything; **`Prop.count()`** — how many live entities carry a component.
- Every compiler diagnostic is reported as `file:line: error: message` — the file the line really lives in, even through imports — so editors can jump to it. Unexpected characters are errors (they used to be skipped silently), and defining one `function` twice is reported in source terms instead of failing in the IR assembler.
- Less to write for a game. **`Map` cell API** — `Map.get/set/fill/rect/border/random_cell/is_solid/is_solid_at/width/height`: a game edits the engine's tilemap in place and asks it what is solid (from the `Solids` config) instead of keeping its own grid. **`Sprite` does the small animation work**: `move_id` is the strip drawn while the entity moves, `face: 1` turns it toward its movement, and the `flash` / `blink` countdowns give a white hit flash and an invulnerability blink with no handler. **`scene X shows Menu`** — the engine opens the menu (and frees the cursor) on enter, draws it last in Overlay, and closes it on exit. **`import "dir/*.ludic"`** imports a directory in name order. **`IVec2.distance2/within/heading/along/step`** and **`Angle.diff_degrees`** cover the geometry every action game rewrites; **`List.sample`** draws distinct random picks; **`Input.move_i`** is the standard top-down movement intent; **`AimMode.Auto`** aims with the mouse, or the right stick while a pad is connected; **`Weapon.set_rate` / `Weapon.rate`** change a fire rate in place; projectiles now die on `Solids` tiles by themselves; **`Screen.bar`** draws a meter.
  Handlers inside a scene's layers are scene-qualified (`Play_Draw`), so two scenes may both name a handler `Draw`; `enable` / `disable` of a scene's own handler by its bare name still works from inside that scene.
- The engine's numeric parameters have names. ludic.core: `BodyPolicy { Platformer, TopDown }`, `BoundsPolicy { Clamp, Wrap, Bounce, Kill }`, `AnimMode { Loop, Once, PingPong }`; ludic.shooter: `AimMode { Mouse, RightStick, MoveDirection, NearestEnemy }`, `WeaponPattern { Single, Cone, Ring, Spiral }`; ludic.npcai: `BrainModel { StateMachine, Utility, BehaviourTree }`, `AiState { Patrol, Chase, Attack, Flee }`; ludic.gameplay: `StatKind { MaxHp, Attack, Defense, Speed }`, `ModifyOp { Flat, Percent }`; ludic.rpg: `StatusKind { Poison, Regen }`; the input runtime: `CursorMode { Normal, Hidden, Locked, Confined }`. `Body { policy: BodyPolicy.TopDown }` reads as what it is; the old integers still work. The input runtime also names the gamepad buttons: `PadButton { A, B, X, Y, LeftShoulder, RightShoulder, Back, Start }` for `Input.bind_pad(button:)`.
- The second "write less" round, all generic. **ludic.gameplay**: `Stats` carries the build stats every action game bolts on — `damage_pct`, `crit_pct`, `leech_pct` / `leech_hp`, `thorns`, `fire_rate_pct` — and `Combat.damage` applies them itself (a `Crit` event fires; thorns never reflect thorns); `Stats.add(e, stat, amount)` changes a base stat in place and `Stats.scale_hp(e, percent)` scales hp and max_hp; `StatKind` names every code. **ludic.shooter**: `Dash { frames, speed, cooldown_frames }` with `Dash.start(e, dx, dy)` / `Dash.active(e)` — a dodge roll with i-frames the package guards; `Melee { range, half_arc, damage, knockback, frames, cooldown_frames, arc }` with `Melee.swing(e)` (hits every hostile in the arc, knocks back, fires `MeleeHit`) / `Melee.ready` / `Melee.active`; projectiles drawn by the engine in their weapon's colour (`Weapon.set_color`); `TopDown { reticle, reticle_length }` draws the aim line and a mouse cross; the weapon system honours `Stats.fire_rate_pct`. **ludic.dungeon** (new package): `Dungeon.arena / open_arena / random_style / set_exit / entry_point / opposite / at_edge`, with `Side` and `RoomStyle` — arena rooms with mirrored cover, door lanes and exits by side, built into the engine tilemap. **Compiler**: `scene Splash lasts N then Next` (a timed scene), `button … goto: Scene` (a click changes scene, no listener to write). **Runtime**: `Map.random_cell_far`, `Sprite.draw_meter` (hearts / pips), `Assets.enqueue_dir`, `Collider.center`, `Prefs.max`. Also `scene X loads then Y` (the loading scene: pumped, drawn, `AssetsReady` fired), `Prop.despawn_all()`, `Map.to_tile`, and `Brain { hunt_blind }` in ludic.npcai (seek the nearest hostile without line of sight). `Prefab.spawn_at(name:, at:)` spawns and places; `Weapon.reset(id)` restores a definition (no pierce, no homing, its fire rate). Five regression examples cover the additions (`examples/library/prefabs`, `component_access`, `scene_menus`, `managers`, `combat_kit`). `Random.weighted(weights:)` draws an index by weight; `ui` widgets inherit `font` / `size` / `fg` / `align` from their panel; the input runtime names `MouseButton { Left, Right, Middle }`.
- `@ClearColor(expr)` takes any constant expression, so a named palette colour (`@ClearColor(COLOR_FLOOR)`) works as well as a hex literal.
- `Ai.seek` + path-aware `brain_seek` — when a Solids tilemap is present the NPC-AI routes a blocked straight line around obstacles with `Grid.a_star`, so foes flow around pillars instead of getting stuck.
- `Key.*` compile-time key constants (`Key.Space`, `Key.Escape`, `Key.A`, `Key.Up`, ...), folded like `Color.*`; and `Font.*` / `Ui.* / File.*` namespaces so `png_load`/`font_load`/file I/O are namespaced.
- `Os.pid()` returns the process id, for scratch files that concurrent runs of one tool must not share.
- `Overlay` render phase — runs after the engine Render systems (sprites, lights) and before present, so a game's HUD / menus are never painted under an actor. Byte-identical when unused.
- `Prop.of(entity)` and `Prop.has(entity)` — typed access to one entity's component from an entity handle, the same binding a query loop makes. `Hero.of(player).iframes = 20` reads and writes fields directly (no `World.prop_id` / `World.field_id` / `World.get` reflection chain); `Prop.has(e)` is true when `e` is in range, alive, and carries the property, so `-1` is a safe "no entity". A package that declares a real `prop_of` / `prop_has` function keeps it.
- `Solids.solid2` — an optional second solid glyph (e.g. a closed door) the move system also blocks.
- `Sprite.strip(sheet, col, row, count, rows)` — register N consecutive animation frames in one call (the base id for `SpriteAnim`).
- `Sprite` component draws atlas ids (#90) — `Sprite.atlas = 1` routes `esys_sprite` through `atlas_draw_ex` (scale/flip/tint) so atlas cells / multi-cell spans (tall characters) use the engine sprite-render system, not just the 16x16 table.
- `Ui.close()` — deactivate the retained UI (no menu open); the readable form of `Ui.open(id: -1)`.
- `[a, b, c]` list literals build a slice in place; the first element fixes the element type, later elements must match, and `[]` is an error (use `new []T`). Tables of records read as `[Row { … }, Row { … }]`.
- `ludic.prefs` package — `Prefs.*`, a human-readable `key=value` text store for scores / options (the right tool for "remember my best run"; a whole-world `Save.write` is not).
- `v.x` and `v.y` read the components of an `IVec2` value (a local, a global, a record field, or a call result) — the readable form of `IVec2.x(v)` / `IVec2.y(v)`. The compiler's static typing now also follows function return types, namespace calls, `Prop.of(e)` and record fields, so `@Computed` fields expand in those positions too.
- engine tilemap-render system (`TileSkin`, shipped from ludic.core) — one entity per glyph paints the whole `Map.*` grid each Render frame *before* sprites, so a game stops hand-looping the map. `esys_tileskin` registered ahead of `esys_sprite`.
- engine-driven retained UI — a program with a `ui` block has its navigation ticked by the frame loop automatically (from the frame key) and an activation now emits a `UiClicked { id }` event, so scenes react with `@On(UiClicked)` instead of polling `Ui.clicked`. New `Ui.*` namespace (`Ui.open/tick/clicked/set_text/render/build`).

### Fixes

- A `UI_Name` handle can be read from any code — a plain function, an `@On(UiClicked)` listener, a global initializer — not only from handlers and scene hooks. The widget table it indexes is now built on first use instead of when `@ui_build` is emitted, which came after functions and listeners and crashed the compiler on such a reference.
- A `var` declared twice — including a game `var` whose name the spliced engine runtime already uses (`ui_font`, `grid`, …) — is now a compile error naming the variable and, when it is the runtime's, saying so (`variable ui_font is also a variable of the engine runtime; choose another name`). Previously the two became one LLVM global and clang reported a redefinition in generated IR. The same check covers `property` names (`property Cell is also a property of the engine runtime; choose another name`); before, the first declaration silently won and field lookups failed with a confusing message.
- A `{` or `}` inside a string literal within an interpolation hole (`` `{f("{")}` ``) is text, not structure; the hole scanner used to miscount it.
- A windowed build that reaches the audio runtime indirectly — through the atlas / `Assets.*` preload queue (which feeds `.wav`/`.mp3` into the sound bank) or the engine sprite-render system, without any `Audio.*` call in the game — now links the native audio backend (`audio.ll` + AVFoundation). Previously `ludicc -o` failed at link with undefined `snd_*` symbols for any windowed game declaring a `Sprite` component; the import of `runtime/native/audio.ludic` now flags the backend link itself.
- Character literals accept the same escapes as strings (`'\''`, `'\\'` and `'\"'` were silently read as 0); an unterminated character literal is now an error.
- Hand-written runtime preludes (string, Os.*, Fs.*, Crypto.*, …) now live under their own `@lp_` symbol prefix, so a user `function` named `is_ws`, `str_eq`, `path_join` and the like no longer collides with them at link time.
- Named arguments now work on namespace functions (`@Namespace(Foo)` and `namespace Foo { export function … }`), not only on builtins and bare functions: `Weapon.def(name: "pistol", fire_rate: 9, damage: 14, speed: 8, spread: 0, pellets: 1, pattern: 0)` reorders to the declared parameter order like any other call. Previously every named call on a namespace function failed with "wrong number of arguments".
- The documented bootstrap works on a fresh clone. `bin/` is gitignored and not
  checked in, so `clang selfhost/ludicc.seed.ll -o bin/ludicc` — the first command
  in the README, in COMPILING, in CONTRIBUTING and on the site — failed with
  `ld: open() failed, errno=2 for 'bin/ludicc'`. Every copy now begins with
  `mkdir -p bin`, which is what CI had been doing all along.
- Unary minus keeps its operand type: `-f` on a `fixed` is a `fixed` (it was typed `int`, which broke mixed arithmetic and comparisons).
- `become Scene` now works from an `@On(Event)` listener, a global handler, or a plain function (#91). Code outside a scene's own layers cannot know the leaving scene at compile time, so the compiler emits `@L_scene_leave()` — a dispatch on the live scene id that runs its `on exit` — and calls it there. Previously a listener's `become` reused the last emitted handler's scene (or crashed), and a global handler's `become` skipped the leaving scene's `on exit` entirely.
- `ludic-fmt` keeps `rows[i]`, `new []int`, `s[a..b]`, `emit(…)`, `~x` and list-literal braces tight, and recognises `<< >> & | ^ ~` as operators.
- `ludic-fmt` no longer glues an opening parenthesis to a preceding operator: `let moving = (a or b)` stays as written instead of becoming `let moving =(a or b)`.
- `self()` inside an `@OnSpawn(Model)` or `@OnAttach(Property)` body is now the entity being constructed. Previously it was the entity of the innermost query loop — or the constant 0 when the spawn happened outside any loop — so a hook such as `@OnSpawn(Hero) handler Remember { player = self() }` silently recorded entity 0.
- `x += y` / `-=` / `*=` / `/=` now lower exactly like `x = x op y`: a Q16.16 `fixed` multiplies and divides through the 64-bit path, a string `+=` concatenates, and an `int` added to a `long` widens (they previously emitted raw integer arithmetic on the LLVM type).
- `x release` keeps a changeset's markdown intact. Bodies used to go through
  `tr '\n' ' '`, which flattened every multi-line changeset into one paragraph —
  nested bullets came out as inline `" - "` runs and a release read as a single
  unbroken wall of text. A section is now grouped by change type (**Features**,
  **Fixes**, **Performance**, …) with one bullet per changeset and continuation
  lines indented to stay inside it.

  - `x release --dry-run` renders the next section to stdout and writes nothing,
    so a release can be read before it is cut.
  - `x changelog-section <version>` prints one release's section from
    `CHANGELOG.md`; `x changelog-render` re-renders a section from a directory of
    changesets. The v0.1.0 and v0.3.0 sections were re-rendered with these.
- cursor `mode 3` (confined) now keeps the OS cursor **associated** (absolute position preserved) and hidden, instead of dissociating it like `mode 2` (lock/relative). Only true-lock `mode 2` uses relative deltas now; `win_mouse` reports the absolute position on `mode 3` and clamps it to the framebuffer. And `mode 3` now **physically confines** the cursor: each frame the platform layer warps it back to the window's content rect (`CGWarpMouseCursorPosition`) whenever it strays past the edge, so clicks can't land outside and the window keeps focus. This lets a top-down game hide + confine the cursor while `aim_mode 0` (mouse aim) keeps resolving to where the reticle points — previously any confine/lock mode silently broke absolute mouse aim, and a confined cursor still escaped the window (#89 follow-up).
- reserved words (`new`, `match`, `spawn`, ...) can no longer name a function — the compiler errors instead of miscompiling.
- the shooter aims / homes / fires from a body's **centre** (Position + Collider offset + half-size) instead of the Position anchor, so auto-aim and homing target what is drawn, not a corner.

### Documentation

- The generated site is redesigned around reading rather than launching: a warm
  paper ground with a serif display face, one ink-blue accent, and rules instead
  of floating cards. Colour is reserved for code. Dark mode is the same design
  with the ground inverted, driven entirely by tokens under one
  `prefers-color-scheme` block, and the landing page's scroll-reveal animations,
  gradient headline, glowing badge and emoji feature icons are gone.

  - Stylesheets are linked files (`base.css` + `site.css`/`docs.css`) instead of
    being inlined into all 900+ pages, which cuts the published site from 16 MB to
    5 MB and means a design change no longer requires regenerating to be seen.
  - Fonts are the platform's own; the site makes no webfont request.
  - `api.css` was dead — the generator never referenced it — and is removed along
    with `item.css`, which `docs.css` replaces.
  - A page no longer flashes its own title on every plain visit; only a deep link
    highlights its target, and under `prefers-reduced-motion` the highlight no
    longer stays on the element permanently.
  - The copy leads with what is verifiable — ahead-of-time compiled, an ECS in the
    syntax, deterministic fixed-point, no C in a build — and the "get started"
    steps now begin with the clang-plus-seed bootstrap, without which `bin/x` does
    not exist on a clean checkout.

### Build

- `x` no longer prints a clang warning on every build. Each `clang` invocation the
  task runner makes now passes `-Wno-override-module`, the same flag `ludicc`
  already passes for its own link step: the emitted IR names no target triple, so
  clang substitutes the host's and says so — four times per `x build`, with
  nothing to act on. (The comment in `selfhost/main.ludic` claimed the opposite,
  that the IR *does* carry a triple; it does not.)

### CI

- Releases are published by CI from a tag instead of by hand from a laptop. The
  new `release` workflow triggers on a `v*` tag, builds the toolchain from the IR
  seed, runs `x test`, `x test-tools` and `x bootstrap-cfree` against the tagged
  tree, and only then creates the Forgejo release. It refuses to publish when the
  tag and `VERSION` disagree or `CHANGELOG.md` has no section for that version.

  `x publish [vX.Y.Z]` is the command behind it and works locally too: it builds
  `dist/` (a source tarball from the tag, this host's toolchain, and a
  `SHA256SUMS` covering both — releases previously shipped no checksums) and takes
  the release notes from that version's `CHANGELOG.md` section, so the notes and
  the changelog cannot drift. Re-running it only adds assets the release is
  missing, which is how a macOS build gets attached to a Linux-built release.
## v0.3.0 — 2026-09-02

### Features

- **Tiled map support (#67–#74)** — load and draw [Tiled](https://www.mapeditor.org/) maps (TMX/TSX/TX and TMJ/TSJ/TJ), the design record from #66.

  - **P0 parsing primitives (#67)** — a minimal pure-Ludic XML reader (`Xml.*`) for the element/attribute/CDATA subset TMX/TSX/TX use; standard base64 decode/encode (`Base64.*`, RFC 4648), whose decoder ignores the whitespace Tiled wraps into `<data>`; and gzip framing (`z_gunzip`, RFC 1952) wrapping the existing DEFLATE inflater. zlib and the JSON reader already shipped. A curated, attributed golden corpus lands under `assets/tiled-fixtures/`.
  - **P0.5 TMX/TSX reader (#68)** — `Tiled.read` / `Tiled.read_tsx` map the native XML formats onto the *same* intermediate the JSON path produces — a `Value` tree in Tiled's JSON schema, with every tile layer's data decoded to a dense GID list (CSV, base64, base64+zlib, base64+gzip). A CSV `.tmx` and a base64+zlib `.tmj` of the same map read structurally identically; the in-repo Kenney `sampleMap.tmx` + external `sampleSheet.tsx` load with no manual JSON re-export.
  - **P1 core load + render (#69)** — the runtime `rt_tmap` model (heap-allocated to `w·h`, lifting the old `96×64` cap), the GID resolver (`Tiled.resolve` → tileset / local id / H·V·D flips), image-backed rendering (`Tiled.draw`, flips applied at blit), and the legacy-tilemap compatibility projection so `Grid.*`/`Path.*`/`esys_move` keep working. `Tiled.load` reads either format, resolves external tilesets + images, and auto-projects a `collision` layer. The Kenney sample loads and renders pixel-identically from `.tmx` and `.tmj`; the `grid` and `physics_tiles` demos now run off a loaded map.
  - **P2 collision & grid (#70)** — normalise three collision sources into the byte tilemap `esys_move`/`Grid.*`/`Path.*` read, in the design's priority order: per-tile `<objectgroup>` hitboxes, the `solid`/`oneway`/`trigger` property convention (`Tiled.collision_kind`/`Tiled.tile_shapes`), and the designated collision layer (`Tiled.project`, any non-zero GID solid) — or drive collision from a visual layer's per-tile metadata alone (`Tiled.collide`). The property convention and the collision-layer fallback produce the same feed; `Path.a_star` over a loaded map matches the hand-authored baseline.
  - **P3 animated tiles + tile objects (#71)** — a tileset `<animation>` advances deterministically as a pure function of the fixed 60/s engine frame clock (`Tiled.frame_gid`/`Tiled.animated`), so an animated GID resolves at draw to the current frame's GID with its flip flags preserved and reproduces frame-for-frame across runs; `Tiled.draw_anim` draws a map with animations advanced. Object-layer entries with a `gid` render the tile image (with their own flips), bottom-anchored, as placeable sprites.
  - **P4 objects, properties, templates, spawning (#72)** — all object shapes (rectangle / ellipse / point / polygon / polyline / text) and custom properties parse and are queryable (`Tiled.object`, `Tiled.object_shape`, `Tiled.prop`/`Tiled.prop_int`/`Tiled.prop_type`); class properties resolve their defaults against a project custom-type table (`Tiled.load_types` over `objecttypes.xml`); template instances inherit their `.tx`/`.tj` template's fields; and an object maps onto Ludic components on demand (`Tiled.spawn`/`Tiled.spawn_layer`, off by default, via the reflection ABI).
  - **P5 breadth (#73)** — image layers (parallax + repeat) and group layers (flattened, with recursive offset/opacity/tint/visible; `Tiled.layer_kind`/`Tiled.layer_offsetx`/`Tiled.layer_tint`); the isometric / staggered / hexagonal orientation coordinate transforms (`Tiled.cell_x`/`Tiled.cell_y`, driving the tile draw so cells land at the correct screen coords); and Wang-set GID resolution through the standard resolver (the terrain-corner authoring concept is editor-side and ignored).
  - **P6 scale (#74)** — infinite/chunked maps: `<chunk>` (TMX) and JSON `chunks[]` decode and flatten into the dense layer; `.world` stitching (`Tiled.world`/`Tiled.world_count`/`Tiled.world_map`) lists member maps at their offsets; and a self-contained pure-Ludic **zstd** decompressor (`z_zstd`, RFC 8878) for base64+zstd layers — frame + raw/RLE/compressed blocks, raw/RLE/direct-weight-Huffman literals, and the full FSE sequence path — decoding the low-entropy GID streams a tilemap produces (a high-entropy FSE-compressed-Huffman-weights block fails cleanly with -1 rather than emitting wrong bytes).
- Builtin NPC AI (#61) — the source package **ludic.npcai**, a perception → decision → action stack that plugs into the other controllers instead of re-implementing movement. The AI never moves a body directly: it writes the SAME intent fields the player controllers read (`want_x`/`want_y`/`want_fire`, `want_jump`), so an enemy gunner reuses the shooter's weapon/projectile/auto-aim systems verbatim (set the body's `TopDown.aim_mode = 3`) and a companion reuses the mover — friendly vs enemy is faction + goal, not different code. **Perception** (`Vision` + `Memory`, throttled `esys_perception` with faction filtering and optional `Grid` line-of-sight) remembers the nearest hostile and emits `TargetSpotted`/`TargetLost`. **Decision** offers three models writing one `Brain` intent — a finite-state machine (patrol/chase/attack/flee), a utility scorer, and a canonical behaviour tree — each decision veto-able via `cancellable DecisionMade`. **Steering** adds Reynolds flocking (separate/cohere), and a `Follower` component gives companion stances. Reuses ludic.gameplay Faction (who is hostile) + Stats (hp for flee). Fully deterministic: perception + replan are frame-throttled and fixed-order. Example: `examples/games/npcai_demo.ludic` — one enemy perceives, chases and shoots a target through the shooter controller, flees at low hp under the utility model, and a companion follows its leader.
- Builtin Platformer controller (#58) — the reference implementation of the six-lever extensibility contract, shipped as the source package **ludic.platformer**. Movement feel is all defaulted POD data (`Platformer { move_speed, jump_height, apex_frames, fall_gravity_mul, coyote_frames, jump_buffer_frames, air_jumps, policy, … }`); the controller is decomposed into small engine-owned sub-systems — input (Input phase), move/gravity/jump (FixedUpdate, before the shared `esys_move` sweep) and animation-state (LateUpdate, after it) — each independently switch-off-able with `disable system <fn>`. It owns movement *policy* only and reuses the engine Body/Collider swept-AABB collision. Jump feel derives gravity + impulse from height/apex, with coyote time, jump buffering, variable jump height and multi-jump; every jump decision emits a `cancellable JumpRequested` / `JumpPerformed` / `Landed` / `StateChanged` event, and a gravity `policy` enum (asymmetric / symmetric / floaty) is the formula hook. Ships the opt-in game-loop layer too (`scaffolding.ludic`): moving & crumbling platform blocks with rider carry, collectibles + `Score`, springs, hazards + a light `Life`/i-frames model, and checkpoint/goal triggers. Deterministic integer Q16.16 throughout. Examples: `examples/games/platformer_demo.ludic`, `examples/games/platformer_scaffolding.ludic`. Also fixes a latent codegen bug in `ludic_sweep_entity` (an SSA register name collided once a program declared ≥11 events).
- Builtin RPG systems suite (#59) — the source package **ludic.rpg**, seven independently-usable modules on the six-lever contract, with name-keyed data registries so a game or mod adds content with zero code. **A Movement** — one `Mover` with a `mode` selector (grid / free / grid-tween) and 4/8-axis, tilemap walkability, and `cancellable MoveRequested` (locked doors/ice) / `TileEntered` (encounters) / `Interacted` (the action-button raycast). **B Inventory** — a name-keyed item registry, per-owner counts, gold, `ItemUse` veto, and `Equipment` whose bonuses flow through the gameplay Stats modifier stack. **C Crafting** — a data-driven recipe + ingredient registry; `Craft.can`/`Craft.make` consume from the inventory. **D Quests** — quests + objectives whose progress is driven by `Quest.notify` (route any gameplay signal in), auto-completing when met, plus a global flag store for branching. **E Dialog** — an Ink/Yarn-style graph registry (nodes + choices) with a per-speaker `Dialog` component and `cancellable DialogChoice` for skill-check gating. **F Puzzles** — Sokoban `Pushable` + a switch / pressure-plate / gate signal graph (logic puzzles with no code). **G Status** — over-time poison/regen effects routed through the shared Combat pipeline. Everything is integer-deterministic, so save/load (world_save) and rollback hold. Example: `examples/games/rpg_demo.ludic` (21 self-checks across all seven modules).
- Builtin top-down Shooter controller (#60) — the source package **ludic.shooter**, conforming to the six-lever contract and built on the engine Body/Collider + ludic.gameplay Faction/Combat/Stats. `TopDown` decouples movement from aim (`aim_mode`: mouse / right-stick / move-direction / nearest-enemy auto-aim, with a `turn_rate` for tank-style rotation). Weapons are a name-keyed **registry** (`Weapon.def("shotgun", …)` — add a gun with zero code) with per-weapon fire-rate, damage, speed, spread, pellet count, pattern (single / spread cone / ring / spiral), plus data-driven pierce (`Weapon.set_pierce`) and homing (`Weapon.set_homing`); `esys_weapon` reads a `want_fire` intent so the **same** weapon fires for a player (input) and an NPC (AI). `Projectile` + `esys_projectile` is a self-contained deterministic pool: integrate, TTL, faction-filtered hit through `Combat.damage`, pierce, and homing that curves onto the nearest enemy — every step observable via `ProjectileSpawned` (mutable/veto) / `ProjectileHit` / `ProjectileExpired`. A budgeted `Spawner` wave director emits `SpawnRequested` / `WaveCleared`. Example: `examples/games/shooter_demo.ludic` (11 self-checks: movement, aim, faction damage, friendly-fire immunity, spread, kill, ring, homing, waves).
- Canonical engine-ABI components (#77) — the shared `Position` / `Body` / `Collider` / `Solids` bundles the engine-owned movement system (`esys_move`, #65) reads by name are now shipped from a base source package, **ludic.core**, instead of being re-declared by hand in every game and example. A game `import "ludic.core/components.ludic"` and the engine moves and collides its entities for free; extend by *composition* (attach your own components on the same model). AOT means the properties compile straight into the consumer's compile-time ECS with no ABI seam, and everything stays integer + Q16.16 deterministic (lockstep / replay / `world_save` hold). Example: `examples/library/core_components.ludic`.
- Cursor capture (#89) — `Input.cursor_mode(mode)` hides / locks / confines the OS mouse for a windowed game: `0` normal (visible, free), `1` hidden (hide the OS cursor while focused so a game draws its own reticle), `2` locked (hidden + dissociated — the mouse feeds *relative* motion through `Input.mouse_dx/dy`, and `Input.mouse_x/y` becomes a clamped virtual cursor, the FPS / twin-stick aim mode), `3` confined (dissociated but visible; the mouse cannot leave the window). The platform auto-releases (shows + reconnects the cursor) while the window is not key (Cmd-Tab) and on close, so the cursor is never left captured. Adds the native macOS implementation in `cocoa.ll` (`[NSCursor hide]/[unhide]`, ref-counted and toggled only on change; `CGAssociateMouseAndMouseCursorPosition`; `CGGetLastMouseDelta` for the relative virtual cursor) behind a new `win_cursor_mode` intrinsic; headless / non-windowed it is a no-op (DCE'd). Example: `examples/library/cursor_capture.ludic`.
- Declarative Render clear + present (#86) — `@ClearColor(0xRRGGBB)` makes the engine own the per-frame clear and flip: at the top of the Render phase it clears the framebuffer to the declared colour, and after the Render handlers run it presents the frame, so a game's Render handler no longer repeats `Screen.clear(color)` / `Screen.show()` and the clear colour is configured *declaratively* rather than in the handler body. Opt-in and backward-compatible: a program with no `@ClearColor` is byte-for-byte identical (it clears/presents itself, or the light system owns the present). Example: `examples/library/clear_color.ludic`.
- Deterministic camera zoom (#78) — `Camera.zoom(scale)` scales the whole view about the screen centre by a Q16.16 factor (`1.0` = none, `2.0` = 2x in, `0.5` = out). It rides on the same two framebuffer chokepoints (`rt_put_px` / `rt_fill_rect`) that already carry the camera offset, so it composes with `Camera.set`/`follow`/`shake`, and it is a *render-time* transform — the world coordinate types stay integer pixels + Q16.16 velocity, so lockstep, replay and `world_save` are untouched, and the zoom itself is deterministic. Gated by an internal `rt_cam_zoomed` flag so a game that never zooms renders byte-for-byte identically (golden renders unchanged); `Camera.zoom(1.0)` turns it back off. This is the concrete outcome of the #78 position-types investigation (`docs/RFC-POSITION-TYPES.md`), which rejected hardware floats for the deterministic coordinate core and identified zoom as the one genuinely-missing render feature. Example: `examples/library/camera_zoom.ludic` (pixel-readback verified).
- Directional int input (#79) — `Input.axis_i(neg, pos) -> int` returns a -1/0/1 movement intent (`+1` positive key held, `-1` negative, `0` neither or both) read from the multi-key device set, so turning WASD into movement no longer needs the `ki(key_down('d')) - ki(key_down('a'))` bool-to-int glue and feeds an int mover directly: `dx = Input.axis_i('a', 'd')`, `dy = Input.axis_i('w', 's')`. Complements `Input.axis` (fixed) / `Input.vector` (normalized). Example: `examples/library/input_movement.ludic`.
- Engine sprite-render system (#85) — the engine already auto-*ticks* SpriteAnim and Motion; it now auto-*draws* too. Declare a `Sprite` component (id + optional offx/offy/scale/flip/tint/hidden, shipped from **ludic.core**) on an entity with a `Position` and the engine draws it each Render frame — no hand-written Render handler querying positions and calling `draw_sprite` per entity, and no hand animation (when the entity also carries `SpriteAnim`, the current frame is added to the base id). Registered on the compile-time engine-system registry for the Render phase and spliced only when a game declares `Sprite`, so a game that never declares it compiles byte-identically; a game wanting a custom draw omits `Sprite` (or `disable system esys_sprite`). Also **deprecates the bare `draw_sprite` / `draw_sprite_scaled` globals** in favour of the namespaced `Screen.sprite` / `Screen.sprite_scaled`: a direct bare call now emits a one-time compile-time deprecation note (the bare form still lowers, since `Screen.sprite` uses it), and the in-repo `chronorift` demo is migrated to the namespaced calls. Example: `examples/library/sprite_render.ludic`.
- Entity-pool stats (#80). Ludic's ECS is already pool-based: the allocator recycles freed entity slots through a freelist (a `despawn`ed slot is reused by the next `spawn` before any new slot is taken), and component storage is fixed per-entity arrays — so spawning and despawning many entities per frame (bullet-hell / horde) does **no per-spawn heap allocation** and cannot fragment. Exposes that with a `Pool.*` namespace so a game can watch the reuse and budget against the cap: `Pool.live()` (entities alive now), `Pool.free()` (freed slots waiting to be reused), `Pool.reserved()` (high-water — slots ever allocated; stays flat across a steady spawn/despawn loop, the proof that slots are pooled not reallocated), and `Pool.capacity()` (the fixed entity cap). Zero-cost — they read the existing allocator counters inline. Example: `examples/library/pool.ludic`.
- Gameplay-controller foundation (#57) — the shared, cross-genre building blocks the builtin controllers stand on, shipped as the source package **ludic.gameplay**: a deterministic `Cooldown` frame timer (engine-ticked), a `Stats` attribute bundle with an unbounded timed **modifier stack** (`Stats.total` computes base+flat then percent on demand; expired modifiers self-despawn), a `Faction` friend/enemy/neutral relationship table (same-id-friendly / different-hostile by default), and a `Combat` damage pipeline whose `cancellable DamageAboutToApply` hook lets a game veto a hit *or rewrite the amount* (`Combat.set_amount`) and which emits `Damaged`/`Died`/`Healed`. Everything is integer-only so lockstep, replay and `world_save` snapshots hold. Also adds extensibility **lever 5** to the language: `disable system <esys_fn>` drops exactly one engine-owned system's tick at compile time, so a game can carry a well-known component but tick it with its own handler (byte-identical when nothing is disabled; the C-free bootstrap fixpoint is untouched). Example: `examples/library/gameplay_foundation.ludic`.
- Incremental asset preloading (#82). Assets used to load synchronously inside Boot/Start (`png_load`, `Audio.load`), stalling the first frame(s) as content grows, with no built-in loading phase. Adds an `Assets.*` preload queue: `Assets.enqueue(name, path)` queues a named image without loading it, `Assets.pump(max)` loads up to `max` queued assets per frame (returning how many it loaded), and `Assets.total` / `loaded` / `ready` / `progress` (0..100) drive a progress bar. A loading scene pumps a few assets per frame, draws `Assets.progress()`, and `become`s the play scene once `Assets.ready()`, so the game shows a responsive loading screen and only enters play once content is ready — the deterministic, no-threads form of async preloading (the work is spread across frames instead of stalling one, and the same enqueue+pump order loads identically every run). Loaded assets are reachable by name via `Assets.get` / `Sprite.named`. Builds on the #81 atlas. Example: `examples/library/preload.ludic`.
- Input Manager + automatic device-layer drive (#83). The generated frame loop now commits the input device layer itself — when a game uses any Input action-map / device method it calls `input_poll` each frame (reading the live key, recording/replaying, and rebuilding the held-key/mouse/gamepad state), so `Input.active` / `Input.key_down` / the mouse and pads read live **without the game calling `Input.poll` by hand** (previously the loop fed only `Input.key`, and the device layer read empty unless the game polled at the top of its Input phase). A game that uses no Input runtime keeps the plain `rt_poll` path, byte-identical. Adds the Input-Manager API on top: `Input.action(name, key)` ships a **default** binding (kept if already bound, so a player's `Input.rebind` or a loaded key-map is not clobbered); `Input.bind_pad(name, button)` makes an action **device-agnostic** (fires from keyboard *or* gamepad); and `Input.active` / `Input.just_pressed` / `Input.just_released` read the whole multi-key device layer with clean on-press / on-release edges (the deterministic, dispatch-free equivalent of event handlers — a handler polls the edge and reacts, so a replay fires identically). Examples: `examples/library/input_manager.ludic`, `examples/library/input_auto.ludic`.
- Namespace block form (#76) — `namespace Name { export function foo(…) … internal function bar(…) … }` declares a `Name.*` namespace once and controls its public surface declaratively, instead of annotating every function with `@Namespace(Name)` one at a time. Inside the block each `function short(…)` is emitted as `namelower_short`; an `export` function (the default) is callable as `Name.short(…)`, while an `internal` function is a private helper — emitted and callable by its short name from siblings in the block (calls are rewritten to the emitted name), but not part of the `Name.*` surface (`Name.internalOne()` is a compile error). It is the block sugar for the per-function `@Namespace` annotation, so a package's public API reads at a glance. A namespace declared the old per-function way is unchanged. Example: `examples/library/namespace_block.ludic`.
- Namespaced spritesheet / atlas API (#81). Sprite loading was a bare `png_load("floor0.png")` — one file per 16x16 sprite, with no way to load one sheet and address a cell by grid coords or name. Adds a `Sprite.*` / `Assets.*` runtime (over the variable-size image loader, so a cell is a sub-rect of the kept image and is **not** restricted to the 16x16 sprite table): `Sprite.sheet(path, cellw, cellh)` -> handle, `Sprite.cell(sheet, col, row)` and `Sprite.cell_span(sheet, col, row, cols, rows)` -> id (a sprite may span more than one cell — a tall character, a wide object), `Sprite.define(name, …)` / `Sprite.named(name)` to name and look up a cell, `Sprite.draw` / `Sprite.draw_scaled` (through the camera / zoom / clip, like `Screen.sprite`), `Sprite.width` / `height`, and `Assets.image(path)` / `Assets.load` / `Assets.get(name)`. Spliced on demand; a program that uses neither compiles byte-identically. Example: `examples/library/atlas.ludic`.
- Optional world boundaries (#84) — declare a single `Bounds` config entity (a rect `x, y, w, h` plus a policy, shipped from **ludic.core**) and the engine-owned world-bounds system keeps every moving `Body` inside the play area each frame, so a game no longer hand-clamps `Position`. Four policies: `0` clamp (walls), `1` wrap (toroidal), `2` bounce (clamp + flip the Body velocity on the axis that hit), `3` kill (despawn a body fully outside). It reads each body's `Collider` size so the whole box stays inside; off by default (no `Bounds` entity = open world). Registered on the engine-system registry for LateUpdate (after movement integrates) and spliced only when a game declares `Bounds`, so a game that never does compiles byte-identically. Also adds `World.despawn(entity)` — the reflective, by-id form of the `despawn` statement (runs `@OnDespawn` + frees the slot), which the kill policy uses and any system can call. Example: `examples/library/world_bounds.ludic`.
- Package manager (#63) — `x add` / `x get` / `x update` / `x verify` / `x vendor` bring third-party packages to Ludic with no new infrastructure. Dependencies are named by their git import path (URL-as-identity, no registry — a `git tag vX.Y.Z` is publishing), resolved by Go-style Minimum Version Selection, fetched into a content-addressed global store (`~/.ludic/store`, keyed by a file-content hash) and linked into each project under `ludic_modules/`. A `package.ludic` manifest declares dependencies, the provided `Foo.*` namespace(s), the kind (source or prebuilt) and, for prebuilt libs, the shipped targets; `package.lock.ludic` pins the resolved versions and content hashes for reproducible, verifiable builds. A source package's Ludic compiles into the consumer via a new module-root import fallback in the compiler (`import "git.workshopsoft.io/user/pkg/foo.ludic"` resolves against `$LUDIC_MODULES`, default `ludic_modules/`), so a package registers a namespace the same way the built-in stdlib does. Namespace collisions and missing prebuilt targets are hard errors. Existing programs compile byte-for-byte identically; the C-free bootstrap fixpoint is untouched. See docs/PACKAGES.md.
- Package-declarable namespaces & engine systems (#62) — the two hooks that made `Foo.*` stdlib namespaces and engine-owned systems compiler-hardcoded are now data-driven registries, so a package registers them with no compiler edit. `@Namespace(Name)` on a function opens a `Name.method(…)` namespace that dispatches to the bare `name_method` through the same generic path the built-in namespaces use (applied only after them, so it never shadows a core one). `@EngineSystem(Component, Phase)` registers an engine-owned system the frame loop runs each phase when the component is present — the package-declarable form of the built-in SpriteAnim/Motion/Light2D systems, reading components by name through the reflection ABI so an unused registration is byte-identical. Both annotations are keyword-free. The core stdlib keeps its optimized codegen (byte-identical output; the C-free bootstrap fixpoint is untouched) and packages ride the generic registry alongside it. This completes the packaging prerequisite for shipping gameplay-controller libraries (#58–#61) as real packages. See docs/PACKAGES.md.
- Prebuilt binary packages (#64) — a package can now ship a compiled artifact whose exported functions, systems and components a consumer uses without the source, over the stable reflection C-ABI. `x build-lib <module.ludic>` compiles a package's module to a per-target native dylib (`lib/<target>/`); a `kind prebuilt` dependency is fetched and linked like any other, and `x link-flags` prints the clang flags to link the module dylibs into a game (or `x app` does it in-repo). A module registers its dynamic components (`world_register_prop`) and its `@System(Phase)` functions with the host at load through a constructor, and the host dispatches every registered system each frame — the systems analogue of dynamic components. Binary packages are native-only and second-class ECS by design (source packages remain the portable, first-class, deterministic path); missing a build target is a hard error. See docs/PACKAGES.md.
- The engine runtime ships with the toolchain, not the project (#75). The compiler auto-splices `runtime/native/*` for any ECS game; a `runtime/...` import that is not found relative to the build is now resolved from the install root **`$LUDIC_HOME`** (default: the compiler binary's directory — where the platform `.ll` files already come from) *before* the package module root. So an external game that consumes the `ludic.*` packages no longer has to copy or symlink the engine runtime into its `ludic_modules/`; that directory holds only third-party packages, and the runtime is part of the toolchain install. In-repo builds are byte-identical (the runtime still resolves locally there, so the `$LUDIC_HOME` fallback never fires and the C-free bootstrap fixpoint is untouched).

### Fixes

- **Correct the element type of a slice indexed by a member-access expression.** `emit_index_addr` set the global `g_addr_ty` to the slice's element type *before* evaluating the index expression, so an index that was itself a struct-field access (`slice[obj.field]`) overwrote it — the load then came back typed as the field, and a following field access failed with "member access on non-aggregate". The slice branch now sets `g_addr_ty` last, matching the raw-pointer branches. Also de-duplicate the `@strcmp` declaration (centralised in the head prelude) so a program that pulls in both the world table and the filesystem prelude links.
- Input.key_pressed / key_released edges now fire (#87). In a frame-loop game the edges never triggered: the loop (since #83) commits the device layer once per frame via `input_drive`, but a game that *also* called `Input.poll` by hand committed a second time in the same frame, and `input_device_commit` copies `in_held` into `in_prev` at the top of every commit — so the second commit left `in_prev == in_held` and `key_pressed` (`held && !prev`) / `key_released` could never see a transition. Fixed with an `in_have_frame_driver` flag: the loop's `input_drive` sets it, and a manual `Input.poll` under the loop becomes a no-op that returns the frame's key instead of re-committing. An entry-driven harness has no loop, so the flag stays false and each `Input.poll` still commits a frame of input as before (record/replay and the #50 device tests are unchanged). Example: `examples/library/input_edge.ludic` (press edge on the down frame, release edge on the up frame).
- Windowed games no longer force-quit on Esc or 'q' (#88). The macOS platform layer (`runtime/native/cocoa.ll` `win_poll`) used to hard-code Escape (keycode 53) and the character 'q' as *quit* — storing `W_running = 0` so a shipped windowed game died the instant a player pressed Esc (a universal pause key) or typed 'q'. Those dev-loop conveniences are removed for windowed builds: **Escape is delivered to the game as key 27** and **'q' is an ordinary key**, consistently across both the single per-frame key (`@W_key`) and the `#50` held-key set (`ev_keyval` now maps Escape→27, not 'q'). A windowed game now owns Esc/pause and shuts down via `quit()` or the window close button (which still ends the run). The headless test driver (`rt_poll` in `core.ludic`) keeps its own `'q'` = quit for scripted golden runs, so nothing headless changes. Also stops forwarding consumed key events to `-sendEvent:`, which was triggering AppKit's system "funk" beep on every keystroke.

## v0.2.0 — 2026-09-01

The types-and-systems release. Ludic grows a real type system — sum types,
`option`/`result`, exact and arbitrarily-big numbers, string-keyed containers and
packed 2D value types — alongside an engine that auto-runs animation, motion and
lighting over components a game merely declares, a full input stack from
rebindable action maps to native gamepads, out-of-band Audio / HTTP / Jobs
standard libraries, and a built-in test framework with line coverage. Every
addition is gated and additive: a program that never touches a feature compiles
byte-for-byte identically, and the C-free bootstrap fixpoint is untouched.

### Language & types

- **feat**: Tagged-union enums (#56) — an `enum` variant may now carry a payload (`enum Tile { Empty, Wall, Door(int), Portal(int, int) }`), making it a sum type. Variants construct by name and `match` destructures them, binding each payload, with exhaustiveness and arity checked so adding a variant surfaces every site to update. Plain enums keep their zero-cost ordinal representation, byte-for-byte unchanged.
- **feat**: `result` + `try`/`else` (#46) — a fallible function returns `ok(payload)` or `err(message)`, and `try EXPR else { … }` recovers a value with the failure message bound to `error`. A plain branch on the tag: no exceptions, no stack unwinding. `is_ok`/`is_err` classify without unwrapping.
- **feat**: `option` (#53) — `some(v)` / `none()`, a maybe-a-value with no magic `-1` sentinel, read with `is_some`/`is_none`/`unwrap_or`.
- **feat**: `panic(msg)` + `assert(cond, msg)` (#8) — a clear, located `file:line: panic:` / `assertion failed:` message and a clean exit 1 instead of a raw segfault; the source location is baked in at compile time.
- **feat**: `IVec2` + `Rect` 2D value types (#1) — by-value spatial types that lower to packed integers, so they copy like scalars and never allocate: an integer 2D vector for grid coordinates and a Q16.16 axis-aligned rectangle for HUD boxes and hitboxes, both exact and platform-identical.
- **feat**: `BigInt` + `Decimal` exact numbers (#52) — arbitrary-precision integers and exact base-10 fixed-point for game economies, so an idle counter never overflows and `0.10 + 0.20` is exactly `0.30`. No `f32`/`f64`; deterministic.
- **feat**: `Huge` + `Angle` + `Percent` (#55) — a display-scale idle/incremental big number (`1.23e45`), an auto-wrapping radian angle over deterministic `Math.*` trig, and a `[0,1]`-clamped fraction for health, volume and interpolation `t`.
- **feat**: `Dict` + `Set` containers (#54) — string-keyed lookups over one open-addressing hash table (FNV-1a, linear probing, tombstones), for resource counts, registries, tags and visited tiles; O(1) average instead of a linear scan.
- **feat**: Value tree + reflection + JSON (#44) — a self-describing `Value` node, `Reflect.serialize`/`apply` to walk an entity's whole component set to and from it bit-exactly, and `Json.encode`/`parse` for compact, stable, diffable text. One-call save/load for entities and the backbone of data-driven tooling.

### Engine, animation & lighting

- **feat**: Engine-owned systems (#43) — the ECS hook that auto-runs a system each frame over a component a game merely declares, no `handler` wired: `SpriteAnim` advances sprite-sheet frames and `Motion` advances value tweens for free. Built on the reflection ABI, so it costs nothing in a game that declares neither.
- **feat**: Animation ergonomics (#48) — an ergonomic layer over those systems: `Anim.clip`/`Anim.play` for named spritesheet clips, `Anim.on_frame`/`fired` frame events, `Motion.to` one-call tweens, and fluent engine-advanced `Tween` handles (`to`/`chain`/`delay`/`parallel`/`stop`). All integer and deterministic under replay.
- **feat**: `Light.*` 2D lighting (#4) — a deterministic software light-accumulation pass over the framebuffer: `ambient` tinting, additive radial `point` lights with linear falloff, and hard shadows cast against rectangular occluders. Integer + Q16.16, identical every run and headless.
- **feat**: ECS-native lighting (#47) — a torch is now just an entity carrying `Light2D`, a wall an `Occluder`, and one `Ambient` sets the night tint; the engine runs the whole light pass at the end of the Render phase with no `Light.*` calls wired by hand.
- **feat**: Lighting render-quality tiers (#49) — cone/flashlight `spot` lights, a `falloff` exponent, `soft` penumbra shadows, colour `gel` cookies, normal-mapped surfaces (N·L) and a `time_of_day` day/night ramp, all on the same deterministic accumulation core and consumable via optional `Light2D` fields.

### Input

- **feat**: Action maps + record/replay (#7) — gameplay reads named, rebindable actions instead of physical keys, and the single per-frame `Input.poll` makes deterministic replay fall out for free: `Input.record` captures the tape and `Input.replay` feeds it back exactly — the seed of lockstep netcode.
- **feat**: Device layer (#50) — multiple simultaneous held keys, analog axes and a normalized vector, the mouse (position/delta/buttons/wheel), gamepads and touch, all injectable on every target (`Input.press`/`set_mouse`/`set_pad`/`set_touch`) and snapshotted whole into the replay tape.
- **feat**: Native hardware bindings (#51) — the device layer's macOS side wired into cocoa.ll: live cursor position, per-frame GameController polling into gamepad buttons/axes (SDL button order), and NSTouch routing, all DCE'd out of a headless build. No API changes.

### Standard library

- **feat**: `Audio.*` (#22) — sound effects and music over a new AVAudioPlayer backend: `load`/`play`/`play_music`/`stop`/`volume`/`pitch`/`is_playing`. Out-of-band (real-time, not part of the simulation) but frame-driven, so a replay fires the same sounds at the same frames; headless builds carry it as dead-stripped no-ops.
- **feat**: `Http.*` (#6) — a poll-based HTTP/HTTPS client for out-of-band data (leaderboards, cloud saves, remote config) that never blocks the frame, over an NSURLConnection transport with system TLS on by default. Pairs with `Json.parse`; the response parser is pure Ludic and tested offline.
- **feat**: Jobs, Promises & opt-in Sync (#14) — a layered concurrency library. `Job.*`/`Promise.*` are the safe default: cooperative futures pumped a little each frame so heavy work spreads out, combined with `Promise.all`/`race`. The advanced `Sync.*` tier adds mutexes, atomics and bounded channels. A deterministic cooperative scheduler — results are collected on the main thread and a Job never touches the world directly, so lockstep and replays stay bit-exact.

### Testing & tooling

- **feat**: Built-in test framework (#12) — a `test "name" { … }` block auto-discovered and run by a synthetic runner (no `entry` to write), with `expect`/`expect_eq`/`expect_near` assertions that report every failure and exit non-zero. `expect_near` carries the tolerance fixed-point game math needs.
- **feat**: Line coverage (#45) — compile with `--coverage` and the compiler instruments each statement with a per-line hit counter dumped at exit; `bin/x test --coverage` aggregates the dumps into a per-file report naming the unreached lines. Flag-gated and additive — an ordinary build stays byte-identical.

### Fixes

- **fix**: `const` of a non-int type is no longer miscompiled. A `const` reference lowered to its initializer's raw integer bits typed as `int`, so `const X: fixed = 10.0` computed as the raw Q16.16 value `655360` instead of `10.0` — silently corrupting fixed-point math (and, in one case, spinning an infinite loop). Const references now emit their initializer with its real type. Every existing const is an `int` literal, so the lowering there is byte-identical and the bootstrap fixpoint and golden renders are unchanged.

## v0.1.0 — 2026-08-30

### Features

- Editor tooling — `ludic-fmt` (formatter) and `ludic-lsp` (language server), plus VS Code and JetBrains integrations, all built by the toolchain.
- Namespaced standard library — Math, Text, List, Random, Time, Screen, Color, Ease, Collide, Memory, Vector, DateTime/Date/Duration/Clock, Unicode, Os, Fs/Path/Mime, Log, Noise, Hash, Crypto and Uuid, each deterministic where a game needs it.
- Native 2D backend — an ECS core with a deterministic fixed-point (Q16.16) runtime, a windowed Cocoa target on macOS and a headless PPM renderer that runs anywhere.
- Self-hosted, C-free toolchain — the compiler, runtime, task runner and editor tools are all written in Ludic and built from a checked-in LLVM-IR seed with clang alone; `x bootstrap-cfree` proves the compiler rebuilds itself byte-for-byte.
- Versioning and releases — SemVer with `ludicc --version`, a changeset-driven `CHANGELOG.md`, and `x release` to bump, tag, and publish a Forgejo release with source and toolchain artifacts.

### CI

- Continuous integration — Forgejo Actions workflows build the toolchain from the seed, run the regression + editor suites, assert the C-free bootstrap fixpoint, and lint commit messages on every push and pull request.
