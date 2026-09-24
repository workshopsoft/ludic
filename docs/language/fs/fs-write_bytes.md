---
id: fs-write_bytes
name: Fs.write_bytes
category: fs
kind: namespace-method
tokens: Fs.write_bytes
sig: Fs.write_bytes(path, data, count) -> bool
tip: Writes the first count bytes of a []byte to a file.
order: 12
ns: Fs
member: write_bytes
---

Writes the first `count` bytes of `data` to `path`, replacing the file, and answers whether all of them were written. `count` is clamped to the slice's length.

Parameters:
- `path` — the file to write
- `data` — a `[]byte`, e.g. from <code>buffer(n)</code>
- `count` — how many bytes of it

```ludic
program Save {
  entry {
    let b = buffer(2)
    b[0] = 72
    b[1] = 105
    print(Fs.write_bytes("hi.bin", b, 2))
  }
}
```
