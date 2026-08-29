---
id: fn-file_write
name: file_write
category: builtins
kind: builtin
tokens: file_write
sig: file_write(handle, buf, len)
tip: Write a run of raw bytes to a stream handle.
order: 50
---

Writes <code>len</code> bytes from <code>buf</code> to the given stream <code>handle</code>. Get the handle from <code>file_stdout</code> or <code>file_stderr</code>; the buffer is typically a string (whose length you pass with <code>len(buf)</code>) or a raw buffer from <code>bytes</code>. This is the precise, no-frills output primitive that underpins Ludic's own tooling and code generators, where exact bytes matter and the automatic newline of <code>print</code> would get in the way. Pass a byte count that does not exceed the buffer's size.

Parameters:
- `handle` — a stream handle from `file_stdout` or `file_stderr`
- `buf` — the bytes to write (a string or a raw buffer)
- `len` — how many bytes to write

```ludic
program WriteTwice {
  handler Emit phase Start {
    let out = file_stdout()
    let heading = "SCORE: "
    let value = "250\n"
    file_write(out, heading, len(heading))
    file_write(out, value, len(value))
  }
}
```
