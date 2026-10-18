# ludic.roadmesh: the road chunk bake, native

The studio's road chunk bake (`roads_bake_chunks`, game-editor `packages/core/src/world`) ported to Ludic. The rules, the arithmetic order,
the tie-breaks and the iteration orders are the TypeScript's, in double precision, so the meshes come out the same to the bit. When
the port is done, the studio keeps reading the rows and building the network (netCtx, the grading inputs), writes a job, and runs
this package's program. The program builds the meshes and writes the chunk files (glb render and collision, lanes.bin,
crossings.json, LOD1 and LOD2). The studio then records them, the way `ludic.ground/conform_window` works with `mcp/src/groundNative.ts`.

Branch `mvp/roadnative` in gpp, game-editor and occutown.

## Module map

| TypeScript (core/src/world) | lines | Ludic file | depends on | status |
|---|---|---|---|---|
| geom.ts | 362 | geom.ludic | util | ported, verified (every export) |
| profiles.ts | 251 | profiles.ludic | util, fixture (Val) | ported, verified (walkwayOf, profileOfPlain, sectionOf, offsetsOf, taperAt) |
| polyMesh.ts | 284 | polymesh.ludic | geom | ported, verified (polyMesh, starFrom) |
| meshBuilder.ts | 361 | meshbuilder.ludic | geom, polymesh | ported, verified (Builder tri, quad, poly, star, fine, ribbon, strip, slot; earClip, visibleFrom, thick) |
| stationLine.ts | 80 | stationline.ludic | geom | next |
| crossings.ts | 151 | crossings.ludic | geom, profiles, network | next |
| roadGrade.ts (+ curve.ts as needed) | 289 | roadgrade.ludic | geom, network | next (the job may carry the grades instead: see the job) |
| network.ts (only what the bake reads: around, edgesNear, nodeHeight, the edge and node records) | part | network.ludic | geom, profiles | next |
| junction.ts | 443 | junction.ludic | corners, geom, network, profiles | to do |
| junctionSurface.ts | 254 | junctionsurface.ludic | geom, junction, network, profiles, roadGrade, stationLine | to do |
| corners.ts | 343 | corners.ludic | geom, junction, junctionSurface, stationLine | to do (one unit with junction and junctionSurface: they import each other) |
| sidewalk.ts | 773 | sidewalk.ludic | corners, crossings, geom, junction, junctionSurface, network, profiles, roadGrade, stationLine | to do |
| throughPath.ts | 168 | throughpath.ludic | geom, paintview | ported, verified (throughPair, throughPath, pathPoint, pathCoords; armToNode inside throughPath) |
| medianThrough.ts | 57 | medianthrough.ludic | meshbuilder, paintview, throughpath | ported, verified (throughBarrier) |
| roadStructures.ts | 602 | roadstructures.ludic | geom, meshBuilder, network, profiles, sidewalk | to do |
| lanePaint.ts | 777 | lanepaint.ludic | geom, meshbuilder, paintview, throughpath | ported, verified (paintLanes whole, flushMedian, offChunkLines) |
| lanePaintChecks.ts | 204 | (none) | | not needed: the bake calls none of it (roadMesh imports only flushMedian, offChunkLines, paintLanes) |
| roadMesh.ts (+ the part of blocks.ts it reads) | 931 | roadmesh.ludic | everything above | to do |
| roadChunks.ts | 461 | roadchunks.ludic | junctionSurface, meshBuilder, roadMesh, sidewalk | to do |
| roadGlb.ts | 428 | roadglb.ludic | roadMesh | to do |
| (the program) | | roadmesh_bake.ludic | all | to do: job in, chunk files out |

