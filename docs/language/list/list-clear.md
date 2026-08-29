---
id: list-clear
name: List.clear
category: list
kind: namespace-method
tokens: List.clear
sig: List.clear(s) -> void
tip: Remove all elements, keeping capacity.
order: 2
ns: List
member: clear
---

Empties <code>s</code> by setting its length back to zero. The backing buffer is kept, so refilling the slice afterward reuses the same memory without reallocating. Use it to reset a per-frame list — collisions, visible tiles, particles to draw — at the start of each update instead of building a new slice every frame.

Parameters:
- `s` — the slice to empty

```ludic
program FrameHits {
  var hits: []int = new []int

  handler BeginFrame phase Update {
    List.clear(hits)   # start the frame with an empty list
  }
}
```
