# Ludic Syntax Redesign — Cohesion Pass

A plan to make Ludic's syntax internally consistent. It fixes the drift between
the spec and the compiler, then unifies the grammar around two rules. Scope:
**full redesign (Phases 0–5)**. Named-field direction: **colon everywhere**.

> Status: **Phases 1 & 2 landed; Phase 3 in progress** (3a records/spawn done).
> Remaining sub-phases and Phases 4→5 are proposals. The phases are ordered so
> the documentation never describes syntax the compiler rejects, and every phase
> ends with the compiler still self-hosting to a fixpoint (`./test.sh`).
>
> Coordinated with the toolchain agent (CLI front-end / `ludicc`+`ludic`
> binaries) via serialized reseeds of `selfhost/ludicc.seed.ll`; Phase 1 rode in
> alongside their `emit_*`/`main.ludic` work, combined suite **14/14 green**.

---

## Why (the findings)

Verified against the self-hosted compiler ([selfhost/parse.ludic](selfhost/parse.ludic),
[selfhost/parse_game.ludic](selfhost/parse_game.ludic), [selfhost/lex.ludic](selfhost/lex.ludic)):

**Structural incoherence**
1. **Five micro-syntaxes for named parts** — `name: type = d` (fields), `name: type`
   (params), `Field = { k = v }` (spawn), `[Name, {Tag}]` (query), whitespace
   `phase X reads [..]` (system clauses), `key=value` (ui props).
2. **`=` means seven things, `:` means one** — assignment, default, record init,
   ui prop, extern symbol, const value, `state X = N` all use `=`.
3. **No statement terminators** — `\n` and `;` both lex to `TK_NL`
   ([lex.ludic:45,121](selfhost/lex.ludic)) but the parser never requires a
   separator, so `t.kind = k  t.text = x  t.ival = v` (three statements, spaces
   only) is idiomatic.

**Broken / dead syntax (compiler-verified)**
4. `edge system` — **hard parse error** (documented at [LANGUAGE.md:188](LANGUAGE.md)). *(✅ fixed in Phase 1)*
5. `pure fn` — parses, `pure` silently discarded ([parse.ludic:272](selfhost/parse.ludic)); undocumented.
6. `@anno` + `reads/writes/needs/uses [..]` — parsed then thrown away
   ([parse_game.ludic:15-31](selfhost/parse_game.ludic)); four synonyms, two undocumented.
7. `scene`/`layer`/`on enter` — full LANGUAGE.md section + [examples/scenes.ludic](examples/scenes.ludic),
   **does not compile** (`expected declaration`).
8. `query (v) [..]` in a system signature — two LANGUAGE.md sections +
   [examples/qdecl.ludic](examples/qdecl.ludic), **does not compile** (`parse error: {`). *(✅ implemented in Phase 1)*
9. `when cond {}` — documented ([LANGUAGE.md:329](LANGUAGE.md)) + in all three editor
   highlighters, **never parsed**. *(✅ implemented in Phase 1 as an if-without-else alias)*
10. CLI `--emit-llvm`/`-o`/`--shared`/`--fmt` — documented, but `ludicc` only
    accepts `--windowed`/`--headless` ([main.ludic:8-14](selfhost/main.ludic)).

**Philosophical splits**
11. Operators are words (`and`/`or`/`not`), symbols (`==`/`<=`), *and* functions
    (`band`/`shl`) at once.
12. Three overlapping control families — `if`/`when`, `match`, `machine`/`become`
    — and `enter` reuses `become`'s AST node ([parse.ludic:176-177](selfhost/parse.ludic)).
13. Typed components/structs exist, but real state lives in 64 untyped int
    registers (`reg`/`setreg`), so `machine`/`match` dispatch on magic numbers.

---

## The two rules everything converges on

**Rule A — `:` associates, `=` binds.**
- `:` introduces a *named part* and its type or value in a declarative structure:
  component/struct fields' types, record initializers, ui props, (future) named
  call arguments.
- `=` binds a value to a storage location or a constant: `let`, assignment
  (`+=` …), `const` value, a field's **default**, and the extern symbol.
- A field declaration uses both, unambiguously: `x: int = 0` reads "`x` *has type*
  `int` (`:`), *defaulting to* `0` (`=`)" — same shape as Rust/TypeScript.
