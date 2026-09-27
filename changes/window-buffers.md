bump: patch
type: fix
**A windowed program's input no longer stops it on the first frame.** Since slices carry their
length, the window's built-ins (`win_held`, `win_mouse`, `win_pad`, `win_touch`, `win_text`,
`win_present`) were handed the slice's header instead of its elements, so the platform wrote the
mouse position over the length and the next read failed its bounds check. They take the elements,
as an `extern` call already did.
