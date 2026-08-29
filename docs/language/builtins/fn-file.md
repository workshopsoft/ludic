---
id: fn-file
name: file_write / file_stdout / file_stderr
category: builtins
kind: builtin
tokens: file_write file_stdout file_stderr
sig: file_stdout() -> ptr   file_stderr() -> ptr   file_write(handle, buf, len)
tip: Low-level output handles and raw writing.
order: 25
---

<code>file_stdout()</code> and <code>file_stderr()</code> return the standard stream handles; <code>file_write(handle, buf, len)</code> writes <code>len</code> raw bytes to one. Most code uses <code>print</code> instead — these are the primitive underneath.
