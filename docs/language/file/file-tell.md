---
id: file-tell
name: File.tell
category: file
kind: namespace-method
tokens: File.tell
sig: File.tell(file: f) -> int
tip: The cursor position in bytes.
order: 5
ns: File
member: tell
---

Returns the current cursor position in bytes from the start of the file.

```ludic
# doc-check: skip — illustrative
let size = File.tell(file: f)
```
