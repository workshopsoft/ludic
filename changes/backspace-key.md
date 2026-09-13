bump: patch
type: fix
**Backspace fires on macOS** — the Delete key reports `Key.Backspace` (8).

AppKit gives the key marked delete (kVK_Delete, 51) the character `NSDeleteCharacter`, 127,
which is what both the held-key set and the per-frame key received, so `Key.Backspace` never
matched. `cocoa.ll` maps key code 51 to 8 in both.
