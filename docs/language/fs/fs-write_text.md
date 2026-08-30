---
id: fs-write_text
name: Fs.write_text
category: fs
kind: namespace-method
tokens: Fs.write_text
sig: Fs.write_text(p, s) -> bool
tip: Write a string to a file (atomically).
order: 4
ns: Fs
member: write_text
---

Writes a string to a file, replacing any existing contents. The write is atomic — the bytes go to a temporary file that is renamed into place — so an interrupted write never corrupts the previous file. Returns <code>true</code> on success.

Parameters:
- `p` — the path to write
- `s` — the string contents

```ludic
program WriteText {
  entry {
    if Fs.write_text("settings.ini", "fullscreen=1") { print(1) }
  }
}
```
