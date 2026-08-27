# Bootstrapping Ludic in Ludic

**What it would take for Ludic to compile itself.**

Today `ludicc` is a C program: 2,508 lines across `compiler/ludicc.c`,
`compiler/native.c` and `compiler/driver.c`. Everything it produces is
Ludic-or-IR — the runtime a game calls is 2,501 lines of `.ludic`, and no C is
generated, compiled or linked in a build. The compiler is the last C in the
pipeline, and this document is about removing it.

Every claim about what the language can and cannot do below was **verified
against the built compiler**, not read off the docs. The probe programs are in
the appendix; each `✅`/`❌` is a real compile-and-run.

---

## 1. What "completely bootstrapped" means

Self-hosting is not one property. It is three independent axes, and they cost
wildly different amounts:

| Axis | Today | Target |
|---|---|---|
| **Compiler independence** — is the compiler written in the language? | ❌ 2,508 lines of C | `ludicc` written in Ludic, compiling itself to a fixpoint |
| **Runtime independence** — is the library the language ships written in the language? | ✅ **already done** — 2,501 lines of `.ludic` (gfx, PNG/DEFLATE, TrueType, UI) | keep |
| **Toolchain independence** — does a build need a foreign compiler? | ❌ `clang` assembles the IR and links | see §7 — three levels, only one is worth reaching |

The runtime axis is already won, and that is the unusual part. Most languages
self-host the compiler long before they stop leaning on a C standard library;
Ludic did it backwards. **The remaining work is concentrated in one axis.**

There is also a fourth, smaller thing: `runtime/native/cocoa.ll` (327 lines) and
`runtime/web/wasm.ll` are hand-written LLVM IR, not Ludic. §7.4 covers whether
that matters.

Running alongside all of this is a question the bootstrap forces rather than
raises: **what the syntax should finally be.** A self-hosted compiler is written
in the language it compiles, so the grammar wants to be settled *before* the
port, not after. §5 audits what is irregular today and proposes the freeze; it
is scheduled as Stage 0.5, between the language features and the libraries.

### The honest bar

"Bootstrapped by itself completely" should mean:

1. `ludicc` is written in Ludic.
2. A `ludicc` binary compiles the Ludic source of `ludicc` and produces a
   **byte-identical** binary to itself (the fixpoint test, §6).
3. The C compiler is needed **only** to build the very first seed, and that seed
   is a checked-in artifact rather than a live dependency.
4. No C source remains in the repo outside that seed.

It should *not* mean writing an object-file writer and a linker. Rust and Swift
are self-hosted and both stand on LLVM; standing on `clang` as an IR assembler
is the same posture. §7 argues this explicitly so the goal does not quietly
inflate.

---

## 2. Where the tree stands

```
compiler/                        C    split by concern; every file under 500 lines
  ludicc.c              435           pipeline + codegen glue + main
  util/    sb, diag      103           string builder; source registry + diagnostics
  front/   lex, ast, parse 469         tokens; Node; recursive descent + imports
  sem/     tables, uitree, validate 208  decl tables; widget flattening; static checks
  back/    ir_* x10       953          the LLVM IR backend, one file per concern
  driver/  toolchain, webbundle 382    IR -> object -> exe/dylib; the wasm bundle
  fmt/     fmt            162          canonical AST printer (--fmt)
                        ------
                         2,712   C    <- all of it, and all that must go
tools/ludic-tools/*      3,260   C    ludic-fmt + ludic-lsp (not yet split)

runtime/native/core.ludic       394  Ludic   framebuffer, text, registers, RNG, input
runtime/native/image.ludic      436  Ludic   PNG, sprites, alpha blend, 9-slice
runtime/native/inflate.ludic    276  Ludic   DEFLATE (RFC 1951)
runtime/native/truetype.ludic   804  Ludic   sfnt loader + AA rasterizer, Q16.16
runtime/native/ui.ludic         591  Ludic   retained widget tree, layout, focus
                               ----
                              2,501  Ludic   <- proof the language is already load-bearing

runtime/native/cocoa.ll         327  LLVM IR  macOS window (objc_msgSend + CoreGraphics)
runtime/web/wasm.ll             369  LLVM IR  browser shims
```

`util/`, `front/`, `sem/` and `fmt/` are separately compiled translation units;
`back/` and `driver/` are still one unit assembled by `back/native.c`, so their
include order is their definition order. The build list lives in
`compiler/sources.sh`, sourced by both `build.sh` and `test.sh`.

`truetype.ludic` matters more than its line count. A from-scratch sfnt parser
with cmap format dispatch, composite glyph recursion and a Bézier rasterizer is
*structurally the same kind of program as a compiler*: binary input, recursive
descent, table lookups, a growing output buffer. It already works. That is the
strongest single piece of evidence that this port is feasible rather than
aspirational.

---

## 3. What the language can already do

All verified. A compiler needs each of these, and each one works today.

| Capability | Status | Evidence |
|---|---|---|
| Recursion | ✅ | `fib(10)` → `55` |
| Mutual recursion / forward references | ✅ | `odd`/`even` cross-call |
| Deep recursion (recursive-descent parsing) | ✅ | 5,000 frames, no crash |
| Heap allocation | ✅ | `mem_alloc`, `mem_free`, `mem_copy`, `mem_set`; 1 MiB alloc verified |
| Byte-level memory | ✅ | `peek8`/`poke8`, `peek32`/`poke32`, `peekp`/`pokep`, `ptr_add` |
| `ptr` locals, params, returns | ✅ | `fn make(n: int) -> ptr` |
| `ptr` in a component field | ✅ | `component Nd { kind: int = 0, a: ptr = ptr_null() }` |
| String literals as readable bytes | ✅ | `peek8("hello", 1)` → `101` |
| `str` accepted where `ptr` expected | ✅ | `f("A")` into `fn f(p: ptr)` |
| String comparison, **hand-written in Ludic** | ✅ | `streq` over `peek8` |
| Integer → decimal, **hand-written in Ludic** | ✅ | `itoa(48291)` → `"48291"` |
| File read: open/seek/tell/read/close | ✅ | full round-trip of a written file |
| File write | ✅ | `file_open`/`file_write`/`file_close` |
| Module-level mutable state | ✅ | `var count: int`, `var heap: ptr` |
| `let` is mutable | ✅ | `i = i + 1` in a loop |
| `while`, numeric `for i in a .. b` with runtime bounds | ✅ | |
| `if` / `else if` / `else` chains | ✅ | |
| `match` with multi-value arms and `_` | ✅ | `1 => …  2, 3 => …  _ => …` |
| Bitwise ops | ✅ | `band`/`bor`/`bxor`/`bnot`/`shl`/`shr` |
| `shr` is **logical**, not arithmetic | ✅ | `shr(-16, 1)` → `2147483640` |
| Character literals | ✅ | `'x'`, `'\n'`, `'\0'` lex to ints |
| Exit codes | ✅ | `os_exit(3)` → shell sees `3` |
| Separate compilation, C ABI | ✅ | `module` + `@export fn`, `extern fn … = "sym"` |

