bump: patch
type: fix
A windowed build that reaches the audio runtime indirectly — through the atlas / `Assets.*` preload queue (which feeds `.wav`/`.mp3` into the sound bank) or the engine sprite-render system, without any `Audio.*` call in the game — now links the native audio backend (`audio.ll` + AVFoundation). Previously `ludicc -o` failed at link with undefined `snd_*` symbols for any windowed game declaring a `Sprite` component; the import of `runtime/native/audio.ludic` now flags the backend link itself.
