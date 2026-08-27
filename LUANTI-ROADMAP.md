# Luanti → Ludic: Full Gap Analysis & Implementation Roadmap

**Question asked:** *what does Ludic miss in order to implement Luanti (formerly
Minetest) — the game/engine?*

**Short answer:** Ludic can already express Luanti's **game logic**. It cannot yet
express Luanti's **engine**. The gap is not one feature; it is roughly six
layers, and two of them (aggregate data types, and a platform layer with
threads + sockets + a GPU) are load-bearing for everything above them.

This document is written against evidence, not memory: `luanti-org/luanti` at
`main` was cloned and read, and every claim about Ludic below was verified
against `compiler/ludicc.c` / `compiler/native.c` or by compiling a probe
program with `build/ludicc`.

---

## 0. TL;DR

| | Luanti | Ludic today |
|---|---|---|
| Size | **362,258** lines (C++ / Lua / GLSL) | 2,508 lines of compiler + 3,692 of runtime |
| World | infinite 3D voxel, ±31,007 nodes/axis | 96×64 char tilemap, 2D |
| Entities | unbounded active objects, chunked | **fixed 1,024** (`LUDIC_MAX_ENT`) |
| Rendering | GPU, 20 shader programs, Irrlicht fork (87k LOC) | 320×240 software framebuffer |
| Extensibility | Lua sandbox, hot-loaded mods, 321 `core.*` calls | AOT compile only |
| Concurrency | emerge threads, mesh threads, net threads, async Lua | **none** |
| Networking | custom reliable UDP, 90 packet types | **none** |
| Numbers | `f32` / `f64`, `v3f`, matrices | `int`, Q16.16 `fixed` (range **±32,768**) |
| Aggregates | vectors, maps, strings, structs | **none** — raw `ptr` + `peek/poke` |

**The single most surprising finding:** Ludic's `fixed` type **cannot represent a
Luanti world coordinate.** Q16.16 saturates at ±32,768; Luanti's map limit is
±31,007 *nodes*, and positions are carried in *BS units* where `BS = 10.0`
(`src/constants.h`) — i.e. ±310,070. Worse, any squared distance
(`31007² ≈ 9.6e8`) overflows Q16.16 by five orders of magnitude. Every collision,
raycast and physics computation in Luanti would silently wrap. See **G-04**.

**Recommended order of attack:** language core (arrays/structs/strings) →
platform (threads/sockets/time) → voxel storage primitive → GPU backend →
mod ABI → networking. Milestones **M0–M4** are all reachable without
compromising any of the project's stated constraints (no C, no VM, no
transpile).

---

## 1. Evidence base

What was read, and how big it is:

| Area | Files | LOC | Read |
|---|---|---|---|
| `src/` (engine core) | ~700 | 210,370 | headers + all subsystem entry points |
| `irr/` (Irrlicht fork: renderer, GUI, mesh loaders) | — | 87,554 | structure + driver list |
| `src/client/` | 134 | 44,247 | `game.cpp`, `content_mapblock.cpp`, `clientmap.cpp`, mesh threads |
| `src/script/` (Lua bindings) | 147 | 34,240 | full API index, `l_object`, `l_env`, `l_mapgen`, `l_vmanip` |
| `builtin/` (Lua engine layer) | ~60 | 22,634 | file map, `game/`, `common/`, `emerge/` |
| `src/gui/` (formspec, menus) | 61 | 19,198 | `guiFormSpecMenu.cpp` (5,610 LOC alone) |
| `games/devtest` | — | 13,455 | node/item/entity registration patterns |
| `src/mapgen/` | 32 | 11,668 | all 8 mapgens + biome/ore/decoration/cave/dungeon/schematic |
| `src/network/` | 23 | 10,958 | protocol enum (90 packets), reliable-UDP impl |
| `src/util/`, `src/database/`, `src/threading/`, `src/server/` | 102 | 21,961 | serialization, 5 DB backends, thread primitives |
| `doc/lua_api.md` | 1 | 12,785 | **the full mod-facing contract** — the real spec |
| `doc/world_format.md` | 1 | 658 | on-disk map format v22–29 |

Ludic side, verified by reading source and by compiling probes:

| Probe | Result |
|---|---|
| recursion (`fib`) | ✅ compiles and links |
| `"ab" + "cd"` | ❌ front-end accepts, **IR fails to assemble** — no string ops |
| `mem_alloc` / `peek32` / `poke32` | ✅ works |
| `fixed` multiply IR | `sext i64 → mul → ashr 16 → trunc i32` — 64-bit intermediate, **i32 result** |
| `sqrt` / `sin` / `cos` / `atan2` | ❌ absent from compiler and runtime entirely |
| runtime component attach/detach | ❌ no such statement — components are fixed at `spawn` |
| entity ceiling | `#define LUDIC_MAX_ENT 1024` (`compiler/native.c:18`) |
| DEFLATE | **decode only** (`runtime/native/inflate.ludic`) — no compressor |

---

## 2. What Luanti actually is

Nine subsystems. For each: what it does, where it lives, and — the part that
matters here — **what it demands from the language underneath it.**

### 2.1 The voxel core

A world is `MapNode`s: a 4-byte struct — `u16 param0` (content id), `u8 param1`
(two 4-bit light banks, day + night), `u8 param2` (rotation / liquid level /
level / colour index). 4,096 of them per `MapBlock` (16³). Blocks live in
sectors; sectors in a `Map`; `ServerMap` and `ClientMap` specialise it.

```cpp
// src/mapnode.h
struct alignas(u32) MapNode {
    u16 param0;   // content_t, up to MAX_REGISTERED_CONTENT (~58k)
    u8  param1;   // day light : 4 | night light : 4
    u8  param2;   // facedir / wallmounted / liquid level / degrotate / colour
};
static constexpr u32 nodecount = 16*16*16;   // src/mapblock.h:426
```

**Demands:** a packed struct type; a fixed-size array of them; bitfield
access; cheap 3D→1D indexing; and the ability to allocate *millions* of these
(a modest 10-chunk view radius is ~9,000 blocks = 36M nodes = 147 MB).

### 2.2 Map storage & persistence

`map.sqlite` keyed by a 64-bit interleaved block position; each blob is a
serialised `MapBlock` — version byte, flags, 12-bit `lighting_complete`
bitfield, timestamp, a **name↔id mapping** so node ids survive mod changes,
then `param0`/`param1`/`param2` planes, node metadata, node timers, and static
objects. Since format 29 the whole block is **zstd-compressed** (zlib before
that). Five interchangeable backends: SQLite3, LevelDB, Redis, PostgreSQL, flat
files.

**Demands:** big-endian byte serialisation, a compressor (not just a
decompressor), a string↔id table, and an FFI-usable key/value store.

### 2.3 Map generation

Eight mapgens (`v5 v6 v7 flat fractal valleys carpathian singlenode`) over a
shared `Mapgen` base, plus five orthogonal generators layered on top:

| Generator | File | LOC | What it does |
|---|---|---|---|
| Caves | `cavegen.cpp` | 912 | 3D-noise caverns + tunnel carving |
| Trees | `treegen.cpp` | 888 | L-system + hardcoded species |
| Dungeons | `dungeongen.cpp` | 658 | room/corridor placement |
| Schematics | `mg_schematic.cpp` | 618 | `.mts` blob stamping, force/probability per node |
| Ores | `mg_ore.cpp` | 583 | scatter / sheet / puff / blob / vein / stratum |
| Decorations | `mg_decoration.cpp` | 472 | simple / schematic / lsystem placement |
| Biomes | `mg_biome.cpp` | 332 | heat+humidity noise → biome, per-node depth layers |

All of it rests on **fractal value noise**:

```cpp
// src/noise.h
struct NoiseParams {
    float offset = 0.0f, scale = 1.0f;
    v3f   spread = v3f(250,250,250);
    s32   seed = 12345;
    u16   octaves = 3;
    float persist = 0.6f, lacunarity = 2.0f;
    u32   flags = NOISE_FLAG_DEFAULTS;
};
float NoiseFractal3D(const NoiseParams *np, float x, float y, float z, s32 seed);
```

**Demands:** floating-point (or ≥Q32.32 fixed), a noise map buffer type,
and — because mapgen runs on `EmergeThread`s — **real threads plus a
thread-local `MMVManip` voxel buffer.**

### 2.4 Environment & simulation

`ServerEnvironment` drives the world tick: **ABMs** (Active Block Modifiers —
probabilistic per-node rules that run in loaded blocks), **LBMs** (Loading Block
Modifiers — run once when a block loads), **node timers**, liquid transformation
queues, and object activation/deactivation as players move.

