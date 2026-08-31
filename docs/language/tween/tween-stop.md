---
id: tween-stop
name: Tween.stop
category: tween
kind: namespace-method
tokens: Tween.stop
sig: Tween.stop(handle)
tip: Stop and dispose a tween handle, freezing its value.
order: 34
ns: Tween
member: stop
---

Stops a <a href="tween-to"><code>tween handle</code></a> immediately and frees its slot back to the pool. Its <a href="tween-value"><code>value</code></a> is frozen where it was, and <a href="tween-done"><code>Tween.done</code></a> then reports it finished. Use it to cancel a motion early — an interrupted animation, an entity that despawned mid-tween — so long-lived games recycle handles instead of exhausting the pool.

Parameters:
- `handle` — the tween handle to stop

```ludic
program Demo {
  property Marker { n: int = 0 }
  model M { Marker }
  entry {
    let h = Tween.to(0, 100, 60, 0)
    Tween.stop(h)                       # cancel it now
    quit()
  }
}
```
