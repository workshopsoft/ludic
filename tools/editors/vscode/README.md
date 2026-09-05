# Ludic for VS Code

Syntax highlighting, formatting, and full language-server support for **Ludic**,
the AI-first, ECS-native game language. See `LANGUAGE.md` in the Ludic repository
for the language reference.

## What you get

| | Source |
|---|---|
| Syntax highlighting | TextMate grammar, works with no build |
| Semantic highlighting | `ludic-lsp` — real name resolution, so a component reads differently from a local |
| Diagnostics | structural errors as you type; `ludicc`'s own errors on save |
| Completion | context-aware: fields after `.`, components inside `query [...]`, phases after `phase`, widgets inside `ui` |
| Hover | signatures and docs for builtins, intrinsics, and everything you declared |
| Go to definition / references / rename | across every file in the compilation unit, following `import` |
| Formatting | format-on-save, comment-preserving |
| Outline, folding, inlay hints, signature help | |
| ` ```ludic ` fences in Markdown | highlighted, checked, and formatted |

## Setup

Build the toolchain once, from the repository root:

```bash
bin/ludic-dev tools
```

That produces `bin/ludic-lsp` and `bin/ludic-fmt`, which the extension finds
on its own. If you keep them elsewhere, set `ludic.server.path`.

Format on save:

```json
"[ludic]": { "editor.formatOnSave": true }
```

## Settings

- `ludic.server.path` — where `ludic-lsp` lives (`~` and `${workspaceFolder}` expand). Empty = search `bin/`, then `PATH`.
- `ludic.server.enabled` — turn the server off and keep only static highlighting.
- `ludic.compilerPath` — where `ludicc` lives, for on-save diagnostics (`~` and `${workspaceFolder}` expand).
- `ludic.compilerDiagnostics` — whether to run the compiler at all.
- `ludic.indentSize` — spaces per level for the formatter.
- `ludic.trace.server` — log LSP traffic (`Ludic: Show Language Server Log`).

## Installing without publishing

```bash
cd tools/editors/vscode
npm install
npx @vscode/vsce package
code --install-extension ludic-1.0.0.vsix
```
