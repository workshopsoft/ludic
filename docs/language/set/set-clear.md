---
id: set-clear
name: Set.clear
category: set
kind: namespace-method
tokens: Set.clear
sig: Set.clear(s)
tip: Remove every member.
order: 5
ns: Set
member: clear
---

Empties the set, removing every member while keeping its allocated capacity.

```ludic
program Demo {
  handler Step phase Update {
    Set.clear(tags)
  }
}
```
