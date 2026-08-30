---
id: fs
title: Fs
order: 6
---

The filesystem, wrapped into one safe, ergonomic API — no file descriptors, no byte buffers, no half-written files. The foundation for saves, config, mods, and asset loading: read and write whole files as text, check existence, make directories, copy, and list a folder. The bare <code>file_*</code> builtins remain underneath for streaming; <code>Fs.*</code> is the everyday layer.

Fallible calls surface failure as a value — <code>null</code>, <code>false</code>, or <code>-1</code> — that you branch on, never a crash (a first-class <code>try/else</code> lands with the error-handling work). Writes are atomic (written to a temporary file and renamed into place), so a crash mid-write never corrupts the previous file. <a href="fs-list"><code>list</code></a> returns entries sorted, so a directory walk is reproducible across runs and platforms.

Paths are <code>/</code>-separated over the native (macOS/BSD) filesystem — the fully supported target today; a sandboxed virtual filesystem for wasm and recursive directory copy are follow-ups. Text helpers are UTF-8 (they pair with <a href="ns-Unicode"><code>Unicode</code></a>); use <a href="ns-Path"><code>Path</code></a> to build the paths and <a href="ns-Os"><code>Os</code></a> for per-user locations.
