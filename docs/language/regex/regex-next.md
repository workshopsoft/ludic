---
id: regex-next
name: Regex.next
category: regex
kind: namespace-method
tokens: Regex.next
sig: Regex.next(text, re, from) -> Match
tip: The next match at or after byte offset from — the basis of a find-all loop.
order: 7
ns: Regex
member: next
---

Returns the first match of <code>re</code> in <code>text</code> starting at or after byte offset <code>from</code>, or <code>null</code>. Loop it from the previous match's end (see <a href="regex-end"><code>Regex.end</code></a>) to iterate every match — the find-all idiom.

Parameters:
- `text` — the string to search
- `re` — a compiled `Regex`
- `from` — the byte offset to resume from

```ludic
program Demo {
  entry {
    let re = Regex.compile("#(\\w+)")
    var m = Regex.exec("#a #b #c", re)
    while Regex.ok(m) {
      print(Regex.group(m, 1))
      m = Regex.next("#a #b #c", re, Regex.end(m, 0))
    }
  }
}
```
