bump: patch
type: fix
**A photograph keeps no memory of its own once the roll is made.** `photo_keep` pushed each frame's tags and
file onto two lists that grew with the roll (+64 B twice a shutter, a "grow" the alloc fence ended a run for), and
`photo_remove` made two new lists each time and gave none back. The roll now holds a slot per frame, filled with ""
when it is made (the way its other columns are), `photo_add` writes the slot and `photo_remove` closes the gap in
place.
