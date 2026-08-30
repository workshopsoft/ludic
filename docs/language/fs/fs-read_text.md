---
id: fs-read_text
name: Fs.read_text
category: fs
kind: namespace-method
tokens: Fs.read_text
sig: Fs.read_text(p) -> string
tip: Read a whole file as a string.
order: 3
ns: Fs
member: read_text
---

Reads an entire file into a string (UTF-8 text), or returns <code>null</code> when it cannot be opened — check for <code>null</code> rather than assuming success. For a missing or unreadable save, fall back to a fresh default.

Parameters:
- `p` — the path to read

```ludic
program ReadText {
  entry {
    if Fs.exists("saves/slot1.json") {
      let text = Fs.read_text("saves/slot1.json")
      print(len(text))
    }
  }
}
```
