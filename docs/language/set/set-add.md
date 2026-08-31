---
id: set-add
name: Set.add
category: set
kind: namespace-method
tokens: Set.add
sig: Set.add(s, key)
tip: Add a member (duplicates ignored).
order: 1
ns: Set
member: add
---

Adds <code>key</code> to the set. Adding a member that is already present is a harmless no-op.

```ludic
program Demo {
  handler Step phase Update {
    Set.add(tags, "poison")
  }
}
```
