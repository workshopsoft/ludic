bump: minor
type: feat
**ludic.render3d: large-world capabilities for a city of hundreds of thousands of buildings on a 16 km map.**

- **Floating origin** (`forg.ludic`) - world positions in double, render space a float offset from a power-of-two-snapped origin that rebases with hysteresis and no jitter; integer-cell + float-offset positions.
- **World partition and streaming** - cell size and tier radii as data (`world_partition.lres`), per-cell content files and an index (`cellfile.ludic`, `BuildingKits`), and a pure streaming scheduler (`wstream.ludic`) with a per-frame time budget, a memory budget, forward-first priority and hysteresis.
- **HLOD** (`hlod.ludic`, `tools/hlod_bake.ludic`) - a merged far proxy a cell, baked by a task a person runs; octahedral impostors for far buildings (`oimp.ludic`).
- **Instancing at scale** - a CPU culler with cell-level culling and an adaptive distance scale (`kinst.ludic`) and a GPU one: parallel compute cull and two-pass binning into indirect draws (`kgpu.ludic`, `kinst_cull.comp`); stress benchmarks in `bench/`.
- **Fake interiors** - interior mapping for facade windows: an `InteriorAtlases` registry, a room a window by deterministic hash, lights on at night, selected by the `INTERIOR_MAP` variant of `kit.frag`.
- **Real interiors** - portal visibility (`portal.ludic`) and multi-map, instanced interiors with a door / load / spawn transition API (`intr.ludic`).
- `r3d_on_prepare`, a hook that runs before the frame's first pass, for compute dispatches; eight shader programs and three compute programs added, `ludic-dev shaders` regenerated.
