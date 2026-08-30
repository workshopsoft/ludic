---
id: unicode-truncate
name: Unicode.truncate
category: unicode
kind: namespace-method
tokens: Unicode.truncate
sig: Unicode.truncate(s, n) -> string
tip: First n code points of a string.
order: 8
ns: Unicode
member: truncate
---

Returns the first <code>n</code> code points as a new string, never splitting a multibyte character — the safe way to cap a display name or a chat line to a length. If the string has fewer than <code>n</code> code points it is returned whole; <code>n &lt;= 0</code> yields the empty string.

Parameters:
- `s` — the UTF-8 string
- `n` — the maximum number of code points to keep

```ludic
program Truncate {
  entry {
    if Unicode.truncate("hello", 3) == "hel" { print(1) }
  }
}
```
