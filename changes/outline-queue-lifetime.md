bump: patch
type: fix
**`outline_model`'s batch survives the whole frame.** A frame is drawn by more than one
pass — a shadow map, a water reflection, the scene — and `actor_draw` runs in each of
them. An Actor's rim survives that because it is a field on the actor; the queue did not,
because the first pass to run emptied it, so a queued outline was drawn into whichever
target happened to come first and was gone by the time the scene was drawn. Nothing
appeared, with every uniform, matrix and mesh correct.

A flush now *closes* the batch rather than clearing it, and the next `outline_model`
opens a new one: every pass in a frame sees the same requests, and a caller still needs
no frame hook.
