bump: patch
type: fix
**Every program render3d can ask for is compiled.** heightgen with no survey and with SMOOTH were never in
variants.list, so a smoothed or noise-only terrain (examples/rendering/chunks, smooth, reload) had no
height field on Vulkan - silently until render3d's faults were made loud. Both are compiled now (61
programs). A program's run-time defines are pure functions in program_defs.ludic (the height field, the
ground's tiers, the blades), and tests/manifest_test reads every r3d_program / gpu_program / ac_prog_new call
in render3d's source, holds each literal one and every value of each computed one to the shipped manifest,
and fails a new computed call site until it is given its function.
