---
id: fs-read_bytes
name: Fs.read_bytes
category: fs
kind: namespace-method
tokens: Fs.read_bytes
sig: Fs.read_bytes(path) -> []byte
tip: A whole file as bytes, or null.
order: 11
ns: Fs
member: read_bytes
---

Reads a whole file into a `[]byte` - bounds-checked, so no raw memory - or returns <code>null</code> when it cannot be read. It reads through the asset pack like every other load, so it finds a shipped game's files. Pair it with <code>text_of(b, n)</code> for text.

Parameters:
- `path` — the file to read

```ludic
program Header {
  entry {
    let b = Fs.read_bytes("sound.wav")
    if b != null { print(b[24]) }
  }
}
```
