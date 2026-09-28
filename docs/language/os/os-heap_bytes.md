---
id: os-heap_bytes
name: Os.heap_bytes
category: os
kind: namespace-method
tokens: Os.heap_bytes
sig: Os.heap_bytes() -> long
tip: malloc's live bytes (macOS; 0 elsewhere).
order: 19
ns: Os
member: heap_bytes
---

The bytes malloc holds live across every zone of the process, on macOS; 0 on other platforms. Ludic has no garbage collector, so a path that runs every frame must give back all it takes: read this before and after many rounds of it, and the difference is what it keeps. A test built on it should allow for 0 elsewhere.

```ludic
program Heap {
  entry {
    let before = Os.heap_bytes()
    var n = 0
    for i in 0 .. 1000 { if `{i}` == "7" { n += 1 } }
    print(Os.heap_bytes() - before)
  }
}
```
