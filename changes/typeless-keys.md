bump: minor
type: feat
**Every key on the keyboard is bindable** — the F-row, Home/End/PageUp/PageDown,
Insert/Delete, Caps Lock and the numpad reach a game as codes 132-166.

Until now the platform gave them no code at all, so a game's rebinding screen could
not take one and nothing said why. Windows asked the active layout what they type and
got nothing back (`w_vk_char` answers 0 for a key with no character); macOS let them
fall through to `charactersIgnoringModifiers`, which reports `NSF1FunctionKey` and its
neighbours at 0xF704 and up - outside the 256-bit held set either way.

- **The codes are the same on both platforms**: 132-143 are F1-F12, 144-149 are Home,
  End, PageUp, PageDown, Insert and Delete, 150 is Caps Lock, 152-161 are the numpad
  digits and 162-166 its `*`, `+`, `-`, `.` and `/`. The numpad's Enter is Enter.
- **`Key.F1`, `Key.Home`, `Key.Numpad0`** and the rest fold at compile time like the
  other named keys.
- **`Input.key_label`** names them - "F1", "Home", "CapsLock", "Num 0", "Num /" - and
  does *not* ask the layout, because a key that types nothing is called the same thing
  on every layout.
