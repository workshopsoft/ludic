---
id: ui-build
name: Ui.build
category: ui
kind: namespace-method
tokens: Ui.build
sig: Ui.build()
tip: Construct every declared ui block (loads skins, measures fonts).
order: 1
ns: Ui
member: build
---

Builds the widget trees of every <code>ui</code> block. Call it once, after the fonts and images the blocks reference are loaded — a loading scene's last step is the usual place.

```ludic
# doc-check: skip — illustrative
handler Boot phase Start {
  Ui.build()
}
```
