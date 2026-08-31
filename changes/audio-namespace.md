bump: minor
type: feat
**Audio standard library (#22).** `Audio.*` — sound effects and music over a new
platform audio backend (`runtime/native/audio.ll`, AVAudioPlayer on macOS, spliced
and linked with AVFoundation only when a windowed build uses it). `Audio.load`
loads a sound file into a handle; `Audio.play` / `play_sound` fire it one-shot,
`play_music` loops it on a single music channel; `Audio.stop` / `stop_music` /
`stop_all` stop them; `Audio.volume` sets the master volume and `Audio.pitch` the
playback rate, both across every loaded sound; `Audio.is_playing` reports state.
Playback is out-of-band — the audio device is real-time, explicitly not part of
the deterministic simulation — but every trigger is an ordinary frame-driven
call, so a recorded/replayed run fires the same sounds at the same frames.
Headless builds carry the whole API as no-ops (the native `snd_*` calls are
`is_windowed()`-guarded and dead-stripped), so the same game code runs under the
test harness with no audio device.
