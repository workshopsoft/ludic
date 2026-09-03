---
id: ui-render
name: Ui.render
category: ui
kind: namespace-method
tokens: Ui.render
sig: Ui.render()
tip: Draw the active menu.
order: 7
ns: Ui
member: render
---

Draws the active menu at its laid-out position. Call it from a handler in the <code>Overlay</code> phase so the menu is painted over the engine-drawn world; it draws nothing while no menu is open.

```ludic
# doc-check: skip — illustrative
layer Menu {
  handler Draw phase Overlay { Ui.render() }
}
```
