bump: patch
type: fix
**Vulkan's host allocations can be counted, a pipeline built in play keeps nothing, and actors come
from a pool made at start-up.** With `R3D_ALLOC_VK=1` render3d hands one set of
`VkAllocationCallbacks` to every create and destroy; the runtime counts live bytes, the peak and
bytes per allocation scope (`lvk_ac_bytes`, `lvk_ac_peak`, `lvk_ac_scope_bytes`, `Vk.alloc_bytes`)
for the memory fence to read. MoltenVK 1.4.2 routes few of its own objects through them. A pipeline
made the first time a variant is drawn frees its seventeen create infos. `actor_init` makes 512 actor
records, so an actor first placed in play takes one instead of allocating.
