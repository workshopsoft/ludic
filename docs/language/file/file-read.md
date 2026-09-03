---
id: file-read
name: File.read
category: file
kind: namespace-method
tokens: File.read
sig: File.read(file: f, buffer: b, count: n) -> int
tip: Read up to n bytes into a buffer; returns the bytes read.
order: 2
ns: File
member: read
---

Reads at most <code>count</code> bytes from the handle into <code>buffer</code> (a <code>bytes</code> allocation) and returns how many arrived; fewer than asked means the end of the file.

```ludic
# doc-check: skip — illustrative
let buf = bytes(size + 1)
let got = File.read(file: f, buffer: buf, count: size)
```
