bump: patch
type: fix
**A rim from `outline_model` no longer stays on after the caller stops asking** — the queue
was only emptied by the next `outline_model` call, so a game that highlights what the
crosshair is on left the last highlighted tree outlined for good once the player looked
away. `r3d_frame` now drops a batch nobody reopened this frame (`outline_frame`).
