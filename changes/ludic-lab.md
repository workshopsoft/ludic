bump: minor
type: feature
**ludic.lab - the visual lab as a package.** A scene is an entry in the open registry `LabScenes`,
shown on a plate: a flat lit disc, a small sky of the package's own with the sun at one hour, and a
frame clock. Headless, each of its cameras (`lab_shot`, `lab_shot_at`) settles and is written as
`build/lab/<scene>/<shot>.png`; in a window N and P step through them. `tools/lab/run.sh` and
`sheet.py` make a contact sheet. ludic.render3d gains `r3d_plate_mode(true)` - no terrain, grass or
water is made - and `r3d_sky_path`; the example scene takes about 120 MB resident. `quit()` in a
program with no frame loop no longer fails to link.
