---
id: fn-file_stdout
name: file_stdout
category: builtins
kind: builtin
tokens: file_stdout
sig: file_stdout() -> ptr
tip: The standard-output stream handle for use with file_write.
order: 50
---

Returns the handle for the standard-output stream, which you pass to <code>file_write</code> to emit raw bytes. Unlike <code>print</code>, which always appends a newline and handles conversion, writing through this handle gives you exact control over what bytes go out and when — useful for tooling and code generators that must emit precise text. It takes no arguments and always refers to the process's standard output. Pair it with <code>file_stderr</code> when you want to separate normal output from diagnostics.

```ludic
program WriteLine {
  handler Emit phase Start {
    let out = file_stdout()
    let message = "built\n"
    file_write(out, message, len(message))
  }
}
```
