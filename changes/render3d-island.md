bump: minor
type: feat
**`ludic.render3d`: `terrain_island(cx, cz, r, fall)`** keeps land out to `r` and then
scales the terrain down into the water over `fall` metres. Scaling rather than blending
to a fixed bed is what makes the coastline come out of the terrain already there: low
ground becomes beach and shallows, high ground becomes cliff. `r = 0` leaves the survey
untouched.
