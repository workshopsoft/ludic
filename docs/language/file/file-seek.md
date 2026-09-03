---
id: file-seek
name: File.seek
category: file
kind: namespace-method
tokens: File.seek
sig: File.seek(file: f, offset: o, whence: w)
tip: Move the file cursor (0 start, 1 current, 2 end).
order: 4
ns: File
member: seek
---

Positions the cursor at <code>offset</code> bytes from <code>whence</code>: 0 the start, 1 the current position, 2 the end. Seeking to the end and reading <code>File.tell</code> measures a file.

```ludic
# doc-check: skip — illustrative
File.seek(file: f, offset: 0, whence: 2)
let size = File.tell(file: f)
File.seek(file: f, offset: 0, whence: 0)
```
