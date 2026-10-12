bump: minor
type: feature
**`ludic.physics`: continuous collision detection per body.** `phys_ccd(st, id, on)` gives a dynamic body
Jolt's `LinearCast` motion quality, so its shape is swept over each step and stopped at what it would
skip: a car at 60 m/s moves a metre a step, more than a wall is thick. `phys_is_ccd(st, id)` asks. Off
by default (a sweep costs); a still or kinematic body, a removed id or no world answers `false`. The shim
gains `jph_body_ccd` and `jph_body_ccd_of`; `jph_body_add` is unchanged. Needs `native/build.sh` to be
run again on the Mac and on the PC for the new symbols.
