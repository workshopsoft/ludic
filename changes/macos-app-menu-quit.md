bump: patch
type: fix
**macOS: a game has a menu bar and quits when asked** — a windowed program gets the standard
application menu (Hide, Hide Others, Show All, Quit *Name* ⌘Q) and a Window menu (Minimize ⌘M),
named from the bundle's `CFBundleName` or the process name. Cmd-Q, the Dock's Quit, logout and
the `quit` Apple event (`osascript -e 'tell application id "…" to quit'`, which failed with -1708)
now end the run the way the window's close button does, so the game's own shutdown runs. Hiding
the app (⌘H) or minimising the window does not end the run.
