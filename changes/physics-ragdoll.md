bump: minor
type: feature
**`ludic.physics`: ragdolls and sensors.** A ragdoll is Jolt's `Ragdoll` (Samples/Utils/RagdollLoader.cpp's way): a
definition built in calls (`phys_ragdef_begin`, `phys_ragdef_part` a part at a time - its joint, a capsule between two
points in the joint's space, a mass, a swing-twist constraint to its parent with a bend for a knee or an elbow -
`phys_ragdef_make`), then any number of ragdolls of it added from a pose and velocities (`phys_ragdoll_add`) and read back
as bones every frame (`phys_ragdoll_read`: a part's body stands at its joint; `false` once every part sleeps). Parts sweep
(LinearCast: a limb is thinner than a step's travel and a road's mesh has no thickness); parts that touch in the
definition's pose never collide. `phys_sensor(st, id, on)` makes a body a sensor: its contacts are facts, it pushes
nothing, and no query (ray, top, overlap, push) finds a sensor. `phys_step_us` is the last step's time in Jolt. The shim
gains `jph_rag_*` and `jph_body_sensor`; the queries skip sensors. The macos-arm64 library is rebuilt (Jolt v5.6.0); the
windows-x64 library still needs `native/build.sh` run on the PC for the new symbols.

Measured on the island (M-series Mac, 60 Hz): Jolt's step 58 us with no ragdoll, 350 us average (530 worst) with six to
eight 12-part ragdolls moving at once.
