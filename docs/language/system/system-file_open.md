---
id: system-file_open
name: System.file_open
category: system
kind: namespace-method
tokens: System.file_open
sig: System.file_open(path, mode) -> ptr
tip: Open a file.
order: 6
ns: System
member: file_open
---

Opens <code>path</code> with the given <code>mode</code> (as C <code>fopen</code>) and returns a file handle, or null on failure.
