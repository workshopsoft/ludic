---
id: fn-arg
name: arg_count / arg
category: builtins
kind: builtin
tokens: arg_count arg
sig: arg_count() -> int   arg(i) -> str
tip: The command line; argv[0] is included.
order: 20
---

Read the process command line: <code>arg_count()</code> is the number of arguments (including the program name at index 0) and <code>arg(i)</code> returns the <code>i</code>th as a string.
