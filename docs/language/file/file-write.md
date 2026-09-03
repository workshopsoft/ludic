---
id: file-write
name: File.write
category: file
kind: namespace-method
tokens: File.write
sig: File.write(file: f, buffer: b, count: n) -> int
tip: Write n bytes from a buffer; returns the bytes written.
order: 3
ns: File
member: write
---

Writes <code>count</code> bytes of <code>buffer</code> (a string or a <code>bytes</code> allocation) to the handle and returns how many were written.

```ludic
# doc-check: skip — illustrative
let line = "best_floor=3\n"
File.write(file: f, buffer: line, count: len(line))
```
