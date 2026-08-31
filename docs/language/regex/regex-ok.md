---
id: regex-ok
name: Regex.ok
category: regex
kind: namespace-method
tokens: Regex.ok
sig: Regex.ok(match) -> bool
tip: True if the match succeeded (the Match is non-null).
order: 13
ns: Regex
member: ok
---

Returns whether <code>match</code> is a real match rather than <code>null</code> — the readable way to test the result of <a href="regex-find"><code>Regex.find</code></a> / <a href="regex-exec"><code>Regex.exec</code></a> / <a href="regex-next"><code>Regex.next</code></a>, and the loop condition for a find-all.

Parameters:
- `match` — a `Match` value (possibly null)

```ludic
program Demo {
  entry {
    if not Regex.ok(Regex.find("abc", "\\d")) { print(1) }
  }
}
```
