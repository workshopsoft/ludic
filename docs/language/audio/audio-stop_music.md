---
id: audio-stop_music
name: Audio.stop_music
category: audio
kind: namespace-method
tokens: Audio.stop_music
sig: Audio.stop_music() -> void
tip: Stop the music channel.
order: 5
ns: Audio
member: stop_music
---

Stops whatever is playing on the music channel (started by <a href="audio-play_music.html"><code>Audio.play_music</code></a>).

```ludic
program Demo {
  entry {
    Audio.stop_music()
  }
}
```
