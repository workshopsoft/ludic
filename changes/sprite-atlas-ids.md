bump: minor
type: feat
`Sprite` component draws atlas ids (#90) — `Sprite.atlas = 1` routes `esys_sprite` through `atlas_draw_ex` (scale/flip/tint) so atlas cells / multi-cell spans (tall characters) use the engine sprite-render system, not just the 16x16 table.
