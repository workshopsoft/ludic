bump: patch
type: fix
**A frame that draws more than any before no longer grows the heap on the Mac.** MoltenVK's command
pooling kept every command object a frame had ever recorded - about 650 bytes for each draw beyond the
busiest frame so far, for as long as the game ran. render3d turns it off
(`MVK_CONFIG_USE_COMMAND_POOLING=0`, unless the environment already says otherwise) before the first
Vulkan call; the objects are made and freed with their command buffer, at no measured cost.
`examples/rendering/steady.ludic` ramps a frame from 20 to 200 actors and fails on what pooling left.
