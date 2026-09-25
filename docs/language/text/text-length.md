---
id: text-length
name: Text.length
category: text
kind: namespace-method
tokens: Text.length
sig: Text.length(s) -> int
tip: The number of bytes in a string.
order: 0
ns: Text
member: length
---

Returns how many bytes are in <code>s</code>, not counting the terminating zero. It is the same count as the bare <code>len(s)</code>, exposed under the <code>Text</code> namespace for discoverability. Use it to size a HUD field, walk a string by index, or check for emptiness with <code>Text.length(s) == 0</code>.

Parameters:
- `s` — the string to measure

```ludic
program NameWidth {
  let label: string = "player one"

  handler Draw phase Render {
    let width = Text.length(label) * 6   # 6 px per glyph
  }
}
```
