# Unreal port (branch render/ue-post): what is ported, its flags, and behaviours to tune for the game

Every feature here follows UE 5.8 source (tag 5.8.4-release); the files are named in each module's header. Each has an
off switch, and its settings live in `UePost` (ue_post.ludic) under Unreal's names with Unreal's defaults.

## Ported

| Feature | Module / shaders | Off switch |
|---|---|---|
| Colour grading LUT + filmic tonemapper | ue_post.ludic, combine_luts.frag, tonemap.frag `ueTonemap` | `R3D_UE_TONEMAP=0`, `r3d_ue_tonemap` |
| Histogram eye adaptation | ue_post.ludic, ue_histogram.frag, ue_eye_adapt.frag | `R3D_UE_EXPOSURE=0`, `r3d_ue_exposure` |
| Gaussian bloom (BM_SOG) | ue_post.ludic, ue_downsample.frag, ue_blur.frag | `R3D_UE_BLOOM=0`, `r3d_ue_bloom` |
| Post Process Volumes | ue_post.ludic `ue_ppv_*`, `R3D_PPV` | `R3D_UE_VOLUMES=0`, `r3d_ue_volumes` |
| Sky Atmosphere (visible sky, sun disc) | ue_sky.ludic, ue_atmosphere.frag, sky.frag `uaSkyLuminance` | `R3D_UE_SKY=0`, `r3d_ue_sky` |
| Exponential height fog + aerial perspective | ue_fog.ludic, ue_fog.frag, ue_fog_apply.frag, ue_atmosphere.frag `UA_AP`/`UA_DISTANT` | `R3D_UE_FOG=0`, `r3d_ue_fog` |
| Real-time sky light (capture, GGX cube, SH diffuse) | ue_skylight.ludic, ue_skylight.frag, lighting.glsl `u_ue_sl` | `R3D_UE_SKYLIGHT=0`, `r3d_ue_skylight` |
| Atmosphere sun light (sun colour = outer illuminance x ground transmittance) | ue_skylight.ludic `ue_sunlight_on`, daylight.ludic `daylight_set` | `R3D_UE_SUNLIGHT=0`, `r3d_ue_sunlight` |
| The hour's grade in Unreal's settings (lowest-priority unbound volume) | ue_post.ludic `ue_tod_grade`, daylight.ludic | `R3D_UE_HOUR_GRADE=0`, `r3d_ue_hour_grade` |
| Lens flares (image based: bokeh blur of the quarter-res scene, eight tinted mirrored copies over the bloom) | ue_post.ludic `ue_lens_flare_pass`, shaders/ue_flare.vert/.frag | off as Unreal ships (r.DefaultFeature.LensFlare 0); `R3D_UE_LENS_FLARE=1`; LensFlareIntensity / Tint / BokehSize / Threshold blend in volumes; `r3d_ue_lens_flare_bokeh` |
| Local exposure (Bilateral: 64 px tiles x 32 log-luminance buckets from the half-res scene, blurred log luminance, CalculateLocalExposure in the tonemapper) | ue_post.ludic `ue_local_exposure_pass`, shaders/ue_le_grid.comp, ue_le_lum.frag, tonemap.frag `ueLocalExposure` | off as Unreal's engine defaults leave it (contrast scales 1); `R3D_UE_LOCAL_EXPOSURE=<scale>` sets both contrast scales (Unreal's new-project templates use 0.8); all ten settings blend in volumes |
| Local lights: point + spot (units, attenuation, cone), on surfaces and in the volumetric fog | ue_lights.ludic, lighting.glsl `ueLocalLights`, ue_volfog.frag | `R3D_UE_LIGHTS=0`, `r3d_ue_lights`; `R3D_LL` test lights |
| MetaHuman head bent normal + material AO (MF_skin_bentNormalsAO: T_MH_BentNormal_AO; ApplyBentNormal's spherical-Gaussian diffuse and specular occlusion, AOMultiBounce on the sky's diffuse and reflections) | morph.ludic `model_set_bent`, actor.ludic `ac_bind_bent` (unit 22), model.frag, lighting.glsl `ueApplyBentNormal` | `R3D_UE_BENT_NORMAL=0` |
| Forward light grid (64 px cells x 32 log slices, GPU cull per cell: box vs sphere + spot cone refinement; every visible light, nearest first, up to 1024) | ue_lightgrid.ludic, shaders/ue_lightgrid.comp, lighting.glsl `ueLightGridRange` | `R3D_UE_LIGHT_GRID=0`, `r3d_ue_light_grid`; settings `r3d_ue_light_grid_settings` (r.Forward.LightGridPixelSize, LightGridSizeZ, MaxCulledLightsPerCell); `R3D_UE_LL_MAX` lights a frame |
| Spot and point light shadow maps (legacy whole-scene; spots: projection, per-light resolution and fade, bias, Manual5x5PCF; points: one-pass cube faces, cube surface sizes, receiver bias, CubemapHardwarePCF 29 samples; one compare each in the fog) | ue_lightshadows.ludic, lighting.glsl `ueSpotShadow` / `uePointShadow` and their `...Volume` | `R3D_UE_LIGHT_SHADOWS=0`, `r3d_ue_light_shadows`; `R3D_UE_LS_PAGES` (atlas pages of each kind), `R3D_UE_LS_RES` (r.Shadow.MaxResolution); settings `r3d_ue_light_shadow_settings` (Unreal's cvar names); per light ShadowBias / ShadowSlopeBias / ShadowSharpen / ShadowResolutionScale; `R3D_UE_LS_DEBUG=1` dumps the first map |
| Volumetric fog (froxel grid: media, sun + sky light scattering, temporal, integration) | ue_volfog.ludic, ue_volfog.frag, ue_fog.frag | `R3D_UE_VOLFOG=0`, `r3d_ue_volfog`; `R3D_UE_FOG_DENSITY`, `R3D_UE_VOLFOG_G` for tuning; `R3D_UE_VOLFOG_DEBUG=1` shadow view |

## Behaviours to tune for the game (Unreal's, not bugs)

These are how Unreal's defaults behave on our scenes. Change them in the game's settings or volumes, not in the ports.

- **Less saturated than our old tonemapper.** Unreal's FilmToneMap desaturates by design (0.96 before the curve, 0.93 after,
  BlueCorrection 0.6); our old curve kept each colour's full saturation (Oklab). Bright colours (sky, yellow clothes, grass) lose
  some richness. Adjust: `grade` saturation (global or per range), in the base settings or a volume.
