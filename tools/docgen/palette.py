#!/usr/bin/env python3
# Single source of truth for Ludic's named color palette.
# Emits: selfhost/emit_color.ludic (compiler lookup) and palette.json (docs).
import json, sys, os

# (Name, 0xRRGGBB, group). Names are PascalCase, unique. >200 entries.
PALETTE = [
  # ---- Whites & off-whites ----
  ("White",          0xFFFFFF, "Whites"),
  ("Snow",           0xFFFAFA, "Whites"),
  ("Ivory",          0xFFFFF0, "Whites"),
  ("EggShellWhite",  0xF0EAD6, "Whites"),
  ("FloralWhite",    0xFFFAF0, "Whites"),
  ("SeaShell",       0xFFF5EE, "Whites"),
  ("Linen",          0xFAF0E6, "Whites"),
  ("AntiqueWhite",   0xFAEBD7, "Whites"),
  ("OldLace",        0xFDF5E6, "Whites"),
  ("Beige",          0xF5F5DC, "Whites"),
  ("Cream",          0xFFFDD0, "Whites"),
  ("Honeydew",       0xF0FFF0, "Whites"),
  ("MintCream",      0xF5FFFA, "Whites"),
  ("Azure",          0xF0FFFF, "Whites"),
  ("AliceBlue",      0xF0F8FF, "Whites"),
  ("GhostWhite",     0xF8F8FF, "Whites"),
  ("WhiteSmoke",     0xF5F5F5, "Whites"),
  ("Lavender",       0xE6E6FA, "Whites"),
  ("Bone",           0xE3DAC9, "Whites"),
  ("Parchment",      0xF1E9D2, "Whites"),

  # ---- Grays & neutrals ----
  ("Gainsboro",      0xDCDCDC, "Grays"),
  ("LightGray",      0xD3D3D3, "Grays"),
  ("Silver",         0xC0C0C0, "Grays"),
  ("Ash",            0xB2BEB5, "Grays"),
  ("DarkGray",       0xA9A9A9, "Grays"),
  ("Gray",           0x808080, "Grays"),
  ("DimGray",        0x696969, "Grays"),
  ("Nickel",         0x727472, "Grays"),
  ("Slate",          0x708090, "Grays"),
  ("SlateGray",      0x708090, "Grays"),
  ("LightSlateGray", 0x778899, "Grays"),
  ("Gunmetal",       0x2A3439, "Grays"),
  ("Charcoal",       0x36454F, "Grays"),
  ("Graphite",       0x1C1C1C, "Grays"),
  ("Onyx",           0x353839, "Grays"),
  ("Jet",            0x343434, "Grays"),
  ("Black",          0x000000, "Grays"),
  ("EerieBlack",     0x1B1B1B, "Grays"),
  ("RaisinBlack",    0x242124, "Grays"),
  ("Ebony",          0x555D50, "Grays"),

  # ---- Reds ----
  ("Red",            0xFF0000, "Reds"),
  ("Crimson",        0xDC143C, "Reds"),
  ("Scarlet",        0xFF2400, "Reds"),
  ("Vermilion",      0xE34234, "Reds"),
  ("FireBrick",      0xB22222, "Reds"),
  ("Cinnabar",       0xE44D2E, "Reds"),
  ("DarkRed",        0x8B0000, "Reds"),
  ("Maroon",         0x800000, "Reds"),
  ("Ruby",           0xE0115F,  "Reds"),
  ("Cardinal",       0xC41E3A, "Reds"),
  ("IndianRed",      0xCD5C5C, "Reds"),
  ("Rust",           0xB7410E, "Reds"),
  ("Sangria",        0x92000A, "Reds"),
  ("Redwood",        0xA45A52, "Reds"),
  ("Cerise",         0xDE3163, "Reds"),
  ("Amaranth",       0xE52B50, "Reds"),
  ("Carmine",        0x960018, "Reds"),
  ("Chestnut",       0x954535, "Reds"),
  ("Brick",          0xCB4154, "Reds"),
  ("TerraCotta",     0xE2725B, "Reds"),

  # ---- Pinks ----
  ("Pink",           0xFFC0CB, "Pinks"),
  ("LightPink",      0xFFB6C1, "Pinks"),
  ("HotPink",        0xFF69B4, "Pinks"),
  ("DeepPink",       0xFF1493, "Pinks"),
  ("PaleVioletRed",  0xDB7093, "Pinks"),
  ("Rose",           0xFF007F, "Pinks"),
  ("Blush",          0xDE5D83, "Pinks"),
  ("Salmon",         0xFA8072, "Pinks"),
  ("LightSalmon",    0xFFA07A, "Pinks"),
  ("DarkSalmon",     0xE9967A, "Pinks"),
  ("Coral",          0xFF7F50, "Pinks"),
  ("Watermelon",     0xFC6C85, "Pinks"),
  ("Flamingo",       0xFC8EAC, "Pinks"),
  ("Bubblegum",      0xFFC1CC, "Pinks"),
  ("Fuchsia",        0xFF00FF, "Pinks"),
  ("Magenta",        0xFF00FF, "Pinks"),
  ("Mauve",          0xE0B0FF, "Pinks"),
  ("Puce",           0xCC8899, "Pinks"),
  ("Thistle",        0xD8BFD8, "Pinks"),
  ("Orchid",         0xDA70D6, "Pinks"),

  # ---- Oranges ----
  ("Orange",         0xFFA500, "Oranges"),
  ("DarkOrange",     0xFF8C00, "Oranges"),
  ("Tangerine",      0xF28500, "Oranges"),
  ("Pumpkin",        0xFF7518, "Oranges"),
  ("Apricot",        0xFBCEB1, "Oranges"),
  ("Peach",          0xFFE5B4, "Oranges"),
  ("Cantaloupe",     0xFFA62B, "Oranges"),
  ("Amber",          0xFFBF00, "Oranges"),
  ("Bronze",         0xCD7F32, "Oranges"),
  ("Copper",         0xB87333, "Oranges"),
  ("Marigold",       0xEAA221, "Oranges"),
  ("Carrot",         0xED9121, "Oranges"),
  ("Persimmon",      0xEC5800, "Oranges"),
  ("Papaya",         0xFF9E2C, "Oranges"),
  ("Sunset",         0xFAD6A5, "Oranges"),

  # ---- Yellows ----
  ("Yellow",         0xFFFF00, "Yellows"),
  ("LightYellow",    0xFFFFE0, "Yellows"),
  ("Gold",           0xFFD700, "Yellows"),
  ("Goldenrod",      0xDAA520, "Yellows"),
  ("Lemon",          0xFFF700, "Yellows"),
  ("Canary",         0xFFEF00, "Yellows"),
  ("Mustard",        0xFFDB58, "Yellows"),
  ("Flax",           0xEEDC82, "Yellows"),
  ("Wheat",          0xF5DEB3, "Yellows"),
  ("Corn",           0xFBEC5D, "Yellows"),
  ("Dandelion",      0xF0E130, "Yellows"),
  ("Saffron",        0xF4C430, "Yellows"),
  ("Khaki",          0xF0E68C, "Yellows"),
  ("DarkKhaki",      0xBDB76B, "Yellows"),
  ("Straw",          0xE4D96F, "Yellows"),

  # ---- Browns ----
  ("Brown",          0x8B4513, "Browns"),
  ("SaddleBrown",    0x8B4513, "Browns"),
  ("Sienna",         0xA0522D, "Browns"),
  ("Chocolate",      0xD2691E, "Browns"),
  ("Peru",           0xCD853F, "Browns"),
  ("Tan",            0xD2B48C, "Browns"),
  ("BurlyWood",      0xDEB887, "Browns"),
  ("Sand",           0xC2B280, "Browns"),
  ("Coffee",         0x6F4E37, "Browns"),
  ("Espresso",       0x4B3621, "Browns"),
  ("Mahogany",       0xC04000, "Browns"),
  ("Walnut",         0x773F1A, "Browns"),
  ("Umber",          0x635147, "Browns"),
  ("Sepia",          0x704214, "Browns"),
  ("Taupe",          0x483C32, "Browns"),
  ("Fawn",           0xE5AA70, "Browns"),
  ("Caramel",        0xC68E17, "Browns"),
  ("Cocoa",          0xD2691E, "Browns"),
  ("Hazel",          0x8E7618, "Browns"),
  ("Wenge",          0x645452, "Browns"),

  # ---- Greens ----
  ("Green",          0x008000, "Greens"),
  ("Lime",           0x00FF00, "Greens"),
  ("LimeGreen",      0x32CD32, "Greens"),
  ("LawnGreen",      0x7CFC00, "Greens"),
  ("Chartreuse",     0x7FFF00, "Greens"),
  ("GreenYellow",    0xADFF2F, "Greens"),
  ("SpringGreen",    0x00FF7F, "Greens"),
  ("MintGreen",      0x98FF98, "Greens"),
  ("SeaGreen",       0x2E8B57, "Greens"),
  ("MediumSeaGreen", 0x3CB371, "Greens"),
  ("ForestGreen",    0x228B22, "Greens"),
  ("DarkGreen",      0x006400, "Greens"),
  ("OliveDrab",      0x6B8E23, "Greens"),
  ("Olive",          0x808000, "Greens"),
  ("Moss",           0x8A9A5B, "Greens"),
  ("Fern",           0x4F7942, "Greens"),
  ("Emerald",        0x50C878, "Greens"),
  ("Jade",           0x00A86B, "Greens"),
  ("Malachite",      0x0BDA51, "Greens"),
  ("Shamrock",       0x009E60, "Greens"),
  ("Pistachio",      0x93C572, "Greens"),
  ("Avocado",        0x568203, "Greens"),
  ("Pine",           0x01796F, "Greens"),
  ("Sage",           0x9CAF88, "Greens"),
  ("Kelly",          0x4CBB17, "Greens"),
  ("Hunter",         0x355E3B, "Greens"),
  ("Basil",          0x579229, "Greens"),
  ("Clover",         0x2E8B57, "Greens"),
  ("Juniper",        0x6D9A79, "Greens"),
  ("Neon",           0x39FF14, "Greens"),

  # ---- Cyans / teals ----
  ("Cyan",           0x00FFFF, "Cyans"),
  ("Aqua",           0x00FFFF, "Cyans"),
  ("LightCyan",      0xE0FFFF, "Cyans"),
  ("PaleTurquoise",  0xAFEEEE, "Cyans"),
  ("Aquamarine",     0x7FFFD4, "Cyans"),
  ("Turquoise",      0x40E0D0, "Cyans"),
  ("MediumTurquoise",0x48D1CC, "Cyans"),
  ("DarkTurquoise",  0x00CED1, "Cyans"),
  ("Teal",           0x008080, "Cyans"),
  ("DarkCyan",       0x008B8B, "Cyans"),
  ("CadetBlue",      0x5F9EA0, "Cyans"),
  ("Lagoon",         0x018E8E, "Cyans"),
  ("Seafoam",        0x93E9BE, "Cyans"),
  ("Cerulean",       0x007BA7, "Cyans"),
  ("SkyBlueLight",   0x80DAEB, "Cyans"),
  ("Robin",          0x00CCCC, "Cyans"),
  ("Verdigris",      0x43B3AE, "Cyans"),
  ("Celadon",        0xACE1AF, "Cyans"),

  # ---- Blues ----
  ("Blue",           0x0000FF, "Blues"),
  ("LightBlue",      0xADD8E6, "Blues"),
  ("PowderBlue",     0xB0E0E6, "Blues"),
  ("SkyBlue",        0x87CEEB, "Blues"),
  ("LightSkyBlue",   0x87CEFA, "Blues"),
  ("DeepSkyBlue",    0x00BFFF, "Blues"),
  ("DodgerBlue",     0x1E90FF, "Blues"),
  ("CornflowerBlue", 0x6495ED, "Blues"),
  ("SteelBlue",      0x4682B4, "Blues"),
  ("RoyalBlue",      0x4169E1, "Blues"),
  ("MediumBlue",     0x0000CD, "Blues"),
  ("DarkBlue",       0x00008B, "Blues"),
  ("Navy",           0x000080, "Blues"),
  ("MidnightBlue",   0x191970, "Blues"),
  ("Cobalt",         0x0047AB, "Blues"),
  ("Sapphire",       0x0F52BA, "Blues"),
  ("Denim",          0x1560BD, "Blues"),
  ("Indigo",         0x4B0082, "Blues"),
  ("Prussian",       0x003153, "Blues"),
  ("Ultramarine",    0x3F00FF, "Blues"),
  ("Periwinkle",     0xCCCCFF, "Blues"),
  ("Iris",           0x5A4FCF, "Blues"),
  ("Glaucous",       0x6082B6, "Blues"),
  ("Zaffre",         0x0014A8, "Blues"),
  ("Berry",          0x2E2D88, "Blues"),

  # ---- Purples ----
  ("Purple",         0x800080, "Purples"),
  ("Violet",         0xEE82EE, "Purples"),
  ("DarkViolet",     0x9400D3, "Purples"),
  ("BlueViolet",     0x8A2BE2, "Purples"),
  ("MediumPurple",   0x9370DB, "Purples"),
  ("Amethyst",       0x9966CC, "Purples"),
  ("Plum",           0x8E4585, "Purples"),
  ("Eggplant",       0x614051, "Purples"),
  ("Grape",          0x6F2DA8, "Purples"),
  ("Wine",           0x722F37, "Purples"),
  ("Mulberry",       0xC54B8C, "Purples"),
  ("Lilac",          0xC8A2C8, "Purples"),
  ("Wisteria",       0xC9A0DC, "Purples"),
  ("Heliotrope",     0xDF73FF, "Purples"),
  ("Byzantium",      0x702963, "Purples"),
  ("Tyrian",         0x66023C, "Purples"),
  ("RebeccaPurple",  0x663399, "Purples"),
  ("Orchid2",        0xAF69EF, "Purples"),
]

