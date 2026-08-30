---
id: text-lower
name: Text.lower
category: text
kind: namespace-method
tokens: Text.lower
sig: Text.lower(s) -> string
tip: A lowercased copy of a string.
order: 12
ns: Text
member: lower
---

Returns a fresh string with every ASCII letter <code>A</code>-<code>Z</code> turned to lowercase; other bytes pass through unchanged. Pair it with <code>Text.equals</code> for case-insensitive matching by lowercasing both sides. This is ASCII-only — accented and non-Latin letters are left as-is; for full Unicode case mapping use <code>Unicode.lower</code>.

```ludic
program Demo {
  handler Step phase Update {
    if Text.equals(Text.lower(cmd), "quit") { stop() }
  }
}
```
