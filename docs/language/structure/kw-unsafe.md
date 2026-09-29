---
id: kw-unsafe
name: unsafe
category: structure
kind: keyword
tokens: unsafe
sig: unsafe function f() { }  /  unsafe { ... }
tip: Raw memory is allowed inside: bytes(), free, Memory.*, indexing a pointer, calling C.
order: 57
---

Ludic's memory is safe unless code says <code>unsafe</code>: raw allocation, freeing, pointer indexing and foreign calls are compile errors elsewhere. An <code>unsafe function</code> or an <code>unsafe { ... }</code> block allows them inside, and only packages and the runtime are trusted to write it; a program's own files need <code>--unsafe</code>.

```ludic
# doc-check: skip — needs --unsafe
unsafe function raw(n: int) -> pointer { return bytes(n) }
```
