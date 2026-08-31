---
id: set-has
name: Set.has
category: set
kind: namespace-method
tokens: Set.has
sig: Set.has(s, key) -> bool
tip: Is a member present?
order: 2
ns: Set
member: has
---

Returns true when <code>key</code> is a member of the set.

```ludic
program Demo {
  handler Step phase Update {
    if Set.has(tags, "poison") { tick() }
  }
}
```