- A record/spawn initializer is declarative, so it uses `:` — `Pos { x: 10 }`.

**Rule B — a statement ends at a newline (or `;` or `}`).**
- Newlines become significant. Two statements on one line require an explicit
  `;`. `ludic-fmt` normalizes one statement per line and inserts/removes `;`.

Everything below is these two rules applied construct by construct.

---

## Target grammar (before → after)

### Records / spawn initializers
```ludic
# doc-check: skip — illustrative redesign snippet (proposed / partial syntax)
# before
spawn Hero { Pos = { x = 10, y = 5 }  Player = { } }
# after
spawn Hero {
  Pos { x: 10, y: 5 }
  Player {}
}
```
`Field = { k = v }` → `Field { k: v }`. The component name is followed directly
by a record; fields use `:`. (Record literals elsewhere read the same:
`{ x: 10, y: 5 }`.)

### UI props → named-argument form
```ludic
# doc-check: skip — illustrative redesign snippet (proposed / partial syntax)
# before
panel id=Root w=288 pad=16 gap=6 align=center { label text="HI" size=26 }
# after
panel(id: Root, w: 288, pad: 16, gap: 6, align: center) {
  label(text: "HI", size: 26)
}
```
A widget becomes "a constructor with named args, then an optional child block."
This deletes the bespoke `key=value` dialect and reuses `:` + commas. (Lower-churn
alternative if the paren form is disliked: keep whitespace separation but colonize
— `panel id: Root w: 288` — still removes the `=` overload.)

