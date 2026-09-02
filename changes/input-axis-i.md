bump: minor
type: feat
Directional int input (#79) — `Input.axis_i(neg, pos) -> int` returns a -1/0/1 movement intent (`+1` positive key held, `-1` negative, `0` neither or both) read from the multi-key device set, so turning WASD into movement no longer needs the `ki(key_down('d')) - ki(key_down('a'))` bool-to-int glue and feeds an int mover directly: `dx = Input.axis_i('a', 'd')`, `dy = Input.axis_i('w', 's')`. Complements `Input.axis` (fixed) / `Input.vector` (normalized). Example: `examples/library/input_movement.ludic`.
