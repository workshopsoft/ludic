---
id: light-falloff
name: Light.falloff
category: light
kind: namespace-method
tokens: Light.falloff
sig: Light.falloff(exponent)
tip: Set the brightness-ramp exponent for later lights (1 linear, 2 quadratic…).
order: 6
ns: Light
member: falloff
---

Sets the **falloff curve** applied to every light emitted after it. A light's brightness ramps from full at the centre to zero at its radius; the ramp is raised to <code>exponent</code>, so <code>1</code> is the original linear falloff, <code>2</code> is quadratic (a softer, more concentrated core), <code>3</code> cubic, and so on. Like the occluder store, the setting persists across frames until changed — a game sets it once, or per light, and it rides alongside the short <a href="light-point"><code>Light.point</code></a> / <a href="light-spot"><code>Light.spot</code></a> signatures. Integer exponent, Q16.16 ramp — deterministic.

Parameters:
- `exponent` — the ramp power, an integer `>= 1` (`1` = linear, the default)

```ludic
program Demo {
  property Torch { x: int = 0, y: int = 0 }
  model Lamp { Torch }
  handler Render phase Update {
    Screen.clear(0)
    Light.ambient(Color.rgb(24, 24, 32))
    Light.falloff(2)                                        # a tighter, quadratic glow
    Light.point(80, 60, 70, Color.rgb(255, 210, 130), 1.0)
    Screen.show()
  }
}
```
