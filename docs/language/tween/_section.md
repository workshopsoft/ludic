---
id: tween
title: Tween
order: 29
---

Value interpolation over a timeline, off the fixed frame clock. The timeline helpers <a href="tween-progress"><code>Tween.progress</code></a>/<a href="tween-loop"><code>Tween.loop</code></a>/<a href="tween-yoyo"><code>Tween.yoyo</code></a> turn an elapsed <code>timer</code> and a <code>duration</code> into a normalized amount; <a href="tween-ease"><code>Tween.ease</code></a> shapes that amount through an easing curve (shared with <a href="ease"><code>Ease</code></a>); and the typed blends <a href="tween-number"><code>Tween.number</code></a>/<a href="tween-round"><code>Tween.round</code></a>/<a href="tween-point"><code>Tween.point</code></a>/<a href="tween-tint"><code>Tween.tint</code></a> interpolate a <code>fixed</code>, <code>int</code>, <code>Vector</code>, or color. All deterministic fixed-point, so a replay reproduces every eased value exactly.
