# Compiling Ludic

> **Note (2026-08-27):** `ludicc` is now **written in Ludic** (`selfhost/*.ludic`)
> and built from a checked-in IR seed — the C compiler this document describes has
> been deleted. The native pipeline below (Ludic → LLVM IR → object → binary) is
> unchanged. `ludicc` now drives clang itself (via an `os_system` intrinsic), so
> `ludicc app.ludic -o bin/app` and `--emit-llvm` work directly, and a sibling
> command `ludic app.ludic` compiles to a temporary binary and runs it in one
> step. The whole toolchain is built by `bin/x build`; `bin/x app` remains as a
> convenience wrapper over the compiler. `--fmt` is reimplemented as a lex+parse
> gate (the doc-check hook). The `--target`/cross-compile and `--shared` paths are
> still features of the old C driver not yet re-implemented on the self-hosted
> toolchain. See BOOTSTRAP.md §5.7.
>
> From a clean checkout, build the compiler and the task-runner in one line, then
> let `bin/x` do the rest (run it from the repository root):
>
> ```bash
> # one-time bootstrap: clang assembles the seed, then ludicc compiles bin/x
> clang selfhost/ludicc.seed.ll -o bin/ludicc && bin/ludicc tools/x/main.ludic -o bin/x
> bin/x build                             # rebuild the whole toolchain into bin/
>                                         #   (ludicc, ludic, x, ludic-fmt, ludic-lsp)
> bin/ludicc examples/snake.ludic -o bin/snake   # compile
> bin/ludic  examples/snake.ludic                # compile + run
> bin/x help                              # list every command
> ```
>
> The binaries are multi-call (one native binary under two names): invoked as
> `ludicc` it compiles, as `ludic` it compiles-and-runs. A `.ludic` file with
> systems is a game and links windowed by default; `--headless` and `--windowed`
> force the mode. The runtime (`runtime/native/cocoa.ll`) is found via
> `$LUDIC_HOME`, defaulting to the directory the binary sits in — keep them in
> `bin/`, or set `LUDIC_HOME` and put them on `PATH`. `$LUDIC_CC` overrides the
> assembler/linker (default `clang`).


`ludicc` is a compiler, not a translator. It lexes, parses, checks and lowers
Ludic to **LLVM IR itself**, then hands that IR to the system toolchain to be
assembled and linked. There is no C in the middle: no generated `.c` file, no C
runtime compiled alongside your game, and no transpiling step you could inspect
and find your program rewritten in another language.

```
   app.ludic
      │  ludicc — lex, parse, check, lower              (compiler/ludicc.c,
      ▼                                                  compiler/native.c)
   app.ll        LLVM IR: your systems, your properties, your runtime
      │  IR assembler                                   (compiler/driver.c)
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
| a shared library † | `ludicc lib.ludic --shared -o build/liblib.dylib` |
| a game that runs in a browser † | `ludicc game.ludic --target wasm32-unknown-unknown -o build/web/game.wasm` |
| an object file † | `ludicc src.ludic -c -o src.o` |

† `--shared`, `--target`/cross-compile, `-c` and the wasm path were features of
the old C driver and are **not yet re-implemented** on the self-hosted toolchain
(see the note at the top). The rows above the line work today via the
self-hosted `ludicc`.

`bin/x app` wraps the common cases:

```bash
bin/x app examples/snake.ludic              # -> build/snake        (native)
bin/x app examples/lib/combat.ludic --lib   # -> build/libcombat.*  (library)
bin/x app examples/snake.ludic --headless   # -> build/snake_headless (out.ppm)
bin/x app examples/snake.ludic --web        # -> build/web/            (browser)
```

The `--lib` and `--web` targets were part of the old C driver and are **not yet
re-implemented** on the self-hosted toolchain — `bin/x app` supports the native
windowed and `--headless` builds today.

## Programs and libraries

> **Not yet on the self-hosted toolchain.** `--shared` and the `nm`/library
> workflow below describe the old C driver's behavior; the self-hosted `ludicc`
> builds executables only for now. The `module`/`@export fn` semantics are
> unchanged — only the packaging step is pending.

A source file opens with `game Name { … }` or `module Name { … }`.

* A **game** gets an entry point and the phase-ordered frame loop
  (`Start`, then `Input → FixedUpdate → Update → LateUpdate → Render` each tick).
* A **module** gets neither. It is a library, and only its `@export fn`s become
  public symbols; everything else stays private to the library.

```ludic
# doc-check: skip — illustrative: elided body
program Combat {
  @export function damage(attack: int, armour: int, roll: int) -> int { … }
  function curve(level: int) -> int { … }          # private: not a symbol
}
```

```bash
ludicc examples/lib/combat.ludic --shared -o build/libcombat.dylib
nm -gU build/libcombat.dylib
#  T _damage   T _hits_to_kill   T _xp_for        (no _curve)
```

Those are ordinary C-ABI symbols, so anything that can call a shared library can
call Ludic. To call them from another Ludic program, declare them and link:

```ludic
extern function damage(attack: int, armour: int, roll: int) -> int = "damage"
```

```bash
ludicc examples/lib/arena.ludic -o build/arena -Lbuild -lcombat
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
with the same five entry points — `win_open`, `win_poll`, `win_present`,
`win_running`, `win_close` — and no compiler change.

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
bin/x app examples/chronorift.ludic --web
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
and the wasm one must render byte-identical frames from the same input. `bin/x test`
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

None of it goes through C. `bin/x test` asserts that directly: no C source
survives in `runtime/`, no C emitter survives in `ludicc`, and the examples all
build, run and render from IR alone.

## Every flag

The self-hosted `ludicc`/`ludic` (built with `bin/x build-cli`) accept:

```
  <file.ludic>       the program to compile (first non-flag argument)
  -o <path>          output binary; with --emit-llvm, the IR path.
                     Parent directories are created. With no -o and not
                     invoked as `ludic`, the IR is written to stdout.
  --windowed         force a windowed (Cocoa) build
  --headless         force a headless build (stdin input, out.ppm output)
  --emit-llvm        stop at LLVM IR — write it and exit, no clang
  --fmt              lex + parse only; exit 0 if it parses, 1 on a parse error
                     (the check-docs gate; canonical formatting not yet restored)
  --save-temps       keep the intermediate .ll
  --run              compile then run (implicit when invoked as `ludic`)
  (unknown -flags are ignored with a warning, never taken as the input file)

environment:
  LUDIC_CC           the LLVM that assembles IR and drives the linker (clang)
  LUDIC_HOME         where runtime/native/ lives (default: the binary's dir)
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
