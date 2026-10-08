bump: minor
type: change
**A world replaced at run time gives back what it held - and what is cleared or replaced is no longer the
caller's to keep pointing at.** A game that swapped its map kept about 7 MB of heap and 20 MB of GPU memory per
swap, reachable from nothing: every actor it did not keep (with its own skeleton), every scatter layer's record,
chunk index, GPU-cull arena, impostor and crossed card, the distant-grass carpet, the grass kind, and on the
packages' side every Thing, animal, range and person record.

**Behaviour changes - a caller must not keep a pointer across these:**

- `ludic.render3d` `actor_release_all()` releases every actor on the stage but those `actor_hold` marked: a
  released record is the next `actor_new`'s. (`actor_clear_all`, off the stage and nothing given back, stays.)
- `scatter_clear_all` frees each `Layer` record and its LOD list (the list `layer_set_lods` was handed; the models
  in it stay the loader's), its impostor and a crossed card it built: a layer pointer is dead after it.
- `grass_kind_set` takes ownership of the kind it is handed and frees the one it replaces.
- `model_release` frees each primitive's factors (`Prim.fac`): a primitive owns its own (the tile-map ground's
  patches each copy the ground's now).
- `terrain_unload` and a second `terrain_set_carpet` free the carpet texture they held.
- `ludic.things` `things_clear` puts every record on the spare list, as a removal does, and the next placement
  reuses it.
- `ludic.wildlife` `wildlife_clear` keeps every record for the next valley's animal of its species - key and all -
  and a valley's ranges are the next one's (`wildlife_ranges_setup`).
- `ludic.npc` `npc_clear` leaves the walkers in `npc_walkers` as inactive records (out of any crowd) for the next
  `npc_spawn`, and the posts for the next `npc_place`: who is about is who is `active`.
- `ludic.base` `baked_path` returns an interned string: never free it.

**Fixes:**

- `ludic.render3d`: a skin clone given back (`skin_clone_free`, `actor_release`) waits on its source skin and is
  the next `skin_clone` of it (a freed clone left a block per node and joint behind - its matrix views); given back
  twice it still waits once. A texture load frees its baked file's name.
- `ludic.anim`: a player bound to another rig gives back the last binding's tables, and a skin bound again its
  masks; `anim_oz_skel` frees the arrays ozz copied.
