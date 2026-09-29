---
id: kw-alias
name: alias
category: structure
kind: keyword
tokens: alias
sig: namespace Name { alias method = function_name }
tip: A namespace method that is another function.
order: 69
---

Inside a <code>namespace</code> block, <code>alias m = f</code> makes <code>Name.m(...)</code> a call of <code>f</code>, checked against its parameters. It is how an engine namespace declared in Ludic forwards to the functions that implement it.

```ludic
# doc-check: skip — the aliased function lives elsewhere
namespace Trail {
  alias length = trail_length
}
```
