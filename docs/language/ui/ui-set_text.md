---
id: ui-set_text
name: Ui.set_text
category: ui
kind: namespace-method
tokens: Ui.set_text
sig: Ui.set_text(id: UI_Name, text: s)
tip: Replace a label's or button's text.
order: 6
ns: Ui
member: set_text
---

Sets the text of the label or button with that id; the menu re-lays itself out on its next tick. Interpolated strings make run stats one line.

```ludic
# doc-check: skip — illustrative
Ui.set_text(id: UI_Stats, text: `floor {run.floor}  kills {run.kills}`)
```
