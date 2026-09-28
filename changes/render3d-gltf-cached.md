bump: minor
type: feature
**`gltf_cached(dir, file, node)` loads a still model once.** The same directory, file and node asked
again hands back the model the first load made, found by comparing the names in place, so a game
that places props while it plays - a fish, a bobber, a sign an animal leaves - reads no file and
parses no document after the first. The model is shared by every actor drawing it and never
released. A model whose document is read after the load (ludic.anim's clips) still goes through
`gltf_load`.
