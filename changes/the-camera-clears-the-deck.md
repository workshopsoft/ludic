bump: patch
type: fix
The orbit camera clears a dock's deck.

The orbit and the eyes kept 0.55 m above the BED under them, and a dock's boards are not the bed
(they are what the body can stand on over it, `CharacterGround.height`), so on the end of a pier
the camera, held low by a look upward, sat inside the planks and the screen was full of boards.
It keeps above the higher of the two.
