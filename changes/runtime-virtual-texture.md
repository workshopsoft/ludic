# Runtime virtual texture for the ground and the roads (planned, on hold)

Status: implemented 2026-10-29 behind `R3D_RVT=1` / `r3d_rvt_set` (OccuTown: `OCCUTOWN_RVT=1`), off by default until shot and profiled
(packages/ludic.render3d/rvt.ludic, shaders/rvt_feedback.comp, model.frag RVT_WRITE / rvtFetch). Not yet run: steps 6 (verify) open.

## Why

On the RTX 3070 Ti at 4K (DLSS Performance, 1920x1080 inside), downtown in third person, the ground and the roads cost
`scene: terrain` 4.9 ms + `scene: static chunks` 5.6 ms of a 27.9 ms GPU frame. A switch-by-switch run from a fixed street view
showed the surface material is most of it: `OCCUTOWN_SURFACES=0` took the terrain timer from 4.55 to 1.81 ms (about 60 %).
Per pixel the ground and the roads run the whole layer stack: up to two scanned surfaces (asphalt and its worn alternative, paint
over asphalt), each with anti-tiling double reads, relief (BumpOffset), the kerb's detail and macro variation. Lights (0.25 ms),
clouds (0.1 ms) and the static depth prepass (no gain) are not where the time goes.

## What Unreal does

Runtime Virtual Texturing (UE 5.8: `Engine/Source/Runtime/Renderer/Private/VT/`, `RuntimeVirtualTextureRender.cpp`,
`URuntimeVirtualTextureComponent`, `ARuntimeVirtualTextureVolume`, landscape material output `Runtime Virtual Texture Output`,
roads with "Draw in Virtual Textures"). The landscape and the road meshes render their material layers once into virtual texture
pages (base colour, normal, roughness/specular) around the camera; the ground's pixel then reads the page (a few taps) instead of
evaluating the layer stack. Pages are requested by a feedback pass (`r.VT.*`, `FVirtualTextureFeedback`), rendered on demand
within a budget (`r.VT.MaxUploadsPerFrame`, RVT's `r.VT.RVT.TileCountBias`), cached in a physical pool and only re-rendered when
invalidated (an edit, a road change).

## Plan

1. Physical page pool: a few atlas textures (base colour sRGB, normal BC5-like RG, roughness/AO), fixed tile size (e.g. 128+4 px
   borders), a page table texture per mip, LRU eviction. Allocated once (alloc fence).
2. Page requests: a low-resolution feedback pass (ground and road pixels write the page/mip they want; UE's feedback buffer),
   read back a frame late, deduplicated; fallback to the nearest resident coarser mip.
3. Page render: draw the terrain patch and the road chunks that cover a page with the existing surface code into the page's
   rect (orthographic top-down), a capped number of pages a frame (UE's upload budget); stamp markings and kerbs the same way.
4. Ground and road shaders: with `R3D_RVT=1`, sample the page (page table lookup + one or two atlas taps per layer) and light it;
   keep the current path when off. Height relief: keep BumpOffset from a height channel in the page, or drop it beyond a distance.
5. Invalidation: on road edits (studio) and terrain conform; never per frame.
6. Verify: close and far shots against the current path (pixel diff, no swimming at page edges), then the PC tour profile.

Expected gain: about 4-5 ms on the PC (terrain + roads from ~10.5 to ~5.5-6.5 ms), a little over a page budget of 0.3-0.5 ms.
Effort: large (a new renderer feature).

Quicker partial alternative (not Unreal's mechanism): beyond ~40 m one surface only, no anti-tiling, a cheaper kerb: about 2-3 ms.