- **Paler sky, slight haze, less contrast at noon.** The filmic shoulder at Unreal's exposure (AutoExposureBias +1) compresses
  the bright sky. Adjust: `auto_exposure_bias`, film curve (`film_slope`, `film_toe`, `film_shoulder`), or highlights grading.
  Partly expected to change once the sky is Unreal's physical Sky Atmosphere instead of the HDRI.
- **Brightness comes from Unreal's exposure, not our tuned key.** The old "open ground" day clamp and the night ceiling
  (`post_exposure_max`) are not used in Unreal mode; exposure follows the frame (10-90% log average, bias +1, 3 / 1 stops a
  second). Night readability will need `auto_exposure_min_brightness` / `max_brightness` or night volumes.
- **The hour's grade is a translation, not Unreal's.** Unreal has no grade by the hour; daylight's (tuned by eye for the old
  tonemapper) now feeds the lowest-priority unbound volume: white balance -> SceneColorTint (exact), saturation -> ColorSaturation
  (before the curve, not after), contrast -> ColorContrast on midtones + highlights, lift -> ColorOffsetShadows (display value ^2.2,
  the loosest), gain -> ColorGain. Retune its numbers in Unreal's controls rather than trusting the old ones.
- **Dusk was warmed twice; the grade's share is now off.** With Unreal's sun light on, daylight's low-sun white balance and lift
  terms are zero (the atmosphere colours the low sun); its low-sun saturation boost stays. Dusk is still golden, from Unreal's sun
  itself plus that saturation: at 19:00 the frame's blue rose 7-12 levels after the change. Further: lower `post_saturation`'s
  lowsun term, or the atmosphere's settings, or a dusk grade in Unreal's controls.
