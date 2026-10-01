---
id: mem-kept
name: Mem.kept
category: mem
kind: namespace-method
tokens: Mem.kept
sig: Mem.kept() -> long
tip: Bytes the last judged frame kept.
order: 5
ns: Mem
member: kept
---

Returns the bytes the last judged frame kept (0 when it kept nothing, or before judging has begun).

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
