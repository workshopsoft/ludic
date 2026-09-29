# Compiling Ludic

> **Note:** `ludicc` is **written in Ludic** (`selfhost/*.ludic`) and built from a
> checked-in IR seed — the C compiler this document once described has been
> deleted. The native pipeline below (Ludic → LLVM IR → object → binary) is
> unchanged. `ludicc` drives clang itself (via an `os_system` intrinsic), so
> `ludicc app.ludic -o bin/app` and `--emit-llvm` work directly. `--fmt` is
> reimplemented as a lex+parse gate (the doc-check hook). The `--target`/
> cross-compile and `--shared` paths are still features of the old C driver not
> yet re-implemented on the self-hosted toolchain. See the
> [Bootstrap deep-dive](https://git.workshopsoft.io/workshopsoft/ludic/wiki/Bootstrap) §5.7 on the wiki.
>
> Most people never invoke `ludicc` directly: the `ludic` CLI drives it.
>
> ```bash
> curl -fsSL https://workshopsoft.pages.workshopsoft.io/ludic/install.sh | sh   # the toolchain, into ~/.ludic
> ludic new mygame && cd mygame
> ludic run                                      # compile + run
> ludic build --headless                         # compile, deterministic render
> ```
>
> From a clean checkout, the compiler and the CLI come up in two lines and the
> CLI does the rest (run it from the repository root):
>
> ```bash
> # one-time bootstrap: clang assembles the seed, then ludicc compiles bin/ludic
> mkdir -p bin && clang selfhost/ludicc.seed.ll -o bin/ludicc
> bin/ludicc --unsafe --globals tools/ludic-cli/dev.ludic -o bin/ludic-dev
> bin/ludic-dev build                                  # the whole toolchain into bin/
>                                                      #   (ludicc, ludic, ludic-fmt, ludic-lsp)
> bin/ludicc examples/games/snake.ludic -o bin/snake   # the compiler, directly
> bin/ludic build examples/games/snake.ludic           # or through the CLI
> bin/ludic help                                       # every command
> ```
>
> A `.ludic` file with handlers is a game and links windowed by default;
> `--headless` and `--windowed` force the mode. The engine runtime
> (`runtime/native/cocoa.ll`, the spliced `runtime/native/*.ludic`) and the
> bundled `ludic.*` packages are found under the **install root**: `$LUDIC_HOME`
> if set, otherwise derived from the binary's own location — the parent of its
> `bin/` directory, which is both `~/.ludic` for an install and the repository
> root for a checkout. `$LUDIC_CC` overrides the assembler/linker (default
> `clang`).


`ludicc` is a compiler, not a translator. It lexes, parses, checks and lowers
Ludic to **LLVM IR itself**, then hands that IR to the system toolchain to be
assembled and linked. There is no C in the middle: no generated `.c` file, no C
runtime compiled alongside your game, and no transpiling step you could inspect
and find your program rewritten in another language.

```
   app.ludic
      │  ludicc — lex, parse, lower                     (selfhost/frontend/*.ludic,
      ▼                                                  selfhost/backend/*.ludic)
   app.ll        LLVM IR: your handlers, your properties, your runtime
      │  IR assembler                                   (selfhost/main.ludic drives $LUDIC_CC)
      ▼
   app.o         Mach-O / ELF / COFF object code
      │  system linker
      ▼
   app     or    libapp.dylib / .so / .dll
```

`clang` appears in that pipeline twice — as the IR assembler and as the linker
driver — which is the same role `rustc` and `swiftc` give it. Set `LUDIC_CC` to
point at a different LLVM toolchain if you have one.

## Artifacts

| you want | command |
| --- | --- |
| a windowed native executable | `ludicc game.ludic -o build/game` |
| a headless executable | `ludicc game.ludic --headless -o build/game` |
| the IR, to read | `ludicc src.ludic --emit-llvm -o src.ll` |
| the schema an editor reads (records, registries and their entries, consts) | `ludicc src.ludic --emit-schema schema.json` |
| every error, as a JSON array on stdout | `ludicc src.ludic --check --diagnostics=json` |
| a shared library † | `ludicc lib.ludic --shared -o build/liblib.dylib` |
| a game that runs in a browser † | `ludicc game.ludic --target wasm32-unknown-unknown -o build/web/game.wasm` |
| an object file † | `ludicc src.ludic -c -o src.o` |

† `--shared`, `--target`/cross-compile, `-c` and the wasm path were features of
the old C driver and are **not yet re-implemented** on the self-hosted toolchain
(see the note at the top). The rows above the line work today via the
self-hosted `ludicc`.

`bin/ludic build` wraps the common cases:

```bash
bin/ludic build examples/games/snake.ludic              # -> build/snake        (native)
bin/ludic build examples/library/combat.ludic --lib   # -> build/libcombat.*  (library)
bin/ludic build examples/games/snake.ludic --headless   # -> build/snake_headless (out.ppm)
bin/ludic build examples/games/snake.ludic --web        # -> build/web/            (browser)
```

The `--lib` and `--web` targets were part of the old C driver and are **not yet
re-implemented** on the self-hosted toolchain — `bin/ludic build` supports the native
windowed and `--headless` builds today.

## Programs and libraries

> **Not yet on the self-hosted toolchain.** `--shared` and the `nm`/library
> workflow below describe the old C driver's behavior; the self-hosted `ludicc`
> builds executables only for now. The `@export function` semantics are
> unchanged — only the packaging step is pending.

A source file opens with `program Name { … }`.

* A program with **handlers** is a game: it gets the phase-ordered frame loop
  (`Start`, then `Input → FixedUpdate → Update → LateUpdate → Render` each tick).
* A program with only an **`entry`** block is a tool: it runs `entry` and exits.
* Either kind can be a library: only its `@export function`s become public
  symbols; everything else stays private.

```ludic
# doc-check: skip — illustrative: elided body
program Combat {
  @export function damage(attack: int, armour: int, roll: int) -> int { … }
  function curve(level: int) -> int { … }          # private: not a symbol
}
```

```bash
ludicc examples/library/combat.ludic --shared -o build/libcombat.dylib
nm -gU build/libcombat.dylib
#  T _damage   T _hits_to_kill   T _xp_for        (no _curve)
```

Those are ordinary C-ABI symbols, so anything that can call a shared library can
call Ludic. To call them from another Ludic program, declare them and link:

```ludic
extern function damage(attack: int, armour: int, roll: int) -> int = "damage"
```

```bash
ludicc examples/library/arena.ludic -o build/arena -Lbuild -lcombat
```

Libraries are linked as `@rpath/…` (`$ORIGIN` on Linux) and executables search
next to themselves, so a built pair keeps working when you move it.

## Cross-compilation

> **Not yet on the self-hosted toolchain.** `--target` and `-c` were old
> C-driver flags; the self-hosted `ludicc` builds only for the host today. The
> section below records the intended design — object code for ELF, COFF and
> Mach-O from one source — which the IR pipeline already supports in principle.

`--target` takes an LLVM triple and retargets the whole pipeline:

```bash
ludicc game.ludic --target x86_64-unknown-linux-gnu  -c -o game-linux.o
ludicc game.ludic --target aarch64-unknown-linux-gnu -c -o game-arm64.o
ludicc game.ludic --target x86_64-pc-windows-msvc    -c -o game-win.o
```

Object code for ELF, COFF and Mach-O comes out of the same source with no
per-platform branches in the compiler. Linking a foreign target additionally
needs that platform's linker and sysroot, as with any cross toolchain.

## The runtime is written in Ludic

`runtime/native/core.ludic` implements the framebuffer, `fill_rect`, the 5×7
bitmap text, the registers, the RNG, input and the frame dump — in Ludic. ludicc
splices it into every native build, and a builtin call in a game resolves to a
runtime function by name: `clear(c)` calls `rt_clear(c)`. Replace that file and
you have replaced the runtime; pass `--freestanding` to build without it.

Underneath the runtime there is exactly one layer, and it is not C: a set of
compiler intrinsics that lower to direct calls into the platform ABI.

| intrinsic | lowers to |
| --- | --- |
| `mem_alloc(n) -> pointer`, `mem_free`, `mem_copy`, `mem_set` | `malloc`, `free`, `memcpy`, `memset` |
| `peek8/peek32(p, i) -> int`, `poke8/poke32(p, i, v)` | `load` / `store` |
| `ptr_add(p, n) -> pointer`, `ptr_null()`, `ptr_is_null(p)` | `getelementptr`, `null` |
| `file_open(path, mode) -> pointer`, `file_read`, `file_write`, `file_close` | `fopen`, `fread`, `fwrite`, `fclose` |
| `read_byte() -> int`, `write_byte(c)`, `print_str(s)`, `print_int(n)` | `getchar`, `putchar`, `printf` |
| `str_len(s) -> int`, `os_exit(code)`, `os_time() -> int` | `strlen`, `exit`, `time` |

That is the operating system's interface — the floor Rust and Swift stand on
too. Everything above it, including all the graphics, is Ludic.

The runtime protocol is four optional functions. Define them (or let the
prelude define them) and the entry point calls them:

| function | when |
| --- | --- |
| `rt_init()` | once, before the `Start` systems |
| `rt_poll() -> int` | once per frame; its result is what `key()` reads |
| `rt_running() -> bool` | each frame; false ends the loop |
| `rt_shutdown()` | after the loop |

## The window

`runtime/native/cocoa.ll` is the macOS platform layer, written in LLVM IR. It
talks to the Objective-C runtime through its C ABI — `objc_getClass`,
`sel_registerName`, `objc_msgSend` — and to Quartz through CoreGraphics, which
is what a compiled `.m` file does anyway; this just skips the `.m`. AppKit
paints through `-drawRect:`, so the view class is built at runtime with
`objc_allocateClassPair` and an IR function is installed as its IMP.

ludicc assembles it exactly like the program's own IR and hands both objects to
the linker, adding `-framework Cocoa`. A `--headless` build omits it entirely,
reads keys from stdin and writes the last frame to `out.ppm`; the `win_*`
intrinsics compile to nothing there, so a headless binary never references a
symbol the window would have provided.

Other platforms build headless today. A Win32 or X11 port is another `.ll` file
with the same entry points — the window (`win_open`, `win_poll`, `win_present`,
`win_running`, `win_close`), keys (`win_held`, `win_held_bit`), the mouse and
cursor (`win_mouse`, `win_cursor_mode`, `win_cursor_confine`,
`win_cursor_maintain`), gamepad (`win_pad`) and touch (`win_touch`) — and no
compiler change.

## The web

WebAssembly is a target, not a port. The front end, the type checker, the ECS
lowering and the Ludic-written runtime are the same ones a macOS build uses;
only the triple changes.

```
   game.ludic
      │  ludicc — the same lex, parse, check and lower
      ▼
   game.ll        LLVM IR, triple wasm32-unknown-unknown
      │  IR assembler
      ▼
   game.o    +    wasm.o        (runtime/web/wasm.ll, the platform layer)
      │  wasm-ld
      ▼
   game.wasm  +  index.html  +  platform.js  +  assets.json  +  the assets
```

```bash
bin/ludic build examples/games/chronorift.ludic --web
python3 -m http.server -d build/web 8000     # then open http://localhost:8000/
```

`build/web/` is self-contained: copy it to any static host — GitHub Pages, S3,
itch.io — and the game runs. It needs no server-side anything, and no
cross-origin isolation headers.

**No game logic passes through JavaScript.** The handlers, the queries, the
fixed-point arithmetic, the PNG decoder, the TrueType rasteriser and the UI are
all compiled Ludic executing as wasm. `platform.js` is 300 lines and implements
the same five-function window protocol `cocoa.ll` implements, plus the host
services wasm has no OS to ask for. It is the web's Cocoa, not an interpreter.

### The toolchain

A wasm build needs an LLVM with the WebAssembly backend and `wasm-ld`. Linux
distributions ship both in `clang` and `lld`, so nothing extra is needed there
or in CI. Apple's clang is built without the WebAssembly target, so on macOS:

```bash
brew install llvm
```

ludicc looks in `/opt/homebrew/opt/llvm/bin` and `/usr/local/opt/llvm/bin`
before falling back to `PATH`. `$LUDIC_CC` and `$LUDIC_WASM_LD` override both,
so any LLVM works — a distro one, a downloaded release, `zig cc`, wasi-sdk.

### Who owns the frame loop

A native build runs the loop:

```c
ludic_boot(); while (ludic_alive()) ludic_frame(); ludic_teardown();
```

A browser tab cannot be held inside that loop — it would never paint, and the
key events the loop is waiting on would never be delivered. So a web build
exports those four functions instead of `main`, and `platform.js` calls
`ludic_frame` from `requestAnimationFrame`. Both targets emit the four from the
same code in `ll_emit_loop_parts`, so the handlers that run, and the phase order
they run in, are identical; only the owner of the loop differs.

### The floor

`wasm32-unknown-unknown` has no libc, so `runtime/web/wasm.ll` *is* the floor —
hand-written LLVM IR, assembled by the same toolchain as everything else:

| what | how |
| --- | --- |
| `malloc` / `free` | a first-fit free list over linear memory, growing it with `memory.grow` |
| `memcpy` / `memset` | the `memory.copy` / `memory.fill` instructions (`-mbulk-memory`) |
| `strlen` | a byte loop |
| `fopen` / `fread` / `fwrite` / `fclose` / `fseek` / `ftell` | wasm imports, over a preloaded asset image and `localStorage` |
| `getchar` / `putchar` / `print_str` / `time` / `exit` | wasm imports |
| `win_open` / `win_poll` / `win_present` / `win_running` / `win_close` | wasm imports, implemented against a `<canvas>` |

Nothing above that file changes for the web: `core.ludic`, `image.ludic`,
`inflate.ludic`, `truetype.ludic` and `ui.ludic` compile to wasm unmodified.

### Assets and saves

The browser has no synchronous file access, and `file_open()` is synchronous, so
a web build ships an image of its files instead of a filesystem. ludicc records
every string literal in the program that names a file existing at compile time,
writes the list to `assets.json`, and copies the files into the bundle;
`platform.js` fetches them all before the first frame. `file_open()` then
resolves exactly the paths it resolves natively.

That is a heuristic, and a deliberately visible one: a path the compiler never
sees written down is a path the browser cannot be told to fetch ahead of time,
and a path outside the project (`/System/Library/Fonts/…`) is refused with a
warning rather than silently dropped.

Writes go the other way. `file_open(path, "wb")` buffers and commits to
`localStorage` on close, so `save()` / `load()` survive a page reload, and a
read prefers a save the player has made over the shipped asset of the same name.

### Testing a wasm build

`--headless --target wasm32-unknown-unknown` produces a bare module with no
page, driven by a runner instead of a browser:

```bash
node tools/ludic-web/run.mjs build/web/snake_headless.wasm --stdin=ddss
```

Because Ludic is fixed-point and its RNG is seeded, the native headless binary
and the wasm one must render byte-identical frames from the same input. `bin/ludic-dev test`
asserts exactly that, which is a much stronger check on the backend than
"it started".

## What a build contains

Everything: properties and models, spawn/despawn, queries with bindings,
`where` filters and model filters, `match`, `machine`/`become`,
`scene`/`layer`/`enter`, module state (`var`), `const`, int and Q16.16
fixed-point arithmetic, control flow, functions, `extern fn` FFI, strings, the
entity allocator, save/load snapshots, the frame loop, the window, and the whole
graphics stack — framebuffer, PNG decoding, sprites, 9-slice, TrueType text and
the retained UI.

None of it goes through C. `bin/ludic-dev test` asserts that directly: no C source
survives in `runtime/`, no C emitter survives in `ludicc`, and the examples all
build, run and render from IR alone.

## Every flag

The self-hosted `ludicc`/`ludic` (built with `bin/ludic-dev build-cli`) accept:

```
  <file.ludic>       the program to compile (first non-flag argument)
  -o <path>          output binary; with --emit-llvm, the IR path.
                     Parent directories are created. With no -o and not
                     invoked as `ludic`, the IR is written to stdout.
  --windowed         force a windowed (Cocoa) build
  --headless         force a headless build (stdin input, out.ppm output)
  --emit-llvm        stop at LLVM IR — write it and exit, no clang
  --check            every check a build makes (types, modules, uses, layers, ports, binds); write nothing
  --fmt              lex + parse only; exit 0 if it parses, 1 on a parse error
                     (the check-docs gate; canonical formatting not yet restored)
  --save-temps       keep the intermediate .ll
  --run              compile then run (what `ludic run` uses)
  (unknown -flags are ignored with a warning, never taken as the input file)

environment:
  LUDIC_CC           the LLVM that assembles IR and drives the linker (clang)
  LUDIC_HOME         the install root — runtime/, packages/, VERSION
                     (default: the parent of the binary's bin/ directory)
  LUDIC_MODULES      the project's fetched packages (default: ./ludic_modules)
```

Mode is automatic when neither `--windowed` nor `--headless` is given: a program
with `system`s (a game) links windowed, anything else headless.

Not yet re-implemented on the self-hosted toolchain (old C-driver flags):
`--shared`, `--emit <kind>`, `-c`, `--target`/cross-compile,
`--freestanding`, `-v`, and the explicit link inputs (`-L`/`-l`/`-framework`/
`-Wl`). Those, plus `LUDIC_WASM_LD`/`LUDIC_RUNTIME_DIR`/`LUDIC_RUNTIME`, describe
the previous driver and are documented here as intended design.

There is one backend. `ludicc` has no mode that emits C, and no part of a
build compiles or links a C translation unit — including the web one, where the
platform layer is LLVM IR and the loader is 300 lines of JavaScript that never
sees a game rule.
