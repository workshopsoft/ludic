---
id: input-key_label
name: Input.key_label
category: input
kind: namespace-method
tokens: Input.key_label
sig: Input.key_label(key) -> string
tip: The name to show a player for a key - in their own keyboard layout.
order: 11
ns: Input
member: key_label
---

Returns the name to show for <code>key</code>. The letter, digit and punctuation codes that <a href="input-key_down.html"><code>Input.key_down</code></a> reads are <em>physical</em> keys, named for what they type on a US layout: <code>'w'</code> is the key above <code>'s'</code> on every keyboard, whatever layout, language, input method or Caps Lock state the player has. So WASD is always under the left hand, and the label is what that key types in the player's layout - <code>"W"</code> on QWERTY, <code>"Z"</code> on AZERTY. Space, Enter, Esc, Tab, Backspace, Shift, Ctrl, Alt and the arrows get words, and a code with no name returns <code>""</code>. The keys that type no character - F1-F12, Home, End, PageUp, PageDown, Insert, Delete, Caps Lock and the numpad, codes 132-166 - are named <code>"F1"</code>, <code>"Home"</code>, <code>"CapsLock"</code>, <code>"Num 0"</code>, <code>"Num /"</code> and so on, and the layout is <em>not</em> asked: a key that types nothing is called the same thing on every layout.

On Windows the label is read from the active layout. Headless, on macOS and in the browser it is the US character, upper case.

```ludic
program Demo {
  entry {
    print(Input.key_label('w'))
    print(Input.key_label(32))
    print(Input.key_label(Key.Left))
  }
}
```
