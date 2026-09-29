bump: patch
type: fix
**One MoltenVK in a process.** On a Mac with the Vulkan SDK installed, the runtime opened the SDK's loader
(/usr/local/lib/libvulkan.1.dylib) before MoltenVK, and the loader loaded the SDK's own MoltenVK as its
driver - beside ludic.render3d's, which every program is linked against: two copies, each with its pools,
and the program drew through the SDK's ("MVKBlockObserver is implemented in both"). MoltenVK is opened
first now (dlopen hands back the linked copy), and the loader only when a layer is asked for
(VK_INSTANCE_LAYERS, VK_LOADER_LAYERS_ENABLE, R3D_VK_LOADER) - then pinned to ludic.render3d's MoltenVK
through VK_DRIVER_FILES and lib/macos-arm64/MoltenVK_icd.json, unless the caller named a driver.
examples/rendering/steady.ludic's stream round warms up over 300 cells and takes the least of three
windows of 150, as the frame round does: one sample of it read +75 KB on a run whose twin read -5 KB.
