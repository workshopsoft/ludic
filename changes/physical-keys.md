bump: patch
type: fix
**Keys are physical positions on Windows and macOS, whatever the layout** - `Input.key_down('w')`
is the key above S on every keyboard.

- **Windows** keyed the held set by the character the active layout gave a virtual key, so
  a game's WASD belonged to whatever the layout put there: on AZERTY W and A were other
  keys, and with an input method on (Chinese, Japanese, Korean) every letter arrived as
  VK_PROCESSKEY and no letter key worked at all. The typing block is now read from the
  scancode; the arrows, the numpad and the F-keys still go by virtual key, and the frame
  key (`Input.key`, typing) keeps the layout's character.
- **macOS** did the same through `charactersIgnoringModifiers`; it now reads `keyCode`.
- **`Input.key_label(key)`** names a key for the player in their own layout - `'w'` shows
  as "W" on QWERTY and "Z" on AZERTY - so a game that shows its bindings never shows a
  key the player cannot find. Windows reads the layout; headless, macOS and the browser
  give the US character.