**The consequence:** a compiler is *already expressible* in Ludic today. You
could write a lexer, a parser building nodes as hand-offset `peek32`/`poke32`
records, a symbol table, and an IR text emitter, using nothing above. It would
be miserable to read and maintain at 6,000 lines — but nothing in §4 is a
*capability* blocker except argv. The rest is about whether the resulting source
is something a human or a model can work in.

That distinction shapes the whole plan: **this is mostly an ergonomics project
with one small hole in it**, not a language-design project.

---

## 4. What the language is missing

Each entry: the gap, why a compiler specifically needs it, the proposed design,
and the lowering. Verified-missing means it is a compile error today.

### Tier A — real blockers

#### A1. Command-line arguments ❌ *the only true capability blocker*

```
ludicc: error: line 1: unknown function 'os_argc'
```

`ll_emit_main` in `compiler/native.c` emits `define i32 @main()` — **no
parameters**. A self-hosted `ludicc` has no way to learn which file to compile.
Everything else in this document has a workaround; this one does not.

**Design.** Two intrinsics:

```ludic
# doc-check: skip — proposed signature notation, not code
os_argc() -> int
os_arg(i: int) -> str
```

**Lowering.** Change the signature to `define i32 @main(i32 %argc, ptr %argv)`,
store both into `@L_argc` / `@L_argv` in the entry block, then `os_argc()` is a
load and `os_arg(i)` is exactly the existing `peekp(@L_argv, i)` path. Add to
`INTRINSICS[]` in `native.c`.

**Cost.** ~30 lines of C. This is the single highest-value change in the
document: it is what turns "a Ludic program" into "a Ludic command-line tool".

#### A2. Aggregate types (`struct`) ❌

```
ludicc: error: line 2: expected declaration (got 'struct')
```

An AST node, a token, a symbol-table entry and a type descriptor are all
records. Today there are two workarounds, and both are bad at compiler scale:

- **Hand-offset memory** — `poke32(n, 0, kind)`, `pokep(n, 1, child)`. This is
  what `truetype.ludic` does, and it works, but every field access becomes a
  magic number. Across a 6,000-line compiler this is the difference between
  maintainable and not.
- **ECS entities as nodes** — verified working (`component Nd { kind, a: ptr }`),
  and initially seductive because queries give you free traversal. **Do not do
  this.** `LUDIC_MAX_ENT` is 1024 in `native.c:18`; the entity world is a fixed
  array of per-component storage. A compiler needs hundreds of thousands of
  nodes. This is a dead end, and it is worth writing down because it is the
  obvious wrong turn.

**Design — reference semantics, not value semantics.** The cheap version that
unblocks everything:

```ludic
# doc-check: skip — proposed syntax: struct does not exist yet
struct Tok { kind: int = 0, text: ptr = ptr_null(), line: int = 0 }

let t = new Tok            # heap-allocated, fields seeded from defaults
t.kind = T_ID
print_int(t.line)
free Tok t                 # or leak it; see §8 on arenas
```

No copying, no by-value passing, no nested-struct inlining — a `struct` value
*is* a `ptr` with a known layout, so it costs nothing in the type system beyond
a layout table.

**Lowering.** This is largely already built. `native.c` already emits
`%Cmp_<Name>` LLVM struct types for components and already resolves
`a.b` through `ll_member_addr` with `getelementptr`. A `struct` is a
`%Cmp_`-style type *without* the parallel entity arrays: `new` is
`malloc(sizeof)` plus a default-seeding memset/store sequence, and `.field` is
the existing `getelementptr` path. Reusing the component machinery is why this
is far cheaper than it looks.

**Cost.** ~250 lines of C across `ludicc.c` (parse) and `native.c` (layout,
`new`, member access). Highest cost in the document, and the highest payoff.

#### A3. Arrays and indexing ❌

```
ludicc: error: line 2: expected identifier (got '[')
```

Token buffers, string tables, keyword tables, scope stacks. Currently
`mem_alloc` + `peek32`, which works but reads badly.

**Design.**

```ludic
# doc-check: skip — proposed syntax: array types do not exist yet
var keywords: [str; 64]           # fixed-size module-level storage
let toks: [Tok; 0] = mem_alloc(n * size_of(Tok))   # or a growable buffer
toks[i].kind = T_ID               # composes with A2
```

**Lowering.** `[T; N]` is `[N x <llty(T)>]`, already exactly how `@L_alive` and
`@S_<Comp>` are emitted. `a[i]` as both rvalue and lvalue is a
`getelementptr` — the same code path as member access, indexed instead of
named. The important part is that `toks[i].kind` composes: index then member,
one GEP chain.

**Cost.** ~150 lines. Should land *with* A2, since neither is much use alone.

#### A4. `break` / `continue` ❌

```
ludicc: error: line 3: unknown identifier 'break'
```

Lexers and parsers are made of `while (1) { … break; }`. The workaround —
sentinel booleans threaded through every loop condition — is the kind of thing
that makes a 6,000-line port unreadable.

**Design.** `break`, `continue`. No labels; nested loops in a compiler rarely
need them, and adding labels later is compatible.

**Lowering.** `native.c` already maintains `ll_loopstk[64]` (for `self()` inside
queries). Extend each frame with `break_label` and `continue_label`, then
`break` is `br label %<break>`. Note the existing gotcha recorded in the native
backend notes: **stack slots must be emitted in the entry block** — no new
allocas at the break site.

**Cost.** ~40 lines. Best value-per-line in the document.

#### A5. `mem_realloc` ❌

