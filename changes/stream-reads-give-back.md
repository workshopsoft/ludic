bump: patch
type: fix
**A streamed world's reads give back what they make** (`ludic.render3d`, `ludic.city`). A long drive over a city tripped
the allocation fence ("declared but unbounded", exit 86) after about a minute: every cell read kept its path, its file's
bytes and its content after the content was copied into the instance arena (`cell_load`, `bw_load`; a proxy likewise,
`hlod_load`), every wet-mask, land-use mask and hole-bit tile read kept its path (`wet_read`, `tmk_read`,
`tm_holes_read`), every PNG decode kept its job record (`png_decode`), a chunk of building colliders kept its path and
bytes (`city_colliders_in`), and the instance arena's free list grew in a frame as it fragmented. Each is given back
now (`cell_content_free`, `hlod_mesh_free`), the arena's lists get their room once (`kar_reserve`, called by
`kgpu_new` for its cells), and `gltf_file_exists(dir, file)` asks for a file without the caller making its path.
`tests/stream_leak_test.ludic` reads each 200 to 300 times and expects the heap not to grow.

**The terrain draw makes nothing in play** (`tilemap_draw.ludic`). Every patch slot's mesh, model and primitive records are
made once with the draw (`tmd_new`); a change of level gives the old level's buffers back and uploads the new one into the
same records (`tmd_fill`), so the memory no longer rises and falls with the patches in view. A walk across the gym's tiles
and a drive into new ground had it rising window after window until the fence failed the run ("declared but unbounded" in
`tmd_model_of` and `gpu_mesh_new`).
