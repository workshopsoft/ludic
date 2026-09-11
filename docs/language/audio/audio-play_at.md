---
id: audio-play_at
name: Audio.play_at
category: audio
kind: namespace-method
tokens: Audio.play_at
sig: Audio.play_at(id, gain, pitch, pan) -> void
tip: Fire a one-shot with its own gain, pitch and stereo position.
order: 2
ns: Audio
member: play_at
---

Plays the sound <code>id</code> from the start as a one-shot, with its **own** gain, pitch
and stereo position, leaving the master settings alone.

<code>Audio.volume</code> and <code>Audio.pitch</code> are global: they exist so a player
can turn the game down, and a game that used them to place a sound in the world would be
fighting its own options screen. This is the per-voice version, and it is what distance
attenuation is made of — work out how far away a sound is and which side it is on, and say
so here.

- <code>gain</code> — 0.0 to 1.0, multiplied by the master volume, so the options screen
  still wins.
- <code>pitch</code> — 1.0 is as recorded; 0.5 an octave down, 2.0 an octave up. Clamped
  to the backend's 0.25 .. 4.0.
- <code>pan</code> — -1.0 hard left, 0.0 centred, 1.0 hard right.

```ludic
program Demo {
  entry {
    let call = Audio.load("elk.wav")
    # an elk eighty metres off, over your left shoulder
    Audio.play_at(id: call, gain: 0.3, pitch: 0.96, pan: -0.55)
  }
}
```

One honest limitation, and it is the backend's: a loaded sound is one player, so firing
the same handle again restarts it rather than layering a second copy over the first. Load
a handle per variant when several need to overlap — which is what a game does anyway, to
stop a repeated sound machine-gunning.
