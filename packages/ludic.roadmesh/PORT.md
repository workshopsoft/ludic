# ludic.roadmesh: the road chunk bake, native

The studio's per-chunk road bake (`roads_bake_chunks`, game-editor `packages/mcp/src/roadBake.ts` over `packages/core/src/world`)
ported to Ludic. The rules, the arithmetic order, the tie-breaks and the iteration orders are the TypeScript's, in double
precision, so the chunk files come out the same to the byte.

The studio keeps reading the rows, building the network and grading it (`gradeNetwork`). It writes a job (game-editor
`packages/mcp/src/roadNative.ts`): the network, the graded lines, the natural ground tiles near the meshed roads, the options. The
program `roadmesh_bake.ludic` builds the three meshes (LOD0 `mesh`, LOD1 `coarse`, LOD2 `far`), cuts them and writes every chunk
file: `<cx>_<cz>.glb`, `.col.glb`, `.crossings.json`, `.lanes.bin`, `lod1/<kx>_<kz>.glb`, `lod2/<kx>_<kz>.glb` and
`light_zones.json`. The studio writes them into the project and records the RoadBakes rows, the way `ludic.ground/conform_window`
works with `mcp/src/groundNative.ts`. It is on whenever `LUDIC_HOME` has this package (the studio builds the program when it is
missing or older than its sources); `LUDIC_ROADS_NATIVE=0` turns it off. The studio bakes in TypeScript as before when the job
cannot carry the ground (a heightmap or flat world, tiles of mixed sizes), when the program fails, when the program read a ground
sample the job left out, and for a window of chunks (`chunks`) or a scene recording (`scene`). The answer says `native: true`, or
`native: "off: <why>"`.

Branch `mvp/roadnative` in gpp, game-editor and occutown.

## Files

