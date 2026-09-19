bump: patch
type: fix
The ground keeps more of its own colour, and the rock keeps all of it.

55% of every ground pixel was the orthophotograph, at every distance and on every
material. A survey image is a good record of WHERE the forest and the scree are and a
poor record of what a steep rock face is coloured: it is shot through kilometres of air
at an angle no player stands at, and it comes back pale. So the photograph keeps the
meadow and the forest, where it carries real variation nothing else knows, and gives the
rock back to the rock - by material and by elevation, never by distance, because a
distance fade used to live here and was removed for a good reason (the photograph has
the day's own shadows baked in, so grass grew dark patches as you backed away and they
slid as you walked). Material and height do not move when the camera does.

The far tier's rock fallback is the maroon mean rather than a neutral grey. TFAST_3 skips
the rock sample and leaves that constant standing in for it, and the file's own rule says
the cheap tier must keep the near tier's mean colour or the boundary shows as a ring.

Ortho-classified snow now needs altitude. Bright and unsaturated is what snow looks like
from a satellite and also what a sunlit rock face looks like, so faces were being painted
90% white wherever the photograph was pale. Gully snow is gated on the snow line too,
rather than on two absolute heights five hundred metres below where snow can lie.

And the distance desaturation from `light-air-and-the-hour` is eased from 1.9 to 1.15.
It was tuned on a valley whose rock was grey anyway; Maroon's air is thin and dry and the
peaks are two kilometres from the lake.
