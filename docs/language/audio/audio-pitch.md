---
id: audio-pitch
name: Audio.pitch
category: audio
kind: namespace-method
tokens: Audio.pitch
sig: Audio.pitch(v) -> void
tip: Set the playback rate / pitch.
order: 8
ns: Audio
member: pitch
---

Sets the playback rate / pitch (<code>1.0</code> normal, <code>0.5</code> an octave down, <code>2.0</code> up), applied to every loaded sound.

```ludic
program Demo {
  entry {
    Audio.pitch(1.5)
  }
}
```
