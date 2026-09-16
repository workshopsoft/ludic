bump: minor
type: feat
**Renderer switches stay out of shipped games** — every `R3D_*` environment switch in
`ludic.render3d` (debug views, feature kills, file writers, hardware fakes, the Windows
feature overrides) now goes through one gate: a headless build honours them as before, a
windowed build only when `R3D_DEV` is set to anything but `0`. See `docs/SHIPPING.md`.
