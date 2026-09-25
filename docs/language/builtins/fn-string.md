---
id: fn-string
name: string
category: builtins
kind: builtin
tokens: string
sig: string(x) -> string
tip: Convert an int, bool, or fixed value to text; a string passes through unchanged.
order: 1
---

Converts a value to its textual form: an <code>int</code>, <code>bool</code>, or <code>fixed</code> becomes a string, and a value that is already a string is returned unchanged. This is what backtick <code>`{…}`</code> interpolation calls under the hood, so most of the time you can interpolate directly instead of calling <code>string</code> yourself. Reach for the explicit form when you need to store or pass around the text, or build a string in pieces. The result can be printed, drawn with <code>Screen.draw_text</code>, or concatenated.

Parameters:
- `x` — the value to convert to text

```ludic
program LabelValue {
  let score: int = 250

  handler ReportScore phase Start {
    let label = string(score)
    print(label)
  }
}
```
