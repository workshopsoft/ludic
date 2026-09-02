# RFC — position & vector numeric types (#78)

Status: **decided — keep the deterministic integer core; add the three things
that were actually missing, all deterministic.** This document is the record of
the investigation asked for in issue #78, and the rationale for the decision.

## The question

Positions are integer pixels and velocities are `fixed` (Q16.16). For a general
2D engine that looked limiting: sub-pixel movement, large/scrolling worlds,
camera zoom, precision. Issue #78 asked whether Ludic should grow an `f32`/`f64`
and/or `i64` option for `Position` and the `Vector` type, and whether `Position`
should be a typed `Vector` rather than raw `int` fields.

## The hard constraint: determinism is the product

Ludic's engine is integer and Q16.16 fixed-point **on purpose**. The value
proposition that everything else is built on — `Input.record`/`replay`, lockstep
netcode (N0–N6), `world_save` snapshots that reproduce bit-for-bit, headless
golden renders — all rest on one property: *the same inputs produce the same
bytes on every machine, every run.*

IEEE `f32`/`f64` breaks that. Float results depend on rounding-mode flags, FMA
contraction, x87 vs SSE, compiler `-ffast-math`, and library `sin`/`sqrt`
implementations that differ across platforms and libc versions. A physics step
that diverges by one ULP on frame 1 desyncs a lockstep match by frame 10 000.
This is why the language deliberately has **no `f32`/`f64`** (see the v0.2.0
changelog and the `Decimal`/`BigInt`/`Huge` types, which exist precisely so a
game never reaches for a hardware float).

So the framing "add a float option" is answered first at the language level:
**Ludic will not add hardware floating point to the deterministic path.** Any
float would have to be opt-in *and* fenced out of every deterministic subsystem,
which is a large, permanent tax on the whole engine for a convenience that fixed
point already delivers. Rejected.

## What was actually limiting (and the deterministic answer to each)

The issue lists four concrete pains. None of them actually needs floats:

### 1. Sub-pixel movement

Already solved, and now documented as the canonical pattern. `Position` stays
integer pixels — that is the *rendered* location, and a framebuffer pixel is the
smallest thing you can draw. Motion accumulates in Q16.16 and only the integer
part reaches `Position`. The move system already does exactly this: `Body`
carries `rx`/`ry` sub-pixel remainder accumulators (Q16.16), integrates
`vx`/`vy` (Q16.16) into them each frame, and moves `Position` by the whole-pixel
carry. A body moving 0.3 px/frame advances one pixel every ~3 frames, exactly and
identically on every machine. **Decision: keep integer `Position`; the remainder
lives in `Body` (or a controller's own accumulator).** No type change.

### 2. Large / scrolling worlds

Integer pixels in `i32` reach ±2.1 billion — a 2-billion-pixel-wide world at
1 px = 1 px. That is not the real limit. The real limit is that a *tile* world
addressed in pixels loses range if tiles are large. **Decision: world extent is a
range question, not a representation question.** For the rare game that needs
more than ±2e9 px of contiguous space, the deterministic answer is a wider
integer (`i64`), not a float — and Ludic already ships exact wide integers
(`BigInt`) and a display-scale big number (`Huge`) for scores/economies. A future
`Position64` opt-in (i64 x/y) is a clean additive change *if a real game hits the
wall*; none has, so we do not add speculative width now. Camera scroll itself is
just a draw offset (`Camera.set`/`follow`, already threaded through the two
framebuffer chokepoints) and needs no coordinate change at all.

### 3. Camera zoom

Zoom is a **render-time** transform, not a world-coordinate change. Multiplying
world→screen by a Q16.16 scale in the blit path is deterministic (fixed×fixed with
a 64-bit intermediate, exactly as the existing sprite-scale and light math do).
Zoom does not require `Position` to be a float — the world stays integer, the
*camera* carries a Q16.16 zoom. **Decision: zoom belongs on the camera as a
Q16.16 scale (future `Camera.zoom`), reusing the existing fixed-point blit; the
coordinate types are untouched.**

### 4. Precision

"Precision" here means sub-pixel motion (answered in §1) and smooth rotation.
Rotation already runs over deterministic `Math.*` trig and the `Angle` type
(auto-wrapping radians over integer trig). Q16.16 gives ~1/65 536 px resolution —
finer than any pixel a game draws. There is no precision problem that a float
would fix that fixed point does not already cover for a 2D pixel engine.

## Should `Position` be a typed `Vector`?

This is the one genuinely appealing part of the proposal, and it is **orthogonal
to the numeric-type question** — it is about ergonomics and the ABI, not floats.

- `IVec2` (packed i64 integer 2-vector, #1) already exists and is the natural
  type for grid coordinates and integer positions.
- Making the engine-ABI `Position` *be* an `IVec2` would be a nice unification,
  **but** the reflection ABI (`World.get`/`set`, `world_save`, netcode deltas)
  addresses component *fields* by name (`Position.x`, `Position.y`) as individual
  `i32` slots. Every engine system (move, bounds, sprite-render, lighting) and
  every serialized save reads those two fields. Repacking `Position` into a single
  `IVec2` field would churn the entire reflection/save/net surface for a cosmetic
  win, and `IVec2` is *already* available to games that want vector math on a
  copy (`let p = IVec2.make(Position.x, Position.y)`).

**Decision:** keep `Position { x: int, y: int }` as the canonical ABI component
(now shipped from `ludic.core`, #77), and let games use `IVec2`/`Vector` freely
for by-value math, converting at the boundary. Position is a *component* (named,
reflected, saved, networked); `IVec2` is a *value* (packed, copied, does math).
Conflating them would cost more than it pays.

## Summary of decisions

| Concern              | Verdict                                                            |
|----------------------|-------------------------------------------------------------------|
| `f32`/`f64` positions | **No.** Breaks determinism; that is the whole product. Use fixed.|
| `i64` positions       | Deferred, additive later (`Position64`) only when a real game needs >±2e9 px. Not speculative now. |
| Sub-pixel motion      | Already solved; `Body.rx`/`ry` Q16.16 accumulators, now documented as the pattern. |
| Large worlds          | Range, not representation; `i32` px is ±2e9. Wide ints (`BigInt`) exist. |
| Camera zoom           | Render-time Q16.16 scale on the camera (future `Camera.zoom`), not a coordinate change. |
| `Position` as `Vector`| **No.** `Position` is a reflected/saved/networked *component*; `IVec2` is the *value* type for math. Convert at the boundary. |

The deterministic integer + Q16.16 core stays. The genuinely-missing pieces are
either already present (sub-pixel), belong on the camera (zoom), or are clean
additive opt-ins to defer until a game demands them (i64 extent). No change to the
`Position`/`Vector` representation is warranted, and adding hardware floats is
explicitly rejected.
