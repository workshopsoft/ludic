# ludic.avatar

Character customisation as data: base bodies, named morphs with ranges, heritage presets blended by a
mix, parts by slot (layered, hiding and conflicting by rule), palettes, decals in zones, premade and saved
outfits, unlock rules, and one avatar per player with validation, randomize from its own dice, a compact
id-based text for the network and the save, and a port the renderer and animation layer bind. Uses
[`ludic.base`](../ludic.base/README.md) and nothing else. No part, body or feature is named in the logic.

```ludic
import "ludic.avatar"
```

The package holds no mesh and moves no bone. It decides WHAT a person looks like and says it through
`AvatarView`; a game binds that to `ludic.render3d` and `ludic.anim`.

## The data

Every table is an open, append-only registry (`def` them in code or `def AvatarParts from "parts.lres"`).
Every row carries a stable **`id`** - never reused, never changed. The wire text and the save name rows by
id, so a registry may be reordered or grow and a stored avatar still reads.

| Registry | Prefix | A row is |
| --- | --- | --- |
| `AvatarBodies` | `AVB_` | a base rig: `@Asset("gltf") model`, `@Node` `root` and `head` |
| `AvatarMorphs` | `AVM_` | a named morph: `group` (face, body), `kind` (blend_shape, bone_scale, bone_offset), `target` (the blend shape or bone), `axis`, `lo` / `hi` / `start` in permille, the bodies it exists on |
| `AvatarHeritage` | `AVH_` | a parent preset: `morphs` and `values` side by side; an avatar blends two |
| `AvatarSlots` | `AVS_` | a place worn: `layer` (stack order), `required`, `start` part, `palette` |
| `AvatarParts` | `AVP_` | a thing worn: `slot`, `@Asset("gltf") mesh` + `@Node` + `@Material` tint, `bodies` it fits, `layer`, `hides` (slots), `covers` (body regions: primitive names of the body model), `conflicts` (parts), `palette`, unlock (`level`, `flag`, `price`) |
| `AvatarRules` | `AVR_` | a slot-level rule: while `slot` (and `part`, or -1 any) is worn, `other` is `hides` (not drawn) or `conflicts` (cannot be worn) |
| `AvatarPalettes` | `AVC_` | `@Color` `colors` a slot or part offers |
| `AvatarZones` | `AVZ_` | where decals go: the `node` they project onto, how many fit (`max`) |
| `AvatarDecals` | `AVD_` | a tattoo or paint: `zone`, `@Asset("png") texture`, default `u` `v` `size` `rot`, bodies, unlock |
| `AvatarOutfits` | `AVO_` | a premade set: `parts` and `colors` side by side, bodies, unlock covering every part |
| `AvatarPoses` | `AVA_` | a body animation: `@Asset("gltf") model` and `@Clip(model) clip`, `kind` (idle, emote, pose), `loop`, bodies |

**Motion is always a clip.** The package never moves a bone: an idle in the creator, an emote, a held pose
are `AvatarPoses` rows naming a clip keyed in Blender or taken from Mixamo, and the view port hands the
clip to whatever plays it (an `ludic.anim` AnimSet through the animation graph). Nothing procedural.
Morphs are blend shapes or bone scale/offset values the renderer applies as numbers; that is data, not motion.

Morph values are whole permille, -1000 to 1000. What a morph comes to is heritage's blend (two parents, by
`mix`) plus the player's own **delta**, held to the row's `lo`..`hi`: `avatar_set_morph(who, morph, value)`
takes the value wanted and keeps the delta, so changing a parent moves the face and keeps the player's tweaks.

