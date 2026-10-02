bump: minor
type: feature
**`ludic.render3d`: the tonemap keeps the scene's hue, and the day's contrast no longer darkens the shadows.**
The filmic contrast (`post_contrast`, 1.23 at noon) was a power about mid grey, so it steepened BELOW mid grey as
much as above: with ACES's toe a 6.5 : 1 sun-to-shade ratio reached the screen as 39 : 1 and a noon shadow on grass
drew at 17-22 of 255. It now steepens above mid grey only (the identity below, eased over a stop): those shadows
draw at 23-29. And ACES per channel turned a colour as one of its channels saturated - a bright red went orange,
sunlit skin yellow-white ((243, 233, 214) at 8:00), a shaded orange shirt red, a blue sky cyan-white. The colour is
now put back at the scene's own hue in Oklab (Ottosson 2020), with the lightness and the richness the per-channel
curve gives (at least the scene's own saturation until it nears white, and the saturation the full contrast curve
gave, so an opened shadow is not greyed), its chroma brought into gamut at that lightness and hue: the same skin is
(249, 225, 209), the shirt's hue holds at 15-21 degrees in sun and shade where it ran 6 to 29. A grey draws exactly
as before; the HDR10 output takes the same colour.
