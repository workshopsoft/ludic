---
id: regex-compile
name: Regex.compile
category: regex
kind: namespace-method
tokens: Regex.compile
sig: Regex.compile(pattern) -> Regex
tip: Compile a pattern once for reuse; returns an error value (null) if it is invalid.
order: 1
ns: Regex
member: compile
---

Compiles <code>pattern</code> to a reusable <code>Regex</code> and returns it, or <code>null</code> if the pattern is malformed — so a bad pattern is a value you can check, never a crash. Compiling once and reusing with <a href="regex-test"><code>Regex.test</code></a> / <a href="regex-exec"><code>Regex.exec</code></a> avoids re-parsing the pattern every call, which matters in a hot loop.

Parameters:
- `pattern` — the regular expression source

```ludic
program Demo {
  entry {
    let re = Regex.compile("^\\d{4}-\\d{2}-\\d{2}$")
    if Regex.test("2026-08-31", re) { print(1) }
  }
}
```
