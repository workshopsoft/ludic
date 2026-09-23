---
id: assets-ready
name: Assets.ready
category: assets
kind: namespace-method
tokens: Assets.ready
sig: Assets.ready() -> bool
tip: true once every enqueued asset has loaded.
order: 8
ns: Assets
member: ready
---

Returns <code>1</code> once every enqueued asset has been loaded (the queue is drained), else <code>0</code>. A loading scene pumps until this is true, then enters play (e.g. <code>become</code> the game scene).
