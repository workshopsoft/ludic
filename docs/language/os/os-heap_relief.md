---
id: os-heap_relief
name: Os.heap_relief
category: os
kind: namespace-method
tokens: Os.heap_relief
sig: Os.heap_relief() -> long
tip: Hand the allocator's cached free memory back.
order: 20
ns: Os
member: heap_relief
---

Asks the allocator to return the memory it keeps cached after frees, and returns the bytes it says it released. On macOS this is <code>malloc_zone_pressure_relief</code>, on Windows <code>HeapCompact</code>; elsewhere it returns 0. Call it after a large build or unload, not every frame.
