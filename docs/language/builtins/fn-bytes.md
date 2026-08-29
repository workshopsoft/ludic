---
id: fn-bytes
name: bytes
category: builtins
kind: builtin
tokens: bytes
sig: bytes(n) -> ptr
tip: Allocate a raw buffer of n bytes and return a pointer to it.
order: 50
---

Allocates a raw, byte-addressable buffer of <code>n</code> bytes and returns a pointer to its start. It is a low-level primitive used for I/O and networking scratch space — for example a buffer to serialize the world into, or to receive bytes from a socket. Size it to what you need; a common pattern is <code>bytes(world_size())</code> so the buffer is exactly large enough for a full world snapshot. For a buffer of 32-bit words rather than individual bytes, use <code>words</code> instead.

Parameters:
- `n` — the number of bytes to allocate

```ludic
program SnapshotBuffer {
  property Position { column: int = 0, row: int = 0 }
  model Player { Position }

  handler Snapshot phase Start {
    spawn Player { Position { column: 3, row: 4 } }
    let buffer = bytes(world_size())
    let written = world_save(buffer)
    print(written)
  }
}
```
