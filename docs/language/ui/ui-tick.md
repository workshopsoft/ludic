---
id: ui-tick
name: Ui.tick
category: ui
kind: namespace-method
tokens: Ui.tick
sig: Ui.tick(key: k)
tip: Advance navigation by one key (the frame loop does this for you).
order: 4
ns: Ui
member: tick
---

Moves focus and activates controls from one key code. The frame loop calls it every frame with the frame key, so a game normally never calls it; it remains for programs that drive their own loop from <code>entry</code>.

```ludic
# doc-check: skip — illustrative
entry {
  Ui.tick(key: Input.key())
}
```
