---
id: dict-keys
name: Dict.keys
category: dict
kind: namespace-method
tokens: Dict.keys
sig: Dict.keys(d) -> []pointer
tip: Every key, as a slice of strings.
order: 8
ns: Dict
member: keys
---

Returns every live key as a slice of strings, in unspecified order — iterate it with <code>len</code> and indexing to walk the whole map.

```ludic
program Demo {
  handler Step phase Update {
    let names = Dict.keys(bank)
  }
}
```
