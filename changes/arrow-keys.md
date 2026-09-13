bump: patch
type: fix
**Held arrow keys register** — `Key.Up`, `Key.Down`, `Key.Left` and `Key.Right` are 128-131.

They folded to the codes of w, s, a and d, which is what the single per-frame key
(`Input.key`) reports for an arrow. The held-key set has always stored an arrow under
128-131, so `Input.key_down(Key.Up)` tested the W bit and `Input.move_i`'s arrow half never
moved anything. `Input.key` keeps its WASD alias: a game comparing it with `'w'` still
takes the arrows.
