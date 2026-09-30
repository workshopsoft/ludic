bump: patch
type: fix
**`ludic.ui`: a held direction moves the focus once, not every frame.** Right, Left, Up and Down (and the d-pad and stick) move on the press, then repeat after `UiState.rp_first` (0.4 s) at `UiState.rp_every` (0.125 s, 8 a second). The platform's own per-frame key-pressed reports while a key is held are ignored; a tap too short to be seen held still moves once. The in-game phone stopped running through all its elements in a second. Nothing is allocated per frame.
