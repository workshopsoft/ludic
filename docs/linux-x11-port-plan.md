# Linux X11 windowed client: port plan

Status: plan only, not implemented and not committed. Scope: a Linux x86_64 desktop client (X11/Xorg, also working under XWayland) for Ludic, so OccuTown can ship `ludic bundle` output on Linux.

Read from this tree: `COMPILING.md`, `tools/ludic-cli/{build,bundle}.ludic`, `selfhost/main.ludic` (link lines ~300-420), `runtime/native/*`, `packages/ludic.render3d/{gpu,gpu_vk_draw}.ludic`, `tools/native/lib.sh`, `packages/*/native/build.sh`. `tools/server/build_linux.sh` and `GPP_REF` live in the occutown repo; their contents are assumed from the brief, not read.

## 0. Findings that change the scope

1. **render3d refuses Linux explicitly.** `gpu_select` in `packages/ludic.render3d/gpu.ludic:38-39` sets "no Vulkan window is built for linux" for any windowed OS other than windows/macos. `gvk_surface_os` (`gpu_vk_draw.ludic:2050`) has only Metal and Win32 branches, and `Os.platform() == "macos"` checks sit elsewhere (e.g. `actor.ludic:1288`). Those need Linux branches (WP3).
2. **The generated Vulkan binding has no X11 surface types.** `vk_api.ludic` and `vk_thunks.ll` contain zero `Xlib`/`Xcb` entries. `ludic-dev vkgen` must be run with `VK_KHR_xlib_surface` and `VK_KHR_xcb_surface` enabled, which adds `VkXlibSurfaceCreateInfoKHR` and `Vk.create_xlib_surface_khr`.
3. **Two build paths must both learn Linux.** `ludicc` (`selfhost/main.ludic`) links windowed builds itself: Windows via `g_target_win`, otherwise Cocoa unconditionally. `ludic build` (`tools/ludic-cli/build.ludic`) has a second copy of the link line, hard-wired to `cocoa.ll` + `-framework` (lines ~125-135), plus `http_link_flags`, `vk_link_flags` and `needed_framework`. The existing `if not is_darwin()` branches mean "headless Linux", not "Linux that can have a window".
4. **No `.c` files in the repo.** Runtime layers are hand-written LLVM IR (`.ll`) or Ludic. The X11 layer should follow suit, which makes dlopen-based design the natural fit: `vk_win.ll` / `vk_mac.ll` already load their libraries at run time and link nothing.
5. **The native-library build already supports Linux.** `tools/native/lib.sh` has a `linux-x64` target (`-fPIC -fvisibility=hidden`, `-shared -Wl,-soname`), and `selfhost/frontend/natives.ludic` already maps `linux-x64`. Item 5 is mostly "run the existing recipes in the Linux builder" (see section 5).
6. **Windows audio is WAV-only** (`audio_win.ll` header). macOS also reads MP3/AAC. `atlas.ludic:376` preloads `.wav/.mp3/.ogg`. If OccuTown ships non-WAV audio, a decoder is needed on Linux too. Check the game's asset formats before WP5.

## 1. X11 window and input layer (`runtime/native/x11.ll`, `x11_window.ll`)

### Entry points to mirror

The Windows split is the template. `win32.ll` (2014 lines) holds the platform half; `win32_window.ll` (210 lines) holds `win_resize/win_scale/win_drawable/win_retina/win_is_fullscreen/win_toggle_fullscreen`; `win_nowin.ll` holds the headless stubs (all of `win_*` returning inert values); `rtlib_win.ll` holds the clock and float helpers. macOS packs everything in `cocoa.ll` (2545 lines) plus `rtlib.ll`.

Symbols a Linux layer must define (names from `win32.ll` and `win_nowin.ll`):

