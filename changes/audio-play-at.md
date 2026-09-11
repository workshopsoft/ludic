bump: minor
type: feat
**`Audio.play_at(id, gain:, pitch:, pan:)`** — fire a one-shot with its own gain, pitch
and stereo position, leaving the master settings alone.

`Audio.volume` and `Audio.pitch` are global: they are there so a player can turn the game
down, and a game that used them to place a sound in the world would be fighting its own
options screen. This is the per-voice version, and it is what distance attenuation is made
of — a 3D game works out how far away a sound is and which side it is on, and says so.
`gain` rides on top of the master volume, so the options screen still wins; `pan` runs
-1 (hard left) to 1 (hard right).

A loaded sound is still one player, so firing the same handle again restarts it rather
than layering a second copy. Load a handle per variant when several need to overlap.
