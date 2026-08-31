---
id: tween-parallel
name: Tween.parallel
category: tween
kind: namespace-method
tokens: Tween.parallel
sig: Tween.parallel(a, b) -> bool
tip: Are two tween handles both finished? — a parallel completion query.
order: 35
ns: Tween
member: parallel
---

Returns whether two <a href="tween-to"><code>handles</code></a> are <em>both</em> finished. Independent handles are advanced together every frame, so running several at once already runs them in parallel; this is the "wait for all" query over a pair — start a fade and a slide together, then act when both complete. For longer sequences on a single value, chain segments with <a href="tween-chain"><code>Tween.chain</code></a> instead.

Parameters:
- `a`, `b` — the two tween handles to test

```ludic
program Demo {
  property Marker { n: int = 0 }
  model M { Marker }
  entry {
    let fade  = Tween.to(255, 0, 20, 0)
    let slide = Tween.to(0, 80, 30, 2)
    if Tween.parallel(fade, slide) { print(1) }   # both done?
    quit()
  }
}
```
