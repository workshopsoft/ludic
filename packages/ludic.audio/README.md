# ludic.audio

A game's sounds, and the one door to the runtime's `Audio.*`. Uses nothing.

**`aud_ui` is the interface; the world goes through `aud_emit`.** A click, a chime, a shutter
and a warning happen in the player's head and are played flat (`aud_ui`, on the interface channel). Everything that happens in
the world - a foot, an axe, a pot, a splash, a call - carries a gain, a pitch and a pan from where it
is relative to the listener, even when that is the listener's own position. A game that played half
its world flat had an axe across the camp as loud as your own and a pot at the fire as loud from the
far shore; nothing said so, because audio is a no-op headless.

```ludic
import "ludic.audio"
bind AudioListener { x: fn ear_x, z: fn ear_z, yaw: fn ear_yaw }
bind AudioFiles { cache_dir: fn audio_cache }            # a writable directory
let axe = aud_load("assets/kit/audio/chop1.wav")
aud_emit_at(axe, tree.x, tree.z, 90.0)                   # heard within 90 m, panned, a little lower far off
aud_ui(click)
```

## Channels

A volume per kind of sound, under the master: `AUD_CH_EFFECTS` (what the player does), `AUD_CH_WILDLIFE`,
`AUD_CH_AMBIENT` (its loop is the runtime's music channel, `Audio.music_volume`) and `AUD_CH_UI`
(`aud_ui` plays on it). `aud_channel_set(ch, v)` holds it to 0..1; `aud_emit_on(ch, h, ...)` is
`aud_emit` scaled by it. `aud_emit` itself stays raw, so its numbers are what a test reads.

## Ports

```ludic
port AudioListener { x: fn() -> float, z: fn() -> float, yaw: fn() -> float }  # yaw: radians, 0 down -z
port AudioFiles { cache_dir: fn() -> string }            # "" (the default): a packed clip stays silent
```

## API

| | |
| --- | --- |
| `aud_emit(h, gain, pitch, pan)` | a world sound, as given, handed to `aud_play`: the one place a float becomes the runtime's Q16.16 |
| `aud_emit_at(h, x, z, range) -> bool` | a world sound at a place, gain, pitch and pan from the listener; false when out of earshot |
| `aud_gain_at(x, z, range)`, `aud_pan_at(x, z)`, `aud_pitch_at(gain)` | a shaped roll-off (not an inverse square: that is deafening or inaudible in a valley of trees), the side from the listener's heading (ahead and behind centred), and a semitone lower at the edge of hearing |
| `aud_ui(h)` | an interface sound, flat, at the interface channel's volume |
| `aud_music(h)`, `aud_stop_music()`, `aud_master(v)` | the loop and the master volume |
| `aud_load(path) -> int`, `aud_unpack(path, name)`, `aud_tried()`, `aud_live()` | a clip, loaded past `Audio.load`'s blind spot; how many were asked for and how many loaded |
| `aud_wav_seconds(path, fallback)` | a PCM WAV's length from its header, for re-triggering a loop before it ends |
| `aud_last_gain()`, `aud_last_pitch()`, `aud_last_pan()`, `aud_emitted()` | what the last shot handed the runtime: the only thing a headless test can hear |

## The pack

`Audio.load` takes a real filesystem path - it bottoms out in AVAudioPlayer's
`initWithContentsOfURL:` - not the pack-aware `file_open` every other asset goes through. In a
project the two are the same; in a bundle every clip loads as 0, while `Fs.exists` (pack-aware) says
it is there. So `aud_load` tries the path and, on 0, lifts the bytes out of the pack into
`AudioFiles.cache_dir()` and loads that. A cached copy is trusted only when it is as long as the
packed one. Say `aud_live()` of `aud_tried()` at start-up: a silent game is otherwise
indistinguishable from a working one.

## The guard

A game keeps the rule with a grep (Maroon Lake's `tests/audio.sh`): nothing outside this package
names `Audio.*`, `Audio.play_at` appears once here (in `aud_play`, which `aud_emit` and `aud_ui` both
call) and `Audio.play` not at all, and the game calls `aud_ui` only for its interface sounds.

## Tests

```bash
ludic test packages/ludic.audio
```

A listener bound to a fake: the roll-off, the pan on each side and turning with the listener, the
pitch, emit's numbers, earshot, a WAV header, a packed file lifted once and a short copy replaced.
