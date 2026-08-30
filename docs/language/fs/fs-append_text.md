---
id: fs-append_text
name: Fs.append_text
category: fs
kind: namespace-method
tokens: Fs.append_text
sig: Fs.append_text(p, s) -> bool
tip: Append a string to a file.
order: 5
ns: Fs
member: append_text
---

Appends a string to the end of a file, creating it if necessary. Returns <code>true</code> on success. Handy for logs and event journals.

Parameters:
- `p` — the path
- `s` — the string to append

```ludic
program AppendText {
  entry {
    if Fs.append_text("run.log", "started\n") { print(1) }
  }
}
```
