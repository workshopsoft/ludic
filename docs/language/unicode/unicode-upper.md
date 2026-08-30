---
id: unicode-upper
name: Unicode.upper
category: unicode
kind: namespace-method
tokens: Unicode.upper
sig: Unicode.upper(s) -> string
tip: Uppercase a string.
order: 6
ns: Unicode
member: upper
---

Returns a new string with each letter uppercased. v1 maps ASCII and Latin-1 letters (correct for Western-European text); other scripts and locale-specific rules are follow-ups, and unmapped code points pass through unchanged.

Parameters:
- `s` — the UTF-8 string

```ludic
program Upper {
  entry {
    if Unicode.upper("hello") == "HELLO" { print(1) }
  }
}
```
