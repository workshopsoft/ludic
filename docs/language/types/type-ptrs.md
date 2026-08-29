---
id: type-ptrs
name: ptrs
category: types
kind: type
tokens: ptrs
sig: ptrs
tip: A buffer of pointers — p[i] reads and writes a ptr.
order: 9
---

A <code>ptrs</code> is a raw buffer whose elements are pointers: index it with <code>buffer[i]</code> to read or write a <code>ptr</code>, with no bounds checking. Allocate the storage with <code>words(n)</code> (a pointer fits in a slot) and type the binding as <code>ptrs</code> so indexing uses the pointer element size. It is the low-level building block for hand-rolled data structures — a table of records made with <code>new</code>, a free list, a bucket array — for when you want manual control instead of a growable <code>[]T</code> slice.

```ludic
program Records {
  property Position { column: int = 0, row: int = 0 }

  handler Setup phase Start {
    let slots: ptrs = words(2)
    slots[0] = new Position
    slots[1] = new Position
    print(2)
  }
}
```
