---
id: tween-chain
name: Tween.chain
category: tween
kind: namespace-method
tokens: Tween.chain
sig: Tween.chain(handle, to, dur, ease) -> handle
tip: Append a tween segment that runs after the handle's current queue.
order: 31
ns: Tween
member: chain
---

Appends a tween segment to a <a href="tween-to"><code>handle</code></a> that runs <em>after</em> its current segments finish, continuing from where the previous one ended — so the game only names the new target. Returns the same handle, so calls chain fluently. A handle holds up to eight segments; combine with <a href="tween-delay"><code>Tween.delay</code></a> for pauses. The engine advances the whole sequence one segment at a time.

Parameters:
- `handle` — the tween handle to extend
- `to` — the target value for this segment
- `dur` — the segment length in engine ticks
- `ease` — 0 linear, 1 in, 2 out, 3 in-out

```ludic
program Demo {
  property Marker { n: int = 0 }
  model M { Marker }
  entry {
    var h = Tween.to(0, 100, 20, 2)     # rise
    h = Tween.chain(h, 0, 20, 1)        # then fall back
    quit()
  }
}
```
