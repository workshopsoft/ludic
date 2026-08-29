---
id: type-words
name: words
category: types
kind: type
tokens: words
sig: words
tip: A raw buffer indexed as 32-bit words — each buffer[i] reads or writes an int.
order: 6
---

`words` is a raw buffer viewed as a sequence of 32-bit words: indexing `buffer[index]` reads or writes one `int`. It is the same underlying memory a `pointer` addresses, retyped so the element size is a word instead of a byte — allocate the storage with `words(count)` (count 32-bit words) and bind it as `words` to index it that way. Reach for it when you need a flat integer array outside the ECS — a lookup table, a scratch grid — and want plain integer indexing without the growable-slice header. Like all raw buffers it is unbounded and unchecked, so keep your own length.

```ludic
let height_map: words = words(64)
height_map[0] = 10
height_map[1] = height_map[0] + 5
```