```lua
core.register_abm({
    label = "Lava cooling",
    nodenames = {"default:lava_source"},
    neighbors = {"default:water_source", "default:water_flowing"},
    interval = 10.0,     -- seconds
    chance = 50,         -- 1-in-50 per node per interval
    min_y = -32768, max_y = 32767,
    catch_up = true,
    action = function(pos, node, active_object_count, active_object_count_wider) ... end,
})
```

**This is the one Luanti concept that maps *beautifully* onto Ludic.** An ABM is
literally a system with a query, a `where` clause and a probability. See G-16 —
this is where Ludic could be *better* than Luanti, not merely equal.

### 2.5 Objects, entities, players

`ActiveObject` → `ServerActiveObject` → `LuaEntitySAO` / `PlayerSAO`; mirrored
client-side by `ClientActiveObject` → `GenericCAO` (`content_cao.cpp`, 2,002
LOC). ~30 shared `ObjectProperties` (visual, mesh, textures, `collisionbox`,
`selectionbox`, `physical`, `stepheight`, `nametag`, …). `ObjectRef` alone
exposes **123 documented methods** in `lua_api.md`.

Collision is swept-AABB against nodes and other objects
(`collisionMoveSimple`), with `stepheight`, and a separate `Raycast` iterator
and an A* `pathfinder.cpp` (1,419 LOC).

**Demands:** float vectors, AABB math, `sqrt`, and dynamic per-entity component
sets (an entity gains/loses attachments, nametags, physics at runtime).

### 2.6 Items, inventory, crafting

`ItemDefManager`, `ItemStack` (name + count + wear + metadata), `InvRef` lists,
`craftdef.cpp` (1,250 LOC) with shaped / shapeless / toolrepair / cooking /
fuel recipe types, and **groups** — the string→int tag system that everything
(digging times, damage, biome placement) keys off:

```lua
groups = {cracky = 3, level = 2, not_in_creative_inventory = 1}
tool_capabilities = {
    full_punch_interval = 1.0, max_drop_level = 1,
    groupcaps = { cracky = {times = {[1]=2.0, [2]=1.0, [3]=0.5}, uses = 20, maxlevel = 2} },
    damage_groups = {fleshy = 2},
}
```

**Demands:** string-keyed maps, dynamic arrays, and a runtime registry.

### 2.7 Client rendering

The heaviest subsystem. `content_mapblock.cpp` (1,870 LOC) turns a MapBlock
into a mesh, one branch per **drawtype** — there are 19:

```
NORMAL AIRLIKE LIQUID FLOWINGLIQUID GLASSLIKE ALLFACES ALLFACES_OPTIONAL
TORCHLIKE SIGNLIKE PLANTLIKE FENCELIKE RAILLIKE NODEBOX GLASSLIKE_FRAMED
FIRELIKE GLASSLIKE_FRAMED_OPTIONAL MESH PLANTLIKE_ROOTED
```

Around it: `mapblock_mesh.cpp` + `mesh_generator_thread.cpp` (background
meshing), `clientmap.cpp` (frustum culling, transparency sorting),
`shader.cpp`, 20 GLSL shader programs (`client/shaders/`) covering nodes,
objects, bloom down/upsample, FXAA, volumetric light, shadow mapping,
exposure adaptation, sky, clouds, minimap, and `imagesource.cpp` (1,915 LOC)
implementing the **texture modifier mini-language** (`default_dirt.png^grass.png^[opacity:160`).

**Demands:** a GPU. Vertex/index buffers, texture atlases + mipmaps, a shader
pipeline, matrices, frustum math. None of this exists in Ludic, whose renderer
is a `320×240` `i32` framebuffer blitted through Core Graphics.

### 2.8 GUI: formspec, HUD, chat

`guiFormSpecMenu.cpp` is the single largest file in the engine at **5,610 LOC**.
It parses a string DSL with **64 element types** (`list`, `field`, `dropdown`,
`scroll_container`, `hypertext`, `model`, `tabheader`, `style`, `table`, …):

```lua
core.show_formspec(name, "mymod:chest", table.concat({
    "formspec_version[7]", "size[8,9]",
    "list[context;main;0.375,0.75;8,4;]",
    "list[current_player;main;0.375,5.5;8,4;]",
    "listring[context;main]",
}))
```

Plus a HUD element system (`hud_element.h`), a chat console, and a markup
`hypertext` renderer (`guiHyperText.cpp`, 1,254 LOC).

**Ludic's `ui` block is genuinely the right shape for this** — retained widget
tree as data — but covers ~8 widget types against 64, has no scrolling, no
tables, no text input, and no inventory-slot widget.

### 2.9 Networking

Custom reliable-UDP over a channel abstraction (`src/network/mtp/impl.cpp`,
1,685 LOC + `threads.cpp`, 1,429 LOC): split packets, reliable/unreliable
delivery, ack windows, peer timeout. **90 packet types**
(`ToClientCommand` / `ToServerCommand`), protocol version floor 37. Server
sends mapblocks by distance priority, streams media by hash, and runs an auth
handshake (SRP).

**Demands:** UDP sockets, threads, timers, checksums, and compression.

### 2.10 Audio

OpenAL + Ogg Vorbis (`src/client/sound/`, 11 files): 3D positional sound,
fading, looping, per-object attachment, a proxy manager so the audio thread
never blocks the main loop.

**Ludic has no audio of any kind.** Not a builtin, not a runtime primitive.

### 2.11 Scripting — the actual design centre

This is the part that is easy to under-weight. **Luanti is not a game; it is a
Lua host.** `games/devtest` and Minetest Game are *mods*. The C++ engine's
purpose is to expose:

- **321** `core.*` functions
- **31** `core.register_on_*` global callbacks
- **19** documented classes (`ObjectRef`, `ItemStack`, `InvRef`, `VoxelManip`,
  `NodeMetaRef`, `PcgRandom`, `ValueNoiseMap`, `AreaStore`, `Settings`, …)
- **24** definition-table schemas (node, item, entity, ABM, LBM, biome, ore,
  decoration, particle, HUD, craft, …)
- a security sandbox (`s_security.cpp`, 1,253 LOC) that whitelists the Lua
  stdlib and confines file access to the mod's own directory
- an async job environment, a mapgen-thread environment, and **SSCSM**
  (server-sent client-side mods)

Mods are hot-loaded at runtime from directories, in dependency order, and can
be added by a server operator without recompiling anything.

**This is the deepest architectural gap**, and it collides head-on with a stated
project constraint (compiled/native only; no VM, no interpreter). Resolved in
**G-25** — the answer is a compiled mod ABI, not a scripting language.

### 2.12 Support layers

Threads + mutex + semaphore + event (`src/threading/`), `SettingsManager`,
gettext i18n with plural forms and per-server translations, `httpfetch` (cURL),
JSON, SRP auth, `Profiler`, `AreaStore` (spatial index), zlib **and** zstd,
GMP for bignum crypto.

External dependencies Luanti links: `SQLite3 Lua CURL Freetype GettextLib
OpenAL Vorbis OpenSSL PostgreSQL ZLIB Zstd GMP Json Threads Ncursesw`.

---

## 3. Ludic today — verified capability inventory

Everything below was confirmed against the compiler source, not the docs.

**Types:** `int` (i32), `fixed` (Q16.16 in i32), `bool` (i32), `entity` (i32),
`str` (`ptr` to literal), `ptr` (opaque), `void`. That is the complete list
(`compiler/ludicc.c:516`).

**Declarations:** `game`, `module`/`export`, `import`, `component`, `archetype`,
`const`, `var` (module-level globals — yes, these exist), `fn`, `extern fn`,
`system`, `scene`/`layer`, `ui`.

**Statements:** `let`, assignment (`= += -= *= /=`), `if`/`else`, `when`,
`while`, `for i in a..b`, `for (…) in query […] where …`, `return`, `spawn`,
`despawn`, `match`, `machine`/`become`, `enter`.

**ECS:** dense per-component arrays sized `LUDIC_MAX_ENT = 1024`, a parallel
`@H_<Comp>` byte per entity for "has", `@L_kind` for archetype, `@L_alive`, a
free list. Queries are **linear scans over all 1,024 slots** re-checking the
mask each visit.

**Intrinsics** (the floor, lowering to libc/OS symbols):
`mem_alloc mem_free mem_copy mem_set peek8 poke8 peek32 poke32 ptr_add ptr_null
ptr_is_null file_open file_read file_write file_seek file_tell file_close
read_byte write_byte print_str str_len os_exit os_time shl shr band bor bxor
bnot peekp pokep peekf pokef as_fixed as_int is_windowed game_title win_open
win_poll win_present win_running win_close`

