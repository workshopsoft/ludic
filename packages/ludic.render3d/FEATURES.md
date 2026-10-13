# ludic.render3d — what is implemented, where, and how it compares

Every item below names the file (and function or shader) that implements it, so
the claim can be checked in the tree. Paths are relative to `packages/ludic.render3d`
unless stated; `Vk.*` lives in `runtime/native/`.

## The Vulkan surface (`Vk.*`)

- **Vulkan only** — the renderer draws through `gpu.ludic`, the seam between it and the
  graphics API, onto Vulkan (MoltenVK on macOS). The Vulkan commands and constants are
  generated from the registry's `vk.xml` by `ludic-dev vkgen` (`tools/ludic-cli/vkgen.ludic`)
  into `runtime/native/vk_api.ludic`, with one ABI thunk each in `runtime/native/vk_thunks.ll`;
  the loader is opened at run time (`runtime/native/vk_mac.ll`, `vk_win.ll`).
- Window at Retina resolution on a `CAMetalLayer` (macOS, `runtime/native/cocoa.ll`) or a
  Win32 window (`runtime/native/win32.ll`); the window layer, IEEE-float helpers over Q16.16
  and the microsecond clock are `runtime/native/window.ludic` and `rtlib.ll`.
- Shaders are GLSL compiled ahead of time to SPIR-V (`ludic-dev shaders`, `shaders/spv/`).

## Rendering features (numbered so they can be counted)

Lighting and materials
1. Cook-Torrance GGX specular, Smith height-correlated visibility, Schlick Fresnel — `shaders/lighting.glsl` `shade()`
2. Diffuse image-based lighting from a convolved irradiance map — `sky.ludic` `sky_precompute`, `shaders/ibl_irradiance.frag`
3. GGX-prefiltered specular environment, 6 roughness levels (importance sampled, mip-filtered) — `shaders/ibl_prefilter.frag`
4. Split-sum BRDF lookup table — `shaders/ibl_brdf.frag`
5. HDRI sky with the sun extracted from the map and its irradiance integrated from the clipped texels — `texture.ludic` `hdr_decode`, `sky.ludic`
6. Sky rotation with all convolutions rebuilt (time-of-azimuth control) — `sky.ludic` `sky_set_yaw`
7. Normal mapping with derivative-reconstructed tangent frames (models) and a heightfield tangent basis (terrain) — `shaders/model.frag` `cotangentFrame`, `shaders/terrain.frag`
8. Distant-grass carpet: the clump cards baked straight down into a tiling tile (alpha = coverage) and draped on the ground beyond the blade rings with stochastic anti-tiling, so the far meadow carries the near cover's clumps and gaps — `scatter.ludic` `carpet_bake`, `shaders/terrain.frag` `sampleCarpet` (replaced the parallax pass, whose sampler slot it took)
9. Stochastic (triangle-grid) anti-tiling texture sampling with rotated taps and `textureGrad` — `shaders/terrain.frag` `sampleMat`
10. Triplanar mapping for steep rock — `shaders/terrain.frag` `sampleTri`
11. Foliage translucency and wrapped diffuse (thin-leaf subsurface approximation) — `shaders/model.frag` `FOLIAGE`
12. Two-sided lighting for thin cards — `shaders/model.frag` `CARD`
13. Ground-bounce fill light (one bounce from the sunlit meadow onto undersides) — `shaders/lighting.glsl` `bounce`
14. Screen-space global illumination: one indirect diffuse bounce gathered from the previous anti-aliased frame, plus ambient occlusion, half resolution, depth-aware blur — `shaders/ssgi.frag`, `shaders/ssao_blur.frag`, `post.ludic` `post_ssao_pass`
15. Specular occlusion from ambient occlusion — `shaders/lighting.glsl`
16. Cloud shadows projected along the sun from an animated cloud layer — `shaders/lighting.glsl` `cloudShadow`
17. Regional vegetation colouring (aspen groves, dry ridges) and slope-aspect colouring — `shaders/lighting.glsl` `regionTint`, `shaders/terrain.frag`

