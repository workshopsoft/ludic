---
id: os-arg
name: Os.arg
category: os
kind: namespace-method
tokens: Os.arg
sig: Os.arg(i) -> string
tip: The i-th command-line argument.
order: 3
ns: Os
member: arg
---

The argument at index <code>i</code>. Index <code>0</code> is the program path; <code>1</code> onward are the launch arguments. Reading past <a href="os-arg_count"><code>arg_count()</code></a> is out of bounds.

Parameters:
- `i` — the argument index (0 = the program path)

```ludic
program Arg {
  entry {
    let prog = Os.arg(0)   # the program path
    print(len(prog))
  }
}
```
