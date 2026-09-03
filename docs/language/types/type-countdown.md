---
id: type-countdown
name: countdown
category: types
kind: type
tokens: countdown
sig: countdown
tip: An int component field the engine steps toward 0 once per Update.
order: 9
---

`countdown` is an `int` for a component field that the engine counts down: once per Update, for every live entity carrying the component, a `countdown` field above 0 loses one (it never goes below 0). It is the timer idiom — roll frames, invulnerability frames, a hit flash, a cooldown — as a type: set the field, then test it, and no handler decrements it. Everywhere else it is an ordinary `int`.

```ludic
# doc-check: skip — illustrative
property Roll { frames_left: countdown = 0, cooldown: countdown = 0 }

Roll.of(player).cooldown = 35                 # 35 frames later it reads 0
if Roll.of(player).cooldown == 0 { start_roll() }
```
