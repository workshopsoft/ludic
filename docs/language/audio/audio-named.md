---
id: audio-named
name: Audio.named
category: audio
kind: namespace-method
tokens: Audio.named
sig: Audio.named(name: s) -> int
tip: The handle registered under a name, or 0.
order: 21
ns: Audio
member: named
---

Looks a sound up in the bank by the name <code>Audio.define</code> (or <code>Assets.enqueue</code>) gave it.

```ludic
# doc-check: skip — illustrative
let hit = Audio.named(name: "hit")
```
