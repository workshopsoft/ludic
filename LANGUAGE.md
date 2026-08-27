# The Ludic Language — Reference

This documents the Ludic language **as actually implemented** by
`compiler/ludicc.c`. Ludic is an AI-first, statically-typed, ahead-of-time
compiled language for games: an ECS is built into the language, and programs
compile straight to machine code.

```
program.ludic ──ludicc──▶ program.ll ──▶ program.o ──▶ native exe / shared lib   (LLVM IR; no C)
```

`ludicc` lowers Ludic to **LLVM IR itself** and links the result — see
[COMPILING.md](COMPILING.md) for the pipeline, `module`/`export`, and
cross-targets. There is one backend: no C is generated, compiled or linked at
any point, and the runtime a game calls is itself written in Ludic.

## Program structure

A program is one `game` block containing declarations:

```ludic
# doc-check: skip — illustrative: elided import list
game Name {
  import ...        # pull declarations in from another file
  component ...     # data (per entity)
  struct ...        # a plain record, not tied to an entity
  archetype ...     # a named entity KIND (bundle of components)
  const ...         # compile-time constants
  fn ...            # functions
  extern fn ...     # bind a C library symbol (FFI)
  system ...        # behavior, grouped into phases
}
```

## Multi-file programs (`import`)

```ludic
# doc-check: skip — paths resolve only inside the repo
game ChronoRift {
  import "chronorift/world.ludic"    # path is relative to THIS file
  import "chronorift/combat.ludic"
}
```

An imported file is a **fragment**: bare declarations, no `game` wrapper. Its
declarations are spliced into the importing program. Imports may appear inside
the `game` block or before it, they may nest (a fragment may import fragments),
and each resolved path is **include-guarded**, so importing the same file twice
(even via different chains) pulls it in once. Diagnostics report the true file:

```
error: line 1: unknown type 'nope' for field Pos.x
  chronorift/world.ludic:1 | component Pos { x: nope = 0 }
```

## Archetypes (entity kinds)

An `archetype` names a *kind* of entity and the fixed set of components it
carries. It replaces the empty "tag component" idiom: identity is stored as one
integer per entity, not a parallel boolean array.

```ludic
# doc-check: skip — composite: declarations and statements together
component Pos   { x: int = 0, y: int = 0 }
component Stats { hp: int = 10 }

archetype Player { Pos, Stats }        # Player IS a kind, not a component
archetype Enemy  { Pos, Stats }

spawn Player { Pos = { x = 5 } }        # attaches every listed component
                                        # (seeding field defaults), then overrides
for (p, s) in query [Pos, Stats, {Player}] { ... }   # {Player} filters by kind
```

Use `{Name}` (tag position) to filter a query by archetype — an archetype can't
be *bound* to a variable since it has no fields of its own. Entity kind is part
of the saved snapshot.

## Text, fonts & images

The 5×7 bitmap `text` stays for zero-asset programs. For real typography, load a
TrueType font and draw UTF-8:

```ludic
let f = font_load("/System/Library/Fonts/Supplemental/Arial.ttf")
text_ttf(f, 20, 20, "Héllo — Καλημέρα — Привет", 0xffffff, 28)   # anti-aliased
let w = text_w(f, "measure me", 28)                              # pixel width
```

The runtime ships a from-scratch TrueType engine (sfnt tables, cmap 0/4/6/12,
simple + composite `glyf` outlines, quadratic Béziers, supersampled AA) and a
glyph cache — no external font library. Arbitrary-size PNGs load as images:

```ludic
let panel = image_load("assets/ui/panel.png")
draw_9slice(panel, x, y, w, h, 10)     # stretch edges/center, keep 10px corners
draw_image_scaled(icon, x, y, 32, 32)
```

## Retained UI (`ui`)

UI is declared as **data** — a widget tree. The engine owns layout (stacked
panels with padding / gap / alignment / grow), drawing (9-slice skins, images,
TrueType text, focus highlight) and keyboard focus + activation.

```ludic
ui MainMenu {
  panel id=Root w=288 pad=16 gap=6 skin="assets/ui/panel.png" inset=10 align=center {
    label  text="CHRONO RIFT" font=reg(R_FONT) size=26 fg=0xffe060 align=center
    button id=NewGame text="New Game" font=reg(R_FONT) size=16 w=236
    button id=Quit    text="Quit"     font=reg(R_FONT) size=16 w=236
  }
}
```

Widget types: `panel` (container + optional skin/bg/border), `col` / `row`
(pure stacks), `label`, `button` (focusable), `image`, `spacer`. Props are
evaluated at build time, so `font=reg(R_FONT)` reads a value the game set first.
Each `id=Name` mints a `UI_Name` handle (the `ui` block name too), used from
systems:

