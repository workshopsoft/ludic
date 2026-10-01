---
id: mem
title: Mem
order: 10
---

The allocation fence: it finds memory a frame keeps that nothing gave back. A game calls <code>Mem.frame()</code> once per frame; everything else is optional.

**Tracking** starts at the first <code>Mem.frame()</code> (or at <code>Mem.play()</code> when <code>R3D_ALLOC_AUTO=0</code>, or at frame <code>R3D_ALLOC_PLAY</code>). Every allocation is recorded by its source line.

**Warm-up.** Loading grows memory on purpose, so judging waits. It starts once <code>R3D_ALLOC_WARM</code> frames (default 600) in a row kept nothing, or <code>R3D_ALLOC_WARM_MAX</code> frames (default 5 times WARM, 3000) after tracking started, whichever is first. <code>R3D_ALLOC_REWARM</code> (120) is the least a later <code>Mem.play()</code> waits.

**Judging.** A judged frame that ends holding more than it began with is a leak, reported with its lines. <code>R3D_ALLOC_FENCE=off|count|warn|fail</code> picks the reaction: <code>count</code> only counts (<code>Mem.bad_frames()</code>), <code>warn</code> prints, <code>fail</code> prints and exits with code 86. A windowed build fails only under <code>R3D_DEV</code>; a headless one fails by default. A table that declares a cap (<code>@max</code>) and overflows exits 87.

**The scene boundary.** A game that builds a world after a long idle screen is already being judged, so the build's one-time memory would fail the run. After the build call <code>Mem.play()</code> then <code>Mem.settled()</code>: play re-arms the warm-up and the frame is not judged, settled makes what is kept now the new floor. A real leak afterwards still fails at its own frame. <code>Mem.play()</code> alone also works, but the fence then stays blind until 600 frames in a row keep nothing or the R3D_ALLOC_WARM_MAX (3000) deadline from the first play, and for at least R3D_ALLOC_REWARM (120) frames after the call; the pair is the deterministic form.

```ludic
program Demo {
  property Box { v: int = 0 }
  entry {
    var world = new []Box
    for f in 0 .. 3000 {
      if f == 900 {
        for i in 0 .. 500 { push(world, new Box { v: i }) }   # the one-time build
        Mem.play()
        Mem.settled()
      }
      Mem.frame()
    }
  }
}
```

See <code>examples/lang/alloc_fence_scene.ludic</code>.
