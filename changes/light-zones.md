bump: minor
type: feat
**Light zones: boxes with no sun and their own ambient, for tunnels and other covered places.** `lightzone_add(st, x, y,
z, yaw, w, h, d, feather)` adds a turned box with a feathered edge; `lightzone_ambient` gives it an ambient colour and a
share of the sky; `lightzone_clear` and `lightzone_rebase` (the floating origin) manage them. Inside a zone every lit
shader drops the sun's direct light, bounce, leaf glow and sheen, water glitter and volumetric shafts. Up to 512 zones are
kept and the 8 nearest the camera are bound each frame; with none, the cost is one loop that exits at once. Shown and
measured by `lab/lightzone_lab.ludic` and `lab/lightzone_check.py`.
