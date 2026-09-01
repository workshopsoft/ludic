---
id: tiled
title: Tiled
order: 42
---

Load and draw <a href="https://www.mapeditor.org/">Tiled</a> maps. Both native format families — TMX/TSX/TX (XML) and TMJ/TSJ/TJ (JSON) — read onto one intermediate, a <a href="value"><code>Value</code></a> tree in Tiled's JSON schema, with layer data decoded to a dense GID list; so a CSV <code>.tmx</code> and a base64+zlib <code>.tmj</code> of the same map read identically. <a href="tiled-read"><code>Tiled.read</code></a> returns that intermediate tree for a map file and <a href="tiled-read_tsx"><code>Tiled.read_tsx</code></a> for a tileset file. Spliced on demand when a program mentions <code>Tiled.*</code>, alongside the <a href="xml"><code>Xml</code></a>, <a href="base64"><code>Base64</code></a> and <a href="value"><code>Value</code></a> runtimes it builds on.
