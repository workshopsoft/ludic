---
id: mem-bad_frames
name: Mem.bad_frames
category: mem
kind: namespace-method
tokens: Mem.bad_frames
sig: Mem.bad_frames() -> long
tip: How many judged frames kept memory.
order: 4
ns: Mem
member: bad_frames
---

Returns the number of judged frames that ended holding more than they began with. Useful under <code>R3D_ALLOC_FENCE=count</code>.

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
