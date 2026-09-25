---
id: text-to_int
name: Text.to_int
category: text
kind: namespace-method
tokens: Text.to_int
sig: Text.to_int(s) -> int
tip: Parse a leading integer from a string.
order: 9
ns: Text
member: to_int
---

Reads an optional sign and the leading decimal digits of <code>s</code> and returns them as an <code>int</code>, stopping at the first non-digit — so <code>Text.to_int("42abc")</code> is <code>42</code>. A string with no leading number yields <code>0</code>. Use it to turn typed input, a config value, or a parsed field into a number. It is the inverse of <code>Text.from_int</code>.

Parameters:
- `s` — the string to parse

```ludic
program ParseAmount {
  let typed: string = "250"

  handler Apply phase Update {
    let gold = Text.to_int(typed)   # 250
  }
}
```
