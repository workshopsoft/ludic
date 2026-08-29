---
id: ease-back
name: Ease.back
category: ease
kind: namespace-method
tokens: Ease.back
sig: Ease.back(t) -> fixed
tip: Ease in with a small backward anticipation.
order: 3
ns: Ease
member: back
---

Returns an ease-in that first dips slightly below <code>0</code> before shooting forward — the anticipation windup that gives a motion snap. Because it undershoots, the eased value can go negative near the start, so use it where a little overshoot reads as lively rather than wrong.

```ludic
program Demo {
  handler Step phase Update {
    let s = Math.lerp(rest, poke, Ease.back(progress))
  }
}
```
