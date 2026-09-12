bump: patch
type: fix
**ludic.render3d: lakes are ellipses** — a water body other than the reflecting one was drawn as the whole rectangle of its bounds, so the corners between that rectangle and the lake's carved ellipse showed sheets of water over dry ground. Those bodies are now clipped to the ellipse; the reflecting body (the sea) still fills its rectangle.
