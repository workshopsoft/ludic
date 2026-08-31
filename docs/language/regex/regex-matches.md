---
id: regex-matches
name: Regex.matches
category: regex
kind: namespace-method
tokens: Regex.matches
sig: Regex.matches(text, pattern) -> bool
tip: True if the pattern matches anywhere in the text (a search).
order: 3
ns: Regex
member: matches
---

Searches <code>text</code> for <code>pattern</code> and returns whether it matches <em>anywhere</em> (like a search, not a full-string match — anchor with <code>^…$</code> for that). Compiles the pattern each call; for a pattern you use repeatedly, compile once with <a href="regex-compile"><code>Regex.compile</code></a> and use <a href="regex-test"><code>Regex.test</code></a>.

Parameters:
- `text` — the string to search
- `pattern` — the regular expression source

```ludic
program Demo {
  entry {
    if Regex.matches("/quit now", "^/(help|quit)\\b") { print(1) }
  }
}
```