```ludic
system Boot phase Start {
  setreg(R_FONT, font_load("…Arial.ttf"))
  ui_build()                 # construct the tree (loads skins/images)
  ui_open(UI_MainMenu)       # make it active, focus the first button
}
system Nav phase Update {
  ui_tick(key())             # w/s move focus, space/enter activate
  if ui_clicked(UI_Quit) { quit() }
  ui_set_int(UI_HpLabel, hp)  # poke dynamic values by id
}
system Draw phase Render { clear(0x0e0e16)  ui_render()  present() }
```

See `examples/menu.ludic` for a complete title screen.

## Types

| Type | Meaning | LLVM IR type |
|------|---------|--------------|
| `int` | 32-bit integer | `i32` |
| `fixed` | Q16.16 fixed-point | `i32` |
| `bool` | boolean | `i32` |
| `entity` | entity handle | `i32` |
| `str` | string literal | `ptr` |
| `ptr` | raw address (runtime/FFI) | `ptr` |

Numeric literals: `42` and `0x1affff` are `int`; a literal with a decimal
point (`1.5`) is `fixed`. Arithmetic on two `fixed` values lowers to
`fxmul`/`fxdiv`; mixing `int` and `fixed` promotes the `int`. Convert with
`fx(i)` (int→fixed) and `flr(f)` (fixed→int).

## Components, entities, queries

```ludic
# doc-check: skip — composite: declarations and statements together
component Pos { x: int = 0, y: int = 0 }   # typed fields with defaults
component Player { }                        # a tag (no fields)

spawn Hero {                                # create an entity
  Pos    = { x = 10, y = 5 }
  Player = { }
}
despawn self()                              # remove the current entity

# iterate every entity that has all listed components:
for (p) in query [Pos, {Player}] { p.x = p.x + 1 }   # {Tag} filters, doesn't bind
for (a, b) in query [Pos, Vel] where a.x > 0 { ... }  # one var per non-tag term
```

Entities are integer handles; component storage and slot reuse are generated per
program. `self()` yields the entity of the innermost `query` loop.

## Systems & phases

```ludic
system Move @deterministic
  reads  [Vel]          # declared data access (parsed and reserved; not yet
  writes [Pos]          # consumed by any analysis pass — see "Not yet implemented")
  phase  FixedUpdate
  query  (p, v) [Pos, Vel]      # the entities this system operates on
{ p.x = p.x + v.dx }
```

Phases run in this order every frame: **`Start`** (once at boot), then each
frame **`Input` → `FixedUpdate` → `Update` → `LateUpdate` → `Render`**.
`edge system` marks a system that touches the outside world.

### The `query` clause

A system declares the entities it works on, alongside its phase. The body then
runs **once per matching entity**, with the components bound and `self()` giving
that entity — the query header is simply hoisted out of the body into the
signature:

```ludic
system CleanBattle phase LateUpdate
  query (b, p) [Battle, Pos, {Enemy}] where b.hp <= 0
{ despawn self() }
```

is the same program as

```ludic
system CleanBattle phase LateUpdate {
  for (b, p) in query [Battle, Pos, {Enemy}] where b.hp <= 0 { despawn self() }
}
```

