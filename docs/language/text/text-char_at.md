---
id: text-char_at
name: Text.char_at
category: text
kind: namespace-method
tokens: Text.char_at
sig: Text.char_at(s, i) -> int
tip: The byte value at an index, 0..255.
order: 1
ns: Text
member: char_at
---

Returns the byte at position <code>i</code> in <code>s</code> as an <code>int</code> in the range <code>0</code>..<code>255</code> — for example <code>Text.char_at("hello", 0)</code> is <code>104</code>, the code for <code>h</code>. Indices are zero-based and count bytes. Use it to inspect or classify individual characters, such as testing whether a key of input is a digit.

Parameters:
- `s` — the string to read from
- `i` — the zero-based byte index

```ludic
program FirstIsDigit {
  var entry: str = "7up"

  handler Check phase Update {
    let c = Text.char_at(entry, 0)
    let is_digit = c >= 48 and c <= 57   # true: '7'
  }
}
```