```
ludicc: error: line 1: unknown function 'mem_realloc'
```

Every table in a compiler grows: tokens, nodes, the output buffer. Hand-rolling
alloc-copy-free works but is written once per table and gotten wrong once per
table.

**Design.** `mem_realloc(p: ptr, n: int) -> ptr`.

**Lowering.** `declare ptr @realloc(ptr, <size_t>)` plus one `INTRINSICS[]`
entry. **Use `ll_size_t()` / `ll_widen()` for the size argument — do not
hardcode `i64`.** `size_t` is `i32` on wasm32, and `native.c` now routes every
size-taking intrinsic through those helpers for exactly this reason.

**Cost.** ~6 lines.

#### A6. Diagnostics on stderr ❌

```
ludicc: error: line 1: unknown function 'print_err'
```

Only stdout exists (`print_str` → `printf`, `write_byte` → `putchar`). This is
not cosmetic: **`ludicc --emit llvm` writes IR to stdout.** A self-hosted
compiler that printed errors to stdout would interleave diagnostics into its own
output, corrupting it in exactly the case you most want a diagnostic.

**Design.** Prefer an intrinsic that yields a handle, so the existing file
plumbing is reused rather than duplicated:

```ludic
# doc-check: skip — proposed signature notation, not code
file_stderr() -> ptr        # then file_write(f, buf, n) as usual
```

**Lowering — note the portability wrinkle.** There is no portable `@stderr`
global in LLVM IR: Darwin exports `@__stderrp`, glibc exports `@stderr`, and
wasm has neither in the same shape. So `file_stderr()` must select per target,
alongside the existing `target_os()` logic in `driver.c`. This is the one item
here that is genuinely target-dependent rather than merely unimplemented, and
it should be designed with that in mind rather than bolted on.

**Cost.** ~40 lines including the per-target selection.

### Tier B — needed for *complete* bootstrap, not for the compiler

#### B1. Function pointers ❌

```
ludicc: error: line 3: unknown type 'fn' for var h
```
`&cb` also fails to compile.

The compiler itself does **not** need these — `match` dispatch covers every
place a C compiler would use a function pointer table.

But they are what would let `cocoa.ll` become Ludic. The macOS window builds an
`NSView` subclass at runtime with `objc_allocateClassPair` and installs **an IR
function as its IMP**. Without the ability to take the address of a Ludic `fn`,
that shim can never move out of hand-written IR. So: irrelevant to §6, and
load-bearing for §7.4.

**Design.** `&fnname` yields a `ptr`; call through it via
`call_ptr(p, args…)` or a typed `fn(int)->int` type.

**Cost.** ~120 lines. Defer until after the fixpoint.

#### B2. String operations — **no language change needed**

`str + str` is worth calling out as a *bug*, not a gap. It passes the front-end
and then emits invalid IR:

```
build/probe_t_headless.ll:13401:17: error: global variable reference must have pointer type
```

That is a front-end/backend mismatch: the typechecker accepts an operation the
backend cannot lower. Until strings exist properly, `str + str` should be a
clean compile error rather than a `clang` error in generated code.

Everything else a compiler needs from strings is **already writable in Ludic
today** — `streq` and `itoa` are verified. This is not a language gap; it is a
library to write (§6 Stage 1), and it is the largest pure-typing chunk of the
whole project.

### Tier C — explicitly out of scope, recorded so they are not rediscovered

| Gap | Why it does not block |
|---|---|
| **64-bit integers** ❌ (`100000*100000` → `1410065408`, wraps at i32) | Line numbers, offsets, node indices and string lengths all fit in `i32`. Only matters for source files > 2 GiB. |
| **A non-ECS entry point** | A `Start`-phase system plus `os_exit(n)` gives correct exit codes — verified. You do pay for an unused 1024-entity world; that is a constant, not a blocker. A `tool Name { fn main() -> int }` form would be nicer, not necessary. |
| Closures, generics, unions, sum types | A compiler in the style of `ludicc.c` uses none of them. |
| GC | A compiler should leak deliberately (§8). |
| Unsigned integer types | `shr` is already logical and `band`/`bor` are bit-level — sufficient. |
| Multiple return values | `ptr` out-parameters work today. |

---

## 5. Designing for readers — human and model

The goal: Ludic source should be obvious to a person skimming it and
unambiguous to a model generating it. Those two goals agree far more than they
conflict, and where they conflict the resolution is **regularity, not
verbosity** (§5.2).

Everything in this section was verified against the built compiler. The probes
are in the appendix under "Syntax audit".

### 5.1 Why this belongs in the bootstrap document, and why now

**Syntax changes are cheap today and expensive after Stage 3.** This is a hard
ordering constraint, not a preference.

Today, changing the grammar costs: edit `ludicc.c`, `sed` three examples and
five runtime files, run `./test.sh`. An afternoon.

After the fixpoint, `ludicc` is *written in the syntax it parses*. Every change
becomes a four-step dance: build a compiler that accepts both old and new forms
→ compile it with the old seed → rewrite every source file → remove the old
form and regenerate the seed. That is what every mature language does, and it
is why mature languages change syntax slowly. It is not a reason to avoid the
change; it is a reason to **make it before the port, not after**.

So the plan gains a stage:

> **Stage 0.5 — Syntax freeze.** Between Stage 0 (language features) and
> Stage 1 (libraries). Nothing in Stage 2 starts until the grammar is final.

The port should be *the first large program written in final Ludic*, not the
last large program written in provisional Ludic.

**This work also strengthens the bootstrap itself.** Stage 2b uses `--fmt`
equality as the oracle proving two parsers agree. That oracle is only as tight
as the language is regular: every alternative spelling is surface variance the
formatter must erase. Reduce the variance and the oracle gets sharper. The
readability project and the self-hosting project are not competing for the same
time — one makes the other more trustworthy.

### 5.2 What actually helps a model — and what is folklore

Worth being precise here, because "AI-friendly syntax" attracts a lot of
confident nonsense.

**Genuinely helps:**

