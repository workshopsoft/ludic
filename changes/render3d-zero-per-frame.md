bump: patch
type: fix
**render3d allocates nothing in its steady state.** A buffer released and made again - what a
streamed or growing buffer does every few frames - left about 224 bytes behind each time: the
Vulkan allocator made a one-slot list per allocation, turned two 64-bit sizes into strings to read
them as ints, and rebuilt its spare-record list whole to drop the last entry. It now keeps one
slot, converts with `int()`, and pops. `Vk.heap_bytes()` reads malloc's live bytes (macOS), and
`examples/rendering/steady.ludic` holds render3d to zero: 5000 buffer rounds and 600 whole frames,
0 bytes each (the unfixed allocator: 1,120,000 over the 5000).
