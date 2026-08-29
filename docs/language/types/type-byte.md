---
id: type-byte
name: byte
category: types
kind: type
tokens: byte
sig: byte
tip: A raw buffer indexed one byte at a time — each buffer[i] reads or writes a byte.
order: 7
---

`byte` is a raw buffer viewed one byte at a time: indexing `buffer[index]` reads or writes a single 8-bit value. It is the byte-sized view of the memory a `ptr` addresses — allocate it with `bytes(count)` and bind it as `byte` when you want per-byte access, for example to build up text, decode a file, or pack a compact grid. Each element is an `int` in the range of a byte. Like the other raw buffers it is unchecked, so you are responsible for staying in bounds.

```ludic
let name_buffer: byte = bytes(16)
name_buffer[0] = 'A'
name_buffer[1] = 'd'
name_buffer[2] = 'a'
```
