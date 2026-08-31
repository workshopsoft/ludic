---
id: dict-clear
name: Dict.clear
category: dict
kind: namespace-method
tokens: Dict.clear
sig: Dict.clear(d)
tip: Remove every key.
order: 7
ns: Dict
member: clear
---

Empties the map, removing every key while keeping its allocated capacity.

```ludic
program Demo {
  handler Step phase Update {
    Dict.clear(bank)
  }
}
```
