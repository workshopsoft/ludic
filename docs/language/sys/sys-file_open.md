---
id: sys-file_open
name: Sys.file_open
category: sys
kind: namespace-method
tokens: Sys.file_open
sig: Sys.file_open(path, mode) -> ptr
tip: Open a file.
order: 6
ns: Sys
member: file_open
---

Opens <code>path</code> with the given <code>mode</code> (as C <code>fopen</code>) and returns a file handle, or null on failure.
