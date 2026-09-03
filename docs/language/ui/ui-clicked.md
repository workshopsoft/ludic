---
id: ui-clicked
name: Ui.clicked
category: ui
kind: namespace-method
tokens: Ui.clicked
sig: Ui.clicked(id: UI_Name) -> bool
tip: Was this control activated this frame? (polled form of UiClicked)
order: 5
ns: Ui
member: clicked
---

True on the frame a focused control with that id was activated (Enter, Space, or pad A). The event form is <code>@On(UiClicked) handler … { if id == UI_Name { … } }</code>; either can <code>become</code> another scene.

```ludic
# doc-check: skip — illustrative
handler Menu phase Update {
  if Ui.clicked(id: UI_Play) { become Play }
}
```
