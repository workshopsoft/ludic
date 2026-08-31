bump: minor
type: feat
**Input device layer (#50).** Beyond one key per frame, gameplay can now read
multiple simultaneous held keys (`Input.key_down` / `key_pressed` /
`key_released`), analog `Input.axis` and a normalized `Input.vector`, the mouse
(`Input.mouse_x/y`, `mouse_dx/dy`, `mouse_down`, `wheel`), gamepads
(`Input.pad_button` / `pad_axis` / `pad_connected`) and touch
(`Input.touch_count` / `touch_x/y`). The held set is fed by the window when
windowed — cocoa.ll now tracks keyDown/keyUp into a held-key bitset and the mouse
buttons/wheel — and by the `Input.press` / `Input.set_mouse` / `Input.set_pad` /
`Input.set_touch` injection on every target (Godot-style action injection, for
replays, AI, and network-fed input). All integer and deterministic, and
`Input.record` / `replay` snapshot the full per-frame device state, extending
#7's single-key tape.
