bump: minor
type: feat
**A launcher's runtime** — start a program, step aside while it runs, and download large
files with a progress bar.

- **`Process.*`** — `Process.spawn(path, args)` starts a program directly (no shell) with this
  process's environment and working directory and returns at once; `Process.poll(h)` is `-1`
  while it runs, then its exit code (`128 + signal` for a signal death, `137` after
  `Process.kill`); `Process.free` lets a handle go. `posix_spawn` on macOS
  (`runtime/native/process.ll`); `CreateProcessW` on Windows (`process_win.ll`), with each
  argument quoted by the MSVC rules and no console window. Linked only into a program that
  uses `Process.*`.
- **`Http.save_to(h, path)`** — before `Http.send`, streams the response body straight into a
  file (written at `path` itself, created on send) instead of memory; `Http.text` of such a
  request is empty and `Http.body_len` is the bytes written. **`Http.received(h)`** and
  **`Http.expected(h)`** (the `Content-Length`, or `-1`) are live while it is pending. macOS
  streams through an `NSURLSession` with a delegate built at run time, Windows through the
  WinHTTP read loop. Freeing a pending request now cancels it and parks its slot until the
  worker has let go, rather than freeing what the worker is still writing.
- **`App.window_hide()` / `App.window_show()`** — take the game's window off the screen and
  bring it back without closing it or its GL / Vulkan surface; the run goes on while it is
  hidden. No-ops headless and before there is a window.
