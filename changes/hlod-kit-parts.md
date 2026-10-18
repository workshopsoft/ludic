bump: minor
type: feat
**HLOD: a kit drawn far off as a few boxes that follow its shape.** Past the full-detail radius every thing was one box (its kit's
footprint times its height, centred on its place), so a landmark read as a block: a crane was the 32 x 24 x 50 m box round its tower
and jib (and, its mesh not being centred, 10 m off where it stands).
- `hlod_parts(tri, ntri, max_parts)` (hlod.ludic, pure): a kit's triangles (9 floats each, its own frame) into at most `max_parts`
  boxes (`HLOD_PART` floats each: x0, y0, z0, x1, y1, z1). The cells of a 20-cell grid along each axis that the triangles pass
  through are marked and taken as boxes (each grown along x, z, then y over marked cells, fitted to the triangles' points in them);
  then the pair whose box round both adds the least empty volume is merged until `max_parts` are left (each box keeps its cheapest
  partner). A portal crane is its four legs, its beams and its jib; a stadium's stands stay round its pitch.
- `kit_parts_read(render3d_st, dir, file, node, max_parts)` (kitbox_read.ludic, CPU, no device): the same from a kit's node.
- `hlod_bake_parts(content, kits, parts, ...)` / `hlod_bake_dir_parts(...)`: `parts[kit id]` (or null) draws each thing of that kit
  as its parts (turned, moved and scaled with the instance, in the kit's proxy colours), never merged with its neighbours.
  `hlod_bake` / `hlod_bake_dir` are these with no parts, unchanged.