- **WhiteTemp means "the light's temperature" by default.** TemperatureType is White Balance, so a lower WhiteTemp makes the
  image cooler (it corrects the light), not warmer. Use `temp_is_white_balance = false` for Unreal's "Color Temperature" mode.
- **Bloom is mild by default.** About 9% of a blurred image (tints sum to ~0.8 x 0.675 / 6); our old bloom had a threshold
  and a different look. Adjust: `bloom_intensity`, sizes and tints.
- **Vignette is Unreal's cos^4 at 0.4.** Slightly different falloff from our old one. Adjust: `vignette_intensity`.
- **The sky's brightness follows our sun.** The atmosphere's outer-space sun illuminance defaults to the scene's own sun
  (`day_sun_base`) so the sky and lit ground share one scale; Unreal's default would be 10 lux with physical units everywhere.
  Set `UeSky.light_illuminance_*` to override. Our stars and moon still draw on top at night (Unreal leaves those to the sky material).
- **The sun's colour now comes from the atmosphere.** Its light is white at the scene's base sun's luminance (`day_sun_base`, standing
  in for the outer-space illuminance: Unreal's directional light is white and only the atmosphere colours it) times the transmittance
  through Unreal's atmosphere at the sun's true elevation (the base's own tint was taken until 2026-10-27: the photograph's sun is
  already through the air, so it was warmed twice: r/g 1.19, b/g 0.74 at 50 degrees against Unreal's 1.13, 0.81); daylight's warmth
  ramp, its fade between -8 and 12 degrees and the 3-degree floor on the light's direction are not used. So the low sun is warmer
  and the noon sun is a little dimmer and cooler-white than daylight's (the base used to be the sun at the photograph's own
  elevation). Exposure takes up the brightness. Adjust: `UeSky.light_illuminance_*` (the outer-space sun), the Rayleigh / Mie /
  ozone settings. The weather's dimming (overcast, lightning) is the game's and still applies; the moon at night is still daylight's.
- **Shadowed sides are darker and bluer than before.** The sky light is the captured sky only: blue from above, black below the
  horizon (bLowerHemisphereIsBlack), no hand-made ground term. In Unreal the light bounced off the ground comes from GI (Lumen), not
  the sky light. Adjust: `UeSkyLight.lower_hemisphere_is_black = false` with a `lower_hemisphere_color`, `intensity`, or GI later.
  Our own ground-bounce fill (lighting.glsl `bounce`) is still on and is not Unreal's.
- **Windows and glossy surfaces look darker.** They reflect the captured cube, and anything below the horizon reflects black;
  Unreal fills that from screen-space reflections or Lumen (not ported yet).
- **The sky light needs Unreal's fog on** (it reads the fog's distant sky light for the capture's fog); with R3D_UE_FOG=0 it stays off.
- **The capture runs every frame** (UeSkyLight.capture_interval 1; its cost is not measured yet, the whole gym frame stayed about 20 ms headless); Unreal time-slices it over frames. Raise the interval
  to save time.
- **A darker band where the land meets the sky.** Unreal fogs sky pixels too (bFogOnlyOnRenderedOpaque false); far away the
  fog's colour wins, and with the sky atmosphere lighting the fog that colour is the distant sky light (the whole sky's average,
  darker than the pale horizon) plus a sun lobe (exponent 4, from 100 m). Adjust: `fog_inscattering_luminance`,
  `sky_atmosphere_ambient_contribution`, `fog_density`, `fog_max_opacity`, or `fog_cutoff_distance`.
- **Unreal's default fog is thin.** FogDensity 0.02 with falloff 0.2 (0.002 / m at the fog height); the old fog was tuned
  thicker for the valley look. Adjust: `fog_density`, `fog_height_falloff`, `height_offset`.
- **Water and blended actors take the fog of what is behind them** for now (Unreal fogs translucency per pixel in its own pass).
- **Below the horizon Unreal draws the planet's ground.** Our old sky filled it with fog colour; terrain hides it on the island.
- **No area looks yet.** The game places no volumes; port, downtown, forest, industrial, beach and interiors each want one.

