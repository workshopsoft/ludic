---
id: assets-font
name: Assets.font
category: assets
kind: namespace-method
tokens: Assets.font
sig: Assets.font(name: s) -> int
tip: A font loaded through the preload queue, by name.
order: 9
ns: Assets
member: font
---

The font handle for a <code>.ttf</code> / <code>.ttc</code> that <code>Assets.enqueue</code> loaded under <code>name</code>; 0 while it is not loaded yet. The queue sorts by extension: images become sprites (<code>Assets.get</code>), sounds go to the audio bank (<code>Audio.play(name:)</code>), fonts here.

```ludic
# doc-check: skip — illustrative
Assets.enqueue(name: "menu", path: "assets/fonts/PixelOperator.ttf")
…
menu_font = Assets.font(name: "menu")
```
