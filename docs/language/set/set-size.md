---
id: set-size
name: Set.size
category: set
kind: namespace-method
tokens: Set.size
sig: Set.size(s) -> int
tip: How many members.
order: 4
ns: Set
member: size
---

Returns the number of members in the set.

```ludic
program Demo {
  handler Step phase Update {
    let n = Set.size(tags)
  }
}
```
