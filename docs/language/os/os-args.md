---
id: os-args
name: Os.args
category: os
kind: namespace-method
tokens: Os.args
sig: Os.args() -> []string
tip: Every command-line argument, as a list.
order: 1
ns: Os
member: args
---

Returns the whole argument vector as a <a href="type-slice"><code>[]string</code></a>: element <code>0</code> is the program path, and the rest are the arguments the process was launched with. The list has exactly <a href="os-arg_count"><code>arg_count()</code></a> elements, so you can iterate it directly to parse launch flags.

```ludic
program Args {
  entry {
    let all = Os.args()
    var i = 0
    while i < len(all) { print(len(all[i])); i = i + 1 }   # one length per argument
  }
}
```
