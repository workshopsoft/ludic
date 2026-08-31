---
id: light
title: Light
order: 33
---

A software 2D light-accumulation pass over the framebuffer, run in a render phase after drawing the scene and before <a href="screen-show"><code>Screen.show</code></a>. <a href="light-ambient"><code>Light.ambient</code></a> multiplies the whole scene toward a tint — the night/cave modulate that darkens everything so lights add mood back on top. <a href="light-point"><code>Light.point</code></a> accumulates a radial glow that falls off with distance and clamps per channel, and <a href="light-occlude"><code>Light.occlude</code></a> registers rectangles that block a light's rays to cast hard shadows (cleared each frame with <a href="light-clear_occluders"><code>Light.clear_occluders</code></a>). Lighting is a rendering concern only — it never touches game state or replays — and it is fully deterministic (integer and Q16.16 fixed), so the same scene lights identically every run and in a headless render, keeping screenshots diffable. Colours are <code>0x00RRGGBB</code>. This is the imperative surface; consuming <code>Light2D</code>/<code>Occluder</code> components automatically, normal-mapped sprites and soft shadows are planned follow-ups. Related: <a href="screen"><code>Screen</code></a>, <a href="color"><code>Color</code></a>, <a href="camera"><code>Camera</code></a>.
