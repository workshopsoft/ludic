---
id: audio-stop_all
name: Audio.stop_all
category: audio
kind: namespace-method
tokens: Audio.stop_all
sig: Audio.stop_all() -> void
tip: Stop every sound.
order: 6
ns: Audio
member: stop_all
---

Stops every loaded sound, including the music channel.

```ludic
program Demo {
  entry {
    Audio.stop_all()
  }
}
```