**Runtime (written in Ludic):** framebuffer + 2D draw, 5×7 bitmap text, a
from-scratch TrueType engine (Q16.16 béziers, AA), PNG decode incl. DEFLATE
*inflate*, sprites + 9-slice, tilemap, xorshift RNG, 64 int registers, retained
UI (panel/col/row/label/button/image/spacer), whole-world save/load snapshot.

**Confirmed absent:** arrays · structs as values · strings (any operation) ·
floats · integers wider or narrower than 32 bits · unsigned · enums · unions ·
generics · closures · function pointers · maps/dicts · slices · bounds checks ·
error handling · `sqrt`/trig · vectors/matrices · threads · atomics · sockets ·
audio · GPU · dynamic loading · runtime component attach/detach · a compressor ·
any entity count above 1,024.

---

## 4. Gap register — summary

Tiers are dependency-ordered: nothing in tier *n* is buildable before tier *n−1*.

| # | Gap | Tier | Blocks | Effort |
|---|---|---|---|---|
| G-01 | Array & slice types | 0 core | everything | L |
| G-02 | Struct / record value types | 0 core | MapNode, vectors, defs | L |
| G-03 | Strings (owned, UTF-8, ops) | 0 core | names, metadata, formspec | L |
| G-04 | Wide numerics: `f32`/`f64` or Q32.32 | 0 core | **world coordinates** | M |
| G-05 | Sized & unsigned ints (`u8 u16 i64`) | 0 core | node packing, serialization | M |
| G-06 | Enums & tagged unions | 0 core | drawtypes, packets | M |
| G-07 | Math library (`sqrt`, trig, `atan2`) | 0 core | physics, noise, camera | S |
| G-08 | Allocator/arena discipline + bounds checks | 0 core | 147 MB of voxels | M |
| G-09 | Error handling (`result`/`try`) | 0 core | I/O, net, parsing | M |
| G-10 | Generics or monomorphised containers | 0 core | every collection | L |
| G-11 | Hash maps | 0 core | registries, name↔id | M |
| G-12 | Entity count beyond 1,024; chunked ECS storage | 1 ecs | any real world | L |
| G-13 | Runtime component attach/detach | 1 ecs | entity properties | S |
| G-14 | Multiple worlds / ECS instances | 1 ecs | client+server in one binary | M |
| G-15 | Query indices (no linear scan) | 1 ecs | performance | M |
| G-16 | Spatial/probabilistic systems (ABM-shaped) | 1 ecs | world simulation | M |
| G-17 | Threads, mutexes, atomics, channels | 2 plat | mapgen, meshing, net | L |
| G-18 | Sockets (UDP + TCP) | 2 plat | multiplayer | M |
| G-19 | Monotonic + wall clock, sleep, timers | 2 plat | fixed timestep | S |
| G-20 | Dynamic library loading at runtime | 2 plat | mods | S |
| G-21 | Compression (deflate **encode**, zstd) | 2 plat | map storage, net | M |
| G-22 | Voxel chunk primitive + VoxelManip | 3 voxel | the game itself | L |
| G-23 | Lighting propagation & mesh generation | 3 voxel | rendering | L |
| G-24 | Collision, raycast, AABB, pathfinding | 3 voxel | movement | M |
| G-25 | **Mod/extension model (compiled ABI)** | 4 ext | Luanti's whole point | XL |
| G-26 | Data-driven registries & definition tables | 4 ext | node/item defs | M |
| G-27 | Metadata stores (node/item/player) | 4 ext | chests, signs | M |
| G-28 | GPU backend: 3D pipeline, shaders | 5 gfx | 3D at all | XL |
| G-29 | 3D math types (vec/mat/quat/aabb) | 5 gfx | everything 3D | M |
| G-30 | UI: 64 formspec elements, scroll, input, tables | 5 gfx | inventories | L |
| G-31 | Audio: mixing, Ogg decode, 3D positional | 6 av | polish | L |
| G-32 | i18n: gettext, plurals, server translations | 6 av | shipping | M |
| G-33 | Persistence: versioned block format, SQLite FFI | 7 net | saving | M |
| G-34 | Network protocol: reliable UDP, 90 packets | 7 net | multiplayer | XL |

`S ≈ days · M ≈ 1–3 weeks · L ≈ 1–2 months · XL ≈ a quarter+` (single developer.)

---

## 5. The gaps in detail

Each entry: what Luanti needs · what Ludic has · proposed Ludic feature · the
compiler/runtime work it implies.

### Tier 0 — Language core

#### G-01 · Array & slice types

**Luanti needs.** `MapNode data[4096]` per block; `std::vector<aabb3f>` per
nodebox; noise buffers of `w*h*d` floats; the 6 tiledefs per node.

**Ludic has.** Nothing. `runtime/native/core.ludic` fakes arrays with
`mem_alloc` + `peek32`/`poke32` and manual stride arithmetic:

```ludic
rt_fb = mem_alloc(320 * 240 * 4)
poke32(rt_fb, (y * rt_fbw + x) * 4, color)     # every access, by hand
```

That is workable for a 3,700-line runtime and fatal for a 100,000-line engine:
no bounds checks, no element type, no length.

**Proposed.**

```ludic
# fixed-size, stack or inline in a struct — length is part of the type
let box: [16]int

# heap-allocated, length carried, bounds-checked in debug builds
let nodes: [] MapNode = alloc [4096] MapNode
nodes[i].param0 = C_STONE
print_int(nodes.len)

# slices: a (ptr, len) pair, no ownership — the workhorse for I/O
fn checksum(bytes: []u8) -> int {
  var sum = 0
  for b in bytes { sum = sum + b }      # `for x in slice` iteration
  return sum
}
let window = nodes[0 .. 256]            # slicing, no copy
```

**Work.** Lexer: `[`/`]` in type position. Types: a new `TARR{elem, len}` and
`TSLICE{elem}`. Codegen: LLVM `[N x T]` and `{ptr, i64}`; `getelementptr` for
indexing; a `panic_bounds` intrinsic. Semantics decision: slices are non-owning,
`alloc` returns an owning array that `free` releases. **This is the single
highest-leverage item in the document** — G-02, G-03, G-05, G-11, G-22 all
depend on it.

#### G-02 · Struct / record value types

**Luanti needs.** `MapNode` is a 4-byte value passed by copy 10⁶ times a frame.
`v3s16`, `aabb3f`, `TileDef`, `NoiseParams`, `ObjectProperties`, `CollisionInfo`.

**Ludic has.** `component`, which is *not* a value type — it is a row in a
global ECS array, addressable only through a query binding. You cannot declare
a local of component type, return one, or nest one.

**Proposed.** Split "data shape" from "ECS membership":

```ludic
struct MapNode {
  param0: u16 = 0      # content id
  param1: u8  = 0      # light: day|night nibbles
  param2: u8  = 0      # facedir / level / liquid
}

struct v3i { x: int = 0, y: int = 0, z: int = 0 }

fn index(p: v3i) -> int { return (p.z * 16 + p.y) * 16 + p.x }

fn get(blk: []MapNode, p: v3i) -> MapNode { return blk[index(p)] }

# a component becomes "a struct that lives in the world"
component Pos = v3i                      # aliasing form
component Vel { dx: fixed = 0, dy: fixed = 0 }   # existing form still valid
```

Add `expr with { field = … }` (already flagged "not implemented" in
LANGUAGE.md) so records can be updated functionally:

```ludic
let lit = n with { param1 = pack_light(15, 15) }
```

**Work.** `NSTRUCT` decl, struct types in the type table, LLVM named struct
types, by-value passing/returning (`byval` for large ones), field access on
non-component values, `with` lowering to insertvalue chains.

#### G-03 · Strings

**Luanti needs.** Node names (`"default:stone"`), item strings
(`"default:pick_steel 1 250"`), formspec strings built by concatenation, chat,
metadata keys, mod names, translation keys, the texture-modifier DSL.

**Ludic has.** `str` = a pointer to a literal. Verified: `"ab" + "cd"` passes
the parser and then **fails to assemble**. `str_len` exists as an intrinsic;
nothing else does.

**Proposed.**

```ludic
# `str` stays an immutable literal/slice: (ptr, len), UTF-8, no allocation
# `string` is owned and growable
let name: str = "default:stone"
var buf: string = string_new()
buf.push("size[8,9]")
buf.push_fmt("list[context;main;{};{};8,4;]", x, y)
let out: str = buf.view()

if name.starts_with("default:") { … }
let (modname, item) = name.split_once(':')
let h = name.hash()                       # for the registry map
for cp in name.codepoints() { … }         # UTF-8 aware
```

