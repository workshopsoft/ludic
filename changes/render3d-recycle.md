bump: minor
type: fix
**A handle, a model and an actor let go come round again.** A texture or buffer freed gives its id
back and the next one made takes it, so the per-handle lists stop growing; `model_release` frees a
glTF model whole (its primitives, meshes, names, skeleton) and takes it out of `gltf_cached`'s
cache; and `actor_release` takes an actor off the stage and keeps its record for the next
`actor_new`. `examples/rendering/steady.ludic` holds 2000 actors placed and released at 0 bytes.
