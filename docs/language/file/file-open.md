---
id: file-open
name: File.open
category: file
kind: namespace-method
tokens: File.open
sig: File.open(path: p, mode: m) -> pointer
tip: Open a file (fopen); null when it cannot be opened.
order: 1
ns: File
member: open
---

Opens <code>path</code> with a C <code>fopen</code> mode string (<code>"rb"</code>, <code>"wb"</code>, <code>"ab"</code>). Returns the handle, or <code>null</code> when the file cannot be opened — always test for it.

```ludic
# doc-check: skip — illustrative
let f = File.open(path: "save/best.txt", mode: "rb")
if f == null { return }
```
