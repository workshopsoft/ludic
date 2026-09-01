---
id: collision
title: Collision
order: 6
---

2D overlap tests on integer coordinates (pixels or tiles). Rectangles are <code>(x, y, w, h)</code> from the top-left; circles are <code>(x, y, r)</code>. Each returns a bool. Squared distances are computed in 64-bit so large coordinates never overflow.

These are static boolean tests. For a *moving* body with real collision resolution, the engine ships a physics-lite movement system built on the same integer math — declare the well-known components and the engine advances them for you each frame, no handler wired:

- <code>property Body { vx, vy, gravity, max_fall, rx, ry, policy, on_ground, hit_wall, hit_ceiling }</code> — velocity/accel state in Q16.16 fixed-point (<code>vx</code>/<code>vy</code>/<code>gravity</code>/<code>max_fall</code>), engine-owned sub-pixel accumulators (<code>rx</code>/<code>ry</code>), an integration <code>policy</code> (<code>0</code> platformer with gravity, <code>1</code> top-down), and the derived contact flags the engine sets each frame.
- <code>property Collider { w, h, offx, offy, is_trigger, one_way, layer, mask, hit, entered, exited }</code> — an AABB shape offset from the entity's <code>Position { x, y }</code>, with layer/mask filtering, one-way-platform and trigger flags, and per-frame trigger outputs.
- <code>property Solids { tile, wall, oneway }</code> — an optional single config entity that turns on the tile-grid broadphase over the <a href="map"><code>Map</code></a> tilemap (<code>tile</code> px size, the solid <code>wall</code> glyph, and an optional one-way <code>oneway</code> glyph).

The engine-owned <code>esys_move</code> system (Update phase) integrates velocity and gravity into a tentative move, then resolves it with a per-axis **swept AABB** — against both solid <code>Collider</code> entities and the tile grid — so a fast body never tunnels through a wall. It handles one-way platforms (which block only a downward landing), reports trigger/sensor overlaps without resolving them, and sets <code>on_ground</code> / <code>hit_wall</code> / <code>hit_ceiling</code> for a controller to read. Everything is integer and deterministic, so movement reproduces exactly under replay, lockstep and <code>world_save</code> snapshots. Contact is surfaced as polled flags (the <code>SpriteAnim.event_fired</code> shape) rather than engine-emitted events, so a game raises its own <code>CollisionResolved</code> / <code>TriggerEntered</code> events from its handler with no coupling. This is the shared foundation the built-in gameplay controllers build on. Related: <a href="grid"><code>Grid</code></a>, <a href="map"><code>Map</code></a>, <a href="motion"><code>Motion</code></a>, <a href="annot-enginesystem"><code>@EngineSystem</code></a>.
