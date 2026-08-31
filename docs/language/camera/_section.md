---
id: camera
title: Camera
order: 32
---

A world-space camera — a draw offset threaded through the render path (the same offset <a href="screen-camera"><code>Screen.camera</code></a> sets). <a href="camera-set"><code>Camera.set</code></a> places it, <a href="camera-follow"><code>Camera.follow</code></a> eases it toward a target, and <a href="camera-shake"><code>Camera.shake</code></a> jitters it from the seeded RNG for impact and explosions. Everything is integer and deterministic — driven off the same seed and inputs, a replay reproduces the exact camera path, shake included. The camera moves everything drawn; reset it to <code>(0, 0)</code> to draw a fixed HUD.
