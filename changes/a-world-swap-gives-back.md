bump: minor
type: fix
**A world replaced at run time gives back what it held.** A game that swapped its map kept about 7 MB of heap
and 20 MB of GPU memory per swap, reachable from nothing: every actor it did not keep (with its own skeleton),
every scatter layer's record, chunk index, GPU-cull arena, impostor and crossed card, the distant-grass
carpet, the grass kind, and on the packages' side every Thing, animal, range and person record.

- `ludic.render3d`: `actor_hold(a)` and `actor_release_all()` - every actor on the stage released (its record
  back to the pool, its skin clone, tint and hidden-part tables given back) but the held ones, which stay.
  `actor_clear_all` (off the stage, nothing given back) stays for a caller that keeps its actors itself.
- `ludic.render3d`: a skin clone given back (`skin_clone_free`, `actor_release`) waits on its source skin
  and is the next `skin_clone` of it: a freed clone left a block per node and joint behind (its matrix
  views), so placing and letting go of figures grew without end.
- `ludic.render3d`: `scatter_clear_all` frees each layer whole - its chunk index, its GPU-cull buffers and
  merged meshes, its impostor, its crossed card when it built one, its LOD list and the record itself (the
  models in that list stay the loader's). `terrain_unload` and `terrain_set_carpet` let go of the carpet,
  `grass_kind_set` of the kind it replaces, `model_release` of a primitive's factors, and a texture load of
  its baked file's name.
- `ludic.things`: `things_clear` puts every record on the spare list, as a removal does.
- `ludic.wildlife`: `wildlife_clear` keeps every record for the next valley's animal of its species, key
  and all, so a game's drawing kept by key is that species' again; a valley's ranges are the next one's.
- `ludic.npc`: `npc_clear` keeps the walkers as records nobody is in and the posts for the next
  `npc_place`, out of any crowd.
- `ludic.anim`: a player bound to another rig gives back the last binding's tables, and a skin bound again
  its masks; `anim_oz_skel` frees the arrays ozz copied.
- `ludic.base`: `baked_path` is interned - one string a path however often a map is loaded.
