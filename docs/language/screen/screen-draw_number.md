---
id: screen-draw_number
name: Screen.draw_number
category: screen
kind: namespace-method
tokens: Screen.draw_number
sig: Screen.draw_number(x, y, value, color, scale)
tip: Draw an integer directly, with no string allocation or conversion.
order: 5
ns: Screen
member: draw_number
---

Draws an integer as digits using the built-in font, without first turning it into a string — so it never allocates and is safe to call every frame for constantly-changing values. Use it for scores, timers, frame counts, health totals, and any HUD number, while reserving <code>Screen.draw_text</code> for fixed labels. It takes the same top-left position, color, and integer <code>scale</code> as <code>draw_text</code>. Negative values are drawn with a leading minus sign.

Parameters:
- `x` — the left edge of the first digit, in pixels
- `y` — the top edge of the number, in pixels
- `value` — the integer to draw
- `color` — the digit color, e.g. a `Color.*` name or a `0xRRGGBB` literal
- `scale` — integer size multiplier (`1` = native size)

```ludic
program ScoreHud {
  var score: int = 0

  handler EarnPoints phase Update {
    score = score + 1
  }

  handler DrawWorld phase Render {
    Screen.clear(Color.MidnightBlue)
    Screen.draw_text(x: 6, y: 4, text: "SCORE", color: Color.White, scale: 1)
    Screen.draw_number(x: 52, y: 4, value: score, color: Color.Gold, scale: 1)
    Screen.show()
  }
}
```
