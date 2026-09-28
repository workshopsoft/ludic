bump: patch
type: fix
**Streaming new ground allocates nothing.** A streamed layer's cache made a record and a copy of
its instances for every chunk the camera found, so the heap grew for as long as there was ground
nobody had stood near - a boat drifting across the lake grew it every frame it crossed a cell. Each
stream now makes its whole cache when it is created: a record per chunk it can keep and an arena of
twice what its layer draws, compacted in place when it evicts. Replacing the world
(`stream_clear_all`) now gives every record, list and stream back. `examples/rendering/steady.ludic`
crosses 300 new cells with eviction running: 156 KB before, 0 after, every kept chunk still its own.
