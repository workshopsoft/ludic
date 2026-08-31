---
id: regex-group
name: Regex.group
category: regex
kind: namespace-method
tokens: Regex.group
sig: Regex.group(match, n) -> string
tip: The text of capture group n (group 0 is the whole match); empty if unset.
order: 9
ns: Regex
member: group
---

Returns the substring captured by group <code>n</code> of <code>match</code> — group <code>0</code> is the whole match, <code>1</code> the first parenthesized group, and so on. Returns an empty string if the group did not participate in the match.

Parameters:
- `match` — a `Match` from `Regex.find` / `Regex.exec` / `Regex.next`
- `n` — the group number (0 = whole match)

```ludic
program Demo {
  entry {
    let m = Regex.find("key=value", "(\\w+)=(\\w+)")
    print(Regex.group(m, 2))
  }
}
```