| Property | Why it matters |
|---|---|
| **Low syntactic variance** — one spelling per concept | Every alternative is a branch point during generation and a case in the parser. Two ways to write a list is two chances to be inconsistent within one file. |
| **Leading-keyword, bounded lookahead** | Every declaration and statement identifiable from its first token. Helps the hand-written recursive-descent parser Stage 2b will be, *and* a model predicting forward. |
| **No silent no-ops** | If the language accepts a construct it must either honour it or reject it. Accepting-and-ignoring teaches a falsehood (see R6 — the worst thing in the audit). |
| **Recoverable structure** — explicit terminators | A slightly-wrong generation fails *locally*, with an error pointing at the mistake, instead of cascading into a confusing error 40 lines later. |
| **Locality** — meaning readable from the construct | No action-at-a-distance. Ludic is already strong here; keep it. |
| **Greppable unique anchors** | `component Pos` is findable. Retrieval quality is a language design property. |
| **Errors that name the fix** | Already partly true: a missing builtin errors naming `rt_<name>`. Extend that everywhere. |

**Folklore, and false:**

- *"More verbose is more AI-friendly."* No. Ceremony without information hurts
  both audiences. What helps is redundancy that **encodes intent** — an explicit
  type, a closing keyword — not boilerplate.
- *"Significant indentation reads better."* It reads fine and **generates
  badly**: indentation drift across a long generated block is unrecoverable and
  survives review. Ludic uses braces. Keep them.
- *"Natural-language-like syntax helps."* Prose-shaped keywords add ambiguity.
  Consistent symbols beat English words that read three ways.
- *"Terseness is bad for models."* Terseness is fine; *irregularity* is the
  problem. A short form used consistently is easy to predict.

**The real tension:** humans skim, so terseness helps them; machines benefit
from redundancy. Regularity resolves it — the same shape everywhere costs a
human nothing once learned, and costs a model nothing to predict.

### 5.3 Audit — what is irregular in Ludic today

Each row verified by compiling a probe, not by reading docs.

| # | Irregularity | Evidence | Cost |
|---|---|---|---|
| **R1** | **No statement terminator at all.** `block()` is `skipnl(); stmt()` in a loop. A newline *stops* an expression (it lexes as `T_NL`, and `binlevel` only continues on `T_OP`) but is never *required*. `let x = 1 x = x + 1 print_int(x)` on one line is three legal statements — verified compiling. | `ludicc.c` `block()`, `binlevel` | The reader cannot see where a statement ends without re-deriving operator precedence. Blocks error recovery entirely. |
| **R2** | **Commas are optional everywhere.** `if(isop(",")) pi++` appears in `comp()`, `arche()`, `fn` params and `spawn`. `{ x: int = 0  y: int = 0 }` and the comma'd form both compile. | 4 parser sites | Two spellings, zero semantic difference. |
| ~~**R3**~~ | ~~**`and`/`or` alias `&&`/`\|\|`.**~~ **RESOLVED** — `and`/`or`/`not` are the only boolean operators; `&&`, `\|\|` and `!` are each rejected with a diagnostic naming the fix, and all three words are reserved. `!=` is unaffected. | landed via S3 | — |
| **R4** | **`{ }` means seven different things** — statement block; component fields (`n: T = e`); archetype list (bare idents); spawn initialisers (`N = { … }`); ui props + children (`k=v` juxtaposed, no commas); match arms (`p, p => …`); machine states (`state N = v { … }`). | `block/comp/arche/spawn/parse_widget/match/machine` | The delimiter carries no information. You must already know the head keyword to know the inner grammar. |
| **R5** | **Contextual keywords, not reserved.** `phase`, `query`, `reads`, `writes`, `needs`, `uses`, `where`, `in`, `on`, `layer`, `state`, `start` are matched with `isid()` — ordinary identifiers. `let query = 5  let phase = 6` compiles and prints `11`. | `sys()`, `scene_decl()` | A local named `enter` or `match` produces a baffling error far from the cause. |
| **R6** | **Contracts are parsed and thrown away.** `requires`/`ensures`/`invariant` parse an expression and **discard it** (`pi++; expr();`). `reads`/`writes`/`needs`/`uses`/`effects` are `skip_brackets()`. `pure` is consumed and ignored. Verified: `fn half(n: int) -> int requires n > 100000 ensures false` compiles, and `half(8)` returns `4`. Verified: a system declaring `reads [Pos]` that **writes** `p.x = 99` compiles. | `fn()`, `sys()` | **The worst item in the audit.** The language accepts a contract and does nothing. A model writing `requires n > 0` is rewarded with a clean compile and zero enforcement — it learns a lie, and so does a human reader trusting the annotation. |
| **R7** | **`str + str` typechecks, then emits invalid IR.** | verified (§4 B2) | The front-end accepts what the backend cannot lower. |
| **R8** | **Two formatters, opposite philosophies, both called "format".** `ludicc --fmt` canonicalises hard (one statement per line, `and`→`&&`, full parenthesisation) but drops comments and inlines imports. `ludic-fmt` is token-based and preserves comments — but **normalises nothing**: handed the one-line `let a = 1 a = a + 1  if true and false { … }`, it returned it unchanged. | verified side-by-side | **Neither tool enforces a single spelling.** The canonicaliser is unusable on real source; the source formatter has no opinion. |
| **R9** | **Two ways to spell a tag** — `component Player { }` (empty component) or `archetype`. | LANGUAGE.md | |
| **R10** | **Stale docs are stale training data.** LANGUAGE.md still says "the current compiler is a tree-to-C translator" (it emits LLVM IR) and lists arrays under "Not yet implemented" beside things never planned. | LANGUAGE.md | Docs are the highest-leverage model input in the repo. A wrong doc is worse than a missing one. |

### 5.4 Proposals

Ordered by value per line of work. Each is a Stage 0.5 item unless noted.

**S1. Require a statement terminator.** A statement ends at a newline, `;`, or
`}`. Make `T_NL` significant inside `block()` instead of discarding it.
*Why:* fixes R1, and it is the precondition for error recovery — without it a
parser cannot resynchronise, so every syntax error stays a cascade.
*Cost:* ~30 lines. *Ripple:* one-line bodies like `if x { a }` still work;
multi-statement one-liners in the runtime need a `sed`.

**S2. Make separators mandatory.** Commas required in every comma-list;
remove the optional path. *Fixes R2. Cost:* ~10 lines + tree-wide `sed`.

**S3. One spelling for boolean operators. ✅ LANDED.** `and`/`or` are the only
boolean operators. Ludic already spells bitwise operations as functions
(`band`/`bor`), so the symbols bought nothing, and dropping them removes the
`&` vs `&&` bug class by construction.

