---
id: text-pad_right
name: Text.pad_right
category: text
kind: namespace-method
tokens: Text.pad_right
sig: Text.pad_right(s, width) -> string
tip: Pad with spaces on the right to a width.
order: 16
ns: Text
member: pad_right
---

Returns <code>s</code> padded with trailing spaces until it is at least <code>width</code> bytes long; a string already that long is returned unchanged. Left-aligns text into fixed-width columns for tables and menus.

```ludic
program Demo {
  handler Step phase Update {
    let cell = Text.pad_right(label, 12)
  }
}
```
