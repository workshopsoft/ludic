bump: minor
type: feat
Anti-aliasing that exists, and a lens for the viewfinder.

THE SHIPPING DEFAULT HAD NO ANTI-ALIASING AT ALL. The temporal resolve was removed (for
good reasons - it reprojected water through the surface plane and dragged the mirror image
behind the camera), the setting's first option went on saying "Temporal", and MSAA defaults
to one sample. Every machine without DLSS - which is every Mac - drew a frame full of grass
blades and needle cards with nothing smoothing a single edge.

FXAA now, in the sharpen pass, because that pass already reads this pixel's neighbourhood
and runs last on the LDR image. It has no history, so it cannot drag or smear a reflection.
Measured on edge pixels: 25.5% less single-pixel staircase.

One trap worth recording. The unsharp mask's delta is computed from the RAW image and only
then applied to the anti-aliased colour. Taking the centre from the FXAA result and the
neighbours from the raw texture measures a difference that is half smoothing and half
signal, so the mask sharpens exactly the edges FXAA just softened - measured, that first
version was 29% WORSE than no anti-aliasing at all.

And depth of field, for the photo mode: a disc of taps whose radius is the pixel's circle
of confusion, signed so the two sides of the focal plane differ and normalised by the focus
distance, because a lens focused at two metres throws a background out far harder than one
focused at two hundred. A tap only counts if it is at least as out of focus as the pixel
it is blurring into, which is what keeps a sharp foreground from haloing into a blurred
background. It runs between the scene and the bloom so a blurred highlight still blooms,
and the whole pass is skipped when the aperture is shut - in ordinary play there is no lens
and this never draws.