- **Volumetric fog is on although Unreal's component default is off** (bEnableVolumetricFog false); the game asked for shafts.
  At Unreal's default density (0.02) it is a light haze; shafts want denser fog (R3D_UE_FOG_DENSITY to try). It replaces our old
  shaft pass (volumetric.frag). It costs about 5 ms a frame headless in the gym (80 frames 1.57 s -> 2.01 s; not profiled per pass).
- **Shafts: the shadow works; Unreal's default medium hardly shows them.** R3D_UE_VOLFOG_DEBUG=1 shows the grid's sun shadow
  factor at each pixel's depth: it matches the scene's shadows (19:00, the box's long shadow), so the cascades are sampled right.
  At Unreal's VolumetricFogScatteringDistribution 0.2 the medium scatters nearly evenly, so toward the sun it glows far less than
  the analytic fog's sun lobe (about 40 levels darker in the test frame) and shadow wedges have little to cut. With g 0.8 and
  density 0.4 (R3D_UE_VOLFOG_G, R3D_UE_FOG_DENSITY) the sun's glow fills the air and buildings visibly cut it. For shafts in the
  game: raise `scattering_distribution` (Unreal projects commonly use 0.6-0.9) and the density, per area with volumes later.
  Lamp and headlight beams need general local lights, which are not ported.
- **Not ported in the volumetric fog:** local lights, light functions, the conservative depth test and its history fix-up,
  super-sampling on a history miss, local fog volumes, Lumen GI.

- **Spot and point lights cast.** A shadowed spot draws the casters into a layer of a depth array at Unreal's per-light
  resolution (on-screen size x 2.55, power of two, at most 2048); a point light draws them six times, into six layers of a cube
  array (face size 1024 / 512 / 256 / 128 / 32 by on-screen size x 1.27). Measured in the headless gym: one shadowed spot and
  one shadowed point add about 5.6 ms a frame (80 frames 2.17 s -> 2.62 s), mostly the seven caster passes. Lights you don't need
  shadowed: set CastShadows false, as in Unreal.
- **Cubes are array layers.** The engine has no cube textures, so the shader picks the face by the major axis and clamps the
  bilinear taps inside the face; Unreal's hardware cube filters across face edges, so a disc sample at a seam can differ slightly.
- **Spot shadow bias is taken at the receiver.** Unreal's caster shader writes linear depth + bias; here the casters keep their own
  programs (hardware depth from the same FShadowProjectionMatrix) and the receiver applies the same constant and slope bias, the
  slope from the receiver's normal (Unreal does this for point lights). The fog compares against the bias-free depth. If thin
  casters lose contact shadows or surfaces acne, tune ShadowBias / ShadowSlopeBias per light, as in Unreal.
- **Shadow maps are packed into atlases, as Unreal packs them** (FTextureLayout, a new atlas when one is full): spot tiles in
  one array, point lights' cube faces in another (Unreal gives each cube a target of its own). No light count limit; the limit is
  max_atlas_pages (R3D_UE_LS_PAGES, 4 of each kind, 16 MB each at 2048). A point light near the camera takes 1024 faces, six of
  them a page and a half, so 4 point atlases hold only two or three close lamps; lights that don't fit go unshadowed that frame.
  Lower r.Shadow.MaxResolution or raise the page budget for streets full of shadowed lamps. R3D_UE_LS_DEBUG=1 logs the packing.
- **Casters for local lights are gathered from the lights' bounds, as Unreal gathers a whole-scene shadow's casters**: they skip
  the sun's cascade rules (band, proxies), actors test against the light's sphere, and the GPU-culled kits (buildings) run a second
  cull, kinst_cull_lights.comp, keeping every instance whose sphere reaches a shadow-casting light (the light's attenuation
  sphere holds a point's cube and a spot's cone). Those casters fill the last quarter of the instance output in a frame where a
  light casts. R3D_UE_LS_CULL=0 draws the camera's list instead, for an A/B; R3D_UE_LS_DEBUG=1 logs both lists' sizes.
- **Light grid as Unreal's default (linked-list culling: no cap a cell).** The cells share one list of cells x 32 entries
  (r.Forward.MaxCulledLightsPerCell); a cell counts its lights, takes its run with an atomic allocator and writes them - the same
  lists as Unreal's linked list compacted. (A first cut capped each cell at 32 and dropped lights in tile-shaped blocks in town.)
  No HZB cell cull. 200 lamps in the gym: 42 ms a frame with the grid, 53 ms without (R3D_UE_LIGHT_GRID=0), the same image. A
  shaded point finds its cell from its world position through the main camera's unjittered view-projection, so reflections and the
  fog grid use it too; a point outside the main view reads every light.
- **GPP: graphics programs read storage buffers.** `readonly buffer <name> { ... };` in GLSL is bound by name with
  `gpu_bind_buffer`, like a sampler (manifest S rows; an unbound one reads a zeroed stand-in). This needs the rebuilt `ludic-dev`
  (tools/ludic-cli/shaders.ludic): an older one drops the S rows and lit programs fail. Rebuild it as the toolchain does:
  `bin/ludicc --unsafe --globals tools/ludic-cli/dev.ludic --emit-llvm -o build/ludic-dev.ll && clang -O2 build/ludic-dev.ll -o bin/ludic-dev`.
- **Light units are Unreal's, on our scene's scale.** Candela / d^2 in metres; Unreal's defaults (point 5000 Unitless = 8 cd,
  radius 10 m) sit on the same scale as Unreal's own default sun, which ours roughly matches (the sky's sun is our base sun). At
  night exposure adapts to the dark frame, so a bright lamp blows out nearby surfaces (the 1500 cd test spot did): pick lamp
  intensities with that in mind, or night exposure limits.
