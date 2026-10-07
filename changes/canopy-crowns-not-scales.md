bump: patch
type: fix
The forest past the fog wall is a stand of crowns, not a hillside of fish scales.

`canopyOver` (`terrain.frag`) drew each crown on its jittered 5 m grid as a smooth hemisphere, its
normal tilted in proportion to the distance from the centre (0.6 at the rim), every cell filled and
every radius within 0.8-1.25 of the stand's. Seen from the overlook at noon, every crown wore the same
lit crescent and the far hills read as a repeating fish-scale pattern (Maroon Lake's vqa8
`ov_nohud`). Proved by `R3D_NOCANOPY=1`, which removes the pattern and nothing else.

A crown is now a cone - one slope from the tip to the skirt (0.25), so the lit and shaded halves meet
in a line through the tip rather than in a crescent - with a ragged seven-pointed edge, radii over
0.65-1.35 of the stand's, and a thin stand leaving cells empty (the share filled follows the cover,
half to all). The stand's colour, roof and gaps are as before.

Measured on that view, two headless shots a side (each pair identical): the strongest off-centre
peak of the hill's high-passed autocorrelation (how regular its fine detail is) 0.138 -> 0.084, against
0.082 with the canopy off; 0.7% of the frame moves by more than 8, and 0.9% / 0.7% of two other noon
views.
