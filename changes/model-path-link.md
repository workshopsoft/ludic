bump: patch
type: docs
**One way to name a model.** A record drawn as a model carries `@Asset("gltf") model` and `@Node(model) node`; the path is the link a game's own
model table matches on, not a key convention in code. Documented in PACKAGES.md ("Naming a model"); `PedLook` (ludic.crowd) gains the pair,
the rest (`CarModel`, `Weapon`, `Attachment`, `AvatarBody`, `VehicleSpec`, `FurnitureItem`, ludic.city) already had it.
