bump: minor
type: feat
**`ludic.physics`: Jolt Physics as a package.** Shapes (box, sphere, capsule, cylinder, a
boulder's dome, a heightfield, a mesh), still, kinematic and dynamic bodies that can be removed
for real, rays, a foot's landing height, a push out of what a body stands in, overlaps, buoyancy
against a `PhysWater` port with its current, and hard contacts and splashes as facts - stepped at a
fixed 1/60 s, deterministic across machines. Jolt v5.6.0 is built here from its pinned tag
(`native/build.sh`) through the phase-15 route.
