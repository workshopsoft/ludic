---
id: assets-enqueue
name: Assets.enqueue
category: assets
kind: namespace-method
tokens: Assets.enqueue
sig: Assets.enqueue(name, path)
tip: Queue a named image file to preload later.
order: 4
ns: Assets
member: enqueue
---

Adds a named image file to the preload queue without loading it now. Load the queue incrementally with <a href="assets-pump"><code>Assets.pump</code></a> from a loading scene, then reach each asset by name with <a href="assets-get"><code>Assets.get</code></a> once <a href="assets-ready"><code>Assets.ready</code></a>. Enqueueing is deterministic — the same order loads the same assets in the same order every run.