### System clauses & modifiers → one annotation channel
```ludic
# doc-check: skip — illustrative redesign snippet (proposed / partial syntax)
# before
edge system Move @deterministic reads [Vel] writes [Pos] phase FixedUpdate
  query (p, v) [Pos, Vel] where a.x > 0 { … }
# after
@edge @deterministic
system Move
  phase FixedUpdate
  reads [Vel] writes [Pos]
  query (p, v) [Pos, Vel] where p.x > 0
{ … }
```
- Prefix modifier words (`edge`, `pure`, `export`) are **retired**; all modifiers
  become `@annotations`, parsed into a real list on the node (not skipped). This
  fixes the `edge system` parse bug (#4) by construction.
- `needs`/`uses` are dropped; `reads`/`writes` stay as the two structural clauses
  and are **stored** (even if analysis is future work) rather than discarded.
- The `query (v) [..]` signature clause is **actually implemented** in
  `parse_system` (#8), lowering to the same `S_QUERY` node as the inline `for`.

### extern
```ludic
# doc-check: skip — illustrative redesign snippet (proposed / partial syntax)
extern fn c_hypot(a: fixed, b: fixed) -> fixed = "hypot_fx"   # unchanged
```
The `= "symbol"` is a binding under Rule A — it stays.

### Statements
```ludic
# doc-check: skip — illustrative redesign snippet (proposed / partial syntax)
# before (legal today)
t.kind = kind  t.text = text  t.ival = ival
# after
t.kind = kind
t.text = text
t.ival = ival
# or, explicitly, on one line:
t.kind = kind; t.text = text; t.ival = ival
```

### Control flow (Phase 4)
- **`when` vs `if`** — `when` is now a working `if`-without-else alias (Phase 1).
  Phase 4 decides whether to keep both spellings or collapse to one; if collapsed,
  remove `when` from docs, the parser, and all editor highlighters together.
- **Typed states replace magic-int machines.** Introduce `enum`, and let
  `machine` dispatch on a typed variable instead of a register:
```ludic
# doc-check: skip — illustrative redesign snippet (proposed / partial syntax)
# before                                   # after
const R_PHASE: int = 0                     enum Phase { KnightMenu, KnightResolve, MageMenu, EnemyTurn }
machine R_PHASE {                          var phase: Phase = Phase.KnightMenu
  state KnightMenu = 0 { … become … }      machine phase {
  state KnightResolve = 1 { … }              state KnightMenu { … become KnightResolve }
}                                            state KnightResolve { … }
                                           }
```
  `state X = N` loses the magic `= N` (ordinal comes from the enum). `become`
  and `enter` (scenes) keep one shared lowering but read from a typed slot.

---

## Phase sequence

Each phase is independently shippable and ends green on `./test.sh` +
`./selfhost/test.sh` (fixpoint).

### Phase 0 — Doctrine (done here)
Rules A and B above; colon-everywhere; `@`-annotations as the single modifier
channel; typed enums for state. No code.

### Phase 1 — Truth-in-documentation ✅ DONE
Made spec ⇄ compiler agree **before** any grammar change. What landed:
- ✅ **`edge system` crash fixed** (#4) — `parse_system` now consumes an optional
  `edge` marker before `system` ([parse_game.ludic](selfhost/parse_game.ludic)).
  (`edge` is a pure marker; the emitter never lowered it differently.)
- ✅ **Signature-`query` implemented** (#8) — `query (vars) [terms] where c` in a
  system header desugars to the same `S_QUERY` node the inline `for` builds, so
  `examples/qdecl.ludic` compiles and runs. Also fixed multi-line clause parsing
  (clauses may now span lines).
- ✅ **`when c { }` implemented** (#9) — as an `if`-without-else alias in
  [parse.ludic](selfhost/parse.ludic). Docs + editors already listed it; now the
  compiler agrees, so no editor-vocab churn was needed.
- ✅ **`scene`/`layer` marked not-yet-implemented** (#7) — prominent note in
  LANGUAGE.md §"Scenes & layers" + a header on [examples/scenes.ludic](examples/scenes.ludic).
  Full scene front-end + emission deferred (real work, out of Phase 1 scope).
- ✅ **`reads`/`writes` honesty** (#6) + the stale "Not yet implemented" section
  updated in [LANGUAGE.md](LANGUAGE.md); scenes/reads-writes/dropped-CLI-flags now
  listed there.
- ✅ **`test.sh` guards drift** — added a `qsmoke qdecl` compile check. Suite
  green (14/14 incl. the toolchain agent's CLI smoke tests).
- ✅ **CLI flags** (#10) — `--shared`/`--fmt`/wasm noted as dropped-with-the-C-driver
  in LANGUAGE.md; `-o`/`--emit-llvm` were being re-added by the toolchain agent
  (now real, verified in `test.sh`); COMPILING.md updated by that agent.
- Deferred (intentionally): `pure`-is-ignored (#5) is undocumented and harmless;
  it will be folded into `@pure` in Phase 3 rather than churned now.
- **Not done / by design:** `scenes.ludic` is *not* added to `test.sh` (it can't
  compile yet — a positive test would fail; the header note + LANGUAGE.md warning
  cover the drift instead).

### Phase 2 — Statement separation (Rule B) ✅ DONE
Landed on branch `syntax-redesign-phase2` (baseline committed on `main` first).
- ✅ **Parser enforces a separator** — `block()` requires a newline or `;` after
  each statement, else `expected newline or ';' between statements`
  ([parse.ludic](selfhost/parse.ludic)). Also fixed `if`-without-`else` swallowing
  its trailing separator (it now peeks for `else` and restores if absent).
- ✅ **Interpretation chosen:** *require a separator*, not *reflow to one-per-line*.
  The migration **inserts `;` at statement boundaries** and leaves lines intact —
  comment-safe, minimal-diff, and it makes boundaries visible without an
  opinionated reflow. One-per-line stays the recommended hand-written form.
- ✅ **Migration tool** ([tools/ludic-tools/migrate_separators.c](tools/ludic-tools/migrate_separators.c),
  reuses the toolchain lexer) with a
  **verification oracle**: a `;` inserted at a real boundary is a semantic no-op,
  proven by the migrated compiler compiling itself to **IR byte-identical to the
  seed** and every golden game rendering identically. ~1100 boundaries across the
  corpus (examples, runtime, and the 25 self-host fragments).
- ✅ **Reseeded** to the strict compiler (19557 lines); C-free bootstrap fixpoint
  holds; `./test.sh` 14/14; all goldens byte-identical; qdecl runs correctly.
- ✅ **Docs updated** — Rule B documented in LANGUAGE.md §Statements; BOOTSTRAP.md
  R1 (which advertised no-separator juxtaposition as legal) and its stale code
  fences updated; `check-docs` (now a live strict parse gate) green across all docs.

**Bug found & fixed en route:** a multi-line string literal in
[emit_expr.ludic](selfhost/emit_expr.ludic) (`emit(")<newline>")`) lexed fine in
the self-host lexer but the **C toolchain lexer** (`ludic_syntax.h`, shared by
sepfix, `ludic-fmt`, and the LSP) stops strings at newline — so it mis-lexed and
`ludic-fmt` would corrupt such a file. Converted it to the byte-identical `\n`
escape. **Open follow-up:** align the C lexer to allow newlines in strings, or
forbid literal newlines in string literals language-wide (the two lexers should
agree). Flagged to the toolchain owners.

### Phase 3 — Named-field unification (Rule A)

**3a — spawn/record initializers ✅ DONE.** `Comp = { f = v }` → `Comp { f: v }`.
`record()` requires `:` and `parse_spawn()` drops the `=` before the record
([parse.ludic](selfhost/parse.ludic), [parse_game.ludic](selfhost/parse_game.ludic)).
The `=` is now assignment/const/default/extern-binding only. Migration tool:
[migrate_records.c](tools/ludic-tools/migrate_records.c) (spawn-context aware).
Records live only in games, so the seed was unaffected; verified every golden
byte-identical, old `=` form now rejected, reseeded, `test.sh` 14/14. Doc examples
updated (LANGUAGE.md, BOOTSTRAP.md R2).

**3b — ui props → `key: value` ✅ DONE.** `panel id=Root w=288` → `panel id: Root
w: 288`. `parse_widget` now reads props with `:` ([parse_game.ludic](selfhost/parse_game.ludic)).
Chose the **colonized** form over parenthesized named-args: it satisfies Rule A
(the `=` overload is gone) with minimal churn, needs no new grammar, and `emit_ui`
(which reads the AST) and `ludic-fmt` (which formats `:` correctly by default)
were both untouched. Migration: [migrate_ui.c](tools/ludic-tools/migrate_ui.c).
menu golden byte-identical, old `=` form rejected, reseeded, `test.sh` 14/14.
(The parenthesized form `panel(id: Root, w: 288)` remains a possible future
refinement if the language ever gains named call arguments.)

**3c — dropped the dead `needs`/`uses` clause synonyms ✅ DONE.** `reads`/`writes`
stay (documented; still parsed-and-reserved). `needs`/`uses` were undocumented and
unused anywhere in the corpus — removed from `parse_system`. *Not done:* actually
*storing* reads/writes on the node for an analysis pass — that's analysis
infrastructure, out of scope for a syntax pass.

**3d — modifiers `edge`/`pure`/`export` → `@`-annotations.** Not started. Low
urgency: `edge`/`pure` are unused in the corpus and `export` appears once
([examples/lib/combat.ludic](examples/lib/combat.ludic)); it needs `parse_one_decl`
to accept leading `@annotations` on any declaration.

Each sub-phase follows the proven pattern: parser change → verification-gated
migration (IR byte-identical / goldens identical) → reseed → docs. The migration
tools ([migrate_separators.c](tools/ludic-tools/migrate_separators.c),
[migrate_records.c](tools/ludic-tools/migrate_records.c)) are the reusable spine.

### Phase 4 — Control-flow & operator consolidation (largest)
- Remove `when`; confirm `if` covers all uses in the corpus.
- Introduce `enum` + typed `machine`/state; migrate `combat.ludic`'s R_PHASE
  machine and the register-driven `match reg(…)` sites.
- Decide the bitwise story: keep `band/shl/…` as functions (document as a
  deliberate "one spelling" choice) or promote to operators — pick one and state
  it, don't leave it implicit.

### Phase 5 — Single source of truth for keywords/grammar
- Generate every editor plugin keyword list, `ludic_syntax.h`, and the LSP's
  token set from **one** canonical list so a keyword can never again be
  highlighted but unparsed.
- Add a CI check (extend `tools/check-docs.py` / `check-vocabulary.py`) that
  every ` ```ludic ` fence in the docs compiles, closing the doc-drift loop
  permanently.

---

## Decision log
- **Scope:** full redesign, Phases 0–5. *(chosen)*
- **Named fields:** colon everywhere; `=` is binding-only. *(chosen)*
- **Open — Phase 4 detail:** typed `enum` state vs. keep integer registers.
  Recommended: typed enums (fixes #13), but it's the deepest change; can be
  deferred without blocking Phases 1–3.
- **Open — ui props:** paren named-args (`panel(id: Root)`) vs. colonized
  whitespace (`panel id: Root`). Recommended: paren form for full cohesion.
- **Open — bitwise ops:** functions (status quo, documented) vs. operators.
