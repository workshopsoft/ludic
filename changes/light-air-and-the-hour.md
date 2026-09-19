bump: minor
type: feat
The air and the light are the hour's, not one constant apiece.

Aerial perspective is a curve now. A low sun shines through far more air than a high
one and shines ALONG the ground rather than down onto it, so density, height falloff
and forward scatter all ride the sun's own elevation, and overcast thickens the air
while flattening the scatter. The term that was missing entirely is distance
DESATURATION: a surface is pulled toward its own luminance faster than the fog itself
arrives. Without it, blending a saturated ridge toward a saturated blue noon sky left
a saturated ridge, and a midday frame had a mountain three kilometres off reading as
vividly as a bench two metres from the camera.

The grade is the hour's too. White balance, the shadows' floor, contrast and
saturation were nine literals bound at the draw; daylight.ludic writes them now.
Noon is the case worth naming: direct sun is warm-white and the only thing filling a
midday shadow is a blue sky, so noon gets a cool balance over a blue-lifted shadow
with hard contrast between it and the lit ground, and dawn and dusk get the reverse.
Gain is deliberately left alone - the grade is `c * gain + lift * (1 - c)`, so it
warms the whole frame rather than the highlights.

The visible sky is relit. It is one HDRI turned on its axis so its sun sits where the
hour wants it, and turning a photograph does not change what colour it was taken at -
so a sunset had a mid-morning blue overhead. An analytic sky supplies the chroma while
the photograph keeps the luminance, so the cloud stays where it is and goes orange at
dusk, and the zenith goes deep blue at noon, with no second sky shipped. It fades out
under the horizon, where the night's own tint, stars and moon take over, and eases off
under heavy cloud.

And the ground bounce follows the ground: the colour a surface is filled with from
below is the map's now, crossing from meadow to rock at its treeline, instead of one
green constant everywhere including above the scree.

R3D_NOAIR=1 restores all of it to what it was, so a before-and-after comes from one
binary at one hour. Measured at 400 frames: no cost on either backend.