What shipped: `&&`/`||` still *lex* as single tokens, purely so the parser can
emit `'&&' is not a Ludic operator - write 'and'` instead of tripping over a
stray `&`; `and`/`or` became reserved words, so `let and = 5` is rejected at the
mistake; the AST op string is now `"and"`/`"or"`, which is **exactly the LLVM
opcode**, so the lowering ternary collapsed to passing `op` straight through;
and `--fmt` emits the new spelling for free, since it prints the op string.
Six regression tests in `test.sh` (64 → 70), including one asserting no `.ludic`
source uses the symbols outside a comment. *Fixed R3.*

**S4. Reserve every keyword.** One table, shared by the lexer, parser,
`ludic-fmt` and `ludic-lsp` — those tools already share a vocabulary in
`ludic_syntax.h`, so there is one obvious home. Reject `let query = 5` at the
point of the mistake. *Fixes R5. Cost:* ~40 lines.

**S5. Delete or implement every silent no-op.** ← **highest value in the
section.** Two honest options per construct, no third:

- `reads` / `writes`: **implement them.** The compiler already knows every
  component a system touches — it builds the query and walks the body. Checking
  the declaration against actual access is a genuine static analysis the
  language claims to have and doesn't. This converts dead syntax into a real
  guarantee, which is exactly what an "AI-first" language should offer a model
  reasoning about a system in isolation.
- `requires` / `ensures`: either lower to a checked assertion in debug builds
  (`if !cond { print_err(...) os_exit(1) }` — cheap, and A6 stderr lands in
  Stage 0 anyway), or remove them from the grammar until they mean something.
- `pure`, `needs`, `uses`, `effects`, `invariant`: remove until implemented.

*Fixes R6. Cost:* ~150 lines for `reads`/`writes` checking, ~60 for assertions,
~10 to delete the rest.

**S6. Cut the block grammars from seven to two.** Full unification is too
invasive to be worth it. The achievable version: every `{ }` is either a
**statement block** or a **field list** (`name: type = default`, comma-separated,
one shape), and `ui` props adopt the same separator rule as everything else.
Document all remaining shapes in one grammar table. *Partially fixes R4.
Cost:* ~120 lines.

**S7. One formatter with one contract.** Merge the philosophies rather than
keeping two half-tools: `ludic-fmt` gains `--fmt`'s normalisation decisions
(statement-per-line, single spelling, consistent commas) while keeping its
token-based comment preservation, and becomes **normative** — `ludic-fmt
--check` gates CI. `ludicc --fmt` reverts to being an honest debug dump and is
renamed `--dump-ast`. *Fixes R8.* After S1–S3, canonical form is the *only*
form, so the formatter stops being a style preference and becomes a check.
*Cost:* ~200 lines, mostly in `ludic_fmt.h`.

**S8. Machine-readable grammar and diagnostics.** Emit the grammar as one EBNF
file, and give every diagnostic a stable code plus a one-line suggested fix
(`ludicc --explain L0412`). Feeds the LSP, the docs and any model at once.
*Cost:* ~250 lines. *Defer to after the fixpoint* — valuable, not ordering-critical.

**S9. Documentation hygiene as a build step.** `test.sh` already understands
` ```ludic ` fences. Extend it so **every fence in every `.md` must compile**,
and fix R10's stale claims. *Cost:* ~60 lines of shell. Do this early — it is
cheap and it stops the docs drifting further while the rest of the work lands.

### 5.5 What not to change

Recording these so they are not relitigated:

- **Braces, not indentation** (§5.2).
- **`#` comments** — unambiguous, one spelling already.
- **The ECS vocabulary** — `component` / `system` / `query` / `phase` are
  unusually self-describing and greppable. This is the language's best existing
  readability asset.
- **`fixed` / Q16.16** — determinism is a design constraint, not a style choice.
- **Do not add** operator overloading, implicit conversions beyond `int`→`fixed`,
  macros, or anything else with action-at-a-distance. Every one of them trades
  local readability for cleverness.

### 5.6 Sequencing

| When | What | Why there |
|---|---|---|
| **Now, before Stage 1** | S9 (doc hygiene) | Cheap; stops further drift immediately. |
| **Stage 0.5** | ~~S3~~ ✅ done · S1, S2, S4, S5, S6, S7 | Must precede the port (§5.1). |
| **After Stage 3** | S8 (EBNF + diagnostic codes) | Valuable, not ordering-critical; better written in Ludic against the self-hosted parser. |

**S3 was the one genuinely contentious call** — which boolean spelling — because
it is pure taste and touches every file. It was decided in favour of `and`/`or`
and has landed. Everything remaining in this section is a choice between "one
spelling" and "two", where the answer is not in doubt.

**`!` → `not` has since landed too**, on the same reasoning and by the same
mechanism: `!` still lexes (so `!=` is untouched) purely so the parser can say
`'!' is not a Ludic operator - write 'not'`. Ludic's three boolean operators are
now `and`, `or`, `not`, all reserved words, with no symbol spellings at all.

---

## 5.7 Status — self-hosting achieved

Updated 2026-08-27. `./test.sh` = 93/93, `./tools/test-tools.sh` = 28/28,
`./selfhost/test.sh` = 5/5 including the bootstrap fixpoint.

**Ludic is fully self-hosted.** The compiler is written in Ludic
(`selfhost/*.ludic`, ~2,400 lines), compiles every example to byte-identical
output and its own source to a fixpoint, and is built from a checked-in IR seed
with **no C compiler** — the former C compiler has been deleted. Run
`./selfhost/bootstrap-cfree.sh`.

| Stage | What | State |
|---|---|---|
| **0** | language features (argv, struct, arrays/slices, break/continue, mem_realloc, stderr) | ✅ done |
| **0.5** | S3 (`and`/`or`/`not`), S9 (doc checking), short-circuit `and`/`or` | ✅ done |
| — | S1/S2/S4/S5/S6/S7 (statement terminators, mandatory commas, reserved-word audit, no-op removal, block unification, one formatter) | not done — polish of the *full* language, not needed for self-hosting |
| **1** | support libraries in Ludic (`str`, `buf`, `io`) | ✅ done |
| **2** | the compiler ported to Ludic (`lex`, `parse`, `emit_*`) | ✅ done |
| **3** | the fixpoint (`gen2.ll == gen3.ll`) | ✅ done |
| **4** | retire the C as a *live dependency* (IR seed, C-free rebuild) | ✅ done — `selfhost/bootstrap-cfree.sh` |
| **4+** | retire `ludicc.c` entirely (port the game backend) | ✅ **done** — `compiler/` deleted; the compiler is `selfhost/*.ludic` |

