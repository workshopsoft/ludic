---
id: sprite-draw_meter
name: Sprite.draw_meter
category: sprite
kind: namespace-method
tokens: Sprite.draw_meter
sig: Sprite.draw_meter(x:, y:, value:, max:, per_icon:, spacing:, full:, half:, empty:)
tip: A value as a row of full / half / empty icons.
order: 10
ns: Sprite
member: draw_meter
---

Draws <code>max / per_icon</code> icons, each full, half or empty according to <code>value</code> — hearts, stars, ammo pips.

```ludic
# doc-check: skip — illustrative
Sprite.draw_meter(x: 8, y: 8, value: hp, max: max_hp, per_icon: 20, spacing: 15, full: heart, half: half_heart, empty: empty_heart)
```
