---
id: regex-end
name: Regex.end
category: regex
kind: namespace-method
tokens: Regex.end
sig: Regex.end(match, n) -> int
tip: The end byte offset of group n, or -1 if it did not participate.
order: 12
ns: Regex
member: end
---

Returns the byte offset just past the end of group <code>n</code> of <code>match</code>, or <code>-1</code> if the group did not participate. Feed <code>Regex.end(m, 0)</code> back into <a href="regex-next"><code>Regex.next</code></a> to walk every match.

Parameters:
- `match` — a `Match` value
- `n` — the group number

```ludic
program Demo {
  entry {
    let m = Regex.find("hi there", "hi")
    print(Regex.end(m, 0))
  }
}
```
