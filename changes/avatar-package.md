bump: minor
type: feat
**`ludic.avatar`: character customisation as data.** A package on `ludic.base` alone for what a person looks like, with no body, part or feature named in the logic.

- **Registries** - bodies (`@Asset("gltf")` / `@Node`), morphs with ranges (blend shapes or bone scale and offset), heritage presets blended by a mix, slots with layers, parts (`@Asset`, `@Node`, `@Material`, the bodies they fit, layering, `hides` and `conflicts`, level / flag / price unlocks), slot-level rules, palettes (`@Color`), decal zones and decals, premade outfits, and poses as `@Clip` rows - body motion is always a clip played through the animation graph, never procedural.
- **An avatar per player**: `avatar_set_body`, `_set_heritage`, `_set_morph`, `_set_part`, `_set_color`, `_add_decal`, `_apply_outfit`, `_save_outfit`, buying and granting, validation, and `avatar_randomize` from the package's own dice.
- **A stable id-based wire text** (`avatar_encode` / `avatar_decode`): ids, not indexes, so a registry may be reordered; a check letter; unknown or ineligible ids dropped and counted, a torn text changes nothing. The same encoding is the save section.
- **`AvatarView`**, the port a renderer and animation layer bind: body, parts in layer order, colours, morphs, decals and the pose clip, documented in the README as the contract.
- Facts (`AVATAR_CHANGED`, `_BOUGHT`, `_REFUSED`, `_FIXED`...), tests on a fixture kit.