**Work.** Interning table for literals (already partly there for `.str` globals),
a `string` runtime type in `runtime/native/string.ludic`, `+`/`==`/`<` operator
lowering for `str`, formatting (`push_fmt`) which needs varargs or a small
format-node lowering. Note the TrueType engine already decodes UTF-8 — reuse it.

#### G-04 · Wide numerics — **the coordinate bug**

**Luanti needs.** `f32` positions in BS units. `MAX_MAP_GENERATION_LIMIT =
31007` nodes; `BS = 10.0f`; so world coordinates reach **±310,070**, and squared
distances reach **~10⁹**.

**Ludic has.** Q16.16 in i32. Range **±32,767.99998**. Verified IR:

```llvm
%t2 = sext i32 %t0 to i64      ; 64-bit intermediate — precision is fine
%t3 = sext i32 %t1 to i64
%t4 = mul i64 %t2, %t3
%t5 = ashr i64 %t4, 16
%t6 = trunc i64 %t5 to i32     ; …but the result truncates back to Q16.16
```

So `fixed` **cannot hold a Luanti world coordinate at all**, and `d = dx*dx +
dy*dy + dz*dz` wraps silently for anything past ~181 nodes from the origin.
Every collision test, raycast, and mob AI decision would be wrong far from
spawn.

**Proposed — pick one (recommendation: both, in this order):**

1. **`fixed64` / Q32.32 on i64** — keeps determinism, which is a genuine
   advantage for a multiplayer voxel game (bit-identical physics across
   platforms; Luanti itself suffers from float drift here).
   ```ludic
   let px: fixed64 = 310070.5      # ±2.1e9 range, 2⁻³² precision
   ```
2. **`f32` / `f64`** — required anyway for mapgen noise (`NoiseParams` is all
   floats and the noise functions are transcendental), and for GPU interop where
   vertex data *must* be IEEE floats.
   ```ludic
   let h: f32 = noise3d(x, y, z, seed)
   ```

**Work.** New scalar types in the type table; LLVM `i64` / `float` / `double`;
promotion rules (`int → fixed → fixed64`, `int → f32 → f64`); literal suffixes
(`1.5f`, `1.5d`); `fmul`/`fdiv`/`fcmp` lowering; printf format selection.

#### G-05 · Sized & unsigned integers

**Luanti needs.** `MapNode` is `u16 + u8 + u8` — exactly 4 bytes, because 36
million of them exist. Serialisation is byte-exact and big-endian. `content_t`
is `u16`; light is two 4-bit nibbles.

**Ludic has.** i32 only. A `MapNode` built from Ludic `int`s would be 12 bytes —
**3× the memory**, 441 MB instead of 147 MB for a 10-block view radius.

**Proposed.**

```ludic
struct MapNode { param0: u16, param1: u8, param2: u8 }    # exactly 4 bytes

let light_day: u8  = band(n.param1, 0x0f)
let content:   u16 = n.param0
let key:       u64 = block_key(bp)         # sqlite position encoding
```

Plus explicit conversion (`as u8`, `as int`) and wrap/saturate semantics stated
in the spec.

**Work.** Type table entries for `u8 u16 u32 u64 i8 i16 i64`; LLVM `zext`/`sext`
/`trunc` at boundaries; struct layout + alignment rules; unsigned comparison and
shift (`lshr` vs `ashr` — the existing `shr` intrinsic already lowers to `lshr`,
which is wrong for signed ints, and would become type-directed).

#### G-06 · Enums & tagged unions

**Luanti needs.** 19 `NodeDrawType`s, 90 packet types, `LiquidType`,
`ContentParamType`, `CollisionType`, and `pointed_thing` which is a genuine sum
type (`nothing` | `node{under,above}` | `object{ref}`).

