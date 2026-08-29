---
id: type-ptr
name: ptr
category: types
kind: type
tokens: ptr
sig: ptr
tip: A raw address into memory — a byte buffer from bytes(n), or an FFI handle.
order: 5
---

`ptr` is a raw address into memory — the low-level type for runtime and foreign-function work, not something an everyday game reaches for. Allocate a raw byte buffer with `bytes(count)`, which returns a `ptr` you index as `buffer[index]` to read or write one byte; retype the binding as `words` / `fixeds` / `ptrs` to index in larger element sizes. A `ptr` is also how an `extern fn` passes an opaque C handle across the ABI. Test one for emptiness against the `null` literal.

```ludic
let scratch: ptr = bytes(256)
scratch[0] = 65
if scratch != null { scratch[1] = 66 }
```