| Group | Symbols |
|---|---|
| Lifecycle | `win_open(w,h,scale,title)` (called from `core.ludic:89` before main; a second call only retitles), `win_poll` (pump events, returns the polled key, `core.ludic:469`), `win_present(fb,w,h)` (software framebuffer blit, `core.ludic:384`), `win_running`, `win_close` |
| Geometry | `win_resize`, `win_scale`, `win_drawable(out)`, `win_retina`, `win_is_fullscreen`, `win_toggle_fullscreen`, `win_visible`, `win_focused`, `win_set_title`, `win_monitor_rect`, `win_monitor_count` |
| Input | `win_held(out)` (key bitset into `in_dev`), `win_held_bit`, `win_key_char(k)`, `win_text(out,max)`, `win_mouse(out)` (`[x,y,buttonmask,wheel,rawdx,rawdy]`), `win_cursor_mode(m)`, `win_cursor_maintain`, `win_cursor_make(slot,bytes,len,w,h,hx,hy)`, `win_cursor_use(slot)`, `win_pad(out)` (6 ints per pad), `win_touch(out)` (3 ints per point) |
| Clipboard | `win_clip_get`, `win_clip_set` |
| Native handles | `win_native_window` (X `Window` id), `win_native_instance` (the `Display*`/`xcb_connection_t*`), `win_metal_layer` (null) |

`input.ludic:316-345` shows the exact per-frame call order and buffer shapes. `win32.ll`'s `w_vk_char`/`w_keyval`/`w_framekey` define the key-code mapping the rest of the engine expects, so the Linux table maps X keysyms onto the same internal key numbers.

### Approach and library choice

