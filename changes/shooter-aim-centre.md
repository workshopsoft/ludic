bump: patch
type: fix
the shooter aims / homes / fires from a body's **centre** (Position + Collider offset + half-size) instead of the Position anchor, so auto-aim and homing target what is drawn, not a corner.