Shadows
18. Cascaded shadow maps, 5 cascades (16 / 60 / 250 / 1100 / 6000 m) fitted to frustum-slice bounding spheres, texel-snapped, PCF radius widened on the far cascades — `shadow.ludic` `shadow_fit`
19. PCF with rotated Poisson taps and interleaved-gradient noise, normal-offset and world-unit slope bias, cascade edge blending — `shaders/lighting.glsl` `sunShadow`
20. Per-layer caster culling (grass in near cascades, coarse terrain meshes for far cascades) — `scatter.ludic` `scatter_draw_casters`, `terrain.ludic`
21. Sun-facing impostor cards in the shadow pass with mip-biased coverage — `shaders/impostor.vert`, `shaders/impostor.frag`

Geometry, terrain and world
22. GPU-generated terrain height field (ridged multifractal, fbm) — `shaders/heightgen.frag`
23. Real-world terrain from the Copernicus GLO-30 elevation model with slope-scaled fractal detail; a lake bed carved under the surface the model records — the survey window in the Maroon Lake game (git.workshopsoft.io/workshopsoft/maroon-lake), `shaders/heightgen.frag` `DEM`, `terrain.ludic` `terrain_use_dem`, `terrain_lake`
24. Satellite orthophoto drape (Sentinel-2 true colour) sampled bicubically, blended in past the middle ground, keeping the scanned materials' luminance grain plus three-scale procedural grain — the survey window in the Maroon Lake game (git.workshopsoft.io/workshopsoft/maroon-lake), `shaders/terrain.frag` `u_ortho`
25. Satellite-classified materials and placement: bare ground (cobble shore near, talus far), snow, meadow, dense conifer stands (tree density and forest-floor duff follow the photograph) — `shaders/terrain.frag`, `terrain.ludic` `terrain_ortho_green/scree/forest`
26. Terrain material splatting by slope, altitude and a track mask; height-map CPU read-back for placement queries — `shaders/terrain.frag`, `terrain.ludic` `terrain_height`
27. Snow by altitude and slope, gully snow, forest-floor material under stands — `shaders/terrain.frag`
28. glTF 2.0 loading of photogrammetry models by byte-range reads from the `.bin`, or from a binary `.glb`'s BIN chunk (told apart by the file's first bytes) — `gltf.ludic` `gltf_open`, `glb.ludic`
29. GPU instancing with divisor attributes and per-instance transforms — `scatter.ludic`, `shaders/model.vert`
30. Baked impostors (16-view atlas with coverage and normals, hull-normal blending, LOD switch) — `scatter.ludic` `impostor_bake`, `shaders/impostor.*`
31. Baked branch-card trees: wedge slices of a scanned crown (sectors × height bands) on radial cards over the real trunk mesh — `scatter.ludic` `impostor_bake_wedges`, `model_branch_cards`
32. Card atlases baked from scanned grass clumps and a dense procedural lupine, instanced as crossed cards — `scatter.ludic` `layer_cards`
33. Procedural grass blades with wind, dryness and base occlusion; distant blades widen, lie flat to the ground normal and sink into the carpet at the ring's edge — `scatter.ludic` `model_blade`, `shaders/model.vert`, `shaders/model.frag` `BLADE`
34. Wind animation (height-weighted sway, per-instance phase) — `shaders/model.vert` `WIND`
35. Chunk-streamed ground cover with distance bands (blades in four rings, densest underfoot), deterministic per-chunk generation, nearest-first amortised over frames with an instance budget — `stream.ludic`
36. Multi-scale noise clustering for natural placement, forest density by elevation/slope/aspect, avalanche chutes, shoreline scrub — the Maroon Lake game (git.workshopsoft.io/workshopsoft/maroon-lake)
37. Level-of-detail by distance: full scan mesh → branch cards → single impostor — `scatter.ludic` `layer_update`
38. Texture edge dilation for cut-out atlases; 16-bit PNG decoding to RGB16/R16; RGBE HDR decoding — `texture.ludic`
39. Anisotropic filtering and mipmapping on all scanned maps — `texture.ludic` `tex_upload`
40. Still water: planar reflection pass through a reflection matrix with clip-below discard, depth-tinted body, soft shores, ripple normals, foam streaks, sun glitter; the surface writes depth so occlusion and temporal passes see it — `water.ludic`, `shaders/water.frag`
40a. The open sea: a plane in sea style - baked tiling swell slopes (spread over a cone of directions, mipped) bend the light with the surface kept flat, fading out before a pixel can alias them and flat toward the horizon, a colour that deepens to plain sea by nine metres, a foam band where the water over the bed is under a metre (swash, lace, none at a metre) drawn on the sea only, a rectangle that reaches the horizon from anywhere on the map, drawn on the wet mask's wet texels with no reflection pass, a mesh body at the same height wins over it, its own shader program and one sky read for reflection and haze (3 times cheaper than the first sea: `lab/sea_budget.py`) - `water_sea.ludic`, `shaders/water.frag`

