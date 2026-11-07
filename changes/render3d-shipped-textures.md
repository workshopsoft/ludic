bump: minor
type: feat
render3d takes textures a game ships as the GPU uses them. An image a `.glb` embeds may be a DX10 `.dds` (BC7, BC5 or BC4, its
whole mip chain): it goes to the GPU as it is, with nothing decoded or mipmapped at the load. `model_texture_exists(path)` answers
whether a map is there to load: its `.png`, or the `.dds` or padded cut-out a shipped build carries in its place. A pack may hold only
those, so a game asks this, not `Fs.exists`. `R3D_TEX_LOG=1` prints a line for each image a load reads, and how: a file's texture,
an image inside a `.glb`, or a PNG read for its samples. A bundler can use it to tell which PNGs to ship as `.dds`.
