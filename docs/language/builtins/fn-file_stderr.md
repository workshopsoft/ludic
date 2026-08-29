---
id: fn-file_stderr
name: file_stderr
category: builtins
kind: builtin
tokens: file_stderr
sig: file_stderr() -> ptr
tip: The standard-error stream handle for use with file_write.
order: 50
---

Returns the handle for the standard-error stream, which you pass to <code>file_write</code> to emit raw bytes. Writing diagnostics and error messages here keeps them separate from normal program output on standard out, so a tool's real results are not mixed with its warnings. It takes no arguments and always refers to the process's standard error. Use it for the error side of command-line tools written in Ludic.

```ludic
program WarnToStderr {
  handler CheckArgs phase Start {
    if arg_count() < 2 {
      let err = file_stderr()
      let message = "missing argument\n"
      file_write(err, message, len(message))
      exit(1)
    }
    print("ok")
  }
}
```
