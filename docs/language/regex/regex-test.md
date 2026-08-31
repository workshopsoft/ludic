---
id: regex-test
name: Regex.test
category: regex
kind: namespace-method
tokens: Regex.test
sig: Regex.test(text, re) -> bool
tip: Like matches, but reuses an already-compiled Regex.
order: 4
ns: Regex
member: test
---

The compiled-pattern form of <a href="regex-matches"><code>Regex.matches</code></a>: returns whether the pre-compiled <code>re</code> matches anywhere in <code>text</code>. No per-call parsing, so this is the one to call every frame.

Parameters:
- `text` — the string to search
- `re` — a compiled `Regex` from `Regex.compile`

```ludic
program Demo {
  entry {
    let re = Regex.compile("[a-z]+")
    if Regex.test("hello", re) { print(1) }
  }
}
```
