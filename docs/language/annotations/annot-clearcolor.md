---
id: annot-clearcolor
name: "@ClearColor"
category: annotations
kind: annotation
tokens: @ClearColor
sig: "@ClearColor(0xRRGGBB) handler Draw phase Render { … }"
tip: Declare a clear colour so the Render phase auto-clears + auto-presents for you.
order: 62
---

<code>@ClearColor(N)</code> declares the framebuffer clear colour (a <code>0x00RRGGBB</code> integer) so the engine owns the per-frame clear and present: at the top of the Render phase it clears the framebuffer to <code>N</code>, and after all Render handlers run it presents the frame — so a game's Render handler carries no <code>Screen.clear</code> / <code>Screen.show</code> boilerplate, and the colour is configured declaratively rather than written in the handler body. It is opt-in: a program with no <code>@ClearColor</code> is byte-for-byte identical (it clears and presents itself, or the light system owns the present). Place it on the program's Render handler (or any declaration — it is program-wide). The argument is any constant expression — a hex literal, a `Color.*` name, or a `const` from your palette.

```ludic
program ClearColorDemo {
  property Tag { n: int = 0 }
  model P { Tag }
  @ClearColor(0x102030)
  handler Draw phase Render {
    Screen.fill_rectangle(10, 10, 4, 4, 0xffffff)
  }
}
```
