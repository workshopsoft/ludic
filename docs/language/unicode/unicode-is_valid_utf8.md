---
id: unicode-is_valid_utf8
name: Unicode.is_valid_utf8
category: unicode
kind: namespace-method
tokens: Unicode.is_valid_utf8
sig: Unicode.is_valid_utf8(s) -> bool
tip: Is a string well-formed UTF-8?
order: 3
ns: Unicode
member: is_valid_utf8
---

Strictly validates that the bytes are well-formed UTF-8: correct continuation bytes, no overlong encodings, no surrogate code points, and nothing above U+10FFFF. Use it as a gate on untrusted input — a chat line, a downloaded file, a mod's data — before treating it as text.

Parameters:
- `s` — the bytes to validate

```ludic
program Valid {
  entry {
    if Unicode.is_valid_utf8("safe text") { print(1) } else { print(0) }
  }
}
```
