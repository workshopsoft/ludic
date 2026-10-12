bump: minor
type: feat
**Box kits: one unit mesh drawn at each instance's own width, depth and height.** A kit whose vertices carry
`_ANCHOR` (VEC4: sx, sz, sh, sd) and `_OFFSET` (VEC3, metres) beside `POSITION` is placed at
`x = sx w + ox`, `z = sz d + oz`, `y = sh h + sd d + oy`, so a parapet stays 1 m high and 0.25 m thick and a gable
stays at 30 degrees at any size, while one mesh draws a whole street (`kitbox.ludic`: `kitbox_new`, `kitbox_add`,
`kitbox_bounds`, `kitbox_card`; `kitbox_read` reads the anchors from a glb). A game's bake registers them with
`kitbake_box(kb, model, node, box)` before `city_cells_bake`, whose signature is unchanged; the culling sphere, the
impostor card and the HLOD box come from the kit's anchors, so they match what `kit.vert` draws. `GPU_MAX_ATTRS` goes
from 8 to 12 (anchors on locations 8 and 9), and kit instance records are 4 vec4s (`kgpu` reads 20 floats an instance
and writes 16).

**Breaking (file format):** a cell holding a box instance is written as **LWC version 2** (box columns); older readers
refuse it. Version 1 cells read unchanged. Rebuild the tools and rebake cells after updating.
