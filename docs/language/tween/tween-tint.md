---
id: tween-tint
name: Tween.tint
category: tween
kind: namespace-method
tokens: Tween.tint
sig: Tween.tint(from, to, t) -> int
tip: Per-channel blend of two colors by amount t.
order: 9
ns: Tween
member: tint
---

Blends two colors (<code>0x00RRGGBB</code> ints) channel by channel by amount <code>t</code> — the color equivalent of <a href="tween-number"><code>Tween.number</code></a>. Fade a sprite to white on hit, cross-fade a sky, or pulse a UI accent. Matches <a href="color-lerp"><code>Color.lerp</code></a>, ready for an eased <code>t</code> from <a href="tween-ease"><code>Tween.ease</code></a>.

Parameters:
- `from` — the color at `t = 0` (an `int`, `0x00RRGGBB`)
- `to` — the color at `t = 1` (an `int`, `0x00RRGGBB`)
- `t` — the blend amount (a `fixed`, usually 0..1)

```ludic
program Demo {
  handler Run phase Update {
    let t = Tween.progress(fixed(1), fixed(2))
    let c = Tween.tint(Color.rgb(0, 0, 0), Color.rgb(255, 255, 255), t)
    print(c)
  }
}
```
