---
id: random-sign
name: Random.sign
category: random
kind: namespace-method
tokens: Random.sign
sig: Random.sign() -> int
tip: A random +1 or -1.
order: 5
ns: Random
member: sign
---

Returns <code>1</code> or <code>-1</code> with equal probability — a deterministic coin flip for choosing a direction or jitter sign.

```ludic
program Demo {
  handler Seed phase Start { Random.seed(value: 7) }
  handler Step phase Update {
    let dir = Random.sign()
  }
}
  }
}
```
