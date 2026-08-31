---
id: audio-play_music
name: Audio.play_music
category: audio
kind: namespace-method
tokens: Audio.play_music
sig: Audio.play_music(id) -> void
tip: Loop a sound as background music.
order: 3
ns: Audio
member: play_music
---

Plays the sound <code>id</code> as looping background music on the single music channel; any music already playing is stopped first.

```ludic
program Demo {
  entry {
    let theme = Audio.load("theme.ogg")
    Audio.play_music(theme)
  }
}
```