def guard_check():
  names = [p[0] for p in PALETTE]
  dup = set(n for n in names if names.count(n) > 1)
  if dup:
    print("DUPLICATE NAMES:", dup, file=sys.stderr); sys.exit(1)
  return names

def emit_ludic(path):
  lines = []
  lines.append("# ============================================================================")
  lines.append("# emit_color.ludic — the named-color palette, resolved at compile time.")
  lines.append("#")
  lines.append("# `Color.Name` in a game lowers to a plain 0xRRGGBB int here: no runtime cost,")
  lines.append("# no allocation, identical codegen to writing the hex by hand. Unknown names are")
  lines.append("# a compile error (color_lookup returns -1, which emit_expr reports).")
  lines.append("#")
  lines.append("# GENERATED by scratchpad/palette.py from the single source-of-truth palette.")
  lines.append("# Edit the palette there and regenerate; do not hand-edit this file.")
  lines.append("# ============================================================================")
  lines.append("")
  lines.append("fn color_lookup(name: ptr) -> int {")
  for (nm, hexv, grp) in PALETTE:
    lines.append(f'  if (name == "{nm}") {{ return 0x{hexv:06X} }}')
  lines.append("  return -1")
  lines.append("}")
  lines.append("")
  with open(path, "w") as f:
    f.write("\n".join(lines) + "\n")

def emit_json(path):
  groups = {}
  order = []
  for (nm, hexv, grp) in PALETTE:
    if grp not in groups:
      groups[grp] = []; order.append(grp)
    groups[grp].append({"name": nm, "hex": f"{hexv:06X}"})
  out = {"count": len(PALETTE), "groups": [{"name": g, "colors": groups[g]} for g in order]}
  with open(path, "w") as f:
    json.dump(out, f, indent=2)

if __name__ == "__main__":
  names = guard_check()
  root = os.path.dirname(os.path.abspath(__file__))
  repo = "/Users/orkuncakilkaya/workspace/gpp"
  emit_ludic(os.path.join(repo, "selfhost", "emit_color.ludic"))
  emit_json(os.path.join(root, "palette.json"))
  print(f"OK {len(PALETTE)} colors ({len(set(names))} unique names)")
