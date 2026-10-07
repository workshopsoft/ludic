bump: patch
type: fix
**GPU-culled trees no longer draw in garbage colours on Vulkan.** A shader input a mesh does not feed (`a_col` on a
model with no COLOR_0, which since the vertex-colour change is every kit tree) read a shared buffer of zeros bound per
INSTANCE at 16 bytes each, 64 KB in all: room for 4096 instances. The GPU-culled scatter layers draw each LOD bucket
from `firstInstance = level x layer count`, so on a layer of 2538 trees everything from the middle of level 1 on read
past the buffer; MoltenVK does not bound vertex fetches, and the mid-distance conifers drew magenta, blue and green.
The zeros binding now has a stride of 0 (`GVK_ZERO_STRIDE`): every vertex of every instance reads the first vec4,
wherever a draw's instances start, and the buffer is 256 bytes. `R3D_GPU_CULL=0` had always drawn them right.
`tests/zero_feed_test` holds the stride and that the last bucket of a large layer reads inside the buffer.
