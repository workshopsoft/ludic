bump: patch
type: fix
A windowed game opens under its package's `app name`. `ludic build`, `ludic run` and
`ludic bundle` pass it to the compiler (`ludicc --title <name>`), so `game_title()` - the
window's first title - is the name the player knows rather than the `program` name, which
showed for up to two seconds before the renderer retitled the window. Without an `app name`
it is the `program` name, as before.
