---
id: screen-bar
name: Screen.bar
category: screen
kind: namespace-method
tokens: Screen.bar
sig: Screen.bar(x:, y:, width:, height:, value:, max:, color:, back:)
tip: A filled meter: value of max over a track.
order: 40
ns: Screen
member: bar
---

Draws a <code>back</code>-coloured track and fills <code>value / max</code> of its width in <code>color</code>. Health bars, cooldowns, loading progress.

```ludic
# doc-check: skip — illustrative
Screen.bar(x: 80, y: 228, width: 160, height: 6, value: hp, max: max_hp, color: Color.Crimson, back: Color.RaisinBlack)
```
