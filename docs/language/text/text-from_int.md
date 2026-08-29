---
id: text-from_int
name: Text.from_int
category: text
kind: namespace-method
tokens: Text.from_int
sig: Text.from_int(n) -> str
tip: Render an integer as a string.
order: 10
ns: Text
member: from_int
---

Returns the decimal text of the integer <code>n</code> — <code>Text.from_int(1234)</code> is <code>"1234"</code>, and negatives keep their sign. It is the same conversion as the bare <code>str(n)</code> and the inverse of <code>Text.to_int</code>. Use it when you need a number as characters — to measure its width, concatenate it, or store it — though drawing a number to the screen is better done with <code>Screen.draw_number</code>.

Parameters:
- `n` — the integer to render

```ludic
program ScoreLabel {
  var score: int = 1500

  handler Build phase Update {
    let label = Text.concat("score: ", Text.from_int(score))
  }
}
```