Anti-aliasing, camera and post-processing
41. Temporal anti-aliasing: Halton-jittered projection, depth reprojection, YCoCg neighbourhood clamping, history ping-pong — `camera.ludic` `cam_set_jitter`, `shaders/taa.frag`
42. Optional MSAA with alpha-to-coverage and per-mip alpha sharpening — `post.ludic`, `shaders/impostor.frag`
43. HDR pipeline (RGBA16F) with NaN/inf sanitising at every stage — `post.ludic`, `shaders/lighting.glsl` `sane`
44. Bloom: 13-tap downsample pyramid with soft threshold, tent upsample — `shaders/bloom_down.frag`, `shaders/bloom_up.frag`
45. Auto-exposure by mean luminance with temporal adaptation — `post.ludic` `post_measure`
46. ACES filmic tonemapping that keeps the scene's hue (Oklab), with a log-space contrast that steepens above mid grey only — `shaders/tonemap.frag`
47. Colour grading: white balance, lift/gain, saturation — `shaders/tonemap.frag`
48. Vignette, dithering, film grain — `shaders/tonemap.frag`, `shaders/sharpen.frag`
49. Luma unsharp sharpening — `shaders/sharpen.frag`
50. Height-based exponential fog / aerial perspective from the prefiltered sky with sun inscatter — `shaders/lighting.glsl` `applyFog`
51. Specular anti-aliasing (highlight cap) and firefly prevention — `shaders/lighting.glsl`
52. Fly camera with mouse look — the Maroon Lake game (git.workshopsoft.io/workshopsoft/maroon-lake)
53. Profiling switches per stage and a frame benchmark — `render.ludic` `r3d_env_flags`

