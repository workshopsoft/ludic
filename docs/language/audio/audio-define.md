---
id: audio-define
name: Audio.define
category: audio
kind: namespace-method
tokens: Audio.define
sig: Audio.define(name: s, path: p) -> int
tip: Load a sound into the bank under a name.
order: 20
ns: Audio
member: define
---

Loads a sound file and registers it under <code>name</code>, so <code>Audio.play(name: …)</code> and <code>Audio.play_music(name: …)</code> can fire it without a handle in the game's own state. Returns the handle (0 headless). <code>Assets.enqueue</code> does the same for a <code>.wav</code> / <code>.mp3</code> path.

```ludic
# doc-check: skip — illustrative
Audio.define(name: "hit", path: "assets/audio/hit.wav")
Audio.play(name: "hit")
```
