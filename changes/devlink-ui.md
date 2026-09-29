bump: minor
type: feature
**`ludic.devlink`: the interface's verbs.** A `DevlinkUi` port, every member defaulting to "not offered":
`ui_screen` (the screen's root class and its components), `ui_model "<Class>" "<out>"` and `ui_tree "<out>"`
(the game writes a component's model or the whole tree to a file, no `..`, and the answer names it, so a
datagram stays small) and `ui_override "<path>" "<file>"` (a template or stylesheet read from another file
and reloaded keeping state; `""` clears one, `"" ""` all). Answered at once; nothing made per frame.