Shared files:
- `paintview.ludic`: what the lane paint, the through paths and the barrier read of the network and the sidewalk (a `PaintWorld`:
  the edges' plain fields, the nodes, and by edge the stations, the laid line and the crossings, by node the junction). The
  fixtures fill it with the studio sidewalk's answers; when sidewalk, junction and junctionSurface are ported, roadMesh fills it
  from them (or those parts answer through it). A node's height (`Sidewalk.nodeY`) stays a function value: `yf(yc, node, x, z)`.
- `util.ludic`: JavaScript's `Math.max`, `Math.min`, `Math.round` and `Math.sign` with V8's NaN and signed-zero rules, `INF` and `NAN`,
  selects (Ludic has no if-expression), and points as flat `[]double` (x0, z0, x1, z1, ...).
- `fixture.ludic`: the tagged-value reader (`Val`) and the checks (`Check`) every module test uses.

Conventions of the port:
- A `Pt[]` is a flat `[]double`. A `Pt | undefined` answer is `null`. A small record answer is a slice of its numbers (in the
  record's field order) or a property when later modules read it by name (`Section`, `Offsets`, `PolyMesh`).
- A closure the TypeScript passes (a `yOf`, a ground) is a function value plus its context, `yf(yc, x, z)`. The method is generic
  in the context's type (`b_star<C>`), so each caller passes its own record and no allocation or cast is needed.
- No `numbers float`: literals take the type of their context. A literal with nothing typed beside it is `fixed`, so write
  `let x: double = 0.5` and never `let x = 0.5`. Write a whole-literal expression as one literal (`0.999999`, not `1.0 - 0.000001`).
  Do not use scientific notation, and do not use if-expressions (use `dsel` and `isel`).
- Read only what the TypeScript reads. An expression like `onA ? A[i + 1] : B[j + 1]` must not index both sides, or an
  out-of-range index stops the program.
- `Math.hypot` is `hypot2` and `hypot3` (V8's algorithm, the same bits). `Math.atan2` is libm's. It is used only under a 1e-6
  tolerance (starFrom), where the last bit does not matter.
- Module `roadmesh`: a name is private unless it says `export`. The test program is `friend module roadmesh_test` and sees everything.

## Fixtures

The fixtures are the studio's own calls, recorded during a real bake.

1. **Scenes.** `roads_bake_chunks` takes `scene: <abs path>/<name>.scene.json`. It writes the bake's inputs: the network as the
   builds get it, each `buildRoadMesh` call's options (`junction.radius` as `radii`, the bake's corners by profile), the meshes'
   digests, and `<name>.ground.bin`, which holds every natural ground height the bake asked for (f64 x, z, y; NaN means no ground). Make them with
   occutown's `tools/roadnative/scenes.mjs`. It covers the gym's whole network and three island LOD1 cells: `f6` (cell 0,1:
   downtown), `interchange` (cell 2,1: two Island Motorway interchanges) and `village` (cell -2,-3: a hill village with 61 stairs
   and path nodes).
   ```
   cd <occutown worktree>
   PATH=<gpp>/bin:$PATH LUDIC_HOME=<gpp> LUDIC_DEVLINK_PORT=0 LUDIC_STUDIO_CLI=<game-editor worktree>/packages/mcp/dist/cli.mjs \
     node tools/roadnative/scenes.mjs <game-editor worktree>/packages/core/test/fixtures/roadnative/scenes [gym f6 interchange village]
   ```
   (Build the studio first: `cd packages/mcp && npm run build`. One run takes about 20 s.)
2. **Module fixtures.** `packages/core/test/fixtures/roadnative/export.test.ts` replays each scene through `buildRoadMesh`. Each
   replay must give the bake's digests, which proves the scene holds everything. `vi.mock` wraps every export of the listed
   modules (and the Builder's methods) and records their outermost calls to `fix/<scene>/<module>.fix`. A first pass counts the
   calls and the second keeps every n-th call, so each function gets at most `CAP` calls (300, fewer for the big Builder methods).
   Functions the bake never calls (most of geom, earClip, visibleFrom) are called on rings made from the scene's own lines.
   ```
   cd <game-editor worktree>/packages/core
   ROADNATIVE_EXPORT=1 npx vitest run test/fixtures/roadnative/export.test.ts      # ~1 min, 34 MB for the four scenes
   ```
   `scenes/` and `fix/` are gitignored (10 MB per island scene): make them again with the two commands.

**Fixture format** (`fixfile.ts` writes it and `fixture.ludic` reads it). It is little-endian:
```
file    "RNFX" (i32 1481002578), i32 version 1, i32 record count, records
record  str function, val args (an array), val result
val     u8 tag: 0 undefined | 1 null | 2 false | 3 true | 4 f64 | 5 str | 6 array (i32 n, n vals) | 7 f64s (i32 n, n f64)
        8 object (i32 n, n x (str key, val)) | 9 pts (i32 n, 2n f64)
str     i32 byte length, utf-8
```
An array of numbers is written as f64s and an array of `[x, z]` pairs as pts. Because the argument list is an array too, read
arguments with `rarg(r, i)`, `arg_n`, `arg_nd` (with a default), `arg_bd`, `arg_pt`, and `v_item`. These take any of the three
forms. A Builder method's record is `[uv, level, ...arguments]`, with a `yOf` replaced by the table of points it was asked
(`{pts, ys}`). Its result is `{tris, layers: [{material, positions, normals, uvs, indices, levels}]}`: what the call appended,
with indices counted from the layer's first new vertex.

## Tests

```
cd <gpp worktree>
PATH=<gpp>/bin:$PATH LUDIC_HOME=<gpp> ludic build packages/ludic.roadmesh/roadmesh_test.ludic -o build/tools/roadmesh_test
./build/tools/roadmesh_test <game-editor worktree>/packages/core/test/fixtures/roadnative/fix/*/*.fix
```
The module is the file's name (`geom.fix` runs `test_geom`). A record passes when every number is the same to the bit (NaN
equals NaN, and -0 differs from 0). The program prints a tally for each function and the first 12 differences. It exits 1 if
any record differs. The 16 fixtures (4 scenes x 4 modules) run in 0.4 s.

**Adding a module (a part agent):**
1. In game-editor `export.test.ts`, add the module to `MODULES` and a `vi.mock('../../../src/world/<module>', ...)` line with
   `R.wrapAll`. Wrap a class's methods as the Builder's are. If some exports are never called by the bake, call them in
   `replay()` on the scene's data. Run the exporter. `fix/<scene>/calls.json` lists the call counts.
2. Port the module as `<module>.ludic` here and import it in `index.ludic` in dependency order.
3. Write `test/<module>_test.ludic` with `export function test_<module>(recs: []Rec) -> int`. Use `check_rec` once per record,
   then `check_num(v)`, `check_nums`, `check_ints`, `check_bool` and `check_str` against `r.res`, and end with `check_report(c)`.
   Import it in `roadmesh_test.ludic` and add its line in `run_one`.
4. Build and run as above until every record of every scene is the same. A difference is a bug unless it is proven to be
   last-bit float noise, and then it must stay within the bake's quantisation (millimetres, `roadChunks.mm`).

## The job (draft)

The job uses the fixtures' tagged values, a single `val` after a header (`"RNJB"`, version). The program answers with the files
it wrote and a summary (`"RNJA"`). The studio side is `mcp/src/roadNative.ts`, beside `groundNative.ts`. It is turned on when
`LUDIC_HOME` has the program, and `LUDIC_ROAD_NATIVE=0` turns it off.

```
{
  net:    { def: { forward, sidewalk, curve }, nodes: [...], edges: [...], turns: [...], profiles: [[key, RoadProfile]], structures: [...] }
          (the scene's network: edges as NetEdge with line, s, at, section, left/right, outer*, heights; RoadScene.net)
  builds: [{ label: 'mesh' | 'coarse' | 'far', opt, gradesFrom?, radii? }]       (as RoadScene.builds)
  ground: { tiles: [{ tx, tz, w, h, x0, z0, texel, min, max, data: u16 }] }      (the natural tiles the box reads, sampled as
          heights.ts tiledGround does, ported); until that sampler is ported, the recorded heights (scene .ground.bin)
  grades: optional, gradeNetwork's EdgeGrade by edge (if roadGrade stays in the studio for a first cut)
  chunk, lod, box: { rect, edges, chunks }, dir, prefix, hashes by chunk (the studio's roadBakeHash: the program writes it into glb extras)
  out:    which files: glb, col.glb, lanes.bin, crossings.json, lod1, lod2, light_zones.json
}
```
Answer: for each chunk, the triangle and material counts and the files, plus the LOD cells, the crossings, the structures and
the problems, which is what `roads_bake_chunks` answers today. Chunks are built in parallel with `Job.parallel_for`, one LOD unit
per worker, and workers may allocate.

## Order

1. Base, done: fixtures, skeleton, geom, profiles, polyMesh, meshBuilder.
2. stationLine, crossings, the network's read side, roadGrade.
3. junction, corners and junctionSurface as one unit, because they import each other.
4. sidewalk, then throughPath and medianThrough.
5. roadStructures and lanePaint (with the part of lanePaintChecks the bake calls), which can run in parallel.
6. roadMesh. Its fixture is the whole build: every layer of `mesh`, `coarse` and `far` against the scene's meshes.
7. roadChunks and roadGlb, then the program and the studio's `roadNative.ts`. The check is the chunk files byte for byte
   against the TypeScript bake, on the gym and then on the district.

## Verified

| module | gym | f6 | interchange | village |
|---|---|---|---|---|
| geom | 2122 records, same | 5374, same | 5350, same | 5341, same |
| profiles | 1070, same | 1163, same | 1151, same | 1200, same |
| polyMesh | 328, same | 271, same | 170, same | 148, same |
| meshBuilder | 1192, same | 1611, same | 1611, same | 1570, same |
| throughPath | 782, same | 325, same | 812, same | 829, same |
| lanePaint (2 whole paintLanes each) | 335, same | 351, same | 338, same | 277, same |
| medianThrough | 231, same | 660, same | 348, same | 294, same |

lanePaint's and medianThrough's records carry what the call read of the sidewalk (a recording sidewalk in `export.test.ts`
notes every junction, stations, laid line, crossing list and node height asked), the road surface the paint is laid on and
what was appended. A native call that asks for something the studio did not ask fails the record. Changing LINE_CLEAR to
0.021 made both gym paintLanes records differ.

To check that the harness catches a real difference, the ribbon's zip condition was inverted. The test then reported the
ribbons' positions, normals (including -0 against 0) and uvs as different.
