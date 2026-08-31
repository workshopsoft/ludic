---
id: ivec2-manhattan
name: IVec2.manhattan
category: ivec2
kind: namespace-method
tokens: IVec2.manhattan
sig: IVec2.manhattan(a, b) -> int
tip: Grid distance |dx| + |dy|.
order: 9
ns: IVec2
member: manhattan
---

Returns the Manhattan (taxicab) distance <code>|dx| + |dy|</code> between two cells — the number of orthogonal steps between them, the natural distance metric on a 4-connected grid.

```ludic
program Demo {
  handler Step phase Update {
    let steps = IVec2.manhattan(pos, goal)
  }
}
```
