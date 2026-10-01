---
id: mem-frame
name: Mem.frame
category: mem
kind: namespace-method
tokens: Mem.frame
sig: Mem.frame() -> void
tip: Mark the end of a frame; call once per frame.
order: 3
ns: Mem
member: frame
---

Closes the frame: tracking starts at the first call, a judged frame that kept memory counts as bad (and warns or exits 86 by <code>R3D_ALLOC_FENCE</code>).

```ludic
program Demo {
  entry {
    Mem.play()
    Mem.settled()
    Mem.frame()
    print(`bad {Mem.bad_frames()} kept {Mem.kept()}`)
  }
}
```
