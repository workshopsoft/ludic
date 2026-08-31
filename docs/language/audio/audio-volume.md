---
id: audio-volume
name: Audio.volume
category: audio
kind: namespace-method
tokens: Audio.volume
sig: Audio.volume(v) -> void
tip: Set the master volume.
order: 7
ns: Audio
member: volume
---

Sets the master volume (<code>0.0</code> .. <code>1.0</code>), applied to every loaded sound now and to every future play.

```ludic
program Demo {
  entry {
    Audio.volume(0.8)
  }
}
```
