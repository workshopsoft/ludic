---
id: type-slices
name: []T (slices)
category: types
kind: type
sig: []T
tip: A growable slice of T — new []T makes one, push appends, len counts, s[i] indexes.
order: 8
---

`[]T` is a growable slice of `T` — a pointer to a header that holds the data, its length, and its capacity. Create one with `new []T`, append with `push(slice, value)` (the storage doubles when it is full), count elements with `len(slice)`, and read or write an element with `slice[index]`. Because the header never moves, an append is visible to everything holding that slice, giving it <b>reference semantics</b>. Slices are the everyday dynamic collection for records and other values outside the ECS.

```ludic
let route: []Waypoint = new []Waypoint
push(route, new Waypoint)
for step in 0 .. len(route) { Screen.put_pixel(x: route[step].column, y: route[step].row, color: Color.Gold) }
```