Drop `(vars)` when nothing binds: `query [{Enemy}]`. A system declares at most
one query, and the number of variables must equal the number of binding terms
(`{Tag}` terms filter without binding, so they don't count). A system with no
`query` clause runs once per tick, as before.

### Conditions

A query selects on more than *which* components an entity has. `where` is an
ordinary expression evaluated with the bindings in scope, so entities can be
matched on their field values:

```ludic
# doc-check: skip — a bare system clause, not a whole declaration
  query (b, s) [Battle, Stats] where b.hp <= 0 and s.level > 3
```

The same `where` works on an inline `for (…) in query […]`.

`where` is evaluated **per candidate entity**, so it is the wrong place for a
guard that concerns the whole system (`where reg(R_MODE) != 1` would re-read the
register for every entity). Keep whole-system guards in the body of a system
with no `query` clause, wrapping an inline query — as `CleanBattle` does in
`examples/chronorift/combat.ludic`.

### Matching is lazy, not snapshotted

Both forms iterate entities by id and re-check the match as they reach each one;
there is no per-tick array of matched entities. Consequences worth knowing:

* `despawn` of the current entity, or of one already visited, is safe.
* An entity **spawned during the loop at a higher id is visited in the same
  tick**. Spawn into a later phase if you don't want that.

## Structs, arrays and slices

`struct` is the aggregate that is *not* tied to an entity — a plain record, for
the data a program keeps outside the ECS.

```ludic
struct Tok { kind: int = 0, line: int = 0, next: Tok }

system Lex phase Update {
  let t = new Tok        # allocates; every field seeded from its default
  t.kind = 1
}
```

Struct values have **reference semantics**: a struct value is a pointer to the
object, so assigning or passing one shares it rather than copying.

```ludic
struct Tok { kind: int = 0, line: int = 0, next: Tok }

fn bump(t: Tok) -> void { t.kind = t.kind + 1 }

system Share phase Update {
  let a = new Tok
  let b = a              # b and a are the SAME object
  b.kind = 9
  print_int(a.kind)      # 9
  bump(a)                # the mutation is visible to the caller
  print_int(a.kind)      # 10
}
```

Fields chain, so a struct can refer to its own type and be walked without
temporaries — which is what an AST or a linked list needs:

```ludic
system Walk phase Update {
  let a = new Tok
  let b = new Tok
  a.next = b
  print_int(a.next.kind)
  a.next.kind = 42       # chains on the left of an assignment too
}
```

Two array forms. `[]T` is the growable slice (below) and is implemented. `[T; N]`
is a **fixed array** — stored inline and zeroed — and is a design target: the
self-hosted compiler's `ptype` parses `[]T` but **not** `[T; N]` yet, so the
snippet below does not compile today. Programs use `[]T` slices for now.

```ludic
# doc-check: skip — [T; N] fixed arrays are not yet implemented (design target)
var table: [int; 8]      # module-level storage
system S phase Update {
  let buf: [int; 4]      # a local; no initializer needed
  buf[0] = 10
  table[2] = buf[0]
}
```

`[]T` is a **growable slice** — a pointer to a header holding data, length and
capacity. `push` appends, doubling the storage when it is full; because the
header never moves, an append is visible to everything holding that slice.

```ludic
system Collect phase Update {
  let toks = new []Tok
  push(toks, new Tok)
  for i in 0 .. len(toks) { print_int(toks[i].kind) }
}
```

Indexing works as both a value and an assignment target, and composes with
fields: `toks[i].kind = T_ID` is a single address computation.

## Functions & FFI

```ludic
fn heal(amount: int) -> int { return amount * 2 }

extern fn c_hypot(a: fixed, b: fixed) -> fixed = "hypot_fx"   # bind a C symbol
```
`extern fn … = "symbol"` declares a foreign function and binds it to a symbol
resolved at link time; pass `-L`/`-l` to ludicc to link its library. This is how
Ludic calls anything with a C ABI — including a shared library built from
another `.ludic` file (see `examples/lib/`).

## Statements

`let x = expr` · `x = expr` (`+= -= *= /=`) · `if/else` · `when cond { }`
(if-without-else) · `while cond { }` · `for i in a .. b { }` (numeric range) ·
`for (…) in query […] { }` · `break` · `continue` · `return` · `spawn` ·
`despawn` · `match` · `machine`.

`break` and `continue` apply to the innermost enclosing loop, and work in all
three loop forms — `while`, the numeric `for`, and the ECS query loop, where
`continue` advances to the next matching entity. Using either outside a loop is
a compile error.

## Pattern matching & state machines

`match` replaces `if`-ladders on one value. Arms list one or more literal
patterns (or `_` for the default) and a body:

```ludic
match tile {
  'T', '#' => return SPR_TREE       # multiple patterns per arm
  'D'      => return SPR_DOOR
  _        => return SPR_GRASS      # optional default
}
```

`machine` turns a register into an explicit state machine: it dispatches on the
register's value to the matching `state`, and `become` transitions to a named
state (no more `if phase == N` chains). See the co-op battle in
`examples/chronorift/combat.ludic`:

```ludic
# doc-check: skip — illustrative: elided bodies
machine R_PHASE {
  state KnightMenu = 0 { … if is_confirm(k) { …attack…  become KnightResolve } }
  state KnightResolve = 1 { … become MageMenu }
  state EnemyTurn = 4 { … become KnightMenu }
}
```

A `machine <reg>` reads `reg(<reg>)` to pick the state; `become Name` compiles to
`setreg(<reg>, <Name's value>)`. Both lower to plain branches (and `match` runs
on the native LLVM backend too).

## Expressions

Precedence: `or → and → compar(< <= > >= == !=) → + - → * / % → unary(- not) →
postfix(. () )`. Operators are built-in only (no overloading). The boolean
operators are spelled **`and` / `or` / `not`**; `&&` and `||` are not Ludic operators
and `!` are rejected with a diagnostic naming the fix (`!=` is unaffected). Bitwise operations are
functions (`band`, `bor`, `bxor`, `bnot`, `shl`, `shr`), so the symbols are free
— which is why there is only one spelling to remember. `expr with { field = … }` is not implemented; records appear
only in `spawn`. Char literals (`'w'`) are `int` code points; colors are hex
ints (`0xff8800`).

## Builtins (the standard library / runtime surface)

```
# math      min max abs clamp                       (int)
# rng       seed(i)  rng_range(lo,hi)->int  rng_chance(pct)->bool   (deterministic)
# fixed     fx(i)->fixed   flr(f)->int
# tilemap   map_size(w,h)  map_row(y,str)  tile(x,y)->int
# 2D draw   clear(color)  fill_rect(x,y,w,h,color)  frame_rect(...)  put_px(x,y,color)
#           draw_sprite(id,x,y)  draw_sprite_scaled(id,x,y,scale)  present()
# text      text(x,y,str,color,scale)  text_int(x,y,n,color,scale)   (5x7 bitmap)
# fonts     font_load(path)->id                                       (TrueType .ttf/.ttc)
#           text_ttf(font,x,y,utf8,color,px)  text_w(font,utf8,px)->int  text_h(font,px)->int
# images    image_load(path)->id   draw_image(id,x,y)   draw_image_scaled(id,x,y,w,h)
#           draw_9slice(id,x,y,w,h,inset)
# UI        ui_build()  ui_open(id)  ui_tick(key)  ui_render()
#           ui_clicked(id)->bool  ui_set_text(id,str)  ui_set_int(id,n)
#           ui_focus(id)  ui_focused()->int  ui_visible(id,bool)
# assets    load_png(path)->id           (decodes a PNG; returns a 16x16 sprite id)
# input     key()->int                   (current frame's key code, 0 if none)
# state     reg(i)->int   setreg(i,v)     (64 integer resources shared by systems)
# entity    self()->entity
# save      save()   load()->bool         (binary snapshot of the whole ECS World)
# control   quit()   print_int(i)
# process   os_argc()->int   os_arg(i)->str        (the command line; argv[0] included)
#           file_stderr()->ptr                     (a handle for file_write, off stdout)
```

## Tooling

```bash
ludicc game.ludic -o build/game         # native binary (windowed for a game)
ludicc game.ludic --headless -o g       # headless build (renders out.ppm; reads stdin)
ludicc game.ludic --emit-llvm -o g.ll   # stop at LLVM IR
ludic  game.ludic                       # compile AND run (forwards the exit code)
```

`ludicc` (compile) and `ludic` (compile-and-run) are one multi-call binary built
by `./build-cli.sh`. **[COMPILING.md](COMPILING.md) is the authoritative CLI
reference** — the full flag set (`-o`, `--windowed`, `--headless`, `--emit-llvm`,
`--save-temps`, `--run`), the `LUDIC_HOME` / `LUDIC_CC` environment variables,
and the IR-to-stdout bootstrap contract (no `-o`, invoked as `ludicc`) that
`build.sh` / `reseed.sh` rely on. The default mode is auto: a file with `system`s
links windowed, otherwise headless; an explicit flag always wins.

The retired C driver's `--shared`, `--fmt`, `-c`, cross-compile (`--target`) and
wasm modes are **not** on the self-hosted toolchain (see "Not yet implemented").
Source formatting now lives in the standalone `build/ludic-fmt` (below), not a
compiler flag.

The self-hosted compiler is intentionally permissive: it has no separate
validation pass yet, so unknown types lower to `ptr` and call arity is not
checked. Diagnostics are limited to parse-level errors
(`ludicc(self): parse error: …`); richer static checks (unknown identifiers,
duplicate types, unknown fields, arity) are future work.

### Editors

```bash
./tools/build-tools.sh                 # -> build/ludic-fmt, build/ludic-lsp
build/ludic-fmt -w src/               # format in place (keeps comments)
build/ludic-fmt --check .             # CI: exit 1 if anything is unformatted
build/ludic-lsp --stdio               # the language server, for any editor
```

`ludic-fmt` is the source formatter: it works on tokens, so comments and blank
lines survive and no file is ever rewritten into another. `ludic-lsp` speaks
LSP 3.17 and supplies completion, diagnostics, hover, go-to-definition,
find-usages, rename, formatting, outlines, folding and inlay hints — the same
binary for every editor. Both also understand ```` ```ludic ```` fences inside
Markdown, so documentation gets the same highlighting and checking as source.

Plugins for VS Code and JetBrains IDEs, plus configuration for Neovim, Helix,
Emacs, Sublime and Zed, are in `tools/editors/` — see
[tools/editors/README.md](tools/editors/README.md).

## Working programs

- `examples/chronorift.ludic` — a co-op JRPG (overworld, dungeon, boss, shop,
  save) using CC0 Kenney sprites. Split across `chronorift/*.ludic` via `import`,
  built on archetypes.
- `examples/menu.ludic` — a retained-UI title screen (9-slice panel, TrueType
  labels, focusable buttons).
- `examples/snake.ludic` — Snake, no assets — same compiler, proving generality.

```bash
./build.sh examples/snake.ludic && ./build/snake
```

## Not yet implemented

Units on quantities (`9.8 m/s^2`), `with` record-update expressions, a bytecode
VM + hot-reload, and the live agent bridge — these appear in the design docs but
are future work.

- **`scene` / `layer` / `on enter` / `on exit`** — the state-machine-over-scenes
  sugar is documented above but not parsed by the self-hosted compiler yet.
- **`reads` / `writes` clauses** — parsed and reserved on the system node, but no
  analysis pass consumes them.
- **`[T; N]` fixed arrays** — documented above, but `ptype` parses only `[]T`
  slices; fixed inline arrays are not accepted yet. Use `[]T` slices.
- **CLI: `--shared`, `--fmt`, and the wasm/cross target** — these were features of
  the retired C driver; the self-hosted `ludicc` does not carry them (source
  formatting lives in `build/ludic-fmt` instead). Output-path and IR flags are in
  flux as the CLI front-end is rebuilt — check `ludicc` usage for the current set.

`struct` and array types, `break`/`continue`, and argv/stderr — once listed here
as near-term — are now implemented and self-hosting; their lowerings are in
[BOOTSTRAP.md](BOOTSTRAP.md) §4.

## Scenes & layers

> ⚠️ **Not yet implemented in the current (self-hosted) compiler.** `scene`,
> `layer`, and the `on enter` / `on exit` hooks are a design target: the
> compiler has no `scene` declaration and [`examples/scenes.ludic`](examples/scenes.ludic)
> does not compile today (`enter Name` parses only as a `become` alias). Games
> that need mutually-exclusive states use a mode register (`reg`/`setreg`) with a
> `machine`, as `examples/chronorift` does. This section describes the intended
> syntax for when scene support lands.

A game is usually several mutually-exclusive states — a title screen, the
overworld, a battle — and the usual way to write that is a mode register
consulted at the top of every system. `scene` makes it structure instead:

```ludic
# doc-check: skip — illustrative: elided bodies
scene Title start {
  on enter { ui_open(UI_Menu) }
  on exit  { ui_visible(UI_Menu, 0) }

  layer Main {
    system Choose phase Update {
      if ui_clicked(UI_NewGame) { enter Overworld }
    }
  }
}

scene Overworld {
  on enter { spawn_party() }

  layer World { system Move phase Update { … } }
  layer Hud   { system Draw phase Render { … } }
}
```

- Exactly **one scene is active**. The one marked `start` runs first (or the
  first declared, if none is marked).
- A scene's systems only run while it is active. Systems declared outside any
  scene are global and run every frame regardless.
- **Layers group systems and declaration order is draw order**: within a phase,
  global systems run first, then the active scene's layers in the order they
  were written — so `Hud`'s `Render` paints over `World`'s.
- `on enter` / `on exit` are lifecycle hooks, not phases. Scene setup goes in
  `on enter`; a layer system may not use phase `Start`.
- `enter Name` transitions: the current scene's `on exit` runs, the active scene
  becomes `Name`, and its `on enter` runs. Inside a layer system the compiler
  knows which scene is leaving, so a transition costs two direct calls and a
  store — there is no dispatch table.

`examples/scenes.ludic` is a runnable demonstration of the ordering rules.

## Queries in a system signature

When a system's whole body is one query loop, the loop header can move into the
declaration:

```ludic
system CleanBattle phase LateUpdate
  query (b, p) [Battle, Pos, {Foe}] where b.hp <= 0
{
  despawn self()
}
```

This is exactly equivalent to wrapping the body in
`for (b, p) in query [Battle, Pos, {Foe}] where b.hp <= 0 { … }` — same
lowering, same semantics. The body runs once per matching entity and `self()`
is that entity.

Mutation during iteration follows the same rules as an inline query, because it
is the same loop: entities are visited by ascending id, `despawn` of the current
or an already-visited entity is safe, and an entity **spawned mid-loop at a
higher id is visited in the same tick**. If you need the tick's matches frozen,
collect them yourself.