### What "self-hosting" means here, precisely

The self-host compiler (`selfhost/`) implements the **compiler-subset**: `struct`
(reference), `[]T` slices with `push`/`len`, functions, a plain `main` entry,
the full control flow, the operators (with short-circuit `and`/`or`), and the
low-level intrinsics. It deliberately does **not** implement the game half of
Ludic — ECS, queries, archetypes, scenes, UI, save/load, `match`/`machine`,
fixed-point. It targets native (macOS/clang) and emits LLVM IR text that clang
assembles, exactly the posture the C `ludicc` has.

It is written entirely in that subset, which is why it compiles itself. The
three-generation proof (`selfhost/bootstrap.sh`):

```
stage0  build/ludicc (C)  compiles selfhost.ludic  -> gen1   (a Ludic-written compiler)
stage1  gen1              compiles selfhost.ludic  -> gen2.ll -> gen2
stage2  gen2              compiles selfhost.ludic  -> gen3.ll
assert  gen2.ll == gen3.ll        # the compiler reproduces itself, independent of its seed
```

`gen1`'s IR legitimately differs (a different compiler built it); `gen2 == gen3`
is the property that matters — the Ludic compiler has no dependency on how it was
built. It is also verified *correct*, not merely self-consistent: it compiles a
corpus (`selfhost/tests/`) of struct, slice, and control-flow programs to
binaries that produce the expected output.

### Stage 4 — the C is retired as a live dependency

The self-hosted compiler no longer needs the C `ludicc` to exist. Its own LLVM
IR is checked in as `selfhost/ludicc.seed.ll` — a proven fixed point — and
`selfhost/bootstrap-cfree.sh` assembles that with clang (an IR assembler, the
floor Rust and Swift stand on) and rebuilds the compiler, which reproduces its
own IR. **The C source is never invoked.** This is the seed path §8 recommended.

Crucially, the compiler **evolves** without the C compiler: `selfhost/reseed.sh`
uses the *current* seed to build a compiler with new source, then takes that
compiler's own output as the new seed. New features (this session: `match`,
bitwise ops, `peek32`/`poke32`) landed and reseeded entirely C-free. The C
compiler is now a historical seed, not a dependency.

### Stage 4+ — `ludicc.c` is deleted

The self-host compiler was extended to the **whole** language — components,
archetypes, systems, phases, `for … in query` (with `where`), spawn/despawn,
`self()`, `machine`/`become`, `match`, `save`/`load` snapshots, the retained
`ui` widget tree, multi-file `import`, fixed-point Q16.16, and every runtime
intrinsic. It auto-splices the Ludic runtime exactly as the C compiler did.

It now compiles **every example** — `snake`, `menu`, and the 6-file JRPG
`chronorift` — to output byte-identical to the original C compiler (checked
against golden renders in `selfhost/golden/`), and still compiles its own source
to a fixpoint. The C compiler (`compiler/`, ~2,700 lines) has been **deleted**.
`build.sh` builds `build/ludicc` from the IR seed with clang and drives the
native link (headless, or windowed via `cocoa.ll`).

What did not come across: the old C driver's **wasm target, cross-compilation,
and shared-library** paths. Those are driver features, not codegen — the
self-host compiler emits native-ABI IR — and re-implementing them on the
self-hosted toolchain (wasm needs i32 `size_t`; the others are clang flags in
`build.sh`) is the remaining follow-up.

---

## 6. The plan

### Stage 0 — Extend the C compiler (~500 lines of C)

The C `ludicc` must be able to compile the Ludic `ludicc`. Land Tier A only, in
this order — cheapest-and-unblocking first:

1. **A4** `break`/`continue` (~40) — immediate readability win on everything after.
2. **A5** `mem_realloc` (~6).
3. **A1** `os_argc`/`os_arg` (~30) — unblocks the entire notion of a CLI tool.
4. **A6** `file_stderr` (~40).
5. **A2 + A3** `struct` + arrays (~400, landed together).

Each gets a test in `test.sh` as it lands. The suite is at 64/64; Stage 0 should
leave it green and larger.

**Explicitly not in Stage 0:** function pointers, 64-bit ints, a `tool` entry
form. They are not on the path to the fixpoint.

### Stage 0.5 — Syntax freeze (~600 lines of C + a tree-wide `sed`)

**The grammar must be final before Stage 2 starts** (§5.1): after the fixpoint,
every syntax change costs a four-step reseed instead of an afternoon.

Land S1–S7 from §5.4: mandatory statement terminators, mandatory separators,
one boolean spelling, reserved keywords, no silent no-ops, two block shapes
instead of seven, one normative formatter. S9 (doc hygiene) can land earlier —
it is cheap and independent.

Exit criterion: `ludic-fmt --check` passes on the whole tree and there is
exactly one legal spelling of every construct. That is also what makes the
Stage 2b oracle tight.

### Stage 1 — Support libraries in Ludic (~800 lines of Ludic, zero language work)

Nothing here needs Stage 0 except `struct`/arrays for pleasantness. This is the
part that is pure writing, and it can start immediately and in parallel.

| File | Contents |
|---|---|
| `runtime/native/strings.ludic` | `str_eq`, `str_len`, `str_dup`, `str_cat`, `substr`, `str_chr`, `str_hash`, `itoa`, `atoi`, `hex` |
| `runtime/native/buf.ludic` | growable byte buffer — `buf_new`, `buf_putc`, `buf_puts`, `buf_putint`, `buf_len`, `buf_ptr`. This is `SB` from `ludicc.c`, and the IR emitter is nothing but calls to it. |
| `runtime/native/io.ludic` | `read_whole_file` (the open/seek/tell/read/close dance, verified working), `write_whole_file`, stderr diagnostics |
| `runtime/native/map.ludic` | open-addressing `str -> int` hash table: keyword lookup, string interning, symbol tables |
| `runtime/native/arena.ludic` | bump allocator — see §8 |

