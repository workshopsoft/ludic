---
id: path
title: Path
order: 6
---

Path manipulation as pure string operations — no disk access, no allocation surprises, just the joining and splitting every save system, mod loader, and asset pipeline needs. Separate a filename from its folder, get an extension, join segments without worrying about doubled or missing separators, and collapse <code>.</code>/<code>..</code>/duplicate slashes into a canonical form.

Paths use <code>/</code> as the separator, matching the native (macOS/BSD) filesystem — the fully supported target today; Windows-style separators are a follow-up. Pair these with <a href="ns-Os"><code>Os</code></a> (which supplies per-user directory *locations*) and <a href="ns-Fs"><code>Fs</code></a> (which does the actual reading and writing).
