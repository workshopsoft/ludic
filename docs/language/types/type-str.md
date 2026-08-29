---
id: type-str
name: str
category: types
kind: type
tokens: str
sig: str
tip: An immutable string — compared by content, sliceable, and interpolatable.
order: 3
---

`str` is an immutable string of bytes. Strings are true <b>values</b>: `+` concatenates two of them and `==` / `!=` compare them <b>by content</b>, not by pointer, so `"go" + direction == "goleft"` behaves as written. Index a single byte with `text[index]` (an `int` code point), take a fresh substring with `text[start..end]`, and measure the byte length with `len(text)`. The readable way to build one is backtick interpolation — `` `score: {score}` `` — which stringifies each `{…}` hole and concatenates.

```ludic
let player_name: str = "Ada"
let greeting: str = `hello {player_name}, score {score}`
if player_name == "Ada" { Screen.status(greeting) }
```
