bump: patch
type: fix
**A validation run sees the game's MoltenVK.** With a layer asked for, the loader was pinned to
ludic.render3d's MoltenVK only when the shell named no driver - but the SDK's setup-env.sh exports both
VK_DRIVER_FILES and VK_ICD_FILENAMES at the SDK's own MoltenVK, so a shell with one left set loaded that
one beside ours. The pin now overwrites VK_DRIVER_FILES and clears VK_ICD_FILENAMES; R3D_VK_ANY_DRIVER=1
keeps the shell's driver for a run that means to try another.
