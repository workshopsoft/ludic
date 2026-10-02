bump: minor
type: feat
**render3d: actors turned any way.** `actor_place_rot(a, x, y, z, yaw, pitch, roll, sx, sy, sz)` places an
actor with a full rotation (yaw about y, then pitch about x, then roll about z, as `translate * Ry * Rx * Rz *
scale`) and a scale per axis; `actor_place_q(a, x, y, z, q, sx, sy, sz)` with a quaternion; and
`actor_billboard(render3d_st, a, x, y, z, size, spin)` turns a card to face the camera. `actor_place` is
unchanged (yaw only).
