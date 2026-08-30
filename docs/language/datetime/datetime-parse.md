---
id: datetime-parse
name: DateTime.parse
category: datetime
kind: namespace-method
tokens: DateTime.parse
sig: DateTime.parse(text, pattern) -> int
tip: Parse text into an instant; -1 on failure.
order: 11
ns: DateTime
member: parse
---

Parses <code>text</code> into a <code>DateTime</code> by reading each token of <code>pattern</code> from the fixed position the pattern lays out; missing fields default to 1970-01-01 00:00:00. Returns <code>-1</code> if a digit was expected but not found (so the caller can detect malformed input). The pattern <b>must be a string literal</b> and uses the same tokens as <code>DateTime.format</code>. <code>text</code> must match the pattern's fixed-width layout.

```ludic
program Demo {
  handler Step phase Update {
    let t = DateTime.parse("2026-08-30 07:05:09", "YYYY-MM-DD HH:mm:ss")
    if t < 0 {
      # malformed input
    }
  }
}
```
