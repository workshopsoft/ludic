---
id: unicode-char_at
name: Unicode.char_at
category: unicode
kind: namespace-method
tokens: Unicode.char_at
sig: Unicode.char_at(s, i) -> int
tip: The i-th code point of a string.
order: 4
ns: Unicode
member: char_at
---

Returns the code point at code-point index <code>i</code> as an integer (a Unicode scalar value), or <code>-1</code> when <code>i</code> is out of range. Indexing is by code point, not byte, so it never lands in the middle of a multibyte character.

Parameters:
- `s` — the UTF-8 string
- `i` — the code-point index (0-based)

```ludic
program CharAt {
  entry {
    print(Unicode.char_at("hello", 0))   # 104 = 'h'
  }
}
```
