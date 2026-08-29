---
id: op-interp
name: String interpolation
category: operators
kind: operator
sig: `text {expr} more`
tip: A backtick string with {expr} holes, each stringified and concatenated.
order: 7
---

A backtick string `` `…` `` is an interpolated string: any `{expr}` hole inside it is evaluated, converted to text, and concatenated with the surrounding literal parts. Numbers, `bool`s, and `fixed` values are stringified automatically and `string` values pass through, so `` `score: {score}` `` desugars to `"score: " + string(score)`. It is the readable way to build a message from mixed pieces without hand-writing a `+` chain. Write a literal brace with `{{` or `}}`.

```ludic
let status_line: string = `score {score} — health {current_health}/{maximum_health}`
Screen.status(status_line)
print(`wave {wave_number} incoming`)
```
