---
id: dict-size
name: Dict.size
category: dict
kind: namespace-method
tokens: Dict.size
sig: Dict.size(d) -> int
tip: How many keys are stored.
order: 6
ns: Dict
member: size
---

Returns the number of keys currently in the map.

```ludic
program Demo {
  handler Step phase Update {
    let kinds = Dict.size(bank)
  }
}
```
