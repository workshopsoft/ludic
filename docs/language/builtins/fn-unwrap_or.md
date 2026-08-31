---
id: fn-unwrap_or
name: unwrap_or
category: builtins
kind: builtin
tokens: unwrap_or
sig: unwrap_or(o: option, fallback) -> int
tip: The option value, or a fallback if empty.
order: 20
---

Reads an <code>option</code>: returns its value when it is <a href="fn-some"><code>some</code></a>, or <code>fallback</code> when it is <a href="fn-none"><code>none</code></a>. The safe, one-line way to get a usable value out of an option without a separate branch.

Parameters:
- `o` — the option to read
- `fallback` — the value to use when the option is empty

```ludic
program Config {
  handler Step phase Update {
    let volume = unwrap_or(none(), 100)     # default to 100
  }
}
```
