bump: minor
type: feat
**Still water as planes and meshes, with a wet mask.** `WATER_MAX` goes from 8 to 16. A body can be a mesh
(`water_mesh_add`, or a `WaterBodies` row with an `asset` and a `node`): a baked lake polygon or river ribbon,
drawn with the water material on its own triangles only. A plane marked `masked` (`water_body_mask`) draws only
on wet texels of a per-tile wet mask (`water_wet.ludic`: `<tile>.wet.png`, read nearest first, mixed tiles kept
in resident layers, `wet_at` on the CPU), so a dry cut below the plane's level stays dry. `water_rebase` follows
the floating origin. The `shore` fixture and its lab (`lab/shore_lab.ludic`, `lab/shore_check.py`) show and
measure it.
