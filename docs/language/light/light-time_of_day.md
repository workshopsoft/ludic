---
id: light-time_of_day
name: Light.time_of_day
category: light
kind: namespace-method
tokens: Light.time_of_day
sig: Light.time_of_day(t)
tip: Set the ambient tint from a 0..1 time-of-day — a day/night cycle in one value.
order: 13
ns: Light
member: time_of_day
---

Sets the scene's <a href="light-ambient"><code>ambient</code></a> tint from a single **time-of-day** phase <code>t</code> — a <code>fixed</code> in <code>[0, 1]</code> where <code>0</code> is midnight, <code>0.25</code> dawn, <code>0.5</code> noon and <code>0.75</code> dusk. It ramps a deep-blue night up to full daylight and back over the day, so a game animates one value and the whole world's mood follows, without wiring the ambient colour by hand. It drives the same multiplicative modulate as <code>Light.ambient</code>, so call it once before adding lights. Deterministic (Q16.16 triangle ramp).

Parameters:
- `t` — the time of day, a `fixed` in `[0, 1]` (`0` = midnight, `0.5` = noon)

```ludic
program Demo {
  property Clock { t: int = 0 }
  model World { Clock }
  handler Render phase Update {
    Screen.clear(Color.rgb(255, 255, 255))
    Light.time_of_day(0.5)                                 # high noon — full daylight
    Light.point(80, 60, 60, Color.rgb(255, 240, 200), 1.0)
    Screen.show()
  }
}
```
