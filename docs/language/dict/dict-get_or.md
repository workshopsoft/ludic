---
id: dict-get_or
name: Dict.get_or
category: dict
kind: namespace-method
tokens: Dict.get_or
sig: Dict.get_or(d, key, fallback) -> int
tip: Look up a key with an explicit default.
order: 3
ns: Dict
member: get_or
---

Returns the value for <code>key</code>, or <code>fallback</code> when the key is absent — the unambiguous lookup when <code>0</code> could be a real value.

```ludic
program Demo {
  handler Step phase Update {
    let n = Dict.get_or(bank, "stone", 0 - 1)
  }
}
```
