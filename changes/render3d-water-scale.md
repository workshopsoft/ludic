bump: patch
type: fix
**`ludic.render3d`: water read the window's size, not the frame it drew into.** The
water shader's `u_screen` and the reflection target were sized from the drawable, but
`gl_FragCoord` there runs over the scene target. They match only at a render scale of 1;
below that the refraction and depth reads landed in the wrong corner of the frame and the
lake showed a squashed copy of it instead of its own bed.
