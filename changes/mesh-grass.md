bump: minor
type: feat
**Mesh-shader grass** — on a card with `VK_EXT_mesh_shader`, `r3d_mesh_grass(on)` draws each grass tile as one
mesh-shader dispatch sized to that tile's blades, and a blade that is culled emits no vertices at all.

- **`ludic-dev shaders`** — a variant whose first file is `*.mesh` compiles that stage as a Vulkan 1.3 mesh
  shader; its SPIR-V keeps the `.vert` name, so the manifest is unchanged.
- **The seam** — `gpu_has_mesh()` and `gpu_draw_mesh_tasks(x, y, z)`; a mesh program's pipeline has no
  vertex input and its bindings the mesh stage. The device enables `meshShader` and `maintenance4`.

Not yet faster: at 4K on an RTX 3070 Ti the grass pass takes 5.0 ms against the chunked path's 1.7, so
`gpu_feature_implemented(GF_MESH_GRASS)` stays false and a game should not offer it as a finished setting.
