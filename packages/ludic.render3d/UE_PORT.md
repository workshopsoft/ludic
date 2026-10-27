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
- **Time-of-day grading is ignored in Unreal mode.** daylight.ludic's per-hour white balance, lift/gain, contrast and saturation
  feed the old tonemapper only. To do: move them into `UePost` (base settings driven by the hour) or volumes.
- **WhiteTemp means "the light's temperature" by default.** TemperatureType is White Balance, so a lower WhiteTemp makes the
  image cooler (it corrects the light), not warmer. Use `temp_is_white_balance = false` for Unreal's "Color Temperature" mode.
- **Bloom is mild by default.** About 9% of a blurred image (tints sum to ~0.8 x 0.675 / 6); our old bloom had a threshold
  and a different look. Adjust: `bloom_intensity`, sizes and tints.
- **Vignette is Unreal's cos^4 at 0.4.** Slightly different falloff from our old one. Adjust: `vignette_intensity`.
- **The sky's brightness follows our sun.** The atmosphere's outer-space sun illuminance defaults to the scene's own sun
  (`day_sun_base`) so the sky and lit ground share one scale; Unreal's default would be 10 lux with physical units everywhere.
  Set `UeSky.light_illuminance_*` to override. Our stars and moon still draw on top at night (Unreal leaves those to the sky material).
- **Surfaces are still lit by the photo HDRI's sky light**, not by the new sky, until Unreal's real-time sky light capture lands;
  the sun's colour is still daylight.ludic's, not the atmosphere's transmittance (Unreal's bAtmosphereSunLight).
- **A darker band where the land meets the sky.** Unreal fogs sky pixels too (bFogOnlyOnRenderedOpaque false); far away the
  fog's colour wins, and with the sky atmosphere lighting the fog that colour is the distant sky light (the whole sky's average,
  darker than the pale horizon) plus a sun lobe (exponent 4, from 100 m). Adjust: `fog_inscattering_luminance`,
  `sky_atmosphere_ambient_contribution`, `fog_density`, `fog_max_opacity`, or `fog_cutoff_distance`.
- **Unreal's default fog is thin.** FogDensity 0.02 with falloff 0.2 (0.002 / m at the fog height); the old fog was tuned
  thicker for the valley look. Adjust: `fog_density`, `fog_height_falloff`, `height_offset`.
- **Water and blended actors take the fog of what is behind them** for now (Unreal fogs translucency per pixel in its own pass).
- **Below the horizon Unreal draws the planet's ground.** Our old sky filled it with fog colour; terrain hides it on the island.
- **No area looks yet.** The game places no volumes; port, downtown, forest, industrial, beach and interiors each want one.

## Not ported yet (in this area)

Lens flares (need Unreal's DefaultBokeh texture from editor content and per-pixel instanced quads), dirt mask, bloom threshold
(BloomSetup), convolution bloom, local exposure, film grain texture, chromatic aberration, HDR output transform (HDR10 keeps the
old tonemapper), exposure compensation curve, meter mask.
