---
id: base64
title: Base64
order: 41
---

Standard base64 (RFC 4648) — <a href="base64-decode"><code>Base64.decode</code></a> reads base64 text into the bytes it stands for, and <a href="base64-encode"><code>Base64.encode</code></a> is the inverse. The decoder ignores ASCII whitespace, so it reads the newline-wrapped base64 that Tiled writes inside a <code>&lt;data&gt;</code> element; that output then feeds the DEFLATE inflater for zlib/gzip-compressed layer data. Deterministic; spliced on demand when a program mentions <code>Base64.*</code>. (The security-sensitive encoder <a href="crypto-base64"><code>Crypto.base64</code></a> is a separate, hardened path.)
