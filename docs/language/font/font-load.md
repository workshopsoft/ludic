---
id: font-load
name: Font.load
category: font
kind: namespace-method
tokens: Font.load
sig: Font.load(path: p) -> int
tip: Load a TrueType font; returns a font handle.
order: 1
ns: Font
member: load
---

Loads a TrueType font file and returns its handle. Load it before <code>Ui.build</code> so the menus can measure their text; the handle is what a <code>ui</code> block's <code>font:</code> reads.

```ludic
# doc-check: skip — illustrative
state Menu { font: int = 0 }
handler Boot(menu: mut Menu) phase Start {
  menu.font = Font.load(path: "assets/fonts/PixelOperator.ttf")
  Ui.build()
}
```
