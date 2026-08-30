---
id: mime
title: Mime
order: 6
---

Content-type detection for assets and downloads: map a filename to its MIME type, or refine the guess by peeking at a file's leading bytes. Useful for deciding how to load a dropped-in mod file, labelling an export, or picking a decoder.

<a href="mime-of"><code>of</code></a> is a pure lookup by extension; <a href="mime-sniff"><code>sniff</code></a> reads the first bytes and recognises a few well-known signatures (PNG, JPEG, GIF, PDF), falling back to the extension when nothing matches. The extension table is deliberately compact and documented; richer magic-byte coverage is a follow-up.
