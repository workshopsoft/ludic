---
id: text-index_of
name: Text.index_of
category: text
kind: namespace-method
tokens: Text.index_of
sig: Text.index_of(s, sub) -> int
tip: The byte index of a substring, or -1 if absent.
order: 6
ns: Text
member: index_of
---

Returns the zero-based byte index where <code>sub</code> first appears in <code>s</code>, or <code>-1</code> if it never does — so <code>Text.index_of("hello world", "world")</code> is <code>6</code>. Use it to locate a separator before slicing, or as a present-and-where test in one call: guard with <code>if idx >= 0</code>. It reports the first match only.

Parameters:
- `s` — the string to search
- `sub` — the substring to locate

```ludic
program KeyValue {
  var pair: string = "hp=42"

  handler Parse phase Update {
    let eq = Text.index_of(pair, "=")            # 2
    let key = Text.slice(pair, 0, eq)            # "hp"
    let value = Text.to_int(Text.slice(pair, eq + 1, Text.length(pair)))
  }
}
```
