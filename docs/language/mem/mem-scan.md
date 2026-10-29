---
id: mem-scan
name: Mem.scan
category: mem
kind: namespace-method
tokens: Mem.scan
sig: Mem.scan() -> long
tip: Bytes tracked allocations hold that nothing reaches.
order: 8
ns: Mem
member: scan
---

Walks every global and state root and returns the bytes of tracked blocks, made since tracking began, that are reachable from none of them. When it finds any it prints an <code>alloc-scan</code> report to stderr with the allocating lines. Returns 0 when tracking has not started or the platform has no <code>malloc_size</code>. <code>R3D_ALLOC_EXIT=1</code> runs the same scan as the program quits.
