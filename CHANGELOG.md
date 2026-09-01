# Changelog

All notable changes to the Ludic toolchain, newest first. Generated from the
changesets under changes/ by x release; do not edit released sections by hand.

## v0.2.0 — 2026-09-01

The types-and-systems release. Ludic grows a real type system — sum types,
`option`/`result`, exact and arbitrarily-big numbers, string-keyed containers and
packed 2D value types — alongside an engine that auto-runs animation, motion and
lighting over components a game merely declares, a full input stack from
rebindable action maps to native gamepads, out-of-band Audio / HTTP / Jobs
standard libraries, and a built-in test framework with line coverage. Every
addition is gated and additive: a program that never touches a feature compiles
byte-for-byte identically, and the C-free bootstrap fixpoint is untouched.

### Language & types

- **feat**: Tagged-union enums (#56) — an `enum` variant may now carry a payload (`enum Tile { Empty, Wall, Door(int), Portal(int, int) }`), making it a sum type. Variants construct by name and `match` destructures them, binding each payload, with exhaustiveness and arity checked so adding a variant surfaces every site to update. Plain enums keep their zero-cost ordinal representation, byte-for-byte unchanged.
- **feat**: `result` + `try`/`else` (#46) — a fallible function returns `ok(payload)` or `err(message)`, and `try EXPR else { … }` recovers a value with the failure message bound to `error`. A plain branch on the tag: no exceptions, no stack unwinding. `is_ok`/`is_err` classify without unwrapping.
- **feat**: `option` (#53) — `some(v)` / `none()`, a maybe-a-value with no magic `-1` sentinel, read with `is_some`/`is_none`/`unwrap_or`.
- **feat**: `panic(msg)` + `assert(cond, msg)` (#8) — a clear, located `file:line: panic:` / `assertion failed:` message and a clean exit 1 instead of a raw segfault; the source location is baked in at compile time.
- **feat**: `IVec2` + `Rect` 2D value types (#1) — by-value spatial types that lower to packed integers, so they copy like scalars and never allocate: an integer 2D vector for grid coordinates and a Q16.16 axis-aligned rectangle for HUD boxes and hitboxes, both exact and platform-identical.
- **feat**: `BigInt` + `Decimal` exact numbers (#52) — arbitrary-precision integers and exact base-10 fixed-point for game economies, so an idle counter never overflows and `0.10 + 0.20` is exactly `0.30`. No `f32`/`f64`; deterministic.
- **feat**: `Huge` + `Angle` + `Percent` (#55) — a display-scale idle/incremental big number (`1.23e45`), an auto-wrapping radian angle over deterministic `Math.*` trig, and a `[0,1]`-clamped fraction for health, volume and interpolation `t`.
- **feat**: `Dict` + `Set` containers (#54) — string-keyed lookups over one open-addressing hash table (FNV-1a, linear probing, tombstones), for resource counts, registries, tags and visited tiles; O(1) average instead of a linear scan.
- **feat**: Value tree + reflection + JSON (#44) — a self-describing `Value` node, `Reflect.serialize`/`apply` to walk an entity's whole component set to and from it bit-exactly, and `Json.encode`/`parse` for compact, stable, diffable text. One-call save/load for entities and the backbone of data-driven tooling.

### Engine, animation & lighting

- **feat**: Engine-owned systems (#43) — the ECS hook that auto-runs a system each frame over a component a game merely declares, no `handler` wired: `SpriteAnim` advances sprite-sheet frames and `Motion` advances value tweens for free. Built on the reflection ABI, so it costs nothing in a game that declares neither.
- **feat**: Animation ergonomics (#48) — an ergonomic layer over those systems: `Anim.clip`/`Anim.play` for named spritesheet clips, `Anim.on_frame`/`fired` frame events, `Motion.to` one-call tweens, and fluent engine-advanced `Tween` handles (`to`/`chain`/`delay`/`parallel`/`stop`). All integer and deterministic under replay.
- **feat**: `Light.*` 2D lighting (#4) — a deterministic software light-accumulation pass over the framebuffer: `ambient` tinting, additive radial `point` lights with linear falloff, and hard shadows cast against rectangular occluders. Integer + Q16.16, identical every run and headless.
- **feat**: ECS-native lighting (#47) — a torch is now just an entity carrying `Light2D`, a wall an `Occluder`, and one `Ambient` sets the night tint; the engine runs the whole light pass at the end of the Render phase with no `Light.*` calls wired by hand.
- **feat**: Lighting render-quality tiers (#49) — cone/flashlight `spot` lights, a `falloff` exponent, `soft` penumbra shadows, colour `gel` cookies, normal-mapped surfaces (N·L) and a `time_of_day` day/night ramp, all on the same deterministic accumulation core and consumable via optional `Light2D` fields.

### Input

- **feat**: Action maps + record/replay (#7) — gameplay reads named, rebindable actions instead of physical keys, and the single per-frame `Input.poll` makes deterministic replay fall out for free: `Input.record` captures the tape and `Input.replay` feeds it back exactly — the seed of lockstep netcode.
- **feat**: Device layer (#50) — multiple simultaneous held keys, analog axes and a normalized vector, the mouse (position/delta/buttons/wheel), gamepads and touch, all injectable on every target (`Input.press`/`set_mouse`/`set_pad`/`set_touch`) and snapshotted whole into the replay tape.
- **feat**: Native hardware bindings (#51) — the device layer's macOS side wired into cocoa.ll: live cursor position, per-frame GameController polling into gamepad buttons/axes (SDL button order), and NSTouch routing, all DCE'd out of a headless build. No API changes.

### Standard library

- **feat**: `Audio.*` (#22) — sound effects and music over a new AVAudioPlayer backend: `load`/`play`/`play_music`/`stop`/`volume`/`pitch`/`is_playing`. Out-of-band (real-time, not part of the simulation) but frame-driven, so a replay fires the same sounds at the same frames; headless builds carry it as dead-stripped no-ops.
- **feat**: `Http.*` (#6) — a poll-based HTTP/HTTPS client for out-of-band data (leaderboards, cloud saves, remote config) that never blocks the frame, over an NSURLConnection transport with system TLS on by default. Pairs with `Json.parse`; the response parser is pure Ludic and tested offline.
- **feat**: Jobs, Promises & opt-in Sync (#14) — a layered concurrency library. `Job.*`/`Promise.*` are the safe default: cooperative futures pumped a little each frame so heavy work spreads out, combined with `Promise.all`/`race`. The advanced `Sync.*` tier adds mutexes, atomics and bounded channels. A deterministic cooperative scheduler — results are collected on the main thread and a Job never touches the world directly, so lockstep and replays stay bit-exact.

### Testing & tooling

- **feat**: Built-in test framework (#12) — a `test "name" { … }` block auto-discovered and run by a synthetic runner (no `entry` to write), with `expect`/`expect_eq`/`expect_near` assertions that report every failure and exit non-zero. `expect_near` carries the tolerance fixed-point game math needs.
- **feat**: Line coverage (#45) — compile with `--coverage` and the compiler instruments each statement with a per-line hit counter dumped at exit; `bin/x test --coverage` aggregates the dumps into a per-file report naming the unreached lines. Flag-gated and additive — an ordinary build stays byte-identical.

### Fixes

- **fix**: `const` of a non-int type is no longer miscompiled. A `const` reference lowered to its initializer's raw integer bits typed as `int`, so `const X: fixed = 10.0` computed as the raw Q16.16 value `655360` instead of `10.0` — silently corrupting fixed-point math (and, in one case, spinning an infinite loop). Const references now emit their initializer with its real type. Every existing const is an `int` literal, so the lowering there is byte-identical and the bootstrap fixpoint and golden renders are unchanged.

## v0.1.0 — 2026-08-30

- **ci**: Continuous integration — Forgejo Actions workflows build the toolchain from the seed, run the regression + editor suites, assert the C-free bootstrap fixpoint, and lint commit messages on every push and pull request.
- **feat**: Editor tooling — `ludic-fmt` (formatter) and `ludic-lsp` (language server), plus VS Code and JetBrains integrations, all built by the toolchain.
- **feat**: Namespaced standard library — Math, Text, List, Random, Time, Screen, Color, Ease, Collide, Memory, Vector, DateTime/Date/Duration/Clock, Unicode, Os, Fs/Path/Mime, Log, Noise, Hash, Crypto and Uuid, each deterministic where a game needs it.
- **feat**: Native 2D backend — an ECS core with a deterministic fixed-point (Q16.16) runtime, a windowed Cocoa target on macOS and a headless PPM renderer that runs anywhere.
- **feat**: Self-hosted, C-free toolchain — the compiler, runtime, task runner and editor tools are all written in Ludic and built from a checked-in LLVM-IR seed with clang alone; `x bootstrap-cfree` proves the compiler rebuilds itself byte-for-byte.
- **feat**: Versioning and releases — SemVer with `ludicc --version`, a changeset-driven `CHANGELOG.md`, and `x release` to bump, tag, and publish a Forgejo release with source and toolchain artifacts.
