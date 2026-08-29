---
id: text-pad_left
name: Text.pad_left
category: text
kind: namespace-method
tokens: Text.pad_left
sig: Text.pad_left(s, width) -> str
tip: Pad with spaces on the left to a width.
order: 15
ns: Text
member: pad_left
---

Returns <code>s</code> padded with leading spaces until it is at least <code>width</code> bytes long; a string already that long is returned unchanged (never truncated). Right-aligns numbers and labels in a fixed-width HUD column.

```ludic
program Demo {
  handler Step phase Update {
    let cell = Text.pad_left(Text.from_int(score), 6)
  }
}
```
