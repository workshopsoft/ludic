---
id: random-int
name: Random.int
category: random
kind: namespace-method
tokens: Random.int
sig: Random.int(max) -> int
tip: A random integer in [0, max).
order: 4
ns: Random
member: int
---

Returns a deterministic integer from <code>0</code> up to but not including <code>max</code>. Use it to pick a random index into a list of length <code>max</code>. Returns 0 when <code>max</code> is not positive.

```ludic
program Demo {
  handler Seed phase Start { Random.seed(value: 7) }
  handler Step phase Update {
    let idx = Random.int(list_count)
  }
}
}
}
```
