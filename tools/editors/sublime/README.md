# Ludic for Sublime Text

Sublime reads TextMate grammars directly, so the shared grammar works as-is.

1. **Highlighting.** Copy `tools/editors/shared/ludic.tmLanguage.json` into your
   `Packages/User/` directory, renamed to `Ludic.tmLanguage.json`. Sublime picks
   up `.ludic` from the grammar's `fileTypes`.

2. **Markdown fences.** Copy
   `tools/editors/shared/ludic.markdown-injection.json` alongside it as
   `Ludic Markdown.tmLanguage.json`. Sublime honours `injectionSelector`, so
   ` ```ludic ` blocks in Markdown are highlighted with no further setup.

3. **Everything else** comes from the language server. Install
   [LSP](https://packagecontrol.io/packages/LSP), then add to
   `Preferences -> Package Settings -> LSP -> Settings`:

```json
{
  "clients": {
    "ludic": {
      "enabled": true,
      "command": ["/path/to/gpp/bin/ludic-lsp", "--stdio"],
      "selector": "source.ludic | text.html.markdown",
      "initializationOptions": {
        "compilerPath": "/path/to/gpp/bin/ludicc",
        "compilerDiagnostics": true,
        "indentSize": 2
      }
    }
  }
}
```

Format on save with `LSP-format-on-save`, or bind `lsp_format_document`.