### Stage 2 — Port the compiler, each piece against a differential oracle

Port in dependency order. The critical discipline: **never port a stage without
an automated way to prove it agrees with the C one.** Ludic is unusually well
set up for this, because it already ships two canonical serializers of compiler
internals.

| Sub-stage | Port | Differential oracle |
|---|---|---|
| 2a | `lex.ludic` | Dump the token stream from both compilers; `diff` over every `.ludic` in the tree. |
| 2b | `parse.ludic` (AST) | **`--fmt` is a free oracle.** The formatter is already a canonical AST printer, and `test.sh` already asserts formatting never changes a program. If both compilers' `--fmt` output is byte-identical on every file, the parsers agree. |
| 2c | `check.ludic` | Diagnostic text must match on a corpus of deliberately-broken programs. `test.sh` already checks diagnostics — extend that corpus. |
| 2d | `emit.ludic` (IR) | **`--emit llvm` must be byte-identical** for every example. This is the strongest oracle available: pass/fail on exact text, no judgement. |
| 2e | `drive.ludic` | Assemble and link via `clang`; compare final binaries. |

Sub-stage 2b deserves emphasis. Most self-hosting projects have no cheap way to
prove two parsers agree. Ludic has one already built and already tested, which
removes the single largest source of silent divergence.

### Stage 3 — The fixpoint

```
stage1 = C-ludicc          compiles ludicc.ludic  ->  binary A
stage2 = A                 compiles ludicc.ludic  ->  binary B
stage3 = B                 compiles ludicc.ludic  ->  binary C

assert B == C     byte-for-byte      <- THE bootstrap test
```

`A != B` is expected and correct: `A` was built by a different compiler, so its
codegen differs. `B == C` is the real property — a compiler that reproduces
itself has no dependency on how it was built. Also assert that `A`, `B` and `C`
all emit identical IR for every example.

If `B != C`, the cause is almost always nondeterminism in the compiler itself:
hash-table iteration order, an address baked into output, uninitialised memory.
Those are worth hunting rather than working around.

### Stage 4 — Retire the C

Once the fixpoint holds, the C compiler becomes a seed. Options:

| Option | Trade-off |
|---|---|
| **Commit the generated `ludicc.ll`** ✅ recommended | Auditable text, diffable in review, builds with `clang` alone — already a dependency. Large but honest. |
| Commit prebuilt binaries per platform | Smallest process, worst auditability; a binary blob nobody can read. What Rust does. |
| Keep `ludicc.c` forever as the seed | Zero risk, but §1's bar is never met — the C never leaves. What Go did for years. |

Recommend the IR seed: it is the only option that both removes the C and leaves
a reviewer something to read.

`tools/ludic-tools/` (3,260 lines of C: `ludic-fmt`, `ludic-lsp`) is a separate
port and should follow, not lead — once the Ludic compiler exists, both tools
should be thin front-ends over its lexer and parser instead of maintaining a
second copy of the vocabulary.

---

## 7. Toolchain independence — and where to stop

`driver.c` shells out to `clang` (overridable via `$LUDIC_CC`) to assemble IR
into an object and to link, plus `wasm-ld` for wasm. Three levels of removing
that, and only one is worth doing:

**Level 1 — self-hosted compiler, hosted toolchain. ← the goal.**
`ludicc` is Ludic; `clang` remains the IR assembler and linker driver. This is
exactly where Rust and Swift stand. Achieved at the end of Stage 4.

**Level 2 — own object writer.** Emit Mach-O / ELF / COFF directly, replacing
IR-text + `clang -c`. Requires instruction selection, register allocation and
relocations: realistically 5,000–15,000 lines of Ludic, and it *loses the LLVM
optimizer* — the generated code gets slower, which for a game language is a
real regression, not a neutral trade. **Not recommended.**

**Level 3 — own linker.** Platform-specific, deep, and buys nothing a user can
perceive. **No.**

**7.4 — The hand-written IR.** `cocoa.ll` (327 lines) and `wasm.ll` are LLVM IR,
not Ludic. Two defensible positions: keep them as *platform glue written in the
platform's own assembly language* (precisely how Rust uses `asm!` shims and how
every libc has hand-written syscall stubs), or move them into `.ludic` — which
needs **B1 function pointers**, because the `NSView` subclass installs a
function as an Objective-C IMP. Keeping them is the honest default; the README's
existing framing ("the same floor Rust and Swift stand on") already covers it.

---

## 8. Risks and gotchas

- **Do not build the AST out of ECS entities.** `LUDIC_MAX_ENT` is 1024
  (`native.c:18`) and component storage is fixed arrays. It compiles, it looks
  elegant, and it caps the compiler at 1024 nodes. Use `struct` (A2).
- **Do not inherit the C compiler's fixed caps.** `ludicc.c:22` has
  `g_srcpath[128]`; `native.c:161` has `Val a[8]`. The Ludic port should grow
  its tables (A5) rather than reproduce the limits.
- **Leak on purpose.** A compiler runs once and exits. A bump arena
  (`arena.ludic`) that never frees is faster and simpler than tracked
  ownership, and it sidesteps having no GC. Free at process exit — i.e. never.
- **Determinism is a feature now.** Anything order-dependent — hash iteration,
  pointer values in output, uninitialised reads — breaks `B == C` in Stage 3.
  Iterate tables in insertion order, not bucket order.
- **Error handling has no exceptions.** Mirror the C `die()`: write the
  diagnostic to stderr (A6), then `os_exit(1)`.
- **The `str + str` mismatch (B2)** is a live example of the front-end accepting
  what the backend cannot lower. Worth auditing for siblings before trusting
  the typechecker as a Stage 2c oracle.
- **Size-taking intrinsics must use `ll_size_t()` / `ll_widen()`.** `size_t` is
  `i32` on wasm32. Any new intrinsic with a size argument (A5) that hardcodes
  `i64` will break the wasm target at link time.
- **Recursion depth is fine** — 5,000 frames verified, well past what a
  recursive-descent parser needs on real source.

---

## 9. Effort

