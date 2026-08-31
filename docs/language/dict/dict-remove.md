---
id: dict-remove
name: Dict.remove
category: dict
kind: namespace-method
tokens: Dict.remove
sig: Dict.remove(d, key)
tip: Delete a key.
order: 5
ns: Dict
member: remove
---

Removes <code>key</code> from the map (a no-op if it is absent). Later lookups of other keys are unaffected.

```ludic
program Demo {
  handler Step phase Update {
    Dict.remove(bank, "wood")
  }
}
```
