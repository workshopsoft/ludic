---
id: input
title: Input
order: 6
---

Reading input. At the base, <a href="input-key.html"><code>Input.key</code></a> gives this frame's key and <a href="input-poll.html"><code>Input.poll</code></a> is the single per-frame read that also drives deterministic record/replay. Over that sit <strong>named actions</strong> — <a href="input-bind.html"><code>Input.bind</code></a> / <a href="input-down.html"><code>Input.down</code></a> / <a href="input-pressed.html"><code>Input.pressed</code></a> / <a href="input-rebind.html"><code>Input.rebind</code></a> — so gameplay reads rebindable actions, not physical keys.

The <strong>device layer</strong> adds everything past one key per frame: multiple simultaneous held keys (<a href="input-key_down.html"><code>Input.key_down</code></a> / <a href="input-key_pressed.html"><code>key_pressed</code></a> / <a href="input-key_released.html"><code>key_released</code></a>), analog <a href="input-axis.html"><code>Input.axis</code></a> and normalized <a href="input-vector.html"><code>Input.vector</code></a>, the <a href="input-mouse_x.html">mouse</a> (position, delta, buttons, <a href="input-wheel.html">wheel</a>), <a href="input-pad_button.html">gamepads</a> and <a href="input-touch_count.html">touch</a>. The held set is fed by the platform when windowed and by the <a href="input-press.html"><code>Input.press</code></a> / <a href="input-set_mouse.html"><code>Input.set_*</code></a> injection on every target — the same idea as Godot's <code>action_press</code>, and what a replay, an AI, or the network feeds. Everything is integer and deterministic, and record/replay snapshots the whole per-frame state.
