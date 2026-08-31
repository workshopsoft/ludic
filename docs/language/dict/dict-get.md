---
id: dict-get
name: Dict.get
category: dict
kind: namespace-method
tokens: Dict.get
sig: Dict.get(d, key) -> int
tip: Look up a key (0 if absent).
order: 2
ns: Dict
member: get
---

Returns the value stored for <code>key</code>, or <code>0</code> when the key is absent. Use <code>Dict.get_or</code> when <code>0</code> is a meaningful stored value.

```ludic
program Demo {
  handler Step phase Update {
    let gold = Dict.get(bank, "gold")
  }
}
```
