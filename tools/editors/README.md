# Ludic in your editor

Everything here is built on one idea: **write the language knowledge once, in
Ludic, and let every editor talk to it.** There is one vocabulary, one
formatter and one language server. VS Code and JetBrains get first-class plugins
because those are the two that were asked for; every other editor gets the same
capabilities by pointing at the same binary.

```
tools/ludic-tools/            the actual language knowledge, in Ludic
  ludic_syntax.h              the vocabulary tables (keywords, operators, builtins)
                              that the formatter, the server and the vocabulary
                              check all read — the source of truth
  fmt.ludic                   -> bin/ludic-fmt   token-based, comment-preserving formatter
  lsp.ludic                   -> bin/ludic-lsp   the language server (LSP 3.17)

tools/editors/
  shared/                     TextMate grammar + Markdown injection + language config
  vscode/                     VS Code extension
  jetbrains/                  IntelliJ Platform plugin (Community editions included)
  neovim/ helix/ emacs/ sublime/ zed/     configuration, no plugin needed
```

## Getting the server

An installed toolchain already has it: `curl -fsSL https://workshopsoft.pages.workshopsoft.io/ludic/install.sh | sh`
puts `ludic-lsp` and `ludic-fmt` in `~/.ludic/bin`, on your `PATH`, and
`ludic lsp` runs the server on stdio — that is what an editor should spawn, since
it needs no path configuration.

From a checkout, build them with:

```bash
bin/ludic-dev tools
```

Produces `bin/ludic-fmt` and `bin/ludic-lsp`. Add `--install` to symlink both
into `~/.local/bin`, `--test` to run `bin/ludic-dev test-tools` afterwards.

## What you get, in any editor

| Feature | How |
|---|---|
| Syntax highlighting | LSP semantic tokens, or the TextMate grammar with no server at all |
| Diagnostics | structural errors as you type; `ludicc`'s own errors on save |
| Completion | context-aware — see below |
| Hover | signature + docs for builtins, intrinsics, and everything you declared |
| Go to definition, find usages, rename | across the whole compilation unit, following `import` — by resolving each occurrence, not by matching text, so renaming a component's `x` leaves every other `x` alone |
| Formatting | whole-file, comment-preserving, idempotent |
| Outline, folding, inlay hints, signature help, document links | |
| ` ```ludic ` in Markdown | highlighted, checked and formatted |

Completion knows where the caret is: fields after `.`, components inside
`query [...]` and after `spawn`, phase names after `phase`, scene names after
`enter`, widget types and props inside a `ui` block, types after `:` and `->`,
and otherwise keywords, builtins, and everything in scope.

## Per-editor setup

- **VS Code** — [`vscode/`](vscode/). `npm install && npx @vscode/vsce package`, then
  install the `.vsix`. Finds the binaries under `bin/` on its own.
- **JetBrains** — [`jetbrains/`](jetbrains/). `./gradlew buildPlugin`, then install the
  zip from disk. Uses LSP4IJ rather than the paid-IDE LSP API, so it works in
  Community editions too.
- **Neovim** — `require('ludic').setup()` from [`neovim/`](neovim/lua/ludic.lua).
- **Helix** — merge [`helix/languages.toml`](helix/languages.toml) into your config.
- **Emacs** — [`emacs/ludic-mode.el`](emacs/ludic-mode.el); eglot is wired up in one line.
- **Sublime** — [`sublime/README.md`](sublime/README.md); the TextMate grammar loads as-is.
- **Zed** — [`zed/README.md`](zed/README.md); LSP-only, no grammar to build.
- **Anything else** that speaks LSP:

  ```
  command: ludic lsp
  languages: ludic, markdown
  initializationOptions: { "compilerDiagnostics": true, "indentSize": 2 }
  ```

  (`ludic lsp` is on `PATH` after an install; from a checkout it is
  `bin/ludic lsp`, and the server finds `ludicc` next to itself.)

## Markdown

Markdown fenced-code highlighting is not one standard — it is three mechanisms,
and this ships all three so that a ` ```ludic ` block works wherever you write
prose:

1. **TextMate injection** (`shared/ludic.markdown-injection.json`) — what VS Code,
   Sublime and other TextMate-based editors use. It is a plain grammar file with
   an `injectionSelector`, so it is portable rather than VS Code-specific.
2. **Language-ID resolution** — JetBrains' Markdown support matches a fence's
   info string against registered language IDs, so the plugin registering as
   `Ludic` is all that is needed; no Markdown-specific code exists in the plugin.
3. **The language server** — `ludic-lsp` accepts Markdown documents directly. It
   copies the buffer, blanks every byte outside a ` ```ludic ` fence, and
   analyses the result; offsets still line up with the real file, so semantic
   highlighting, hover, completion and go-to-definition all work inside fences
   with no editor-side support at all. This is the fallback that works even
   where the other two do not.

   It reports **no diagnostics** in Markdown, deliberately. A fence is a
   snippet — an elision mark, or a body shown without its enclosing `game`
   block — so nearly every error found there would be the documentation doing
   its job. `ludic-fmt --check` still keeps the fences formatted, which is the
   part of "is this doc correct" that can be answered without guessing.

The formatter handles Markdown too, which keeps documentation honest:

```bash
bin/ludic-fmt --check LANGUAGE.md README.md     # CI: fail if a fence is unformatted
bin/ludic-fmt -w LANGUAGE.md                    # reformat the fences, leave the prose
```

## Keeping a tree formatted

```bash
ln -sf ../../tools/git-hooks/pre-commit .git/hooks/pre-commit
```

The hook runs `ludic-fmt --check` over the staged `.ludic` and `.md` files only,
and does nothing at all when `bin/ludic-fmt` has not been built — so it never
blocks a commit on a machine that has not run `bin/ludic-dev tools`.

## Why the formatter is not `ludicc --fmt`

The compiler has a canonical printer, and it is the right tool for seeing what
the compiler parsed. It is the wrong tool for an editor: it walks the AST *after*
import splicing, so it drops every comment and inlines every imported file into
whichever file you pointed it at. Running it as format-on-save on
`chronorift/combat.ludic` would replace that file with the whole game.

`ludic-fmt` works on the token stream instead. Nothing is dropped or reordered —
every token is re-emitted in order, and the only freedom taken is the whitespace
between them. Lines are re-indented and respaced but never joined or split, so
you keep control of line structure.

Two carve-outs keep the output idiomatic rather than merely uniform, because
both spellings are what the language documents and uses:

- runs of two or more spaces are preserved, so hand-aligned columns
  (`const R_DIR:   int = 0    # 0 up`) survive a save;
- `id=Root` inside a `ui` block and `{Enemy}` inside a query stay tight.

`bin/ludic-dev test-tools` checks the property that matters: formatting every file in
the tree and re-running the *compiler's* canonical dump produces byte-identical
output. The formatter cannot change what a program means.

## Keeping it honest

The vocabulary is written down in five places that cannot include each other —
the compiler's two tables, `ludic_syntax.h`, the TextMate grammar (JSON), and the
JetBrains lexer (Kotlin). Adding a builtin and forgetting the rest is silent
failure, so `bin/ludic-dev check-vocabulary` (written in Ludic) compares all five, and
`bin/ludic-dev test-tools` runs it.

When you add a keyword or builtin: put it in `ludic_syntax.h`, then run
`bin/ludic-dev test-tools` and let it tell you which copies still need it.
