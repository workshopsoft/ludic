---
id: assets-pump
name: Assets.pump
category: assets
kind: namespace-method
tokens: Assets.pump
sig: Assets.pump(max) -> int
tip: Load up to max queued assets this frame; returns how many it loaded.
order: 5
ns: Assets
member: pump
---

Loads up to <code>max</code> queued assets this frame, registering each under its name, and returns how many it loaded. Call it each frame in a loading scene with a small <code>max</code> so the frame stays short and the loading screen animates; <a href="assets-ready"><code>Assets.ready</code></a> flips true when the queue is drained. This is the deterministic, no-threads form of async preloading — the work is spread across frames instead of stalling one.