| Stage | Work | State |
|---|---|---|
| 0 | Tier A language features (argv, struct, slices, break/continue, mem_realloc, stderr) | ✅ done |
| 0.5 | `and`/`or`/`not` + short-circuit; doc checking (S9) | ✅ done (S1/S2/S4/S5/S6/S7 deferred — full-language polish) |
| 1 | `str`, `buf`, `io` support libraries in Ludic | ✅ done (`selfhost/`) |
| 2 | lexer + parser + AST + IR emitter, in Ludic | ✅ done (`selfhost/`, ~1,300 lines) |
| 3 | the fixpoint (`gen2.ll == gen3.ll`) + harness | ✅ done (`selfhost/bootstrap.sh`) |
| 4 | port the game backend, retire `ludicc.c` | ⛔ out of scope — mechanical continuation |

The self-host compiler is **~1,300 lines of Ludic** covering the compiler-subset.
A `main`-tool entry point and short-circuit `and`/`or` were the two language
additions that made it self-compilable; the rest of Stage 0 was already in place.

Roughly **6,000 lines of Ludic and 1,100 lines of C** to reach Level 1 — larger
than the 2,508-line C compiler it replaces, which is normal: the C version leans
on libc for everything in Stage 1.

**Two independent critical paths, and they can run in parallel.** Stage 0 + Stage 0.5
are C work on the existing compiler; Stage 1 is Ludic work that needs almost none of
it. The only hard barrier is that Stage 2 starts after *both*.

**The critical path is short.** A1 (argv, ~30 lines of C) plus A2/A3
(`struct` + arrays, ~400) plus A4 (`break`, ~40) is nearly all the *design* risk
in the project. Everything after it is typing against oracles that already
exist.

---

## Appendix — probe programs

Each was compiled with `./build.sh probe.ludic --headless` and run against the
current tree (`./test.sh` = 64/64).

**Recursion** ✅ → `55`
```ludic
program P {
  fn fib(n: int) -> int { if n < 2 { return n };  return fib(n-1) + fib(n-2) }
  handler B phase Start { print_int(fib(10)); quit() }
}
```

**String comparison, hand-written** ✅ → `1`
```ludic
fn streq(a: ptr, b: ptr) -> bool {
  let i = 0
  while true {
    let ca = peek8(a,i)
    let cb = peek8(b,i)
    if ca != cb { return false }
    if ca == 0  { return true }
    i = i + 1
  }
  return false
}
```

**Integer → string, hand-written** ✅ → `48291`
```ludic
fn itoa(v: int, buf: ptr) -> int {
  let n = 0
  let x = v
  if x == 0 { poke8(buf,0,48); return 1 }
  let tmp = mem_alloc(16)
  while x > 0 { poke8(tmp, n, 48 + x % 10); x = x / 10; n = n + 1 }
  let i = 0
  while i < n { poke8(buf, i, peek8(tmp, n-1-i)); i = i + 1 }
  mem_free(tmp)
  return n
}
```

**Read a whole file** ✅ → the compiler's front door
```ludic
let f = file_open("/tmp/x.txt", "rb")
file_seek(f, 0, 2)
let n = file_tell(f)
file_seek(f, 0, 0)
let b = mem_alloc(n+1)
file_read(f, b, n)
poke8(b, n, 0)
file_close(f)
```

### Syntax audit — every one of these compiles today

Each is a spelling the language accepts; the point is that the *alternative*
spelling is equally legal (§5.3).

**R1 — statements now require a separator (Rule B, syntax-redesign Phase 2)** → parse error
```ludic
# doc-check: skip — intentionally rejected under Rule B: needs a newline or ';'
program P { handler B phase Start { let x = 1 x = x + 1 print_int(x) quit() } }
```
Statements no longer sit adjacent with only spaces between them; the compiler
reports `expected newline or ';' between statements`. Put each on its own line,
or separate them with `;` (both lex to the same separator token):
```ludic
program P { handler B phase Start { let x = 1; x = x + 1; print_int(x); quit() } }
```

**R2 — commas omitted throughout** → `7`
```ludic
# doc-check: skip — composite: declaration plus statements
property Pos { x: int = 0  y: int = 0 }
spawn Hero { Pos { x: 7  y: 2 } }
```

**R3 — RESOLVED.** Every symbol form is now rejected where it is written:
```
ludicc: error: line 1: '&&' is not a Ludic operator - write 'and' (got '&&')
ludicc: error: line 1: '||' is not a Ludic operator - write 'or' (got '||')
ludicc: error: line 1: '!' is not a Ludic operator - write 'not' (got '!')
ludicc: error: line 1: 'and' is a reserved operator and cannot be used as a name
```
`--fmt` prints `if ((true and false) or (1 < 2))` and `(not true)`, while unary
minus keeps its tight spelling `(-x)`. `!=` is untouched.

**R5 — reserved-looking words used as locals** → `11`
```ludic
let query = 5
let phase = 6
print_int(query + phase)
```

**R6 — contracts accepted and discarded.** Both are violated; it compiles and
prints `4`:
```ludic
# doc-check: skip — composite: declaration plus statements
fn half(n: int) -> int requires n > 100000 ensures false { return n / 2 }
print_int(half(8))
```
And a system may declare read-only access, then write — also compiles:
```ludic
handler Violate phase Update reads [Pos] query (p) [Pos] { p.x = 99 }
```

**R8 — the two formatters disagree about what "format" means.** Given
`component Pos { x: int = 0  y: int = 0 }` and a multi-statement one-liner,
`ludicc --fmt` rewrites both (one statement per line, `and`→`&&`, full
parenthesisation) while `ludic-fmt` returns the input **unchanged**.

**Verified-missing** — each a compile error today:
```ludic
# doc-check: expect-error — every line here is a compile error by design
while i < 10 { i = i + 1;  if i == 3 { break } }   # unknown identifier 'break'
struct Node { k: int, a: ptr }                    # expected declaration (got 'struct')
var t: [int; 8]                                   # expected identifier (got '[')
var h: fn = a                                     # unknown type 'fn' for var h
let p = &cb                                       # fails to compile
print_int(os_argc())                              # unknown function 'os_argc'
print_err("x")                                    # unknown function 'print_err'
let p = mem_realloc(ptr_null(), 10)               # unknown function 'mem_realloc'
print_str("ab" + "cd")                            # passes front-end, invalid IR
let a = 100000;  print_int(a*100000)               # 1410065408 — i32 wrap
```
