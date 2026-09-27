bump: patch
type: fix
**The Vulkan renderer no longer leaks memory as it loads and draws.** Every texture upload
malloc'd a CPU copy of its pixels and never freed it (236 MB over the valley's boot, and again on
every model loaded later); the pixels are now converted straight into the mapped staging buffer.
The per-level and per-layer views made for mipmapped and layered targets outlived their texture,
and on MoltenVK a view keeps its Metal texture alive, so every rebuild of the screen-sized targets
left the last set in memory; a released texture now takes its views with it, and the cache is
keyed by numbers rather than a string built on every call. The Vulkan structs filled for a draw, a
pass, a barrier, a descriptor set or a buffer (about sixty call sites, several per draw) come from
a reused 1 MB scratch ring instead of a malloc each; the descriptor-set cache and the retired
buffer list are emptied and refilled rather than replaced; and on macOS the frame drains an
autorelease pool (`Vk.frame_pool()`), which MoltenVK and the layer rely on. `R3D_VK_PROF` now
also prints, every 120 frames, the Vulkan objects made and destroyed by kind and the length of
every cache, so a kind made each frame and never destroyed shows at once.
