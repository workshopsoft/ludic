---
id: kw-new
name: new
category: structure
kind: keyword
tokens: new
sig: new Record { … }   new []T
tip: Allocate a property record or an empty slice on the heap.
order: 12
---

<code>new</code> constructs a heap value and returns a reference to it. <code>new Record { field: value, … }</code> allocates a property (or struct) record, filling any omitted fields with their declared defaults; <code>new []T</code> allocates an empty growable slice of element type <code>T</code>, ready for <code>List.push</code>. Because both are references, passing one around shares the same underlying object. Use <code>new</code> for standalone data your code holds directly — as opposed to <code>spawn</code>, which creates a full ECS entity the world tracks and queries.

```ludic
program Build {
  property Point { x: int = 0, y: int = 0 }

  entry {
    let origin = new Point { x: 3 }   # y defaults to 0
    let items = new []int             # empty, then grow it
    List.push(items, origin.x)
  }
}
```