| TypeScript | Ludic file | what |
|---|---|---|
| geom.ts | geom.ludic | plan geometry (every export) |
| profiles.ts | profiles.ludic | cross-sections: sectionOf, offsetsOf, taperAt, walkwayOf, profiles from rows |
| polyMesh.ts | polymesh.ludic | constrained Delaunay tiling of a ring (polyMesh, starFrom) |
| meshBuilder.ts | meshbuilder.ludic | the Builder (tri, quad, poly, star, fine, ribbon, strip, slot), earClip, thick |
| junction.ts | junction.ludic | junctionOf, setbacks, cornerLevel, cornerOffsets, cornerRadius, endsOf, arc |
| corners.ts | corners.ludic | the strict corners (armOf, convexCorner, fitCorner, outsideCorner, cornerRails) |
| junctionSurface.ts | junctionsurface.ludic | edgeStations, nodeSurface (heights inside a junction), junctionRing, insideRing |
| network.ts, roadGrade.ts, stationLine.ts (read side) | netview.ludic | `NetEdge`, `NetNode` (its `around` and `edges`), `Net`, `EdgeGrade`, stationLine's pointAt and trim |
| sidewalk.ts (sidewalkOf), crossings.ts | world.ludic | `RWorld` (what every build shares: the network, its grades, the setbacks, the crossings planned, the natural ground, edgesNear) and `Sw` (one build's sidewalk: stations, junction, nodeY, nodeLvl, lvlAt, rampAt, bulb, each made once) |
| sidewalk.ts (helpers) | sidewalk.ludic | deadCap, discVertices, bulbRails, bulbArc, railPoints, densifyLine, thinRing |
| throughPath.ts | throughpath.ludic | throughPair, throughPath, pathPoint, pathCoords |
| medianThrough.ts | medianthrough.ludic | throughBarrier |
| lanePaint.ts | lanepaint.ludic | paintLanes, flushMedian, offChunkLines (lanePaintChecks.ts is not needed: the bake calls none of it) |
| (lanePaint's view) | paintview.ludic, glue.ludic | the `PaintWorld` the paint reads, filled from the native sidewalk as it is asked |
| roadStructures.ts | roadstructures.ludic | decks, piers, abutments, spans, tubes, light zones, portals, wing walls |
| roadMesh.ts | roadmesh.ludic | buildRoadMesh, the full bake only (strips, stairs, medians, skirts, nodes, crossings and their paint, structures, lane paint); the plain bake's slopes and block sides are never drawn by roads_bake_chunks |
| roadChunks.ts | roadchunks.ludic | chunkMesh, lodCells, farCells, collisionOf, laneLines, chunkLanes |
| roadGlb.ts, studio/folder.ts textHash | roadglb.ludic | roadGlb, lodCellGlb, collisionGlb, weldVertices, lanesBin, JSON as JSON.stringify writes it, textHash |
| mcp roadBake.ts (fullBake and its files) | bake.ludic | the job, the three builds, the files and the answer |
| mcp heights.ts tiledGround | world.ludic `Ground` | the 16-bit tiles on one texel grid, bilinear, a missing neighbour read from the home tile |
| (Math.sin, cos, tan, atan2, asin) | jsmath.ludic, trig.ludic | V8's fdlibm with Node's arm64 fused multiply-adds (exact software fma): the same bits as the studio's (jtan: 1 million random arguments, none differ) |
| (Number::toString) | util.ludic `js_number` | a double as JavaScript writes it (the glb JSON, the crossings, the notes; 200,000 numbers, none differ) |

Conventions: a `Pt[]` is a flat `[]double`; a closure is a function value plus its context (`b_star<C>`); no `numbers float`
(literals take their context's type: `let x: double = 0.5`); one literal for a whole-literal expression; no scientific notation, no
if-expressions (`dsel`, `isel`); read only what the TypeScript reads (never index both sides of a select). Where the studio keys a
Map by edge or node key, the port uses `[]` by `idx`. Ludic traps met: `<` on strings is not lexicographic (`str_lt`); `>>` on an
`int` is a logical shift; `push(xs, 0.0)` into a `[]double` emits bad IR (`ZERO_D`); slices have no `pop`; memory is never freed
(a bake of a 1 km cell peaks near 1.5 GB).

## The job and the answer

The job is one tagged value (the fixture format below, plus tag 10: raw bytes) after `"RNJB"` (i32 1112166994) and version 1:
```
forward, profiles: [RoadProfile], structures: [rows],
edges: [{key, from, to, line, s, length, lanesFwd, lanesBack, laneWidth, profile, taper, level, left, right, outerLeft, outerRight,
         missing, section}],                                          (the network's order)
nodes: [{key, x, z, kind, radius, edges: [edge idx], around: [edge idx, out]...}],
grades: [null | {line, s, y, len, scale, maxGrade}] by edge,          (gradeNetwork's, the whole network)
ground: {kind: none} | {kind: tiles, tileSize, originX, originZ, min, max, offset, res, tiles: [tx, tz, data index (-1: loaded by
         the studio, not sent)]..., data: [bytes]},                    (the tiles near the meshed roads)
opt: {skirt, skirtBelowGround, medians, crossings, markings, structures, lanePaint, areas, radii},
chunk, lod, far: {plan, y, max} | null, only: [edge keys] | null, box: [k0x, k1x, k0z, k1z, unit] | null, zonesAll,
hash: {base, param}, extras: {world, row, network}, tones
```
`roadmesh_bake <job.bin> <out dir> <answer.json> [times]` writes the files under `<out dir>` and answers in JSON: the chunks
(`chunk, tris, materials, crossings, lanes`), the files, the bytes, `lod1`, `lod2`, `crossings`, `paint`, `barriers`, `structures`,
`problems` (the grading's come from the studio, before them) and `groundMiss` (ground samples the job did not carry: the studio
then bakes in TypeScript). A fourth argument prints the phases' times. `LUDIC_ROADS_KEEP=<path>` makes the studio keep a copy of
its last job there.

Every core: the setbacks (a junction per node), the three builds and every tunnel's light zones, and every chunk's and LOD cell's
files run under `Job.parallel_for`. Each build has its own sidewalk (`Sw`) over the shared `RWorld`, which is read only once made.

## Proof

occutown `tools/roadnative/compare.mjs` bakes each scene with `LUDIC_ROADS_NATIVE=0` and native into two scratch folders of the
game and compares every chunk file byte for byte, and the answers:
```
cd <occutown worktree>
PATH=<gpp>/bin:$PATH LUDIC_HOME=<gpp> LUDIC_DEVLINK_PORT=0 LUDIC_STUDIO_CLI=<game-editor>/packages/mcp/dist/cli.mjs \
  node tools/roadnative/compare.mjs [gym rail f6 interchange village]
```
The gym's roads (41 files with the shared stage and OC-40's tile; 109 with the whole gym), its railway, and the island cells f6,
interchange and village: every file the same, every answer the same. Raising the crossings' paint 0.1 mm made the gym's `-1_0.glb`
differ, so the comparison sees a real change.

## Module fixtures

The parts were ported against the studio's own calls, recorded during a real bake, and they still run:
```
cd <gpp worktree>
PATH=<gpp>/bin:$PATH LUDIC_HOME=<gpp> ludic build packages/ludic.roadmesh/roadmesh_test.ludic -o build/tools/roadmesh_test
./build/tools/roadmesh_test <game-editor worktree>/packages/core/test/fixtures/roadnative/fix/*/*.fix
```
A record passes when every number is the same to the bit (NaN equals NaN, -0 differs from 0). JsMath is no longer bound to the
recorded trig (`trig.bin`): jsmath's own answers pass every junction record. The Sidewalk's methods and roadStructures now run on
the native world, so the chunk bytes check them instead (sidewalk_test keeps the drawing helpers).

1. **Scenes.** `roads_bake_chunks` with `scene: <abs path>/<name>.scene.json` writes the bake's inputs (the network, each build's
   options, the meshes' digests) and `<name>.ground.bin` (every ground height read). occutown `tools/roadnative/scenes.mjs` makes
   `gym`, `f6` (cell 0,1), `interchange` (cell 2,1) and `village` (cell -2,-3).
2. **Module fixtures.** In game-editor `packages/core`, `ROADNATIVE_EXPORT=1 npx vitest run test/fixtures/roadnative/export.test.ts`
   (base modules and the junctions, with `trig.bin`), `export-sidewalk.test.ts` (sidewalk, roadStructures) and
   `export-paint.test.ts` (throughPath, lanePaint, medianThrough) replay each scene and record each module's calls to
   `fix/<scene>/<module>.fix`. `scenes/` and `fix/` are gitignored.

Fixture format (little-endian): `"RNFX"` (i32 1481002578), i32 version 1, i32 record count; a record is str function, val args,
val result; a val is u8 tag: 0 undefined | 1 null | 2 false | 3 true | 4 f64 | 5 str | 6 array (i32 n, n vals) | 7 f64s (i32 n,
n f64) | 8 object (i32 n, n x (str key, val)) | 9 pts (i32 n, 2n f64) | 10 bytes (i32 n, n bytes: the job only); a str is i32 byte
length, utf-8.

| module | gym | f6 | interchange | village |
|---|---|---|---|---|
| geom | 2122 records, same | 5374, same | 5350, same | 5341, same |
| profiles | 1070, same | 1163, same | 1151, same | 1200, same |
| polyMesh | 328, same | 271, same | 170, same | 148, same |
| meshBuilder | 1192, same | 1611, same | 1611, same | 1570, same |
| junction | 994, same | 1938, same | 1890, same | 1963, same |
| corners | 1115, same | 1341, same | 1351, same | 1370, same |
| junctionSurface | 1011, same | 1550, same | 1489, same | 1667, same |
| sidewalk (helpers) | same | same | same | same |
| throughPath | 782, same | 325, same | 812, same | 829, same |
| lanePaint (2 whole paintLanes each) | 335, same | 351, same | 338, same | 277, same |
| medianThrough | 231, same | 660, same | 348, same | 294, same |
