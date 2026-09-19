bump: minor
type: feat
Light you can see: sun shafts, and mist that lies in the valley.

Everything before this made the air a COLOUR APPLIED TO A SURFACE. Nothing put light in
the space between surfaces, so a basin at dawn had no shafts, no pooled mist and no rays
off a ridge at any hour, however the fog was tuned.

A half-resolution march from the camera to the depth buffer, asking the SAME shadow the
rest of the frame asks - the cascades, the baked height-field shadow and the cloud mask -
so a shaft is cast by the actual trees and the actual ridge, and a passing cloud dims its
own rays. Henyey-Greenstein scattering, because real air throws light forward, which is
why a low sun fills a valley when you look into it and does almost nothing when you look
away. Density and a separate ground-hugging MIST layer ride the sun's elevation from
daylight.ludic, so the mist forms in the cold at either end of the day and burns off by
mid-morning.

It composites into the HDR scene with the bloom pyramid's own tent upsample under ONE/ONE
blending - which is exactly what was wanted and already existed - and before bloom, so a
shaft blooms like the bright thing in the air it is. Into post_hdr and not post_scene:
post_scene is the copy the water refracts, and shafts added there would sit under the lake.

The tuning that mattered was the SKY term. It is added at every step, so at 0.06 it
accumulated into a flat grey wash that lifted lit and shadowed air by the same amount -
which is the contrast a shaft is made of. The valley came out as one pale sheet with no
rays in it. At 0.012 the sun's term dominates and there is light to see rather than fog.

R3D_NOVOL=1 switches it off for an A/B. Off in Settings skips the pass whole rather than
marching once, because a feature is off when it costs nothing.

Measured, 400 frames at 07:00: OpenGL 7.1 -> 7.3 s, Vulkan 7.2 -> 7.4 s. Backends agree
to 0.08/255.
