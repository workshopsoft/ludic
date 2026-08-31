---
id: audio-play_sound
name: Audio.play_sound
category: audio
kind: namespace-method
tokens: Audio.play_sound
sig: Audio.play_sound(id) -> void
tip: Fire a one-shot sound (alias of play).
order: 2
ns: Audio
member: play_sound
---

An alias of <a href="audio-play.html"><code>Audio.play</code></a> — plays the sound <code>id</code> once from the start.

```ludic
program Demo {
  entry {
    let sfx = Audio.load("blip.wav")
    Audio.play_sound(sfx)
  }
}
```
