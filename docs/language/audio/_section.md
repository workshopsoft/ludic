---
id: audio
title: Audio
order: 7
---

Sound effects and music. A sound is loaded once with <a href="audio-load.html"><code>Audio.load</code></a> into a handle; <a href="audio-play.html"><code>Audio.play</code></a> fires it one-shot and <a href="audio-play_music.html"><code>Audio.play_music</code></a> loops it on a single music channel. Playback is <strong>out-of-band</strong> — the audio device is real-time, not part of the deterministic simulation — but every trigger here is an ordinary frame-driven call, so a recorded run replays the same sounds at the same frames. Headless builds carry the whole API as no-ops (no audio device needed), so the same game code runs under the test harness.
