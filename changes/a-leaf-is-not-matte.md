bump: patch
type: fix
A leaf is not matte.

Foliage roughness was pinned to 1.0 and grazing Fresnel switched off, so nothing green in
the game had a highlight anywhere: the glint off waxy leaves and wet needles, which is
most of what makes a real stand look alive rather than painted, was simply absent.

The reason it was switched off is real. A crown is card quads, and at a grazing angle the
card's normal is a lie, so a plain specular lobe frosted whole crowns white against the
sky. So the sheen comes back as its own term gated on exactly that: it fades out as the
card turns edge-on, which is where its normal stops meaning anything. A tight lobe for the
glint, a weak wide one for the waxy rim, and nothing at all at the angles that frosted.

Thin-leaf translucency reaches further with it - a backlit stand glows for as far as you
can see it, not 140 m - and a dense crown passes 0.45 of it rather than 0.3. The distance
cap that stops a two-pixel clump card becoming a lime disc stays.
