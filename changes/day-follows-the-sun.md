bump: minor
type: feature
**Packages stop reading the summer clock.** Rules that were about the light or the day's rhythm are asked
of the game: `WildlifeWorld.heat` / `drinking_time` (thirst climbs in the heat and when they go down to
drink), `PhotoLight.sun_elev` (the golden hour is the sun between -1 and 15 degrees, a flat noon one above 60;
`PHOTO_NO_SUN` leaves the clock's hours), `NpcWorld.after_dark` / `deep_night` / `sunset` / `window` with
`NpcStep.window` and `NpcKind.leave_by_sun` (a routine hangs on the game's windows of the day, a kind leaves
at hours after sunset), and `WeatherWorld.wind_up` (the wind turns when the slopes are warm). Every member
defaults to the old hours, so a game with no sun behaves as before.
