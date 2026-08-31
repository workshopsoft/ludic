---
id: audio-play
name: Audio.play
category: audio
kind: namespace-method
tokens: Audio.play
sig: Audio.play(id) -> void
tip: Fire a one-shot sound.
order: 1
ns: Audio
member: play
---

Plays the sound <code>id</code> from the start as a one-shot effect, at the current master volume and pitch.

```ludic
program Demo {
  entry {
    let sfx = Audio.load("blip.wav")
    Audio.play(sfx)
  }
}
```
