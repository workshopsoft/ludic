bump: minor
type: feat
**Windows target** — `ludicc` builds and runs headless programs on Windows, and builds itself there.

- **`--target <triple>`** — a triple naming `windows` selects the Windows runtime; without
  the flag the target is the host, read at run time from `OS=Windows_NT`. The IR still
  carries no triple, so clang assembles it for the machine it runs on.
- **The libc surface, in IR** — on Windows the header emits `emit_win.ludic`, which defines
  the POSIX names the backend calls (`fopen`, `ftell`, `rename`, `opendir`, `mmap`,
  `fmemopen`, `uname`, …) over the UCRT and Win32. Three of them fixed silent breakage
  rather than link errors: `rename` onto an existing file (every `Fs.write_text` after the
  first), a 32-bit `ftell`, and text-mode `fopen` rewriting `\n` as `\r\n`.
- **Known folders** — `Os.save_dir` / `config_dir` are `%APPDATA%\<app>`, `cache_dir` is
  `%LOCALAPPDATA%\<app>`, `temp_dir` is `%TEMP%`, all with forward slashes; a bundle's
  `home` line points at `%APPDATA%\<name>`.
- **The driver** — finds `C:\Program Files\LLVM\bin\clang.exe` when clang is not on
  `%PATH%`, writes `.exe` outputs, speaks cmd.exe for its directory and cleanup commands,
  and reads `argv[0]`, `%PATH%` and `$LUDIC_HOME` with either separator.
- **Not yet** — a window, `Gl.*`, `Audio.*` and `Http.*` are still macOS platform layers;
  a Windows build that needs one stops with a message saying so.
