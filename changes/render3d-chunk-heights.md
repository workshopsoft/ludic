bump: minor
type: feature
**The ground's heights a chunk at a time: `terrain_chunk_heights(i, j, size_m, n, out)`.** For
whatever is built per chunk (plan 23.5 of maroon-lake: the physics ground by 64 m chunks): n x n
samples of chunk (i, j) of a grid laid from the terrain's corner, row-major into the caller's
buffer, nothing allocated. Each is the ground's cubic B-spline at the texel under it - the
separable (1 4 1) / 6 filter `ter_spline_at`, the same numbers ludic.physics' B-spline
heightfield makes of the whole map - so neighbouring chunks share their edges bit for bit and
agree with the drawn ground. The read-back lives from `terrain_generate` to `terrain_unload`.
`examples/rendering/chunks.ludic` holds it.
