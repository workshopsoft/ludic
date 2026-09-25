---
id: text-ends_with
name: Text.ends_with
category: text
kind: namespace-method
tokens: Text.ends_with
sig: Text.ends_with(s, suffix) -> bool
tip: Whether a string ends with a given suffix.
order: 4
ns: Text
member: ends_with
---

Returns <code>true</code> when <code>s</code> ends with <code>suffix</code>, comparing the tail of the string over the suffix's length. If the suffix is longer than the string it simply returns <code>false</code>. Use it to detect file types by extension, recognize a trailing marker, or validate that input closes as expected.

Parameters:
- `s` — the string to test
- `suffix` — the trailing substring to look for

```ludic
program IsImage {
  let filename: string = "hero.png"

  handler Classify phase Update {
    let png = Text.ends_with(filename, ".png")   # true
  }
}
```
