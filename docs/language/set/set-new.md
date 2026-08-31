---
id: set-new
name: Set.new
category: set
kind: namespace-method
tokens: Set.new
sig: Set.new() -> Set
tip: Create an empty string set.
order: 0
ns: Set
member: new
---

Creates an empty <code>Set</code> of string members. Add to it with <code>Set.add</code> and test membership with <code>Set.has</code>.

```ludic
program Demo {
  handler Step phase Update {
    let tags = Set.new()
  }
}
```
