---
id: annot-onstart
name: @OnStart
category: annotations
kind: annotation
tokens: @OnStart
sig: @OnStart handler Name { … }
tip: Run a handler once at boot instead of assigning it a frame phase.
order: 50
---

<code>@OnStart</code> pins a handler to the program's boot moment: it runs exactly once when the program starts, before the per-frame phases begin, instead of being placed in a recurring phase. Use it for one-time setup — spawning the initial world, seeding program vars, loading a scene. It overrides the handler's phase, so you write <code>@OnStart handler Name { … }</code> rather than <code>handler Name phase Start</code> and get the same once-at-boot placement through the annotation channel. Its shutdown counterpart is <code>@OnQuit</code>; add <code>@Public</code> to also emit a <code>program_start</code> event other modules can hook.

```ludic
program BootHook {
  property Health { current: int = 0, maximum: int = 100 }
  model Player { Health }

  var elapsed_frames: int = 0

  @OnStart handler CreateWorld {                     # runs once at boot
    spawn Player { Health { current: 100, maximum: 100 } }
    elapsed_frames = 0
  }

  handler CountFrames phase Update { elapsed_frames = elapsed_frames + 1 }
}
```
