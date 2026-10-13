bump: minor
type: feature
**`ludic.physics`: continuous collision detection per body.** `phys_ccd(st, id, on)` gives a dynamic body
Jolt's `LinearCast` motion quality, so its shape is swept over each step and stopped at what it would
skip: a car at 60 m/s moves a metre a step, more than a wall is thick. `phys_is_ccd(st, id)` asks. Off
by default (a sweep costs); a still or kinematic body, a removed id or no world answers `false`. The shim
gains `jph_body_ccd` and `jph_body_ccd_of`; `jph_body_add` is unchanged. The macos-arm64 library is rebuilt
(Jolt v5.6.0, SHA-256 checked); the windows-x64 library still needs `native/build.sh` run on the PC for the
new symbols.

Measured (Jolt 5.6.0, 60 Hz, 1500 kg 4.4 m boxes): two cars head-on at 55 m/s each swap places without it,
overlap 0.64 m with it on one, 0.02 m with it on both, so **a game sets `phys_ccd` on both cars**; a car at
60 m/s into a standing car or a 0.1 m barrier is stopped by its own flag alone (the target's changes nothing).
