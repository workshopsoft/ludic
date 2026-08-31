bump: minor
type: feat
**2D value types — `IVec2` and `Rect` (#1, phase 1).** Two by-value spatial
types that lower to packed integers, so they copy like scalars and never
allocate. `IVec2` is an integer 2D vector (a pair of `int` packed into one
`i64`) for tile and grid coordinates — `IVec2.make/zero/x/y/add/sub/scale/dot`,
the grid distance `IVec2.manhattan`, `IVec2.equal`, and `IVec2.to_vector` to
widen into the fixed-point `Vector`. `Rect` is an axis-aligned rectangle (four
Q16.16 `fixed` components packed into one `i128`) for HUD boxes and hitboxes —
`Rect.make/x/y/w/h`, the derived `Rect.right/bottom/center`, and the
`Rect.contains` (point) and `Rect.intersects` (overlap) tests. Both are exact
and deterministic, bit-identical on every platform, and complement the existing
`Vector` and `Color` types that already cover phase 1's other 2D primitives.
