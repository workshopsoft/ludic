---
id: text-equals
name: Text.equals
category: text
kind: namespace-method
tokens: Text.equals
sig: Text.equals(a, b) -> bool
tip: Whether two strings have identical bytes.
order: 7
ns: Text
member: equals
---

Returns <code>true</code> when <code>a</code> and <code>b</code> hold the same bytes in the same order. This is a value comparison, not a pointer check, and is exactly what the <code>==</code> operator does between two strings — <code>Text.equals</code> is the named form for readability. Use it to match input against a keyword or compare a slice with an expected token.

Parameters:
- `a` — the first string
- `b` — the second string

```ludic
program Guess {
  var answer: string = "swordfish"
  var attempt: string = "swordfish"

  handler Check phase Update {
    if Text.equals(attempt, answer) {
      # correct
    }
  }
}
```
