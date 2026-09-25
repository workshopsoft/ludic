---
id: text-to_float
name: Text.to_float
category: text
kind: namespace-method
tokens: Text.to_float
sig: Text.to_float(s) -> float
tip: Parse a leading decimal number from a string.
order: 11
ns: Text
member: to_float
---

Reads an optional sign, the leading digits, a decimal point and an exponent from <code>s</code> and returns them as a <code>float</code>, stopping at the first character that cannot continue a number - so <code>Text.to_float("0.25 m")</code> is <code>0.25</code>. A string with no leading number yields <code>0.0</code>. It is the float twin of <code>Text.to_int</code>, for reading a data file or a typed value.

Parameters:
- `s` — the string to parse

```ludic
program ParseSpeed {
  let typed: string = "3.2"

  handler Apply phase Update {
    let speed = Text.to_float(typed)   # 3.2
  }
}
```
