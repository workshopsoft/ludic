---
id: unicode-chars
name: Unicode.chars
category: unicode
kind: namespace-method
tokens: Unicode.chars
sig: Unicode.chars(s) -> []int
tip: Every code point of a string, in order.
order: 5
ns: Unicode
member: chars
---

Decodes the whole string into a <a href="type-slice"><code>[]int</code></a> of code points, in order — the iteration primitive for laying out glyphs, scanning text, or transforming character by character without byte-fiddling.

Parameters:
- `s` — the UTF-8 string

```ludic
program Chars {
  entry {
    let cs = Unicode.chars("hi")
    var i = 0
    while i < len(cs) { print(cs[i]); i = i + 1 }   # 104, 105
  }
}
```