- **The game places no Unreal lights yet.** Street lamps, shop lights and car headlights need ue_light_add calls in the game.

## Not ported yet (in this area)

Unreal's DefaultBokeh texture (content), dirt mask, bloom threshold
(BloomSetup), convolution bloom, local exposure's contrast curves, Fusion method and bloom term, film grain texture, chromatic aberration, HDR output transform (HDR10 keeps the
old tonemapper), exposure compensation curve, meter mask.

- **Lens flares draw square ghosts until a bokeh texture is set.** Unreal falls back to a white texture when its DefaultBokeh
  content isn't loaded, so the ghosts are squares; with it they are soft hexagons. DefaultBokeh (/Engine/EngineMaterials, 64 x 64,
  sRGB, TEXTUREGROUP_Bokeh) is Unreal engine content under its EULA, so it is not in this repository: export it from a UE 5.8
  install (UnrealEditor-Cmd -run=pythonscript, an AssetExportTask with TextureExporterTGA), then pass it as
  `R3D_UE_LENS_FLARE_BOKEH=<png>` or load it and call `r3d_ue_lens_flare_bokeh`.

## What is left, and what it needs

- **Rect lights** (shop windows, signs): Unreal integrates them with linearly transformed cosines (RectLight.ush, its LTC tables
  in the renderer's system textures). Portable to this forward renderer; a sizeable port. Until then the shops keep their pools.
- **IES profiles**: need photometric files (.ies) per lamp model; the game has none yet. The light side is small once there are some.
- **Light functions**: Unreal evaluates a light function material per light; this engine has no material graph to evaluate.
- **SSR**: Unreal's screen space reflections run in the deferred renderer only (its forward renderer lists them as unsupported):
  they need a G-buffer with normals and roughness per pixel. This renderer is forward; SSR means a G-buffer (or every material
  shader writing normal and roughness to a second target) first.
- **Virtual shadow maps, Lumen, MegaLights**: built on Nanite-era infrastructure (virtual pages, a G-buffer, surface caches,
  hardware or software ray tracing). Each is a renderer project of its own, not a port of one pass.
- **Cached whole-scene shadows** (r.Shadow.CacheWholeSceneShadows): what lets Unreal shadow many lamps; not ported, so the game's
  street lamps cast no shadows.
- **Night exposure**: Unreal's auto exposure lifts a dark street towards middle grey; the game's lamps run at a quarter of real
  output so they read. Tune the night's AutoExposureMin/MaxBrightness (a volume or the hour's grade), then raise the lamps.

