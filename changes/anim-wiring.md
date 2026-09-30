bump: minor
type: feature
**Animation wiring is data.** `ludic.anim` gains the open registry `AnimBindings`: a row names a source by a stable string
(`crowd.speed`, `melee.SWING`, `weapons.RELOAD_STARTED`, `vitals.DOWNED`, `character.grounded`, `vehicles.seat_pose`) and the parameter,
trigger or state of a graph it feeds, with a scale, offset, curve, clamp, gate and smoothing; `anim_link_tick(anim_st, dt)` once a frame does the rest,
allocating nothing. `ludic.base` gains `SignalSources`, the registry mechanics declare their facts, per-actor values and words in
(`SignalSource`, `SigFact`, `sig_find`, `sig_problem`, and a dev verb `signal_source` that lists them for a studio). `ludic.melee`, `weapons`, `vitals`,
`crowd`, `character` and `vehicles` declare theirs in a `signals.ludic` each, and a new package adds its own with one `def` a source.
`anim_link_validate()` reports a source nobody registered, a kind it cannot feed, a parameter or state the graph lacks, and two rows writing one parameter.
**`animset_tick` now samples through ozz-animation** when the native layer built the player's skeleton and the clip (`anim_oz_enable`, `animset_release`),
with the Ludic sampler as the reference and the fallback; the pose agrees within 3.5e-5 a component over fades, layers and root motion.
