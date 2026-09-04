# Ludic for Zed

Zed extensions want a Tree-sitter grammar for highlighting, which this toolchain
deliberately does not ship — the vocabulary lives in one shared header and is
exposed through the language server's semantic tokens instead, so there is no
second grammar to keep honest.

That is enough for Zed: point it at `ludic-lsp` and highlighting, completion,
diagnostics and formatting all arrive over LSP.

Add to `~/.config/zed/settings.json`:

```json
{
  "lsp": {
    "ludic-lsp": {
      "binary": { "path": "/path/to/gpp/bin/ludic-lsp", "arguments": ["--stdio"] },
      "initialization_options": {
        "compilerPath": "/path/to/gpp/bin/ludicc",
        "compilerDiagnostics": true,
        "indentSize": 2
      }
    }
  },
  "file_types": { "Ludic": ["ludic"] },
  "languages": {
    "Ludic": {
      "language_servers": ["ludic-lsp"],
      "tab_size": 2,
      "hard_tabs": false,
      "format_on_save": "on"
    }
  }
}
```

If you would rather have static highlighting too, the TextMate grammar in
`tools/editors/shared/ludic.tmLanguage.json` can be dropped into a Zed extension
that declares a `grammars` entry — but it is not required.
