bump: minor
type: feat
**HDR10 output on the Vulkan renderer** — `r3d_hdr(on)` asks for an ST 2084 / BT.2020 swapchain where the
display offers one.

The tonemap's HDR10 variant keeps the SDR picture up to a 200-nit paper white and rolls highlights on to
1000 nits; the overlay converts the interface to the same white; HDR metadata is set where the loader has
the command. The screen and LDR images are 10-bit while it is on, and screenshots refuse rather than write
a PQ image as SDR. OpenGL and the Vulkan SDR frame are unchanged. `R3D_HDR` overrides the setting.
