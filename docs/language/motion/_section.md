---
id: motion
title: Motion
order: 29
---

Ergonomic control of the engine-owned <code>Motion</code> component — the value tween the engine advances each tick (see the ECS engine-systems). <a href="motion-to"><code>Motion.to</code></a> starts a tween on an entity from one value to another over a number of ticks with an easing curve, rewinding it so it plays from the start, instead of setting the component's <code>from</code>/<code>to</code>/<code>dur</code>/<code>ease</code> fields by hand. The tween is integer and deterministic, so motion reproduces exactly under replay and lockstep. For a standalone, sequenced tween not tied to a component, see the fluent <a href="tween"><code>Tween</code></a> handles. Related: <a href="anim"><code>Anim</code></a>, <a href="ease"><code>Ease</code></a>, <a href="tween"><code>Tween</code></a>.
