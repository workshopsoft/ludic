bump: minor
type: feat
**`countdown` fields.** A component field declared `frames_left: countdown = 0` is an `int` the engine steps toward 0 once per Update for every live entity carrying the component (never below 0). Roll timers, invulnerability frames, hit flashes and cooldowns need no hand-written "decrement each frame" handler: set the field, test it.
