bump: minor
type: feature
**The sun's hours: `solar_sunrise` / `solar_sunset` (render3d) and `clock_set_sun` / `clock_set_night` (clock).** Where
the sun crosses the horizon on a date, from a site (latitude, longitude, the clock's UTC offset) and a day of the year,
found where it happens (the declination and the equation of time move through the day) and held to the almanac at
Maroon Lake. `ludic.clock` keeps the hours the game last told it (`clock_sunrise` / `clock_sunset`, 6 and 20 until it
does) so a window of the day can be an offset from them, and `clock_set_night` moves `clock_is_night` with the day.
