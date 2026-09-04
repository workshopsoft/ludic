---
id: random-value
name: Random.value
category: random
kind: namespace-method
tokens: Random.value
sig: Random.value() -> fixed
tip: A random fixed value in [0, 1).
order: 3
ns: Random
member: value
---

Returns a deterministic fixed-point value in <code>0.0</code>..<code>1.0</code> (exclusive of 1). Multiply it into a range, or compare it against a probability. The sequence is fixed for a given <code>Random.seed</code>.

```ludic
program Demo {
  handler Seed phase Start { Random.seed(value: 7) }
  handler Step phase Update {
    let t = Random.value()
  }
}
}
}
```
