---
id: dict-has
name: Dict.has
category: dict
kind: namespace-method
tokens: Dict.has
sig: Dict.has(d, key) -> bool
tip: Is a key present?
order: 4
ns: Dict
member: has
---

Returns true when <code>key</code> is present in the map.

```ludic
program Demo {
  handler Step phase Update {
    if Dict.has(bank, "gold") { spend() }
  }
}
```
