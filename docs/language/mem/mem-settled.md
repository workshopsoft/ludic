---
id: mem-settled
name: Mem.settled
category: mem
kind: namespace-method
tokens: Mem.settled
sig: Mem.settled() -> void
tip: Judge from now: the kept set becomes the floor.
order: 2
ns: Mem
member: settled
---

Ends the warm-up at once and takes the memory held now as the baseline. It does nothing while the fence is already judging, so after a build call <code>Mem.play()</code> first. A leak after it fails at its own frame.

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
