---
id: audio-is_playing
name: Audio.is_playing
category: audio
kind: namespace-method
tokens: Audio.is_playing
sig: Audio.is_playing(id) -> bool
tip: Is this sound playing?
order: 9
ns: Audio
member: is_playing
---

Returns whether the sound <code>id</code> is currently playing. Always <code>false</code> in a headless build.

```ludic
program Demo {
  entry {
    let sfx = Audio.load("blip.wav")
    if Audio.is_playing(sfx) { print(1) }
  }
}
```
