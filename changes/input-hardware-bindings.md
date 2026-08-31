bump: minor
type: feat
**Native input hardware bindings (#51).** The #50 device layer's platform side
is now wired on macOS, feeding the same state buffers the read APIs already use —
no API changes. cocoa.ll reads the live cursor position (`mouseLocationOutsideOfEventStream`,
converted to framebuffer pixels and y-flipped) so windowed games get
`Input.mouse_x/y` without injection; polls GameController.framework each frame
(`GCController.controllers` → extended-gamepad buttons/sticks) into
`Input.pad_button` / `pad_axis` / `pad_connected`, mapping to SDL_GameControllerButton
order; and routes the view's NSTouch phase handlers into `Input.touch_count` /
`touch_x/y`. A windowed build now loads GameController (via `-needed_framework`,
since its classes are reached by name); the whole binding is DCE'd out of a
headless build. `Input.set_pad` / `set_touch` injection still works on every
target, so replays, AI, and network-fed input are unchanged.
