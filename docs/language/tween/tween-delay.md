---
id: tween-delay
name: Tween.delay
category: tween
kind: namespace-method
tokens: Tween.delay
sig: Tween.delay(handle, ticks) -> handle
tip: Append a pause to a tween handle's sequence.
order: 32
ns: Tween
member: delay
---

Appends a <strong>pause</strong> of <code>ticks</code> ticks to a <a href="tween-to"><code>handle</code></a>'s sequence: the value holds where the previous segment left it, then the next <a href="tween-chain"><code>chained</code></a> segment begins. Returns the handle for fluent chaining. Use it to stagger a multi-step motion — rise, hold, fall — or to offset one handle from another running in parallel.

Parameters:
- `handle` — the tween handle to extend
- `ticks` — how many engine ticks to hold

```ludic
program Demo {
  property Marker { n: int = 0 }
  model M { Marker }
  entry {
    var h = Tween.to(0, 50, 15, 0)      # move
    h = Tween.delay(h, 10)              # wait
    h = Tween.chain(h, 100, 15, 0)      # move again
    quit()
  }
}
```
