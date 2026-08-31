---
id: anim
title: Anim
order: 28
---

Spritesheet frame animation off the fixed frame clock. Store an elapsed <code>timer</code> (seconds, a <code>fixed</code>) on a component and each frame ask <a href="anim-frame"><code>Anim.frame</code></a> / <a href="anim-once"><code>Anim.once</code></a> / <a href="anim-pingpong"><code>Anim.pingpong</code></a> which cell to draw; <a href="anim-cell_x"><code>Anim.cell_x</code></a>/<a href="anim-cell_y"><code>Anim.cell_y</code></a> turn a frame index into a source rectangle on the sheet. Everything is integer/fixed and deterministic — the same timer reproduces the same frame every run, so replays and lockstep netcode match exactly.
