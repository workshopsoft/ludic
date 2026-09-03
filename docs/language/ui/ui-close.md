---
id: ui-close
name: Ui.close
category: ui
kind: namespace-method
tokens: Ui.close
sig: Ui.close()
tip: Deactivate the menu: no menu is open.
order: 3
ns: Ui
member: close
---

Closes whatever menu is active, so nothing is drawn by <code>Ui.render</code> and no click can fire. A play scene opens with it so a menu left over from the title never lingers.

```ludic
# doc-check: skip — illustrative
scene Play {
  on enter { Ui.close() }
}
```
