---
id: light-clear_occluders
name: Light.clear_occluders
category: light
kind: namespace-method
tokens: Light.clear_occluders
sig: Light.clear_occluders()
tip: Forget every occluder — call once per frame before re-registering.
order: 4
ns: Light
member: clear_occluders
---

Forgets every rectangle previously passed to <a href="light-occlude"><code>Light.occlude</code></a>. Occluders accumulate across calls and persist between frames, so a game that casts shadows calls this once at the top of its render phase and then re-registers the walls that should block light this frame — the same clear-then-rebuild rhythm as an immediate-mode draw list. With no occluders registered, <a href="light-point"><code>Light.point</code></a> lights its whole radius unobstructed.

Parameters: none.

```ludic
program Demo {
  property Tag { v: int = 0 }
  model Marker { Tag }
  handler Render phase Update {
    Screen.clear(0)
    Light.clear_occluders()                       # start the frame with no shadows
    Light.occlude(90, 60, 6, 40)
    Light.point(40, 80, 100, Color.rgb(255, 255, 255), 1.0)
    Screen.show()
  }
}
```
