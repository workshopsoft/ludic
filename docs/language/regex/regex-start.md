---
id: regex-start
name: Regex.start
category: regex
kind: namespace-method
tokens: Regex.start
sig: Regex.start(match, n) -> int
tip: The start byte offset of group n, or -1 if it did not participate.
order: 11
ns: Regex
member: start
---

Returns the byte offset where group <code>n</code> of <code>match</code> begins, or <code>-1</code> if the group did not participate. Group <code>0</code> is the whole match, so <code>Regex.start(m, 0)</code> is where the match begins.

Parameters:
- `match` — a `Match` value
- `n` — the group number

```ludic
program Demo {
  entry {
    let m = Regex.find("  hi", "hi")
    print(Regex.start(m, 0))
  }
}
```
