bump: patch
type: fix
**A texture made and freed leaves nothing behind.** Making a texture's image once kept four small
Vulkan create-info buffers, and a texture loaded from a .png kept the .dds path it looked for
beside it; both are given back now. `examples/rendering/steady.ludic` holds a glTF model loaded and
released at 0 bytes, and reads a frame's growth as the least of three windows after the device is
idle, so a busy machine beside it does not fail it.
