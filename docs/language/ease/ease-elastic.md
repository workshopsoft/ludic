---
id: ease-elastic
name: Ease.elastic
category: ease
kind: namespace-method
tokens: Ease.elastic
sig: Ease.elastic(t) -> fixed
tip: Ease out with a springy wobble.
order: 5
ns: Ease
member: elastic
---

Returns an ease-out that shoots past <code>1.0</code> and wobbles around it a few times with shrinking amplitude before settling — a spring released under tension. The overshoot comes from a decaying <code>2<sup>-10t</sup></code> envelope on a sine, all in Q16.16, so it is deterministic and bit-identical on every platform. Great for UI that snaps in with personality: a panel that springs open, a picked-up item that jiggles, a selection that bounces to place.

```ludic
program Demo {
  handler Step phase Update {
    let scale = Math.lerp(0.0, 1.0, Ease.elastic(progress))
  }
}
```
