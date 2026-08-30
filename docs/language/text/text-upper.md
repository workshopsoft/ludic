---
id: text-upper
name: Text.upper
category: text
kind: namespace-method
tokens: Text.upper
sig: Text.upper(s) -> string
tip: An uppercased copy of a string.
order: 11
ns: Text
member: upper
---

Returns a fresh string with every ASCII letter <code>a</code>-<code>z</code> turned to uppercase; other bytes pass through unchanged. The input is left untouched. Use it to normalize input before comparing, or to shout a label. This is ASCII-only — accented and non-Latin letters are left as-is; for full Unicode case mapping use <code>Unicode.upper</code>.

```ludic
program Demo {
  handler Step phase Update {
    let shout = Text.upper("ready")   # "READY"
  }
}
```
