---
id: unicode-len
name: Unicode.len
category: unicode
kind: namespace-method
tokens: Unicode.len
sig: Unicode.len(s) -> int
tip: Number of code points in a string (not bytes).
order: 1
ns: Unicode
member: len
---

Counts the <strong>code points</strong> in a UTF-8 string — the correct "length" for most text logic, unlike a raw byte count which over-counts anything non-ASCII. Contrast <a href="unicode-byte_len"><code>byte_len</code></a> (storage size) and <a href="unicode-grapheme_len"><code>grapheme_len</code></a> (user-perceived characters).

Parameters:
- `s` — the UTF-8 string

```ludic
program Len {
  entry {
    print(Unicode.len("hello"))   # 5
  }
}
```
