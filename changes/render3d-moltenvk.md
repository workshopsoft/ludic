bump: minor
type: feature
**ludic.render3d carries MoltenVK, so a Mac program has its Vulkan driver without the SDK.**
`native/build.sh` builds MoltenVK from a pinned tag (v1.4.2, its SHA-256 checked; its own
dependencies at the commits its ExternalRevisions pins), thinned to arm64 and signed, into
`lib/macos-arm64/libMoltenVK.dylib`, with its licence in `native/LICENSE-MoltenVK`. Every program
that imports render3d links it through its rpath - the package's lib/ while developing,
`Contents/Frameworks` in a bundle, where `ludic bundle` puts and signs it - and the loader
(`vk_mac.ll`) now also looks for `@rpath/libMoltenVK.dylib`. An SDK loader found first still wins,
so the validation layer can be stacked in development. `gpu_is_gl()` is gone.
