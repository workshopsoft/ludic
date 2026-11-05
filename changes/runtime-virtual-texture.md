bump: minor
type: perf
**Runtime virtual texture for the ground and the roads (`ludic.render3d`, experimental, off by default).** Turn it on with `R3D_RVT=1` or `r3d_rvt_set`.

- The terrain patches and the near road chunks draw their surface layers once, top-down, into cached pages. The ground and the roads then read a page instead of running the whole layer stack on every pixel. This follows Unreal's Runtime Virtual Texturing.
- The pool holds 16×16 pages of 128+4 px in two sRGB atlases and a height atlas, evicted least-recently-used. Each of 9 levels (1 m to 256 m pages) has its own page table and falls back to its parent.
- A 1/16 feedback pass requests pages. It reads results two frames late and renders at most 8 pages a frame. Pages are invalidated when terrain streams in or on `r3d_rvt_invalidate`.
- It has not been measured yet. On the PC the surface material is about 60 % of the terrain timer, and the expected saving is 4–5 ms at 4K.
