---
id: text-slice
name: Text.slice
category: text
kind: namespace-method
tokens: Text.slice
sig: Text.slice(s, a, b) -> str
tip: A substring covering bytes [a, b).
order: 2
ns: Text
member: slice
---

Returns a fresh string of the bytes from index <code>a</code> up to but not including <code>b</code> — the half-open range <code>[a, b)</code>, so <code>Text.slice("hello world", 0, 5)</code> is <code>"hello"</code>. It is the call form of the <code>s[a..b]</code> slice syntax and allocates a new string. Use it to cut a fixed-width field, drop a prefix, or take the first few characters of a name.

Parameters:
- `s` — the source string
- `a` — the start byte index (inclusive)
- `b` — the end byte index (exclusive)

```ludic
program FirstWord {
  var line: str = "hello world"

  handler Split phase Update {
    let space = Text.index_of(line, " ")   # 5
    let word = Text.slice(line, 0, space)  # "hello"
  }
}
```
