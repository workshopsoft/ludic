---
id: unicode-lower
name: Unicode.lower
category: unicode
kind: namespace-method
tokens: Unicode.lower
sig: Unicode.lower(s) -> string
tip: Lowercase a string.
order: 7
ns: Unicode
member: lower
---

Returns a new string with each letter lowercased. v1 maps ASCII and Latin-1 letters; other scripts and locale-specific rules are follow-ups, and unmapped code points pass through unchanged. Useful for case-insensitive comparison of names and commands.

Parameters:
- `s` — the UTF-8 string

```ludic
program Lower {
  entry {
    if Unicode.lower("HELLO") == "hello" { print(1) }
  }
}
```
