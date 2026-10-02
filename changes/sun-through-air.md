bump: minor
type: feature
**`ludic.render3d`: a low sun is the colour the air leaves of it.** The sun's warmth was a ramp that stayed
white down to 20 degrees and only greened at 11 - and a basin whose ridges take the sun at 15 to 20 never
saw it warm. Its colour is now each channel's transmittance toward the sun (Kasten & Young's air mass,
Rayleigh scattering by Bucholtz's fit, Angstrom's aerosol: `solar_air_mass`, `solar_transmit`) over the same
at the photograph's own sun, held at 1 above it: a fifth of the blue gone at 21 degrees, half at 11, and the
light dims with the air it crossed. `daylight_air(pressure, beta)` sets the site's air (pressure over sea
level's, Angstrom turbidity; 1.0 and 0.06, a clear day at sea level, by default). Noon and anything above the
photograph's sun draw as before.
