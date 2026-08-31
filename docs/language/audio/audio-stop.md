---
id: audio-stop
name: Audio.stop
category: audio
kind: namespace-method
tokens: Audio.stop
sig: Audio.stop(id) -> void
tip: Stop one sound.
order: 4
ns: Audio
member: stop
---

Stops the sound <code>id</code> and rewinds it to the start. If it was the current music, the music channel is cleared.

```ludic
program Demo {
  entry {
    let sfx = Audio.load("blip.wav")
    Audio.play(sfx)
    Audio.stop(sfx)
  }
}
```
