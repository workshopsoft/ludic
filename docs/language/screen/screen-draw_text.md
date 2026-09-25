---
id: screen-draw_text
name: Screen.draw_text
category: screen
kind: namespace-method
tokens: Screen.draw_text
sig: Screen.draw_text(x, y, text, color, scale)
tip: Draw a string with the built-in font at an integer scale.
order: 4
ns: Screen
member: draw_text
---

Draws a string using Ludic's built-in bitmap font, starting at the top-left pixel <code>(x, y)</code>. The <code>scale</code> is an integer multiplier: <code>1</code> is the native font size, <code>2</code> is double-height and double-width, and so on — there are no fractional sizes. Use it for labels, menus, and messages such as titles or "GAME OVER"; for numbers that change every frame prefer <code>Screen.draw_number</code>, which needs no string conversion. The text is drawn in the given color over whatever is already on screen.

Parameters:
- `x` — the left edge of the first character, in pixels
- `y` — the top edge of the text, in pixels
- `text` — the string to draw
- `color` — the text color, e.g. a `Color.*` name or a `0xRRGGBB` literal
- `scale` — integer size multiplier (`1` = native size)

```ludic
program TitleScreen {
  state TitleScreenState {
    elapsed_frames: int = 0
  }

  handler CountFrames(title_screen_st: mut TitleScreenState) phase Update {
    title_screen_st.elapsed_frames = title_screen_st.elapsed_frames + 1
  }

  handler DrawWorld phase Render {
    Screen.clear(Color.MidnightBlue)
    Screen.draw_text(x: 40, y: 60, text: "CHRONORIFT", color: Color.Gold, scale: 3)
    Screen.draw_text(x: 64, y: 120, text: "PRESS ANY KEY", color: Color.White, scale: 1)
    Screen.show()
  }
}
```
