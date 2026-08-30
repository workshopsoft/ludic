# Ludic Syntax Redesign — Cohesion Pass

A plan to make Ludic's syntax internally consistent. It fixes the drift between
the spec and the compiler, then unifies the grammar around two rules. Scope:
**full redesign (Phases 0–5)**. Named-field direction: **colon everywhere**.

> Status: **Phases 1–5 complete.** Every phase kept the compiler self-hosting to
> a fixpoint (`bin/x test` 14/14), and each syntax migration was proven
> behaviour-preserving (the migrated compiler compiles itself to byte-identical
> IR; every golden game renders byte-identically). Landed on branch
> `syntax-redesign-phase2` over a committed baseline on `main`.
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
5. `pure fn` — parses, `pure` silently discarded ([parse.ludic:272](selfhost/parse.ludic)); undocumented. *(✅ Phase 3d: now `@pure`)*
6. `@anno` + `reads/writes/needs/uses [..]` — parsed then thrown away
   ([parse_game.ludic:15-31](selfhost/parse_game.ludic)); four synonyms, two undocumented. *(✅ Phase 3c: `needs`/`uses` dropped)*
7. `scene`/`layer`/`on enter` — full LANGUAGE.md section + [examples/lang/scenes.ludic](examples/lang/scenes.ludic),
   **does not compile** (`expected declaration`).
8. `query (v) [..]` in a system signature — two LANGUAGE.md sections +
   [examples/lang/qdecl.ludic](examples/lang/qdecl.ludic), **does not compile** (`parse error: {`). *(✅ implemented in Phase 1)*
9. `when cond {}` — documented ([LANGUAGE.md:329](LANGUAGE.md)) + in all three editor
   highlighters, **never parsed**. *(✅ implemented in Phase 1 as an if-without-else alias)*
10. CLI `--emit-llvm`/`-o`/`--shared`/`--fmt` — documented, but `ludicc` only
    accepts `--windowed`/`--headless` ([main.ludic:8-14](selfhost/main.ludic)).

**Philosophical splits**
11. Operators are words (`and`/`or`/`not`), symbols (`==`/`<=`), *and* functions
    (`band`/`shl`) at once.
12. Three overlapping control families — `if`/`when`, `match`, `machine`/`become`
    — and `enter` reuses `become`'s AST node ([parse.ludic:176-177](selfhost/parse.ludic)). *(Phase 4: `if`/`when` kept by choice; magic-int dispatch resolved)*
13. Typed components/structs exist, but real state lives in 64 untyped int
    registers (`reg`/`set_reg`), so `machine`/`match` dispatch on magic numbers. *(✅ Phase 4: auto-numbered states + `enum` name the values)*

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
edge handler Move @deterministic reads [Vel] writes [Pos] phase FixedUpdate
  query (p, v) [Pos, Vel] where a.x > 0 { … }
# after
@edge @deterministic
handler Move
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
extern function c_hypot(a: fixed, b: fixed) -> fixed = "hypot_fx"   # unchanged
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

Each phase is independently shippable and ends green on `bin/x test` +
`bin/x selfhost-test` (fixpoint).

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
  `examples/lang/qdecl.ludic` compiles and runs. Also fixed multi-line clause parsing
  (clauses may now span lines).
