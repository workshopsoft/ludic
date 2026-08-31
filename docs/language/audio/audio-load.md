---
id: audio-load
name: Audio.load
category: audio
kind: namespace-method
tokens: Audio.load
sig: Audio.load(path) -> int
tip: Load a sound file into a handle.
order: 0
ns: Audio
member: load
---

Loads a sound file and returns a handle (>= 1), or <code>0</code> on failure or in a headless build. Load each sound once (e.g. during the <code>Start</code> phase) and reuse the handle.

```ludic
program Demo {
  entry {
    let sfx = Audio.load("blip.wav")
    print(sfx)
  }
}
```
