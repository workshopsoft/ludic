---
id: set-members
name: Set.members
category: set
kind: namespace-method
tokens: Set.members
sig: Set.members(s) -> []pointer
tip: Every member, as a slice of strings.
order: 6
ns: Set
member: members
---

Returns every member as a slice of strings, in unspecified order — iterate it with <code>len</code> and indexing.

```ludic
program Demo {
  handler Step phase Update {
    let all = Set.members(tags)
  }
}
```
