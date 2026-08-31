---
id: regex-group_count
name: Regex.group_count
category: regex
kind: namespace-method
tokens: Regex.group_count
sig: Regex.group_count(match) -> int
tip: How many capture groups the match's pattern has.
order: 10
ns: Regex
member: group_count
---

Returns the number of capture groups in the pattern behind <code>match</code> (not counting group 0, the whole match). Valid group numbers for <a href="regex-group"><code>Regex.group</code></a> are <code>0</code>…<code>group_count</code>.

Parameters:
- `match` — a `Match` value

```ludic
program Demo {
  entry {
    let m = Regex.find("a-b", "(\\w)-(\\w)")
    print(Regex.group_count(m))
  }
}
```
