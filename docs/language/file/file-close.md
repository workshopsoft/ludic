---
id: file-close
name: File.close
category: file
kind: namespace-method
tokens: File.close
sig: File.close(file: f)
tip: Close a handle from File.open.
order: 6
ns: File
member: close
---

Flushes and releases the handle. Every successful <code>File.open</code> pairs with one <code>File.close</code>.

```ludic
# doc-check: skip — illustrative
File.close(file: f)
```