- ✅ **`when c { }` implemented** (#9) — as an `if`-without-else alias in
  [parse.ludic](selfhost/parse.ludic). Docs + editors already listed it; now the
  compiler agrees, so no editor-vocab churn was needed.
- ✅ **`scene`/`layer` marked not-yet-implemented** (#7) — prominent note in
  LANGUAGE.md §"Scenes & layers" + a header on [examples/lang/scenes.ludic](examples/lang/scenes.ludic).
  Full scene front-end + emission deferred (real work, out of Phase 1 scope).
- ✅ **`reads`/`writes` honesty** (#6) + the stale "Not yet implemented" section
  updated in [LANGUAGE.md](LANGUAGE.md); scenes/reads-writes/dropped-CLI-flags now
  listed there.
- ✅ **`bin/x test` guards drift** — added a `qsmoke qdecl` compile check. Suite
  green (14/14 incl. the toolchain agent's CLI smoke tests).
- ✅ **CLI flags** (#10) — `--shared`/`--fmt`/wasm noted as dropped-with-the-C-driver
  in LANGUAGE.md; `-o`/`--emit-llvm` were being re-added by the toolchain agent
  (now real, verified in `bin/x test`); COMPILING.md updated by that agent.
- Deferred (intentionally): `pure`-is-ignored (#5) is undocumented and harmless;
  it will be folded into `@pure` in Phase 3 rather than churned now.
- **Not done / by design:** `scenes.ludic` is *not* added to `bin/x test` (it can't
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
  holds; `bin/x test` 14/14; all goldens byte-identical; qdecl runs correctly.
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
byte-identical, old `=` form now rejected, reseeded, `bin/x test` 14/14. Doc examples
updated (LANGUAGE.md, BOOTSTRAP.md R2).

**3b — ui props → `key: value` ✅ DONE.** `panel id=Root w=288` → `panel id: Root
w: 288`. `parse_widget` now reads props with `:` ([parse_game.ludic](selfhost/parse_game.ludic)).
Chose the **colonized** form over parenthesized named-args: it satisfies Rule A
(the `=` overload is gone) with minimal churn, needs no new grammar, and `emit_ui`
(which reads the AST) and `ludic-fmt` (which formats `:` correctly by default)
were both untouched. Migration: [migrate_ui.c](tools/ludic-tools/migrate_ui.c).
menu golden byte-identical, old `=` form rejected, reseeded, `bin/x test` 14/14.
(The parenthesized form `panel(id: Root, w: 288)` remains a possible future
refinement if the language ever gains named call arguments.)

**3c — dropped the dead `needs`/`uses` clause synonyms ✅ DONE.** `reads`/`writes`
stay (documented; still parsed-and-reserved). `needs`/`uses` were undocumented and
unused anywhere in the corpus — removed from `parse_system`. *Not done:* actually
*storing* reads/writes on the node for an analysis pass — that's analysis
infrastructure, out of scope for a syntax pass.

**3d — modifiers → `@`-annotations ✅ DONE.** `edge`/`pure`/`export` prefix keywords
are retired; declaration modifiers are now leading `@annotations`: `@export fn`,
`@edge system`, `@pure`, `@deterministic`. `parse_one_decl` collects a leading
`@anno` run and `@export` sets the fn export flag ([parse.ludic](selfhost/parse.ludic));
the dead `edge`-dispatch was removed from `parse_system`. Migrated the one
`@export` user ([examples/library/combat.ludic](examples/library/combat.ludic)); old
prefix forms now rejected. Behavior-identical: the export flag is parse-only in
the self-hosted emitter (it emits `@fn_<name>` for every function and never reads
the flag — the C-ABI-export capability is vestigial, a pre-existing gap), so
`@export` and the old `export` produce byte-identical IR. Reseeded, fixpoint
holds, `bin/x test` 14/14, goldens byte-identical.

**Phase 3 is complete.** The `=`/`:` overload (finding #2) and the modifier-zoo
(findings #5, #6) are resolved; `:` associates and `=` binds throughout.

Each sub-phase follows the proven pattern: parser change → verification-gated
migration (IR byte-identical / goldens identical) → reseed → docs. The migration
tools ([migrate_separators.c](tools/ludic-tools/migrate_separators.c),
[migrate_records.c](tools/ludic-tools/migrate_records.c)) are the reusable spine.

### Phase 4 — Control-flow & state consolidation

**4a — machine states auto-number ✅ DONE.** `state KnightMenu = 0 { }` →
`state KnightMenu { }`; a state's value is its declaration index (an explicit
`= expr` still works). Removes the magic constants from state machines
([parse.ludic](selfhost/parse.ludic)). combat.ludic migrated; chronorift golden
byte-identical.

**4b — `enum` types ✅ DONE.** `enum Action { Attack, Guard, Item, Flee }` declares
named `int` constants; a variant is a compile-time int accessed as `Action.Guard`
(= 1), numbered by order. Parser `parse_enum` + dispatch, `enum_ordinal` resolver
in [emit_core.ludic](selfhost/emit_core.ludic), and `Enum.Variant` handling in
[emit_expr.ludic](selfhost/emit_expr.ludic). combat.ludic's battle menus now
dispatch on `KnightAct`/`MageAct` instead of `0..3`; chronorift golden
byte-identical. Editor vocab (`ludic_syntax.h`, JetBrains, TextMate, emacs) gained
`enum` and lost the retired `edge`/`export`/`pure` decl keywords; check-vocabulary
+ test-tools green. **Scoped:** enums are a naming layer over `int` (no distinct
runtime type / enum-typed variables yet) — that keeps register/save semantics
untouched, which the "enum var replaces the register" vision would have to solve.

**`when` vs `if` — kept both (decision).** `when` stays as the `if`-without-else
spelling: it is not incoherent so much as a readability signal ("no else here"),
it is documented and highlighted, and it is a pure alias with no semantic overlap
to untangle. The real target of finding #12 — dispatch on magic integers — is
addressed by 4a/4b, not by collapsing `if`/`when`.

**Bitwise operators — kept as functions (decision).** `band`/`bor`/`bxor`/`bnot`/
`shl`/`shr` stay functions, documented as the deliberate "one spelling, symbols
stay free" choice (LANGUAGE.md §Expressions already states this). Promoting them
to operators would re-introduce the symbol soup the current design avoids.

### Phase 5 — Vocabulary anchored to the compiler ✅ DONE
The editor vocabulary already stayed in sync *with itself* (`check-vocabulary.py`
compares `ludic_syntax.h`, the JetBrains lexer, and the TextMate grammar). The
missing anchor was the **compiler**: a keyword could be highlighted everywhere
and still be silently unparsed. Closed both loops:
- ✅ **Vocabulary ⇄ parser.** `check-vocabulary.py` now extracts every keyword
  `selfhost/parse*.ludic` dispatches on (`is_id(...)` / `streq(t.text, ...)`) and
  requires the header's declaration + clause keywords to be a subset — with a
  `LUDIC_KW_RESERVED` escape hatch for documented, not-yet-implemented keywords
  (`scene`/`layer`/`on`/`start`), itself checked so a reserved word that gets
  implemented must be promoted. Verified it catches an injected bogus keyword.
- ✅ **Reconciled the drift it exposed.** Removed the highlighted-but-unparsed
  `scene`/`layer`/`on`/`start` (→ RESERVED) and the never-implemented
  `needs`/`uses`/`requires`/`ensures`/`invariant`/`effects` clause words, and the
  retired `edge`/`export`/`pure` prefix modifiers, from `ludic_syntax.h`, the
  JetBrains lexer, the TextMate grammar, and the emacs mode; added `enum`/`main`.
  `@`-annotations already highlight generically (`@[A-Za-z_]…`). test-tools 28/0.
- ✅ **Doc-fence compilation** — the other half of "single source of truth" — was
  already live: `check-docs.py` compiles every ` ```ludic ` fence through the
  self-hosted `ludicc --fmt` parse gate (revived during Phase 1's coordination).

Full generation-from-one-list (emit the editor files from a manifest) was not
needed: the bidirectional *checks* give the same guarantee — nothing can drift
without CI failing — without a code-generation step to maintain.

**Phases 1–5 are complete.**

### Phase 6 — vocabulary rename + annotation DSL ✅ DONE (follow-on request)
Renamed the core nouns: `game`/`module` → `program`, `main` → `entry`,
`component` → `property`, `archetype` → `model`, `system` → `handler`. Done via a
transitional self-hosting bootstrap (accept both → reseed → move the compiler's
own source to new keywords + tighten → reseed); old keywords now rejected.
Token-safe corpus migration ([rename_kw.c](tools/ludic-tools/rename_kw.c)), goldens
byte-identical. Reconciled the LSP indexer, editor vocab, check-docs wrapper, and
docs; fixed two pre-existing toolchain bugs (a `set -e` bug in build-tools.sh that
blocked all editor-binary rebuilds, and a stale LSP test offset).

Added an **annotation DSL**: `@Queries(these: [Prop{constraint}, …], on: Model)` on
a handler desugars to the existing `S_QUERY` loop (each property binds by its own
name; a `Prop{…}` constraint qualifies its bare fields; `on:` adds a `{Model}`
tag), and `@Handles(…)` on a program parses as documentation. See
[examples/lang/annotations.ludic](examples/lang/annotations.ludic); bin/x test 15/15. All thirteen findings are resolved or resolved by an
explicit, documented decision.

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
