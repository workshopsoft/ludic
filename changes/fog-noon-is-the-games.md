bump: patch
type: fix
The fog's noon density is the game's, not overwritten at start-up.

The renderer's last load step set `r3d_fog_density = 0.00024` unconditionally, after the game had set the map's
own noon density (Maroon's `fog_noon`, set before `r3d_init`), so a booted map never got its own air: the figure
only took effect after a world switch. It now sets its default only where the density is still 0.
