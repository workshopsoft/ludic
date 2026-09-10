bump: minor
type: feat
**Asset packs.** `ludic pack` writes every asset a game opens into one `.lpak`
beside the binary, and the runtime mounts it before `main`. Nothing about how a
game is written changes: the pack is spliced in at `file_open`, the one place
every asset comes through, so `gltf_load`, `tex_load`, `Audio.load`,
`Fs.read_text` and the renderer's own shader loads all find it without knowing
it exists. `Fs.exists` and `Fs.size` consult the packs too. Entries are stored
rather than compressed and the pack is `mmap`'d, so 165 MB of terrain costs one
syscall at startup and pages in only what is touched. Several packs can be
mounted in order, and a later one shadows an earlier one - which is how a patch
replaces individual files without rewriting the base pack. See `docs/SHIPPING.md`.
