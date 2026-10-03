bump: patch
type: fix
**The roll's order and its page are made at their room.** `photo_order` and `photo_page_list` refill two kept
lists every frame the Photos tab is up; made empty, each grew whenever the roll held more frames than ever before, and
the alloc fence failed the run there (`photo_order`, `photo_page_list`, exit 86). They are made with room for 256 and 8.
`tests/photo_test`: a roll of 40 filled and paged grows the heap 0 bytes.
