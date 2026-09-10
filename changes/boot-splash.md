bump: minor
type: feat
**A boot splash**, customised by the game. `app splash` in `package.ludic` names
the artwork and `app splash_bg` the colour behind it; the runtime raises a
borderless window from a constructor that runs before `main`, reading the image
out of the asset pack, so it is on screen while the process is still starting
rather than after the slow part it exists to cover. Nothing hides it
automatically - only the game knows when its first real frame is ready, so the
game calls `App.splash_hide()`.