**Unlocks.** A part, decal or outfit is usable when the world's `level(who)` reaches its `level`, `flag(who,
flag)` holds, and - when it has a `price` - it was bought (`avatar_buy`, through the purse) or granted
(`avatar_grant`). Premade outfits cover their parts; a part inside one needs no unlock of its own.

**Conflicts and hiding.** Wearing a part that conflicts (by its `conflicts`, the other's, or an `AvatarRules`
row) takes the other off - the later choice wins - and says so with a fact. `hides` leaves a part chosen but
undrawn (`avatar_visible`, and the view skips it). A required slot is refilled from its `start`, else the
first free part that fits the body.

## Ports

```ludic
export port AvatarWorld {   # all defaulted: no gate, every purchase paid, seed 1
  level: fn(int) -> int;  flag: fn(int, string) -> bool
  spend: fn(int, int) -> bool          # (who, price): the wallet
  seed: fn() -> int
}
export port AvatarView {    # all optional: what a renderer / anim layer binds
  begin: fn(int) -> void
  body: fn(int, string, string) -> void                       # (who, model, root)
  part: fn(int, int, string, string, int) -> void             # (who, slot, mesh, attach node, draw order)
  cover: fn(int, string) -> void                              # (who, body region): a drawn part covers it; hide that part of the body
  color: fn(int, int, string, int) -> void                    # (who, slot, material, rgb)
  morph: fn(int, int, string, int, float) -> void             # (who, kind 0 blend / 1 bone scale / 2 bone offset, target, axis, -1..1)
  decal: fn(int, string, string, float, float, float, float) -> void   # (who, zone node, texture, u, v, size, rot)
  pose: fn(int, string, string, bool) -> void                 # (who, model, clip, loop)
  end: fn(int) -> void
}
```

**The renderer contract.** `avatar_apply(who)` (or `avatar_tick`, which applies every avatar changed since
the last frame) calls, in this order: `begin`; `body`; `part` then `color` for each visible slot, lowest
`layer` first; `morph` for every morph that exists on the body; `decal` for each decal; `pose` when one is
chosen; `end`. A binder on `render3d` loads the body's model once per `model`, skins each `part`'s mesh to the
body's skeleton by node name (`ludic.anim`'s `skin_joint`) and attaches it at `node`, sets the material named
`color`'s `material` to `rgb`, drives blend shapes by `target` and scales or offsets bones by `target` and
`axis` (the value is already -1..1; a bone kind multiplies by the morph's `scale`), projects each decal
texture onto the zone `node` at (u, v) of its size and turn, and starts the `pose` clip through the game's
animation graph. `begin` means: drop everything bound for this player - a full rebuild each time keeps the
binder stateless.

## Verbs

| | |
| --- | --- |
| `avatar_new(who, body)`, `avatar_remove`, `avatar_has`, `avatar_count`, `avatar_who_at` | a player's avatar, made (or started over: owned things stay) |
| `avatar_set_body`, `avatar_set_heritage(who, mother, father, mix)`, `avatar_set_morph`, `avatar_morph` | the body, the parents, a morph, what a morph comes to |
| `avatar_set_part`, `avatar_clear_slot`, `avatar_part_in`, `avatar_visible`, `avatar_set_color`, `avatar_color_in`, `avatar_color_rgb` | what is worn |
| `avatar_add_decal(who, decal, u, v, size, rot)`, `avatar_add_decal_default`, `avatar_remove_decal`, `avatar_decal_*` | tattoos |
| `avatar_apply_outfit`, `avatar_save_outfit(who, slot, name)`, `avatar_wear_saved`, `avatar_saved_used`, `avatar_saved_name`, `avatar_delete_saved` | premade outfits and eight saved ones a player keeps |
| `avatar_unlocked`, `avatar_owns`, `avatar_grant`, `avatar_buy` | unlocks (kind `AVK_PART`, `AVK_DECAL`, `AVK_OUTFIT`) |
| `avatar_set_pose`, `avatar_pose` | the clip the view plays |
| `avatar_randomize(who, what)` | `AVATAR_RAND_FACE`, `_BODY`, `_HERITAGE`, `_PARTS`, `_COLORS`, `_ALL`: from the package's own `Rng`; only what the player may wear |
| `avatar_apply`, `avatar_dirty`, `avatar_tick` | the view |
| `avatar_encode(who) -> string`, `avatar_decode(who, text, checked) -> int`, `avatar_validate(who, checked) -> int` | the wire text (below) |
| `avatar_reset`, `avatar_save`, `avatar_load`, `avatar_system()` | `"avatar"`, `PH_PRESENT`; its save section |

Every verb that can say no returns false (or -1) and leaves `avatar_why()` = `AVATAR_BAD_ID`, `_WRONG_SLOT`,
`_WRONG_BODY`, `_LOCKED`, `_NOT_OWNED`, `_FULL`, `_BROKE`, `_REQUIRED`, `_BAD_TEXT` or `_NO_AVATAR`.

## Facts

`avatar_facts()` is a `Queue<AvatarFact { what, who, kind, index, value, reason }>`: `AVATAR_CHANGED`
(`kind` `AVK_BODY` / `_HERITAGE` / `_MORPH` / `_PART` / `_COLOR` / `_DECAL` / `_OUTFIT` / `_ALL`, the row
`index`, a `value`), `AVATAR_BOUGHT` (value = price), `AVATAR_REFUSED` (reason), `AVATAR_FIXED` (a repair dropped
`value` things), `AVATAR_OUTFIT_SAVED`, `AVATAR_OUTFIT_WORN`, `AVATAR_POSED`.

## The wire text

`avatar_encode(who)` is a short string for the network: version, body id, the parents' ids, the mix, the
non-zero morph deltas as (id, delta), the worn parts as (slot id, part id, colour), the decals as (id, u, v,
size, rot) - every number a zigzag varint in 5-bit groups, one letter of a 64-letter alphabet each, and a check
letter at the end. A typical avatar is 40 to 80 characters. It names rows by `id`, never by index.

`avatar_decode(who, text, checked)` replaces what the player chose, and returns how many things were dropped
(an id no longer known, a part that does not fit the body, a full zone, and - when `checked` - what the
player may not wear yet), or -1 and changes nothing when the text is torn (cut, a stray or changed character,
a wrong check letter). A peer decodes what the host sent unchecked; the host decodes a client's claim
`checked`. `avatar_validate` is the same pass over the avatar already held, for a registry that lost a row or
a level that dropped.

## Multiplayer

The host owns avatars. A client's UI calls the verbs on its own copy for the creator's preview; the choice
it commits is `avatar_encode` sent to the host, which calls `avatar_decode(who, text, true)`, buys what must
be bought, and replicates the validated `avatar_encode` to everyone else, each of whom calls
`avatar_decode(who, text, false)` and lets `avatar_tick` apply it. The save section `avatar` (version 1,
per player `p<who>` text, owned ids, saved outfits) is written by whoever keeps the character.

## Tests

`ludic test packages/ludic.avatar`: the registries and ids, a new avatar, morph ranges and heritage blending,
the unlock rules and buying, conflicts and hiding, required slots, a body change, colours, decal zones, premade
and saved outfits, randomize (deterministic and valid), the wire text (whole, torn, checked), the view port's
order and pose, facts and the save.
