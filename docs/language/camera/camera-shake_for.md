---
id: camera-shake_for
name: Camera.shake_for
category: camera
kind: namespace-method
tokens: Camera.shake_for
sig: Camera.shake_for(amount: px, frames: n)
tip: Shake for a number of frames, then stop, with no bookkeeping.
order: 5
ns: Camera
member: shake_for
---

Shakes the camera by up to ±<code>amount</code> pixels for <code>frames</code> frames; the engine re-rolls the offset each frame and clears it when the time is up. A bigger amount replaces one in flight. <code>Camera.shake(amount: 0)</code> still cancels the offset for the rest of a frame — useful before a HUD pass that must stay steady.

```ludic
# doc-check: skip — illustrative
@On(Damaged) handler Hurt { if target == player { Camera.shake_for(amount: 4, frames: 8) } }
```
