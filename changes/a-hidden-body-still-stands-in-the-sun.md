bump: patch
type: fix
`Actor.cast_hidden` separates being DRAWN from CASTING. `ac_visible` rejected any hidden
actor from the shadow pass as well as the scene pass, so a game that hides the player's
own body - first person, or a viewfinder held to the eye - lost that player's shadow
entirely. An actor hidden because the camera is inside its head is still standing in the
sun; set this on it and it keeps its shadow. Everything else still stops casting when it
is hidden.