**Ludic has.** `const` ints, and `match` over int literals (which is already
half of what's needed and works well).

**Proposed.**

```ludic
enum DrawType { Normal, Airlike, Liquid, FlowingLiquid, Glasslike, Allfaces,
                Torchlike, Signlike, Plantlike, Fencelike, Raillike, Nodebox,
                GlasslikeFramed, Firelike, Mesh, PlantlikeRooted }

union Pointed {
  Nothing
  Node   { under: v3i, above: v3i }
  Object { ref: entity }
}

match p {
  Pointed.Nothing        => return
  Pointed.Node(u, a)     => place_node(a, item)      # destructuring arms
  Pointed.Object(e)      => punch(e)
}
```

`match` already exists and already lowers on the native backend — extending its
arms to enum cases and destructuring patterns is incremental, not new
machinery.

#### G-07 · Math library

**Luanti needs.** `sqrt` (every distance), `sin`/`cos` (rotation, sky, camera),
`atan2` (`automatic_face_movement_dir`), `pow`/`exp` (noise persistence,
exposure adaptation), `floor`/`ceil`/`round`.

**Ludic has.** `min max abs clamp` — integer only. **Verified: no `sqrt`
anywhere in the compiler or the runtime.**

**Proposed.** A `runtime/native/math.ludic` written in Ludic (consistent with
the project's "runtime is in Ludic" rule) — CORDIC or polynomial approximations
for trig on `fixed`, Newton–Raphson `sqrt`, plus direct `llvm.sqrt.f32` /
`llvm.sin.f32` intrinsic lowering once `f32` lands (G-04).

```ludic
sqrt(x: fixed) -> fixed      sin(a: fixed) -> fixed      atan2(y, x) -> fixed
pow(b, e) -> fixed           floor(f) -> int             lerp(a, b, t) -> fixed
```

**Effort: S.** This one is a weekend, and unblocks a surprising amount.

#### G-08 · Memory discipline

**Luanti needs.** A 10-block view radius is ~9,000 MapBlocks ≈ **147 MB of node
data alone**, churning constantly as blocks load and unload.

**Ludic has.** `mem_alloc`/`mem_free` (raw `malloc`/`free`), no ownership
tracking, no bounds checks, no leak detection. `runtime/native/image.ludic`
already leaks decoded PNG buffers by design.

**Proposed.** Not a borrow checker — that is a different language. An **arena
and a pool**, expressed in Ludic, plus optional bounds checking:

```ludic
arena frame                      # reset once per frame, no individual frees
let verts = frame.alloc [4096] Vertex

pool blocks: MapBlock            # fixed-size slab, free-list backed
let b = blocks.take()
blocks.give(b)

# debug builds: every [] access bounds-checked; --release drops the check
```

#### G-09 · Error handling

**Luanti needs.** Corrupt map blobs, truncated packets, missing textures,
unknown node names, failed DB writes. It uses C++ exceptions
(`src/exceptions.h`) plus sentinel returns.

**Ludic has.** Nothing. `file_open` returns a `ptr` you must test with
`ptr_is_null`; every failure path is a hand-rolled convention.

**Proposed.** No unwinding (it would fight the AOT/no-runtime philosophy) —
sum-typed results with sugar, which falls straight out of G-06:

```ludic
fn read_block(path: str) -> MapBlock ! IoError {
  let f = file_open(path, "rb") else return IoError.NotFound
  let n  = try file_read(f, buf, 4096)      # `try` propagates the error arm
  return parse(buf[0..n])
}

match read_block(p) {
  Ok(b)  => use(b)
  Err(e) => log_warn("block load failed", e)
}
```

#### G-10 · Generics (or monomorphised containers)

Without some form of parametric types, every container is written N times.
Minimum viable: **compile-time monomorphisation over one type parameter**, no
constraints, no inference beyond the call site.

```ludic
struct Vec[T] { data: []T, len: int, cap: int }

fn push[T](v: Vec[T], x: T) -> void {
  if v.len == v.cap { v.data = realloc(v.data, v.cap * 2)  v.cap = v.cap * 2 }
  v.data[v.len] = x
  v.len = v.len + 1
}

var objects: Vec[entity] = vec_new[entity]()
```

**Work.** Parse `[T]` in decls and calls; a monomorphisation pass keyed on
(fn, concrete args) before codegen; name mangling. Deliberately *not* traits,
*not* variance, *not* HKT — this is a game language, and Luanti's C++ uses
templates in exactly this restrained way.

#### G-11 · Hash maps

**Luanti needs.** name→id for nodes and items (~60k entries), the definition
registries, `NodeMetaRef` string→string stores, groups (`string → int`), mod
storage, translation catalogues.

**Proposed.** One monomorphised open-addressing map, in Ludic:

```ludic
var by_name: Map[str, u16] = map_new[str, u16]()
by_name.set("default:stone", 1)
if let id = by_name.get("default:stone") { … }
for (k, v) in by_name { … }
```

### Tier 1 — ECS at world scale

#### G-12 · The 1,024-entity ceiling

**The number.** `compiler/native.c:18` — `#define LUDIC_MAX_ENT 1024`. Every
component becomes `@S_<Comp> = internal global [1024 x %Cmp_<Comp>]`, plus a
`[1024 x i8]` presence array. Storage is **static, dense, and allocated for
every component whether used or not.**

**What Luanti needs.** A busy server carries thousands of active objects; a
single 16³ MapBlock holds 4,096 nodes. Nodes must *not* be ECS entities (see
G-22), but mobs, items, players, particles, and node timers all should be.

**Proposed.** Two changes, independent:

1. **Configurable + dynamic capacity.** `game Foo { entities 65536 }` for the
   static bound, and a growth path: component arrays become heap
   `[]Cmp` that double.
2. **Sparse-set storage** (the standard ECS answer): per component a dense
   packed array + a sparse index. Iteration cost becomes proportional to the
   number of entities *with that component*, not to 1,024. This also kills the
   memory waste: a component held by 10 entities stops costing 1,024 slots.

```ludic
game Voxel {
  entities 262144            # ceiling, or `dynamic` for growable
  storage sparse             # or `dense` for the current behaviour
}
```

#### G-13 · Runtime component attach/detach

**Luanti needs.** An entity gains a nametag, loses physics, gets attached to a
vehicle, picks up an inventory — all at runtime. `ObjectRef:set_properties`,
`set_attach`, `set_armor_groups` are per-object mutations of the *shape* of the
entity.

**Ludic has.** Components are attached only by `spawn`. There is no statement to
add or remove one afterwards. (Verified: no `attach`/`detach` in the parser.)
The `@H_<Comp>` presence byte already exists — the storage supports it; the
*language* does not expose it.

**Proposed.**

```ludic
attach Nametag { text = "Zombie", color = 0xffffff } to e
detach Physics from e
if has Physics on e { … }
```

**Effort: S** — the runtime representation is already there.

#### G-14 · Multiple ECS worlds

Luanti runs a `ServerEnvironment` and a `ClientEnvironment` **in the same
process** for singleplayer. Ludic has exactly one implicit global world.

```ludic
world Server { … }      # separate component storage per world
world Client { … }
for (p) in Server.query [Pos] { … }
```

Also needed for: mapgen worker threads that build a block in isolation, and for
tests.

#### G-15 · Query indices

Today: `for (p) in query [Pos]` scans slots 0..1023 and re-tests the mask.
With G-12's higher ceilings that becomes the hot loop. Sparse sets (G-12) fix
the common case; the remaining need is **multi-component intersection** — pick
the smallest dense set and probe the others.

#### G-16 · ABM-shaped systems — *where Ludic can beat Luanti*

Luanti's ABM is a hand-rolled sampler in C++: pick random positions in loaded
blocks, test `nodenames`, test `neighbors`, roll `chance`, call a Lua closure.
It is one of the most-profiled parts of the engine.

In Ludic this is a **declaration**:

```ludic
system LavaCooling phase Update
  every 10.0s                       # interval, not a hand-rolled timer
  chance 1 in 50                    # sampler, compiled in
  nodes [C_LAVA_SOURCE]             # content filter → an index, not a scan
  near  [C_WATER_SOURCE, C_WATER_FLOWING]
  in    y -32768 .. 32767
{
  set_node(self_pos(), C_OBSIDIAN)
}
```

The compiler knows the node set at compile time, so it can build the per-block
content index once and iterate only matching positions — an optimisation Luanti
cannot do because its ABM predicates arrive as runtime strings. **This is the
strongest argument in the whole document for the language existing.**

### Tier 2 — Platform

#### G-17 · Threads, mutexes, atomics

**Luanti needs.** `EmergeThread` × N (mapgen), `MeshUpdateThread` (client
meshing), `ConnectionSendThread` + `ConnectionReceiveThread`, the sound proxy
thread, and an async Lua job environment. `src/threading/` provides
`Thread`, `Mutex`, `Semaphore`, `Event`, `OrderedMutex`.

**Ludic has.** Nothing. No `pthread_create` binding, no atomics, and — a real
problem — **`var` globals are unsynchronised i32 stores** and the ECS arrays are
process-global.

**Proposed.**

```ludic
thread pool emerge count 4 {          # a named pool with a typed job queue
  job Generate(bp: v3i) -> MapBlock { … }
}
emerge.submit(Generate(bp))
if let blk = emerge.poll() { install(blk) }

atomic var block_count: int = 0
block_count.add(1)

mutex map_lock
lock map_lock { … }

channel Chan[MapBlock] results        # MPSC, blocking or try_recv
```

Design steer: prefer **message passing + job pools** over shared mutable state,
because it composes with the ECS (a job owns its world slice) and because it is
what a determinism-oriented language should encourage.

#### G-18 · Sockets

UDP is mandatory (the whole protocol is UDP), TCP + TLS for the content store
and HTTP mods.

```ludic
let s = udp_bind("0.0.0.0", 30000)
let (n, from) = s.recv(buf)
s.send_to(from, reply)
```

Bind at the syscall level from the runtime, as with `file_open` — `socket`,
`bind`, `sendto`, `recvfrom`, `poll`. No new language feature required beyond
G-01 (slices) and G-09 (errors), which is why this is M, not L.

#### G-19 · Time

`os_time()` returns whole seconds. A game loop needs a **monotonic** clock at
microsecond resolution, and Luanti's `DTIME_LIMIT = 2.5f` / fixed-timestep
stepping depends on it.

```ludic
let t = now_us()          # monotonic, u64
sleep_ms(2)
```

#### G-20 · Dynamic loading

`dlopen`/`dlsym` equivalents, so mods (G-25) can be loaded from a directory at
startup without relinking the engine.

```ludic
let m = module_load("mods/farming/farming.dylib")
let init = m.symbol("mod_init") as fn(ModApi) -> void
```

#### G-21 · Compression

**Luanti needs.** zstd for map format ≥29, zlib below it, and both directions.

**Ludic has.** `runtime/native/inflate.ludic` — **decoder only** (verified: the
file implements `z_start`, `z_bits`, `z_table_build`, `z_decode`, `z_stored`;
there is no encoder). PNGs load; nothing can be written.

**Proposed.** Write `deflate.ludic` (fixed-Huffman + LZ77 with a hash chain is
~300 lines and enough for map storage), and FFI to `libzstd` via `extern fn` for
the real thing. Both consistent with existing project practice.

### Tier 3 — The voxel engine

#### G-22 · A voxel chunk primitive

This is the heart. **Nodes must not be ECS entities** — 36 million entities is
absurd, and Ludic's `entity` is an i32 index into parallel arrays. Voxels want
the opposite layout: dense, implicit position, no id.

**Proposed** — make chunked volumes a first-class construct, the way `component`
is:

```ludic
volume Map of MapNode chunk 16 {          # 16³ chunks of MapNode
  origin v3i                               # chunk coordinate
  meta { generated: bool, timestamp: u32, lighting_complete: u16 }
}

# indexing is bounds-safe and computes chunk + offset in one shot
let n = Map[pos]
Map[pos] = MapNode { param0 = C_STONE }

# an explicit borrowed working area = Luanti's MMVManip / VoxelManip,
# which is how mapgen and bulk edits avoid touching the live map
manip vm = Map.borrow(pmin, pmax)
for p in vm.area { if vm[p].param0 == C_AIR { vm[p] = stone } }
vm.commit()                                # write back + relight + remesh
```

Mapped to Luanti: `Map` ≈ `ServerMap`, `chunk` ≈ `MapBlock`, `manip` ≈
`MMVManip`, `vm.area` ≈ `VoxelArea`, and `commit()` ≈
`blit_back + update_liquids + calc_lighting`.

**Work.** L. Chunk table (hash map keyed on `v3i` — needs G-11), an allocator
for chunk payloads (G-08), the index arithmetic, and a loaded/unloaded state
machine. But note: this is *exactly* the kind of thing a domain-specific game
language should have, and no general-purpose language offers it.

#### G-23 · Lighting & meshing

**Lighting.** Luanti propagates two banks (day/night) via BFS flood fill across
block boundaries (`voxelalgorithms.cpp`, 1,309 LOC), with the 12-bit
`lighting_complete` mask tracking which faces are still provisional.

**Meshing.** `content_mapblock.cpp` (1,870 LOC) emits geometry per drawtype;
`mapblock_mesh.cpp` builds the buffers; `mesh_generator_thread.cpp` does it off
the main thread.

**Proposed.** Both stay *library* code written in Ludic — but they need G-01
(vertex arrays), G-04 (float vertex data for the GPU), G-17 (mesh threads), and
G-28 (somewhere to send the buffers). Language-level help worth adding:

```ludic
# a declarative face-culling rule set, instead of 19 hand-written branches
drawtype Normal {
  cull when neighbor.solid
  faces cube tiles [top, bottom, left, right, front, back]
}
drawtype Plantlike { faces cross scale visual_scale  cull never }
```

#### G-24 · Collision, raycast, AABB

Swept AABB against the node grid + other objects, with `stepheight`; a voxel
DDA raycast for pointing; A* over the node grid for mob pathing (1,419 LOC).

All expressible in Ludic **once G-04 (wide numbers) and G-07 (`sqrt`) exist.**
No new language feature needed — this is library work, ~2,000 lines.

### Tier 4 — Extensibility

#### G-25 · The mod model — the hard architectural call

**The problem.** Luanti's entire value proposition is that a server operator
drops a folder into `mods/` and restarts. 321 `core.*` functions exist to serve
that. Ludic is AOT-compiled, and the project constraint is explicit: **no VM,
no interpreter, no scripting language, ever.**

These are not reconcilable by adding Lua. They *are* reconcilable, and the
answer is already half-built in the repo — `ludicc lib.ludic --shared -o
lib.dylib` and `extern fn … = "symbol"`.

**Proposed: compiled mods behind a stable C-ABI interface.**

```ludic
# mods/farming/farming.ludic
mod Farming {
  version 1
  depends ["core"]

  on init(api: ModApi) {
    api.register_node("farming:wheat_1", NodeDef {
      drawtype   = DrawType.Plantlike,
      tiles      = ["farming_wheat_1.png"],
      groups     = [("snappy", 3), ("flammable", 2)],
      walkable   = false,
      buildable_to = true,
    })

    api.register_abm(Abm {
      nodes    = ["farming:wheat_1"],
      interval = 20.0, chance = 20,
      action   = grow_wheat,
    })
  }
}
```

Built with `ludicc mods/farming/farming.ludic --shared -o mods/farming/farming.dylib`,
loaded at startup via G-20, and talking to the engine only through a versioned
`ModApi` vtable.

**What you gain over Lua:** mods run at native speed (Luanti's ABMs and
`on_generated` handlers are its top profiler entries, and they are all Lua);
mod errors are compile-time; the ECS is available to mods directly.

**What you lose, and must decide about:**
- **No hot reload** without process restart (mitigable: reload the dylib).
- **No sandbox.** Lua's `s_security.cpp` confines mods to their own directory;
  a native dylib can do anything. Options: (a) accept it, like Factorio pre-2.0
  or any C++ plugin system; (b) run mods in a subprocess with an IPC boundary;
  (c) restrict the `ModApi` surface and ship signed mods.
- **Distribution.** Mods become per-platform binaries, or ship as source and
  compile on first load (`ludicc` is 2,508 lines — shipping it *is* viable).

**My recommendation:** ship-as-source + compile-on-load. It keeps the "drop a
folder in" workflow, keeps everything in one language, needs no VM, and turns
`ludicc`'s small size into a genuine architectural advantage.

#### G-26 · Definition tables & registries

Luanti registers definitions from Lua tables at runtime. Ludic has no table
literal, no runtime registry, and no way to name 60,000 content ids.

**Proposed** — a declarative `def` construct that is data at compile time *and*
registrable at runtime:

```ludic
def node Stone {
  name        = "default:stone"
  drawtype    = DrawType.Normal
  tiles       = ["default_stone.png"]
  groups      = [("cracky", 3)]
  is_ground_content = true
  sounds      = SoundSet.Stone
  drop        = "default:cobble"
}
```

The compiler assigns content ids, emits the table as static data, and the
registry maps `str → u16` at load (G-11). Mod-supplied defs go through the same
path at runtime.

#### G-27 · Metadata

`NodeMetaRef` / `ItemStackMetaRef` / `PlayerMetaRef`: string→string stores
attached to positions, stacks, and players, with an "inventory" attached to node
meta. Needs G-03 and G-11; then it is straightforward library code.

### Tier 5 — Graphics & UI

#### G-28 · The GPU

Luanti bundles an **87,554-line Irrlicht fork** to get: OpenGL 3 / GLES2 /
WebGL contexts, vertex + index buffers, texture management with mipmaps and
atlases, a material/shader system, scene graph, frustum culling, and mesh
loaders (B3D, OBJ, glTF). On top of that sit 20 GLSL programs.

Ludic has a 320×240 software framebuffer presented through
`runtime/native/cocoa.ll` (327 lines of hand-written LLVM IR calling
`objc_msgSend`).

**This is the largest single gap in the document.** Options:

| Option | Cost | Fit with constraints |
|---|---|---|
| Software rasteriser in Ludic | L | ✅ perfect — but ~5 fps at 720p for voxels |
| Bind OpenGL/Metal via `extern fn` | M | ✅ same posture as zlib FFI; **recommended** |
| Hand-written IR per platform, like `cocoa.ll` | XL | ✅ but repeated per API |
| Write a GPU driver | ✗ | not serious |

**Recommended:** treat the GPU exactly as the project already treats the OS —
an ABI to call, not a C program to compile. `extern fn glDrawElements(…) =
"glDrawElements"`, with a thin `runtime/native/gfx3d.ludic` over it. This is
consistent with the existing rule ("C libraries are used via FFI") and needs
**no compiler change beyond G-04's `f32`.**

#### G-29 · 3D math types

```ludic
struct v3f { x: f32 = 0, y: f32 = 0, z: f32 = 0 }
struct m4  { m: [16]f32 }
struct aabb { min: v3f, max: v3f }

fn dot(a: v3f, b: v3f) -> f32
fn cross(a: v3f, b: v3f) -> v3f
fn normalize(v: v3f) -> v3f
fn look_at(eye: v3f, at: v3f, up: v3f) -> m4
fn perspective(fovy: f32, aspect: f32, znear: f32, zfar: f32) -> m4
```

Worth considering: **operator overloading for vector types only** — Ludic
currently forbids overloading entirely, and `a + b` on vectors is the one place
where the ban costs real readability. A narrow, built-in-types-only exception is
defensible.

#### G-30 · UI at formspec scale

Ludic's `ui` block is architecturally right and 8 widgets deep. Formspec is 64
elements. The gap that matters most:

| Missing | Why it blocks Luanti |
|---|---|
| `field` / `textarea` / `pwdfield` | no text input at all — no chat, no sign editing |
| `list` (inventory slots) | the core interaction of the game |
| `scroll_container` / `scrollbar` | any inventory bigger than a screen |
| `table` / `textlist` | server list, mod manager |
| `dropdown`, `checkbox`, `tabheader` | settings |
| `model` | 3D item preview |
| `style[]` / `style_type[]` | theming |
| mouse input | **Ludic's UI is keyboard-only today** (`ui_tick(key())`) |
| `hypertext` markup | formatted text |

### Tier 6 — Audio & i18n

#### G-31 · Audio

Nothing exists. Needed: a mixer, Ogg Vorbis decode (or ship a simpler codec),
3D panning + attenuation, and an audio callback thread (G-17). Consistent with
project practice: decode in Ludic (as PNG and TrueType already are), bind
CoreAudio/ALSA/WASAPI via `extern fn`.

```ludic
let s = sound_load("assets/dig_stone.ogg")
sound_play(s, SoundSpec { gain = 0.8, pitch = 1.0, pos = p, max_hear = 32.0 })
```

#### G-32 · i18n

Luanti: gettext, plural forms (`gettext_plural_form.cpp`), per-server
translation files (`.tr`), and escape-sequence-based inline translation. Ludic
has UTF-8 rendering (good) and no translation machinery. Needs G-03 and G-11.

### Tier 7 — Persistence & network

#### G-33 · Persistence

Ludic's `save()`/`load()` writes **the entire ECS world** in one blob. Luanti
needs per-block, versioned, compressed, incrementally-written storage keyed in
SQLite, plus player files, auth, and mod storage.

```ludic
serialize MapBlock version 29 {
  u8  version
  u8  flags
  u16 lighting_complete
  u32 timestamp
  map name_id: Map[u16, str]
  zstd {                       # everything inside is compressed
    array param0: [4096]u16 bigendian
    array param1: [4096]u8
    array param2: [4096]u8
    list  metadata
    list  timers
    list  static_objects
  }
}
```

A declarative `serialize` block generating both encoder and decoder would be a
strong Ludic feature — it is exactly the kind of error-prone, symmetric,
version-tagged code that a game language should generate rather than hand-write.

#### G-34 · Networking

90 packet types, reliable UDP with split packets and ack windows, and priority
block streaming. Depends on G-17, G-18, G-21, G-33. The packet definitions
themselves fall out of `serialize` (G-33) + `union` (G-06):

```ludic
packet ToClient {
  BlockData    = 0x20 { pos: v3i, block: MapBlock }
  AddParticle  = 0x46 { … }
  ActiveObjectMessages = 0x31 { msgs: []ObjectMsg }
}
```

---

## 6. Roadmap

Ten milestones. Each one **ends in something runnable** — that is the rule; no
milestone is "add a type system feature" with nothing to show. Effort estimates
assume one developer and are deliberately conservative.

### M0 — Language core, part 1: aggregates *(≈6 weeks)*
> **Gates:** G-01 arrays/slices · G-02 structs · G-05 sized ints

**Demo:** rewrite `runtime/native/image.ludic`'s PNG decoder to use
`[]u8` and `struct Pixel` instead of `mem_alloc` + `peek8`. Same output PNG,
half the lines, bounds-checked.

**Why first:** every other item in this document is blocked on it. The existing
runtime is the perfect proving ground — it is 3,700 lines of exactly the
hand-rolled pointer arithmetic these features exist to delete.

```ludic
# before (runtime/native/image.ludic today)
fn px(img: ptr, x: int, y: int, w: int) -> int { return peek32(img, (y*w+x)*4) }

# after
struct Rgba { r: u8, g: u8, b: u8, a: u8 }
fn px(img: []Rgba, x: int, y: int, w: int) -> Rgba { return img[y*w + x] }
```

### M1 — Language core, part 2: numbers, strings, errors *(≈6 weeks)*
> **Gates:** G-03 strings · G-04 `f32`/`fixed64` · G-06 enums/unions · G-07 math · G-09 errors

**Demo:** a `noise.ludic` implementing Luanti's `NoiseFractal3D` exactly, and a
headless program that renders a 512×512 heightmap PNG from it. Compare against
Luanti's own output for the same seed — **bit-comparable terrain is the
acceptance test.**

This is the milestone that closes the coordinate bug (G-04). Worth writing the
regression test first:

```ludic
system CoordRange phase Start {
  let far: fixed64 = 310070.0          # would wrap in Q16.16
  assert(flr64(far) == 310070)
  let d = far * far                     # 9.6e10 — must not wrap
}
```

### M2 — Platform *(≈5 weeks)*
> **Gates:** G-17 threads · G-19 time · G-18 sockets · G-20 dynamic loading · G-21 deflate encode

**Demo:** a headless Ludic program that spawns 4 worker threads, each generating
a 16³ noise chunk, deflate-compresses it, writes it to a file, and a second
process that reads it back — proving the thread pool, the compressor and the
round-trip.

**Note on the new WASM target.** A peer session just landed WebAssembly support
(`runtime/web/`, `test.sh` now 64/64), and `@main` is now split into
`ludic_boot/frame/alive/teardown` so a browser can drive the loop from
`requestAnimationFrame`. Two consequences for this roadmap: (a) threads on
wasm32 mean Web Workers + SharedArrayBuffer, not pthreads, so **G-17 needs a
per-target backend from day one**; (b) `size_t` is `i32` on wasm — new
intrinsics must go through `ll_size_t()`/`ll_widen()`/`ll_narrow()`, which
matters for every slice and array intrinsic added in M0.

### M3 — The voxel primitive *(≈8 weeks)*
> **Gates:** G-11 maps · G-12 ECS scale · G-13 attach/detach · G-22 `volume`/`manip`

**Demo:** **a flat 3D world you can fly through**, still software-rendered at
320×240 — a chunked `volume Map of MapNode chunk 16`, chunks generated on the
worker pool from M2, a free camera, and a simple raycast rasteriser for
visualisation. Ugly, slow, and unambiguously a voxel engine.

```ludic
volume Map of MapNode chunk 16 { origin v3i  meta { generated: bool } }

system Generate phase Update {
  for bp in pending_chunks() {
    manip vm = Map.borrow_chunk(bp)
    for p in vm.area {
      let h = flr(noise2d(fx(p.x) / 64.0, fx(p.z) / 64.0) * 24.0) + 8
      vm[p] = if p.y <= h { NODE_STONE } else { NODE_AIR }
    }
    vm.commit()
  }
}
```

### M4 — GPU + 3D *(≈10 weeks)*
> **Gates:** G-28 GPU FFI · G-29 3D math · G-23 meshing/lighting

**Demo:** the M3 world, **textured, lit and running at 60 fps** — greedy or
per-face meshing on a worker thread, day/night light banks propagated by BFS,
one shader program, a texture atlas from the existing PNG decoder.

This is where the project stops being a 2D game language and becomes capable of
Luanti's genre. It is also the milestone with the most schedule risk — bind
OpenGL 3.3 via `extern fn` first (Metal/WebGL later) and resist the temptation
to write a scene graph.

### M5 — Interaction *(≈6 weeks)*
> **Gates:** G-24 collision/raycast · G-30 UI (input, lists, scroll) · mouse input

**Demo:** **you can walk, jump, dig and place.** Swept-AABB player physics with
`stepheight`, a DDA raycast for pointing, a hotbar, and an inventory screen with
draggable slots. This is the first milestone that is *playable*.

### M6 — Definitions & registries *(≈5 weeks)*
> **Gates:** G-26 `def` blocks · G-27 metadata · G-16 ABM systems

**Demo:** 30 node types and 10 item types declared with `def node` / `def item`,
groups-based dig times, a chest with node metadata and an inventory, and lava
that cools into obsidian via an ABM-shaped system. **This is the milestone where
the language's ECS finally pays off visibly.**

### M7 — Persistence *(≈4 weeks)*
> **Gates:** G-33 `serialize` blocks · SQLite via FFI

**Demo:** quit and relaunch; the world, your inventory and your position are
exactly as you left them. Blocks written incrementally, zstd-compressed, keyed
by interleaved position — read Luanti's own `map.sqlite` as a compatibility
stretch goal.

### M8 — The mod ABI *(≈8 weeks)*
> **Gates:** G-25 mod model · G-20 loading · a versioned `ModApi`

**Demo:** a `mods/farming/` folder containing only `.ludic` source and textures;
drop it in, restart, and wheat exists — compiled on first load, cached as a
dylib. Then delete the folder and it is gone. **This is the milestone that makes
it Luanti rather than a voxel game.**

### M9 — Multiplayer *(≈12 weeks)*
> **Gates:** G-34 protocol · G-14 multiple worlds · G-18 sockets

**Demo:** two clients, one server, on separate machines: block changes,
movement, chat, and inventory sync. Client and server in one binary via
`world Server` / `world Client` (G-14) so singleplayer is just a loopback.

### Audio & i18n *(fold into M5–M8 opportunistically)*
> **Gates:** G-31 · G-32

### Timeline summary

| Milestone | Effort | Cumulative | Ends with |
|---|---|---|---|
| M0 aggregates | 6 wk | 6 wk | runtime rewritten on arrays/structs |
| M1 numbers/strings | 6 wk | 12 wk | Luanti-comparable noise terrain |
| M2 platform | 5 wk | 17 wk | threaded, compressed chunk I/O |
| M3 voxel primitive | 8 wk | 25 wk | flyable 3D voxel world |
| M4 GPU | 10 wk | 35 wk | textured, lit, 60 fps |
| M5 interaction | 6 wk | 41 wk | **playable: walk, dig, place** |
| M6 definitions | 5 wk | 46 wk | modded content, ABMs |
| M7 persistence | 4 wk | 50 wk | worlds that survive restart |
| M8 mod ABI | 8 wk | 58 wk | **drop-in mods** |
| M9 multiplayer | 12 wk | 70 wk | two clients, one server |

≈**70 developer-weeks** to a Luanti-class engine written in Ludic. For scale:
Luanti itself is 362,258 lines accumulated since 2010.

---

## 7. Decisions I need from you

These change the shape of the work and are yours to make, not mine. My
recommendation is given first in each case.

1. **Numerics: `fixed64` *and* `f32`, or just `f32`?**
   *Recommendation: both.* `fixed64` for gameplay/physics (deterministic
   lockstep multiplayer is a real advantage, and Luanti's float physics is a
   known source of desync); `f32` for noise and GPU vertex data, where it is
   non-negotiable.

2. **Mod distribution: source-and-compile-on-load, or prebuilt binaries?**
   *Recommendation: source.* `ludicc` is 2,508 lines — shipping the compiler
   with the game preserves the "drop a folder in" workflow that is Luanti's
   entire ecosystem, keeps one language end-to-end, and needs no VM.

3. **Mod sandboxing: accept native trust, or subprocess isolation?**
   *Recommendation: accept it for M8, revisit before any public server.*
   Luanti's `s_security.cpp` is 1,253 lines of Lua-specific confinement that has
   no native analogue; subprocess + IPC is the only real answer and it is a
   quarter of work on its own.

4. **GPU: FFI to OpenGL, or hand-written IR per platform like `cocoa.ll`?**
   *Recommendation: FFI.* It matches the project's existing posture toward
   libraries, and `cocoa.ll` is 327 lines for *five* window functions — OpenGL
   has hundreds of entry points.

5. **Compatibility: read Luanti's `map.sqlite` and speak protocol 37+, or a
   clean-room format?** *Recommendation: clean room, with a one-way importer.*
   Wire compatibility means implementing 90 packet types before anything is
   playable; it inverts the whole milestone order.

6. **Scope: the full engine, or a Luanti-shaped game?** Worth being honest with
   yourself here. M0–M6 (≈46 weeks) gets a genuinely good single-player voxel
   game and, more importantly, **makes Ludic a language that could plausibly
   build one.** M8–M9 are what make it *Luanti*, and they are half the budget.

---

## 8. Appendix A — target state

What `examples/voxel.ludic` would look like once M0–M6 land. This is the
document's thesis in one file: nothing here is expressible today, and all of it
is ordinary Ludic in shape.

```ludic
game Voxel {
  import "voxel/nodes.ludic"
  import "voxel/worldgen.ludic"

  # ---- data ---------------------------------------------------------------
  struct MapNode { param0: u16 = 0, param1: u8 = 0, param2: u8 = 0 }
  struct v3i      { x: int = 0, y: int = 0, z: int = 0 }
  struct v3f      { x: f32 = 0, y: f32 = 0, z: f32 = 0 }

  volume Map of MapNode chunk 16 {
    origin v3i
    meta { generated: bool = false, timestamp: u32 = 0 }
  }

  component Body   { pos: v3f, vel: v3f, aabb: aabb, on_ground: bool = false }
  component Look   { yaw: f32 = 0, pitch: f32 = 0 }
  component Health { hp: int = 20, max: int = 20 }
  component Inv    { slots: [32]ItemStack }

  archetype Player { Body, Look, Health, Inv }
  archetype Mob    { Body, Look, Health }

  # ---- content ------------------------------------------------------------
  def node Stone {
    name = "voxel:stone"  drawtype = DrawType.Normal
    tiles = ["stone.png"] groups = [("cracky", 3)]
    is_ground_content = true  drop = "voxel:cobble"
  }
  def node Water {
    name = "voxel:water"  drawtype = DrawType.Liquid
    tiles = ["water.png"] liquid = Liquid.Source { alt_flowing = "voxel:water_flowing" }
    walkable = false  light_propagates = true
  }

  # ---- generation, off the main thread ------------------------------------
  thread pool emerge count 4 {
    job Generate(bp: v3i) -> Chunk {
      manip vm = Map.stage(bp)
      for p in vm.area {
        let n  = noise2d(p.x as f32 / 64.0, p.z as f32 / 64.0, seed())
        let h  = flr(n * 24.0) + 8
        vm[p]  = if p.y > h      { NODE_AIR }
                 else if p.y == h { NODE_GRASS }
                 else             { NODE_STONE }
      }
      return vm.finish()
    }
  }

  system Emerge phase Update {
    for bp in Map.wanted(view_radius = 10) { emerge.submit(Generate(bp)) }
    while let c = emerge.poll() { Map.install(c)  relight(c)  remesh(c) }
  }

  # ---- simulation: an ABM as a first-class system -------------------------
  system LavaCooling phase Update
    every 10.0s  chance 1 in 50
    nodes [NODE_LAVA_SOURCE]  near [NODE_WATER_SOURCE, NODE_WATER_FLOWING]
  { Map[self_pos()] = NODE_OBSIDIAN }

  # ---- physics ------------------------------------------------------------
  system Physics phase FixedUpdate
    query (b) [Body]
  {
    b.vel.y = b.vel.y - 9.81 * dt()
    let r = collide_swept(Map, b.aabb, b.pos, b.vel * dt(), stepheight = 0.6)
    b.pos = r.pos
    b.on_ground = r.hit_floor
    if r.hit_floor { b.vel.y = 0.0 }
  }

  # ---- interaction --------------------------------------------------------
  system Dig phase Input
    query (b, l) [Body, Look, {Player}]
  {
    when mouse_pressed(MOUSE_LEFT) {
      match raycast(Map, eye(b), dir(l), 5.0) {
        Pointed.Node(under, _) => {
          let def = node_def(Map[under].param0)
          give(self(), def.drop)
          Map[under] = NODE_AIR
        }
        _ => {}
      }
    }
  }

  # ---- render -------------------------------------------------------------
  scene InGame start {
    layer World {
      system DrawWorld phase Render {
        gfx_begin(camera_of(local_player()))
        for c in Map.visible(frustum()) { gfx_draw_mesh(c.mesh) }
        gfx_end()
      }
    }
    layer Hud {
      system DrawHud phase Render { ui_render() }
    }
  }
}
```

**Read that against LANGUAGE.md.** The `system`/`query`/`phase`/`scene`/`layer`
/`archetype`/`match` skeleton is *unchanged* — every line of new capability is
either a type (`struct`, `f32`, `[]T`, `enum`) or one of four new constructs
(`volume`, `manip`, `thread pool`, `def`). That is the encouraging finding of
this whole exercise: **Ludic's programming model is already the right one for
this game. What is missing is underneath it, not around it.**

---

## 9. Appendix B — what Ludic already has that Luanti had to build

Not everything is a deficit. Ludic starts with several things Luanti spent years
acquiring, and they should be counted:

| Ludic has | Luanti equivalent | Cost Luanti paid |
|---|---|---|
| ECS in the language (`component`/`query`/`system`/`phase`) | hand-rolled `ActiveObjectMgr` + ad-hoc containers | scattered across `serverenvironment.cpp` (2,091) + `activeobjectmgr` |
| `scene`/`layer` state machine | mode flags and `if` ladders in `game.cpp` | part of 3,815 LOC |
| `match`/`machine`/`become` | switch chains | — |
| Retained `ui` tree as data | formspec **string DSL** parsed at runtime | `guiFormSpecMenu.cpp`, **5,610 LOC** |
| TrueType engine written in-language | FreeType + `CGUITTFont.cpp` (1,003) | external dep |
| PNG + DEFLATE decode in-language | libpng + zlib | external deps |
| Deterministic RNG in the language | `PcgRandom`/`PseudoRandom` exposed to Lua | — |
| Compile-time type checking of game logic | Lua: runtime errors on a live server | the entire class of mod crashes |
| One language for engine *and* content | C++ engine + Lua mods + a 1,253-line sandbox | the whole `src/script/` tree, **34,240 LOC** |

That last row is the strategic one. **A third of Luanti's engine — 34,240 lines
of `src/script/` plus 22,634 lines of `builtin/` Lua — exists solely to bridge
C++ and Lua.** A Ludic implementation with a compiled mod ABI (G-25) does not
need that bridge at all. Roughly 57,000 lines of Luanti are a tax that Ludic
would simply not pay.

---

## 10. Verdict

**Can Ludic implement Luanti today?** No — and not because of anything about
games. It is missing arrays, strings, structs, floats, threads and sockets. Any
language missing those cannot implement any large program.

**Is Ludic's design wrong for Luanti?** No — and this is the more interesting
answer. The ECS-in-the-language model, phases, scenes, archetypes and `match`
are a *better* fit for a voxel sandbox than C++-plus-Lua is. The `system … every
10.0s chance 1 in 50 nodes […]` form (G-16) compiles to something Luanti's ABM
implementation cannot achieve, because Luanti's predicates arrive as strings at
runtime and Ludic's arrive at compile time.

**What is the actual shortest path?** M0 and M1. Arrays, structs, strings,
floats. Twelve weeks that convert Ludic from a language that can express a
2D JRPG into one that can express an engine — after which every remaining gap in
this document is ordinary library work in Ludic, plus one hard call about mods
(G-25) and one large push on the GPU (G-28).

---

*Generated from `luanti-org/luanti@main` (362,258 LOC surveyed) against
`ludicc` at `compiler/{ludicc,native,driver}.c` and `runtime/native/*.ludic`.
Every Ludic limitation cited was verified by reading the compiler or by
compiling a probe program, not inferred from documentation.*
