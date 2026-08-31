---
id: regex-find
name: Regex.find
category: regex
kind: namespace-method
tokens: Regex.find
sig: Regex.find(text, pattern) -> Match
tip: The first match of the pattern in the text (a Match, or null if none).
order: 5
ns: Regex
member: find
---

Searches <code>text</code> and returns the first <code>Match</code> — carrying the overall span and every capture group — or <code>null</code> if the pattern does not match. Read groups with <a href="regex-group"><code>Regex.group</code></a> and spans with <a href="regex-start"><code>Regex.start</code></a> / <a href="regex-end"><code>Regex.end</code></a>.

Parameters:
- `text` — the string to search
- `pattern` — the regular expression source

```ludic
program Demo {
  entry {
    let m = Regex.find("name: Alice", "(\\w+): (\\w+)")
    if Regex.ok(m) { print(1) }
  }
}
```
