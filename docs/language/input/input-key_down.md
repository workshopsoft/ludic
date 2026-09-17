---
id: input-key_down
name: Input.key_down
category: input
kind: namespace-method
tokens: Input.key_down
sig: Input.key_down(key) -> bool
tip: Is a physical key held this frame?
order: 8
ns: Input
member: key_down
---

Returns whether a physical <code>key</code> is held this frame — from the platform when windowed, from the polled key when headless, and from <a href="input-press.html"><code>Input.press</code></a> injection on any target. Unlike the single-key <a href="input-down.html"><code>Input.down</code></a>, several keys can be held at once (move left <em>and</em> jump). Every key on the keyboard has a code: letters, digits and punctuation are their US-layout character, Space, Enter, Esc, Tab, Backspace, Shift, Ctrl and Alt their usual ones, the arrows 128-131, and the keys that type nothing 132-166 - F1-F12 at 132, Home, End, PageUp, PageDown, Insert and Delete at 144, Caps Lock at 150, the numpad digits at 152 and its <code>*</code>, <code>+</code>, <code>-</code>, <code>.</code> and <code>/</code> at 162. <code>Key.F1</code>, <code>Key.Home</code> and <code>Key.Numpad0</code> name them.

```ludic
program Demo {
  entry {
    Input.press('a')
    Input.poll()
    if Input.key_down('a') { print(1) }
  }
}
```