- **Xlib (`libX11.so.6`), loaded with `dlopen`, not xcb.** Reasons: `XLookupString`/`Xutf8LookupString` give text input and layout-correct characters without libxkbcommon; clipboard (selections), `XCreatePixmapCursor`, `XPutImage` for the software `win_present`, and `XGrabPointer` are single calls in Xlib and dozens of lines each in xcb. The cost is Xlib's global lock and threading assumptions, which is fine for a single-threaded poll. The brief asks for justification: xcb is the better choice for Vulkan-only apps (Chromium and SwiftShader dropped Xlib surfaces in favour of xcb, per [the SwiftShader commit](https://swiftshader.googlesource.com/SwiftShader/+/f6386eabea2b0cc90fdf3c7d13e52cb95892b38c%5E%21/) and [Dawn's XCB fallback](https://git.axiodl.com/encounter/dawn-cmake/commit/fb0bf70459c44b31419400598b592eaaae85f932)), but a game needs the input helpers Xlib bundles. The standard Khronos loader and Mesa expose both surface extensions, so we use `VK_KHR_xlib_surface` first and, if `vkEnumerateInstanceExtensionProperties` lacks it, fall back to `VK_KHR_xcb_surface` using `libX11-xcb.so.1`'s `XGetXCBConnection`. That fallback is a stretch goal inside WP3, not a prerequisite.
- **Optional extra libraries, all dlopened and all optional:** `libXi.so.6` (XInput2 raw motion for `rawdx/rawdy` in mouse-look; without it, warp-to-centre fallback), `libXcursor.so.1` (not needed: `win_cursor_make` builds ARGB cursors through `XRenderCreateCursor` or falls back to a 1-bit `XCreatePixmapCursor`; decide in WP1), `libXrandr.so.2` (monitor list for `win_monitor_*`; without it, one monitor from the screen size), `libXext.so.6` (not needed).
- **Fullscreen** through `_NET_WM_STATE_FULLSCREEN` ClientMessage to the root window (EWMH). **Title** via `_NET_WM_NAME` (UTF8_STRING). **Close button** via `WM_DELETE_WINDOW` (feeds `win_running`). **DPI/scale**: read `Xft.dpi` from `XResourceManagerString`; `win_scale` returns round(dpi/96), `win_retina` stores the preference.
- **Gamepads** (`win_pad`): `/dev/input/js*` or evdev `/dev/input/event*` read with plain `open/read/ioctl` (no library); the Windows file uses XInput, the Mac one GameController. Mapping to the 6-int layout is the only real work. Steam Input users get a virtual XInput-style pad, so a plain evdev reader is enough for v1; make it a late work package.
- **Touch** (`win_touch`): stub returns "none". X11 desktop targets do not need it.
- **Calling convention for a dlopen layer in IR:** copy `vk_win.ll`/`vk_mac.ll` (`lvk_open`, `lvk_sym`, `lvk_bind` filling a thunk table) and `vk_thunks.ll`'s `lsl_call_*` helpers. The Xlib command set needed is about 60 functions; write the symbol table by hand or extend the existing generator. A small generator is recommended (`ludic-dev` task, ~100 lines of Ludic): list of `name / return / args` in, thunks out, to avoid 60 hand-written IR wrappers.
- Struct offsets (x86_64 LP64) for `XEvent` (192-byte union), `XKeyEvent`, `XButtonEvent`, `XConfigureEvent`, `XClientMessageEvent`, `XSetWindowAttributes`, `XSizeHints` are fixed and documented; encode them as named constants at the top of `x11.ll`, like `win32.ll` does for its structs. Note: `XEvent` layout is only valid for 64-bit; the target is x86_64 only for v1.

### Runtime libraries
`libX11.so.6` (required); `libXi.so.6`, `libXrandr.so.2` (optional); `libc`, `libm`, `libpthread`, and `libdl` for glibc below 2.34.

## 2. Vulkan loader and X11 surface (`runtime/native/vk_linux.ll`)

### Mirror
`vk_win.ll` (442 lines): `lvk_open`, `lvk_sym`, `lvk_has`, `lvk_sl_prefer/active` (Streamline hooks, which Linux can stub), the `lsl_*` NVIDIA wrappers (keep as null-returning since Streamline does not ship for Linux), `lvk_frame_pool` and the `lvk_ac_*` allocator-callback counters (pure IR, copy verbatim), `lmfx_*` (MetalFX, stubs returning 0). `vk_mac.ll` shows the multi-path search order and the layered-loader pinning (`lvk_pin_icd`), which is macOS-specific and not needed on Linux. `vk_thunks.ll` (3392 lines, generated) is shared and `lvk_bind()` fills it.

### Approach
- `dlopen("libvulkan.so.1", RTLD_NOW|RTLD_GLOBAL)`, with `libvulkan.so` as a second try; `dlsym` for `vkGetInstanceProcAddr` and let `lvk_bind` do the rest. Return 0 from `lvk_open` if the loader is missing so a game can show a message instead of crashing at startup.
- `render3d` surface branch: `Vk.create_xlib_surface_khr(inst, {sType, dpy=win_native_instance(), window=win_native_window()})`. Instance extensions: `VK_KHR_surface` + `VK_KHR_xlib_surface` (and xcb variant).
- `gpu.ludic:38` and every `Os.platform()` comparison in render3d get a `"linux"` case; check `Os.platform()` returns "linux" in `selfhost` (the check is string-based and will already do so on a Linux build host; confirm).
- Shaders: `render3d` ships SPIR-V (manifest checked in `gpu_select`), so no shader toolchain is needed on Linux.
- Drivers: Mesa (RADV, ANV, NVK) and the NVIDIA proprietary driver all ship `libvulkan.so.1`-compatible ICDs. The Vulkan loader is a distro dependency and is not bundled (like `vulkan-1.dll` on Windows).

### Runtime libraries
`libvulkan.so.1` (loader, runtime dependency of the system, not the bundle), plus the GPU's own ICD.

## 3. Audio (`runtime/native/audio_alsa.ll` or `audio_pulse.ll`)

### Mirror
`audio_win.ll` header and `audio.ll`: `snd_load(path)`, `snd_play(p,loops,rate,vol)`, `snd_stop`, `snd_playing`, `snd_set_volume`, `snd_set_rate`, `snd_set_pan`. Semantics: loops 0 = once, -1 = forever, n = n more; rate/vol/pan are 16.16 fixed; firing a playing sound restarts it rather than layering; clip bytes arrive through weak `@lp_pak_open` so sounds inside the shipped pack load. `audio_win.ll` parses RIFF WAVE only (PCM and float, any rate/channels); reuse its parser logic.

### Approach and library choice
There is no single Linux audio API. A comparison from [miniaudio](https://github.com/mackron/miniaudio) (the usual reference design): it loads ALSA, PulseAudio and JACK at run time with `dlopen`, needs no development packages, and treats PipeWire through its PulseAudio compatibility layer ([discussion](https://github.com/mackron/miniaudio/discussions/711)). Recommendation:

1. **Primary: PulseAudio "simple" API, dlopened (`libpulse-simple.so.0` + `libpulse.so.0`)**: `pa_simple_new` (stereo S16 or float32, 48 kHz), `pa_simple_write` from a dedicated mixer thread (pthreads, `threads.ll` shows the pattern). It works unchanged on PipeWire machines through `pipewire-pulse`, which is the default on current Fedora, Ubuntu and SteamOS. Latency of the simple API is good enough for effects (set `tlength` ~50 ms).
2. **Fallback: ALSA (`libasound.so.2`)** `snd_pcm_open("default")`, `snd_pcm_set_params`, `snd_pcm_writei`. About 5 functions. Used when PulseAudio is absent; on PipeWire/Pulse machines `default` already routes via the plugin.
3. Not recommended for v1: a native PipeWire client (heavier API, headers needed, no gain for a game) and writing our own mixer in a different style from Windows (we do need a software mixer, since neither Pulse-simple nor ALSA mixes voices: sum `N` active clips, apply vol/pan/rate resampling (linear), clip, write). Windows gets mixing for free from XAudio2 voices; this is the biggest piece of new logic in the port, hence the larger estimate.
- MP3/OGG: only if the game needs them (finding 6). A decoder in Ludic is large; first check what OccuTown ships.

### Runtime libraries
Optional: `libpulse-simple.so.0`, `libpulse.so.0`, `libasound.so.2`. A machine with neither plays silently (`snd_load` still returns a handle, as `audio_none` would).

## 4. HTTP transport (`runtime/native/http_curl.ll`)

### Mirror
`http_none.ll` (62 lines) lists the contract: `hs_req_new(method,url)`, `hs_req_header`, `hs_req_body(bytes,len)`, `hs_send(slot,req)`, `hs_done`, `hs_status`, `hs_body`, `hs_blen`, `hs_header(slot,name)`, `hs_free`, `hs_save_to(slot,path)`, `hs_received`, `hs_expected`, `hs_cancel`. `http.ll` (macOS, 708 lines, NSURLConnection) and `http_win.ll` (685 lines, WinHTTP) are the working implementations: they are asynchronous (a slot, polled by `hs_done`), stream to disk for large downloads (`hs_save_to`, progress via `hs_received`/`hs_expected`), and cancel. `build.ludic:205-213` `http_link_flags` and `selfhost/main.ludic` (`g_uses_http`) choose the file.

### Approach and library choice
Options considered:
- **Own TLS stack:** certificate validation, TLS 1.3, X.509 chains and a trust store in IR/Ludic. Weeks of work and a security liability. Rejected.
- **Static libcurl + mbedTLS/OpenSSL in the bundle:** reliable, but adds ~2-4 MB, and a CA-bundle path to manage, plus license notices. Viable fallback.
- **`dlopen("libcurl.so.4")`: recommended.** It exists on virtually every desktop distro (`libcurl4`, `libcurl-gnutls.so.4` is the Debian variant with the same ABI). Use the curl multi interface (`curl_multi_*`) driven from `hs_done` polls (or a worker thread), `CURLOPT_WRITEFUNCTION` into a growing buffer or a `FILE*` for `hs_save_to`, `CURLOPT_XFERINFOFUNCTION` for received/expected, `CURLOPT_FOLLOWLOCATION`. Try sonames `libcurl.so.4`, `libcurl-gnutls.so.4`, `libcurl-nss.so.4`. The CA bundle: libcurl's compiled-in path differs per distro ([curl-library thread on AppImage bundles](https://curl.se/mail/lib-2022-05/0047.html)), which only matters if we bundle our own libcurl; with the system's libcurl it is correct by construction. If we ever bundle it, probe `/etc/ssl/certs/ca-certificates.crt`, `/etc/pki/tls/certs/ca-bundle.crt`, `/etc/ssl/ca-bundle.pem`, `/etc/ssl/cert.pem` and set `CURLOPT_CAINFO`.
- If libcurl is missing, `hs_send` completes with status 0, exactly like `http_none.ll`, so the game's "unreachable" path handles it.
- The first-start data-pack download needs resume (`CURLOPT_RESUME_FROM_LARGE`) only if the macOS/Windows versions have it; check `hs_save_to` usage in `ludic.update`/`ludic.launcher`.

### Runtime libraries
`libcurl.so.4` (or `libcurl-gnutls.so.4`), pulling in the distro's OpenSSL/GnuTLS and CA store. Not bundled.

Build-system change: `http_link_flags` returns `http_curl.ll` on Linux (keeping `http_none.ll` for the dedicated server if a size or dependency reason exists; the dlopen design makes that unnecessary, one file can serve both), and `selfhost/main.ludic` adds a Linux branch to the `g_uses_http` block.

## 5. Native libraries on Linux: ludicjolt, ludicnav, ludicozz

### Mirror
Recipes: `packages/ludic.physics/native/build.sh` (Jolt v5.6.0 + `shim/jph_shim.cpp`, pinned SHA256, `JPH_CROSS_PLATFORM_DETERMINISTIC`, `-ffp-contract=off`, `-fno-exceptions -fno-rtti`), `packages/ludic.nav/native/build.sh` (Recast/Detour + `patches/`), `packages/ludic.anim/native/build.sh` (ozz-animation). All source `tools/native/lib.sh`, whose `native_target` returns `linux-x64` on a Linux host, `native_cflags` is `-O2 -fPIC -fvisibility=hidden`, and `native_link` produces `lib<name>.so` with `-Wl,-soname`. Windows differences are one `case` branch in `ludic.physics/build.sh` (`-D_CRT_SECURE_NO_WARNINGS`) and the `-implib` line in `lib.sh`; none apply to Linux.

### Approach
- Run the three `build.sh` files inside the existing Linux builder (the Docker/OrbStack image used by `build_linux.sh`) with `LUDIC_CC=clang-16` (CI already uses that, see memory notes), producing `packages/<pkg>/lib/linux-x64/lib{ludicjolt,ludicnav,ludicozz}.so`. Needs `clang++`, `curl`, `tar`, `make`-free (the scripts compile directly), plus `libstdc++` headers. Add `-static-libstdc++ -static-libgcc` to the Linux branch of `native_link` so the bundle does not depend on the host's libstdc++ version (this is the one real change; guard it with `case linux-*`).
- Determinism: Jolt's cross-platform determinism holds across x86_64 compilers with `-ffp-contract=off`; verify by comparing the existing physics determinism test between the macOS and Linux server builds (the headless server build in Docker already exercises the Jolt path if `native` lines resolve to `linux-x64`, check whether `ludicjolt` is already built there for the dedicated server; if so this item is already done).
- `natives.ludic` / `; ludic-native:` lines already resolve `linux-x64`; `native_link_flags` in `build.ludic:187-195` already emits `-Wl,-rpath,{dir}` and an `@executable_path/../Frameworks` rpath (macOS spelling). On Linux the rpath should be `$ORIGIN` / `$ORIGIN/lib`: add an `is_darwin()` split there (and the same in `selfhost`'s `native_link_args`).
- Steam: `ludic.steamworks/native/build.sh` already copies `libsteam_api.so`; no new work.

### Runtime libraries
Bundled: `libludicjolt.so`, `libludicnav.so`, `libludicozz.so` (statically linked C++ runtime).

## 6. Compiler and bundler (`ludicc --windowed`, `ludic build`, `ludic bundle`)

- **`selfhost/main.ludic` (~line 316):** add `else if g_target_linux` (or `not is_darwin()` host) windowed branch: link `x11.ll x11_window.ll` + `-ldl` (glibc < 2.34 only); with `g_uses_audio` link the audio file; `g_uses_vk` links `vk_thunks.ll vk_linux.ll` instead of `vk_mac.ll` and drops `-Wl,-needed_framework,QuartzCore`; `g_uses_win` links `rtlib.ll` (confirm `rtlib.ll` has no Mac-only symbols, which `crash.ll`/`udp.ll`/`threads.ll` having Linux builds suggest) and, for headless Linux, the `win_*` stubs from `rtlib.ll` weak definitions (as on macOS); `g_uses_http` links the new transport. `--windowed` becomes legal on a Linux host (today `ludic build` with a game links Cocoa and fails).
- **`tools/ludic-cli/build.ludic`:** the mode-1 branch (lines ~118-135) gets a Linux alternative to `{cocoa} {audio} -framework Cocoa ... -Wl,-rpath,@loader_path`; replace with `-Wl,-rpath,$ORIGIN`. `vk_link_flags`, `http_link_flags`, `needed_framework` already tolerate non-Darwin. `incr.ludic` already has a `stat` fork for Linux but `incr_test.ludic` skips Linux; incremental windowed builds stay macOS-only for v1.
- **`tools/ludic-cli/bundle.ludic:418-423`:** `cmd_bundle` refuses non-macOS non-Windows with an explicit error. Add `cmd_bundle_linux` modelled on `cmd_bundle_windows` (line 344; a folder, not a `.app`): `bin/<name>` (stripped), `lib/*.so` natives (via a `bundle_natives_linux` next to `bundle_natives_win`/`_mac`, `bundle_native_notices` unchanged), `assets/`/`packs.index` identical to the other two bundlers, `.desktop` file + icon PNG (Windows uses `.ico`; `app icon` lines in `package.ludic` need a PNG variant), and a launcher script setting `LD_LIBRARY_PATH` only if the rpath approach proves insufficient. `game_release.ludic:116-123` already names `linux` as a Velopack OS (`--os osx|win|linux`) and needs the Linux return value added.
- **Pre-main window opening:** `core.ludic:89` and the startup code in `cocoa.ll`/`win32.ll` open the window before `main` for a game. On Linux this means a constructor (`@llvm.global_ctors`) or the first `win_open`; check how `win32.ll` does it.
- **`Os.platform()`** must return "linux" (confirm in `namespaces.ludic`), and `gpu.ludic`'s fallback message changes.
- **Docs/inventory:** new keyword-free change, but the feature-integration checklist (docs pages under `docs/`) still applies to `COMPILING.md` (add a Linux section; update the "windowed (Cocoa)" wording at line 353).

### Runtime library list for the final bundle (Linux x86_64)

| Source | Libraries | Bundled? |
|---|---|---|
| glibc | `libc.so.6`, `libm.so.6`, `libpthread`/`libdl` (merged into libc from 2.34) | system; build in an old-glibc container (Ubuntu 20.04 / Steam sniper runtime, glibc 2.31) so the binary runs everywhere |
| X11 | `libX11.so.6` (required); `libXi.so.6`, `libXrandr.so.2` (optional) | system, dlopen |
| Vulkan | `libvulkan.so.1` + GPU ICD | system, dlopen |
| Audio | `libpulse-simple.so.0`, `libpulse.so.0`, else `libasound.so.2` | system, dlopen |
| HTTP | `libcurl.so.4` (or `-gnutls`) | system, dlopen |
| Game natives | `libludicjolt.so`, `libludicnav.so`, `libludicozz.so`, optional `libsteam_api.so` | bundled in `lib/` |

Because everything but libc is dlopened, `ldd bin/<name>` should show only libc/libm; that is also a good CI assertion.

## 7. Testing without a window or GPU

All of this runs in the existing Linux builder container (OrbStack/Docker, per the standing rule, never a windowed app on the Mac):

- Packages: `xvfb xauth x11-utils xdotool mesa-vulkan-drivers libvulkan1 vulkan-tools libx11-6 libxi6 libxrandr2 pulseaudio libpulse0 libasound2 libcurl4`. Mesa's `mesa-vulkan-drivers` includes **lavapipe** (`lvp_icd.*.json`), a CPU Vulkan driver; set `VK_ICD_FILENAMES` (or `VK_DRIVER_FILES`) to the lavapipe JSON to pin it. The supplied search evidence did not confirm Xvfb-plus-lavapipe presentation; verify first with `xvfb-run -a vulkaninfo --summary` and check that `VK_KHR_xlib_surface` and `VK_KHR_xcb_surface` appear in the instance extension list.
- Window layer: `xvfb-run -s "-screen 0 1280x720x24" ./game`, then `xdotool` to send keys and mouse moves, `xwininfo`/`xprop` to assert the title, size and `_NET_WM_STATE` fullscreen, and `import -window root` or `xwd` to capture a frame and diff against a reference (the existing `--headless` PPM frame verify is unaffected and complementary).
- Vulkan: a one-frame clear colour (WP2 target) with lavapipe: read the root window pixel with `xwd | convert` and assert the colour. Note that lavapipe presents through a CPU path to the X server (X11 WSI uses SHM or software blit), fine for tests, slow for real play.
- Audio: `pulseaudio --start` with `module-null-sink` in the container, assert `snd_playing`, and record the monitor source for a non-silent check; or use `ALSA_PCM` null device (`pcm.!default { type null }`).
- HTTP: a local `python3 -m http.server` plus a self-signed TLS endpoint with `CURL_CA_BUNDLE`/`SSL_CERT_FILE` pointing at the test CA.
- Natives: the existing package tests (`ludic dev test`) with `LUDIC_NATIVE_TARGET=linux-x64`.
- Real GPU smoke test: needs a Linux machine or VM with GPU passthrough; not available in OrbStack. Plan one manual pass on a real Linux box (and a Steam Deck) before release.

## 8. Work packages (hours, sequential unless noted)

| WP | Work | Depends | Hours |
|---|---|---|---|
| WP1 | **Window + software present.** `x11.ll` dlopen layer (generator for thunks), `win_open/poll/present/close/running/set_title/resize/drawable/scale/fullscreen/visible/focused`, `win_held` + `win_key_char` + `win_text` key mapping, `win_mouse` incl. buttons and wheel, `win_native_*`; hook into `selfhost/main.ludic` and `build.ludic`; Xvfb smoke test with a 2D `.ludic` game | none | 20-26 |
| WP2 | **Vulkan clear colour under Xvfb.** `vk_linux.ll`; run `vkgen` with xlib/xcb surface extensions; surface branch in `gvk_surface_os`; remove the `gpu.ludic:38` refusal for linux; lavapipe in the container | WP1 (window handle) | 8-12 |
| WP3 | **render3d Linux pass.** Other `Os.platform()` branches, swapchain resize on `ConfigureNotify`, xcb fallback surface, run the full renderer under lavapipe and fix driver-specific failures | WP2 | 10-16 |
| WP4 | **Bundler + build paths.** `cmd_bundle_linux`, `.desktop`/icon, `$ORIGIN` rpaths, `game_release` linux return, `COMPILING.md` Linux section, `ldd` assertion in CI | WP1, WP5 for natives | 8-12 (parallel with WP3) |
| WP5 | **Natives for Linux.** Run the three `build.sh` in the builder, `-static-libstdc++`, rpath fix in `native_link_flags`/`native_link_args`, determinism check | none | 4-8 (parallel with WP1) |
| WP6 | **HTTP via libcurl dlopen.** `http_curl.ll`, link-flag changes in both build paths, local TLS test, large-download + cancel tests | none for code; WP4 for link wiring | 12-16 (parallel with WP1) |
| WP7 | **Audio.** WAV parse reuse, software mixer, Pulse-simple backend with ALSA fallback, null-sink test | WP1 (for linking) | 16-22 |
| WP8 | **Input completeness.** XInput2 raw mouse, cursor images (`win_cursor_make/use/mode`), clipboard (`win_clip_*`, selection protocol), `win_monitor_*` via XRandR, evdev gamepad (`win_pad`) | WP1 | 14-20 |
| WP9 | **Hardening.** Wayland-via-XWayland test, HiDPI, multi-monitor, a real-GPU pass (Intel/AMD/NVIDIA) and Steam Deck, glibc-floor build, CI job (Linux builder runs WP1/2/5/7 tests under Xvfb) | all | 12-18 |

Total about 105-150 h. The critical path to a playable client is WP1 → WP2 → WP3, with WP5/WP6/WP4 alongside; WP7/WP8 can follow while the game is already playable without sound or a gamepad. The research limit for this plan was 30 minutes, so the hour figures are estimates from the sizes of the existing Windows files (`win32.ll` 2014 lines, `audio_win.ll` 444, `http_win.ll` 685, `vk_win.ll` 442).

## 9. Risks

- **Hand-written IR for Xlib is error-prone** (struct offsets, varargs-free but pointer-heavy). Mitigation: constants at the top, one Xvfb test per entry point, a thunk generator.
- **Lavapipe fidelity vs real drivers.** Passing under lavapipe does not prove the renderer works on a GPU (sync, formats, `VK_KHR_swapchain` present modes, memory types). WP9 needs real hardware; schedule it early rather than last if possible.
- **Wayland-only sessions.** XWayland handles X11 clients on all major desktops, but input grab, fullscreen and cursor warping behave differently (mouse-look in XWayland needs XInput2 raw motion or pointer constraints, so WP8's raw-motion piece matters). No native Wayland client is planned.
- **glibc / distro variance.** Build in a container with an old glibc, dlopen everything else; otherwise the binary will not start on older distros. The builder image behind `build_linux.sh` is pinned by `GPP_REF`; check its glibc before reusing it for the client.
- **Audio mixer correctness** (resampling, clipping, thread safety with `snd_play` calls from the game thread) is new logic with no existing Linux reference; keep it simple (linear resample, 48 kHz stereo float).
- **HTTP/TLS outside our control.** Reliance on the host's libcurl is fine for a 2020s desktop, but a stripped container or minimal distro lacks it; the failure mode must be a clear "cannot download" message in the game.
- **Determinism for co-op/server.** The Linux server already runs Jolt; make sure the client's `libludicjolt.so` is built with the same flags and compiler as the server's, or the client-side prediction and server will diverge.
- **MP3/OGG assets.** If OccuTown's audio is not WAV, WP7 grows by a decoder (estimate +16 h).
- **Compiler paths drift:** two link implementations (`selfhost/main.ludic` and `build.ludic`) must be changed in step; the reseed/bootstrap flow (`ludic dev reseed`, `bootstrap-cfree`, `test`) applies after the `selfhost` edit.
- **Cross-toolchain version.** The Linux build uses the toolchain pinned in `tools/server/GPP_REF`; the port lands in gpp, so the pin must be bumped to the commit that contains it.

## 10. Recommended first work package: a window with a Vulkan clear colour under Xvfb

Fastest visible result, about 14-18 h, in this order:

1. `x11.ll` with only: `win_open`, `win_poll`, `win_close/running`, `win_native_window/instance`, `win_set_title`, `win_drawable`, `win_scale` (returns 1), and inert stubs for the rest copied from `win_nowin.ll`. dlopen `libX11.so.6` for `XOpenDisplay`, `XCreateSimpleWindow`/`XCreateWindow`, `XMapWindow`, `XStoreName`, `XSelectInput`, `XPending`/`XNextEvent`, `XInternAtom`, `XSetWMProtocols`, `XCloseDisplay`.
2. `ludic-dev vkgen` with the xlib surface; `vk_linux.ll` (`dlopen libvulkan.so.1`, reuse the `vk_win.ll` body).
3. Link wiring for `ludicc --windowed` on Linux (just enough: the windowed `else` branch in `selfhost/main.ludic`), then a 40-line test program: open the window, create a Vulkan instance + xlib surface + swapchain, clear to a fixed colour, present three frames.
4. In the builder: `apt install xvfb mesa-vulkan-drivers libvulkan1 xwd`, `xvfb-run -a ./clear`, then `xwd -root | convert` and check the centre pixel equals the clear colour. That is the first end-to-end proof that the window, loader, surface and swapchain work on Linux, and it unblocks WP3, WP4 and WP7.
