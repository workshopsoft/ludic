---
id: fn-arg
name: arg
category: builtins
kind: builtin
tokens: arg
sig: arg(i) -> string
tip: The i-th command-line argument as a string.
order: 50
---

Returns the command-line argument at index <code>i</code> as a string. Index <code>0</code> is conventionally the program's own name or path, so the first user-supplied argument is at index <code>1</code>. Use it together with <code>arg_count</code> to write configurable command-line tools in Ludic — reading an input filename, a mode flag, or a numeric option. Guard the index against <code>arg_count()</code> before reading so you never ask for an argument that was not passed.

Parameters:
- `i` — the argument index (`0` is the program name)

```ludic
program EchoFirstArg {
  handler ShowArg phase Start {
    if arg_count() > 1 {
      print(arg(1))
    } else {
      print("no argument")
    }
  }
}
```
