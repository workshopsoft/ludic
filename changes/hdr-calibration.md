bump: patch
type: feat
**HDR calibration, and two HDR fixes** — the HDR10 picture follows the player's display instead of one fixed curve.

- **`r3d_hdr_calibrate(peak, paper, black)`** — nits as float bits: the brightest the display shows (100-10000),
  where the picture's and the interface's white sit (80-1000, never above the peak) and how far the darkest shade is
  lifted (0-5, fading out by paper white). The tonemap's and the overlay's HDR10 variants read them, and the display's
  HDR metadata is sent again with the new peak. The defaults are the old constants: 1000, 200 and 0.
- **`ov_hdr_nits(nits)` / `ov_hdr_paper()`** — what the overlay draws next is at that many nits on an HDR10 frame,
  for a calibration screen's test patches; it closes the batch so far. No effect on an SDR frame.
- **Fixed: a crash toggling HDR on the Vulkan renderer.** `gpu_caps_probe()` made and destroyed a second Vulkan
  instance under NVIDIA Streamline's interposer; the next swapchain rebuild then called through a pointer that
  instance had left behind, at address 0. With the Vulkan renderer running, the probe asks its instance instead.
- **Fixed: yellow read as red in HDR.** The overlay drew sRGB values straight into the HDR10 swapchain (it now has an
  HDR10 variant, chosen while `gpu_hdr_active()`), and the tonemap extended highlights per channel, which boosted a
  bright yellow's red far more than its green; it now brightens the graded colour by one factor.
