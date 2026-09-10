bump: patch
type: perf
**The ground costs half what it did.** Measured in the Maroon Lake game, the terrain was 10.3 ms of
a 22.2 ms frame; it is now 5.4 ms of 16.4 ms — 45 fps to 61 fps at 1080p, with the
frame otherwise unchanged (every viewpoint tested stays above 54 dB PSNR against the
old renderer, with no channel differing by more than 7/255).

**Measure by frame time, not by the pass timers.** `R3D_PROF`'s per-pass
`GL_TIME_ELAPSED` queries cannot be trusted on this driver: with the ground's shading
work removed the terrain query fell from 10.5 ms to 1.3 ms while the frame time did
not move at all. Every number above and below is a median real frame time, taken by
switching one thing off (`prof_ft_report`); the pass timers are still printed, and are
still useful for spotting a pass that appears out of nowhere, but they cannot size one.
`R3D_NOTERRAIN` skips the ground, `R3D_TNEARONLY` / `R3D_TFARONLY` draw every patch
with one tier's program, and `R3D_RES=<w>x<h>` renders at another size — the three
switches that say whether a cost is the ground, which tier it is in, and whether it is
pixels at all.

**Each detail tier is its own program.** `terrain.frag` holds a detailed near tier and
a cheap far one and chose between them per pixel, so every pixel of the valley walls
was compiled — and scheduled — for a near path it never ran. CDLOD selection now knows
which tiers a patch can contain: one that never comes within the split draws with
`FAR_ONLY`, one wholly inside it with `NEAR_ONLY`, and only the ring of patches that
straddle the band needs the program that holds both and cross-fades. Pixel-identical,
and it makes the tiers separately measurable: the near tier costs 7.5 ms over a whole
frame, the far tier 2.3 ms.

**The sun visibility is its own pass** (`tersun.frag`). The same CDLOD patches are
rasterised once into a screen-sized R8 buffer that holds nothing but each ground
pixel's sun visibility, and `terrain.frag` fetches it by fragment coordinate. The pass
costs 0.27 ms, shares the frame's depth buffer so it doubles as a depth prepass, and
takes the cascade read out of the shader that covers the screen. It picks its tier —
filtered PCF near, a single tap far — over the same cross-faded band the ground uses,
so the boundary is not a contour you can find on the hillside.

**Nothing is sampled for a weight of zero.** The ground sampled all four of its
materials for every pixel and then blended three of them at zero: a meadow pixel took
nine taps of triplanar rock, a cliff pixel nine taps of stochastic grass, and every
pixel in the valley took the snow tile and the four noise fields behind the lake's
shore wash — a wash that is a hairline along one shore within 120 m of the camera. The
survey photograph's classification now runs first, because it is what decides which
materials are present; each material block sits behind its own weight; the ridge field
that ragged the snow line is skipped 160 m below it, where it cannot change anything;
and inside the stochastic blend a cell's rotation, offset and rotated gradients are
computed inside its own test, so a cell whose sharpened weight rounds away costs
nothing. All of it exact where the weight is zero, and it is most of the win.

Material sampling is what remains (2.8 ms of the 5.4): scanned 2K tiles taken at 16x
anisotropy on ground seen at a grazing angle. `R3D_ANISO=<n>` sets the filter (the
default is unchanged at 16; 4 is worth 1.0 ms and 1 is worth 1.7 ms).

The shadow pass is 1.2 ms of the frame and has nothing to give: re-using the far
cascades between frames — their windows are snapped to a 14 m and a 64 m grid — is
worth 0.15 ms standing still and nothing while walking, so it is not in the tree.
