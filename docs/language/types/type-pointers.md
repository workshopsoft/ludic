---
id: type-pointers
name: pointers
category: types
kind: type
tokens: pointers
sig: pointers
tip: A buffer of pointers — p[i] reads and writes a pointer.
order: 9
---

A <code>pointers</code> is a raw buffer whose elements are pointers: index it with <code>buffer[i]</code> to read or write a <code>pointer</code>, with no bounds checking. Allocate the storage with <code>words(n)</code> (a pointer fits in a slot) and type the binding as <code>pointers</code> so indexing uses the pointer element size. It is the low-level building block for hand-rolled data structures — a table of records made with <code>new</code>, a free list, a bucket array — for when you want manual control instead of a growable <code>[]T</code> slice.

```ludic
program Records {
  property Position { column: int = 0, row: int = 0 }

  handler Setup phase Start {
    let slots: pointers = words(2)
    slots[0] = new Position
    slots[1] = new Position
    print(2)
  }
}
```
