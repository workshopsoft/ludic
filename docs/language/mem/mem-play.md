---
id: mem-play
name: Mem.play
category: mem
kind: namespace-method
tokens: Mem.play
sig: Mem.play() -> void
tip: Arm the fence's warm-up (a scene boundary).
order: 1
ns: Mem
member: play
---

Starts tracking if it is not running. While tracking, it re-arms the warm-up: judging stops and the current frame is not judged, until 600 frames in a row keep nothing or the <code>R3D_ALLOC_WARM_MAX</code> deadline from the first play, and for at least <code>R3D_ALLOC_REWARM</code> (120) frames. Call it with <code>Mem.settled()</code> after building a scene.

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