Characters and moving objects
54. glTF skins: node hierarchy, joints and inverse bind matrices loaded per model, four-influence GPU skinning, poses set per node in the model's frame — `skin.ludic`, `shaders/skin.vert`, `quat.ludic`
55. Actors: models placed and moved per frame (skinned or rigid), lit and cast into every cascade — `actor.ludic`
56. The drawn terrain height on the CPU (cubic B-spline of the texels) for things that stand on it — `terrain.ludic` `terrain_height_smooth`
57. A third-person character controller with a distance-driven procedural gait (walk / run / idle), slope and water limits, and a settling orbit camera — the Maroon Lake game (git.workshopsoft.io/workshopsoft/maroon-lake)
58. A 2D overlay over the finished frame: batched rectangles, images and proportional text from a baked font atlas (`tools/blender/font_build.py`) — `overlay.ludic`, `shaders/overlay.*`
59. Time of day over the HDRI: a solar arc drives the sun's direction and colour, the sky's light scales toward a deep-blue starry night, a moon lights the night, the visible sky turns with the sun and its convolutions rebake when far off, the height-field shadow rebakes as the sun moves, auto-exposure is capped at night — `daylight.ludic`, `shaders/sky.frag`, `shaders/lighting.glsl`
60. One point light (the campfire) in the shading — `shaders/lighting.glsl` `fireLight`
61. ~~Static collision: ground circles in a cell grid~~ - removed; still things are bodies in `ludic.physics` (Jolt)
62. Cut-out and emissive actors (a flame's cards) — `actor.ludic`, `shaders/model.frag` `u_emissive`
63. Per-instance skin clones (a herd posed individually), per-part tints and hidden parts on actors, uniform-location caching with frustum and distance culling — `skin.ludic` `skin_clone`, `actor.ludic`
64. A second point / cone light (a torch or flashlight in the hand) with a reach in metres and a gentle falloff to it — `daylight.ludic` `daylight_hand`, `shaders/lighting.glsl` `handLight`
64a. Tree foliage dithered out inside arm's length of the camera, in the depth prepass — `shaders/model.vert` `v_near`, `shaders/depth.frag`, `#define NEAR_FADE`
65. Auto-exposure adapted on the GPU: a 1x1 pass meters a centre-weighted histogram of the frame (a band of it, averaged), holds it by day within a few stops of open ground's exposure, eases last frame's value toward key / that over seconds, not frames (1 - exp(-dt / tau); 0.2 s as the scene brightens, 0.5 s as it darkens: `post_adapt_speed`) and the tonemapper samples it, so nothing is read back (a pixel-buffer read still synchronised on Apple's GL) — `post.ludic` `post_measure`, `post_meter.ludic`, `shaders/adapt.frag`
66. A PPM reader with box-filtered downscale (photo thumbnails) and word-wrapped overlay text — `texture.ludic` `tex_load_ppm`, `overlay.ludic` `ov_text_wrap`
67. The overlay batches a whole frame into one upload and draws per texture range with optional scissor clips (per-change uploads stalled the driver: 40 ms -> 25 ms), plus nine-slice, rotated, line, disc and arc primitives — `overlay.ludic` `ov_flush`, `ov_clip`, `ov_nine`, `ov_sub_rot`, `ov_line`, `ov_disc`, `ov_arc`
68. Weather on the daylight: an overcast factor greys and dims the sun and the sky's light, a fog multiplier thickens the air, a lightning flash — `daylight.ludic` `daylight_weather`
69. An outline pass: an actor carries a rim width and colour, drawn as an inverted hull depth-tested against the scene, and anything that is not an actor can queue one at a transform (a scatter instance, a tile) — `actor.ludic` `actor_draw_outlines`, `outline_model`, `shaders/outline.frag`
70. Two ways to make an island out of a survey: a radius from a centre, or the sea put around the survey's own edge with a noise-wobbled coast, both scaling the existing relief into the water and compressing the last few metres of height either side of the line into beach and shallows — `terrain.ludic` `terrain_island`, `terrain_coast`, `shaders/heightgen.frag`
70a. Blended actors: an actor laid over the scene (alpha, premultiplied) or added to it (additive), in a pass of its own after the opaque scene and the water and before bloom, depth-tested against the scene and writing none, "over" sorted far to near, lit with the sun, shadow, sky light and fog of the opaque actors or unlit (base colour x emissive), an additive one dimmed by the air rather than fogged, a soft-particle fade against the resolved depth, a closed shape drawn inside then outside; no shadow unless asked — `actor_blend.ludic` `actor_draw_blended`, `shaders/model.frag` `TRANSLUCENT`, lab scene `packages/ludic.lab/example/blend.ludic`
70b. Actors placed with yaw, pitch and roll and a scale per axis, by a quaternion, or as a camera-facing card — `actor_place.ludic` `actor_place_rot`, `actor_place_q`, `actor_billboard`

Large worlds (cities of hundreds of thousands of buildings on 16 km and more; README, "Large worlds")
71. Floating origin: world positions in double, render space a float offset from an origin snapped to a power-of-two grid, rebased with hysteresis and no jitter (a rebase moves every render number by exactly the shift); integer-cell + float-offset positions - `forg.ludic` `forg_update`, `forg_shift_floats`, `CellPos`
72. World partition as data (cell size, tier radii, budgets in one row of the map's `world_partition.lres`) and a pure streaming scheduler: two layers a cell (HLOD proxy, full instances), nearest-and-forward-first, per-frame time budget from measured cost per byte, memory budget with nearer-evicts-farther, hysteresis, pins, async and failed loads, drops handed out once - `wpart.ludic`, `wstream.ludic`
73. Per-cell content files (kit id, cell-local transform, tint, variation, flags), a cell index and the map's building kits as data - `cellfile.ludic` `CellContent`, `CellIndex`, `RenderKits`
74. HLOD: a merged, simplified far proxy a cell (buildings to boxes, merged by ground cell and height band under a volume-growth limit), a bake task and its files - `hlod.ludic` `hlod_bake`, `tools/hlod_bake.ludic`, `hlod_gpu.ludic`, `shaders/hlod.vert`, `shaders/hlod.frag`
75. Instancing at scale, CPU: per-cell frustum culling (cells culled whole), distance LOD binning to (kit, level) lists, per-list caps and an adaptive distance scale for a steady frame time - `kinst.ludic` `kinst_cull`, `kinst_adapt`
76. Instancing at scale, GPU: one arena of every resident cell's instances, a parallel frustum/distance cull with two-pass atomic binning (count, scan, scatter) in compute, indirect draws a material, a range allocator that holds a freed range while a frame is in flight - `kgpu.ludic`, `karena.ludic`, `shaders/kinst_cull.comp`, `shaders/kinst_args.comp`, `shaders/kinst_reset.comp`, `shaders/kit.vert`
77. Octahedral impostors for far buildings: hemi-octahedral frame atlas, three-frame barycentric blend with per-frame reprojection, baked from the kit's model by an MRT pass - `oimp.ludic`, `oimp_gpu.ludic`, `shaders/oimp.vert`, `shaders/oimp.frag`
78. Interior mapping: per-window room from an atlas (deterministic hash of the instance's variation, wall and window cell), lights on at night room by room, glossy glass over the room, a facade measured in the model's own frame (nothing moves with the origin) - `imi.ludic`, `interior_atlas.ludic` `InteriorAtlases`, `shaders/kit.frag` `INTERIOR_MAP`
79. Portal visibility inside buildings: rooms and portals as data, a frustum narrowed at each open portal, entry from outdoors through the exterior portals, the verdict driving the culler - `portal.ludic` `pg_visible`, `intr.ludic` `InteriorRooms`, `InteriorDoors`
80. Multi-map and instanced interiors: an interior is a map loaded on demand (once however many instances), a slot and far-away origin for each (def, owner), fade / load / spawn / exit transition with events, eviction, keep time, the city's streaming held while inside - `intr.ludic` `intr_enter`, `intr_update`, `intr_rehome`
81. A default font for a game that names none: `overlay_init(st, "")` loads Noto Sans (OFL, baked: Latin, Latin Extended-A, Greek, Cyrillic) from `fonts/default/` in this package, which a shipped game's pack carries; a game's own TTF is baked with `ludic font bake` — `overlay.ludic` `overlay_font_default`
82. A map's ground from the studio's 16-bit height tiles, read as they are (layout from the map's row: texel centres, tile edges, height range), a pool of tiles streamed nearest first within a budget, heights and normals anywhere for physics and placement, and heights for a Jolt heightfield shape - `tilemap.ludic` `tmap_new`, `tmap_stream`, `tmap_height`, `tmap_field`
83. The ground drawn from baked levels of detail: tiles cut into patches and levels offline (quantized heights and normals, one LWT1 file a tile, checked against the row), patches streamed and uploaded nearest first, a skirt hiding the cracks between levels, the renderer's own model pass lighting it - `tilemap_bake.ludic`, `tools/terrain_bake.ludic`, `tilemap_lwt.ludic`, `tilemap_draw.ludic` `tmd_frame`
84. Placed things baked into instanced kits: one `RenderKits` row a model, node and atlas, the cell files and index the scheduler loads, rows a game reads back, existing ids kept - `kitbake.ludic` (ludic.city's rows: `packages/ludic.city/tools/cells_bake_city.ludic`)

## Against Unreal Engine 5 and RAGE (RDR2), honestly

| Technique | UE5 / RAGE | Here |
|---|---|---|
| Physically based shading, IBL, split-sum | both | implemented (1–4) |
| Cascaded shadow maps with PCF | both (UE5 also virtual shadow maps) | implemented (18–21); no virtual shadow maps |
| Temporal AA / upsampling | TSR / TAA | TAA implemented (41), no upscaling |
| Screen-space AO / GI | SSAO, SSGI, Lumen | SSGI + AO implemented (14); no Lumen-class GI, no ray tracing |
| Volumetric clouds and fog | both | HDRI sky with cloud shadows and analytic fog; no ray-marched clouds |
| Foliage: impostors, wind, translucency | both | implemented (30–34) |
| Nanite / virtualised geometry | UE5 | not applicable; LOD chain (37) instead |
| Terrain: height fields, layered materials, real-world data | both | implemented (22–27) |
| Water with planar reflection | RAGE planar, UE SSR | planar reflection implemented (40); no screen-space reflection |
| Translucency: sorted blended surfaces, soft particles | both | blended actors (70a): sorted per actor, soft fade; no order-independent transparency, no lit volumetric particles |
| Post: bloom, exposure, tonemap, grading, DoF, motion blur | both | bloom/exposure/tonemap/grading implemented (44–49); no depth of field, no motion blur |
| Streaming world | both | chunk streaming of cover (35); terrain is one 8 km tile; cell streaming with HLOD, floating origin and instancing for a city (71-76) |
| Compute shaders, indirect draw, bindless | both | compute passes and indirect draws implemented (`gpu.ludic`, `shaders/grass_cull.comp`); no bindless |

Where the remaining visual gap sits: photogrammetry cards for several meadow
species, ray-traced or probe-based global illumination, virtual shadow maps, and
volumetric clouds. Those are the techniques that separate this from the reference.
