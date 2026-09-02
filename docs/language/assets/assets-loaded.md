---
id: assets-loaded
name: Assets.loaded
category: assets
kind: namespace-method
tokens: Assets.loaded
sig: Assets.loaded() -> int
tip: How many enqueued assets have loaded so far.
order: 7
ns: Assets
member: loaded
---

Returns how many of the enqueued assets have loaded so far (advanced by <a href="assets-pump"><code>Assets.pump</code></a>) — the numerator for a progress bar.
