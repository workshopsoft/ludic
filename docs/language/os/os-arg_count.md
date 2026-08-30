---
id: os-arg_count
name: Os.arg_count
category: os
kind: namespace-method
tokens: Os.arg_count
sig: Os.arg_count() -> int
tip: How many command-line arguments there are.
order: 2
ns: Os
member: arg_count
---

The number of command-line arguments, always at least <code>1</code> (the program path itself). Pair it with <a href="os-arg"><code>arg</code></a> for index-based access, or just use <a href="os-args"><code>args</code></a>.

```ludic
program Argc {
  entry {
    if Os.arg_count() >= 1 { print(1) }
  }
}
```
