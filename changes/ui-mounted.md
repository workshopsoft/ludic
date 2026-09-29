bump: minor
type: feature
**`ui_mounted` and `ui_model_of`: an editor's questions of a running interface.** `ui_mounted(out)` fills the
caller's list with the classes of the components the last frame showed, in tree order and each once;
`ui_model_of(cls)` is the first mounted instance's model, read in place (the next frame fills it again), or
null. For devlink's ui_screen and ui_model; asked on request, never a frame.
