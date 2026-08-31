---
id: set-remove
name: Set.remove
category: set
kind: namespace-method
tokens: Set.remove
sig: Set.remove(s, key)
tip: Remove a member.
order: 3
ns: Set
member: remove
---

Removes <code>key</code> from the set (a no-op if it is not a member).

```ludic
program Demo {
  handler Step phase Update {
    Set.remove(tags, "fire")
  }
}
```
