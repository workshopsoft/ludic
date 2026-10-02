bump: minor
type: feature
**The sun is where it really is.** `ludic.render3d` gets `solar.ludic` - NOAA's general solar position
calculation (`solar_elevation`, `solar_azimuth`, `solar_declination`, `solar_noon`: a latitude, a longitude,
the clock's offset from UTC, a day of the year and an hour) - and `daylight_site(lat, lon, utc)` /
`daylight_date(doy)` put the day's light on a site and a date: the sun's height and bearing, the moon (where
the sun was a phase of a day ago) and the sky's turn all follow, and every curve that was keyed to the old fixed
arc (the haze, the grade, the exposure) is keyed to the real elevation. Without a site the old arc runs as before.
The photograph's sun disc is turned to sit exactly under the light (its own azimuth, not the start's), the terrain
shadow's step is measured on the sky (a sun near the zenith sweeps azimuth fast and its shadow barely moves), and
the sky's convolutions are only rebuilt once they exist.

`ludic.clock` gets `clock_dates(month_starts)` and `clock_doy()` / `clock_doy_of(day)`: the real day of the year
each game month begins on, so a game day lands on a date (ten to a month, the month's real length) and a sun or
a season can follow it.
