---
id: dict-set
name: Dict.set
category: dict
kind: namespace-method
tokens: Dict.set
sig: Dict.set(d, key, value)
tip: Insert or update a key.
order: 1
ns: Dict
member: set
---

Associates <code>value</code> with <code>key</code>, inserting it or overwriting the previous value. The table grows automatically as it fills.

```ludic
program Demo {
  handler Step phase Update {
    Dict.set(bank, "gold", 100)
  }
}
```
