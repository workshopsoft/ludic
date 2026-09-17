bump: patch
type: fix
A game's window takes the title it asks for. The runtime opens a game's window before `main`,
titled with the `program` name, and `Gl.open` / render3d's `gl_open` and `gvk_open` attached
to it without passing their title on, so a `program Valley` that opened "Maroon Lake" showed
"Valley". `win_set_title` (cocoa.ll `setTitle:`, win32.ll `SetWindowTextW`, UTF-8 to UTF-16)
now retitles it, and a second `win_open` on macOS retitles the open window instead of making
another, as it already did on Windows.
