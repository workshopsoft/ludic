---
id: op-interp
name: String interpolation
category: operators
kind: operator
sig: `text {expr} more`
tip: A backtick string with {expr} holes, each stringified and concatenated.
order: 7
---

A backtick string with <code>{expr}</code> holes, each stringified and concatenated. <code>{{</code> and <code>}}</code> are literal braces.

```ludic
print(`score: {score}`)
```
