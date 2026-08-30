---
id: unicode-grapheme_len
name: Unicode.grapheme_len
category: unicode
kind: namespace-method
tokens: Unicode.grapheme_len
sig: Unicode.grapheme_len(s) -> int
tip: Number of user-perceived characters.
order: 9
ns: Unicode
member: grapheme_len
---

Counts <strong>grapheme clusters</strong> — what a reader perceives as one character — which is what you want for cursor movement and visual width. A base letter plus a combining accent, a ZWJ emoji sequence (like a family emoji), and a two–regional-indicator flag each count as one, even though they span several code points. This v1 approximates UAX#29 over those common cases; full segmentation is a follow-up.

Parameters:
- `s` — the UTF-8 string

```ludic
program GraphemeLen {
  entry {
    print(Unicode.grapheme_len("hello"))   # 5 (plain ASCII)
  }
}
```
