---
id: ui-open
name: Ui.open
category: ui
kind: namespace-method
tokens: Ui.open
sig: Ui.open(id: UI_Name)
tip: Make one menu active and focus its first button.
order: 2
ns: Ui
member: open
---

Activates the menu whose root has that id and moves keyboard focus to its first focusable control. Only one menu is active at a time; opening another replaces it.

```ludic
# doc-check: skip — illustrative
scene Title {
  on enter { Ui.open(id: UI_TitleMenu) }
}
```
