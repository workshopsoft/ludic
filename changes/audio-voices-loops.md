bump: minor
type: feat
ludic.audio: sounds as banks of takes x voices (`aud_sound_load`, `aud_sound_at`, `aud_sound_flat`: a take other than the last, the voice
that rested longest, a pitch spread) and loops asked for every frame (`aud_loop`, `aud_loop_at`: started once audible, moved without a
restart, stopped when silent). The runtime gains `Audio.loop_at` / `Audio.set_at` and holds 512 voices; `Audio.volume` no longer sets
every playing voice to the bare master (each keeps its own gain). Headless, loaded voices get stand-in handles so a game's proofs count them.
