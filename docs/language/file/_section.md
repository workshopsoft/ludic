---
id: file
title: File
order: 44
---

Raw file access over the C stdio calls, for programs that read and write their own formats. <a href="file-open"><code>File.open</code></a> returns a handle (or <code>null</code>), <a href="file-read"><code>File.read</code></a> / <a href="file-write"><code>File.write</code></a> move bytes through a <code>bytes</code> buffer, <a href="file-seek"><code>File.seek</code></a> / <a href="file-tell"><code>File.tell</code></a> position the cursor, and <a href="file-close"><code>File.close</code></a> releases the handle. For text and structured data prefer the higher-level <code>Fs</code>, <code>Json</code> and <code>Prefs</code> APIs.
