bump: minor
type: feat
**Crash reports for games.** `ludic.crash` installs the runtime's crash handler (`runtime/native/crash.ll`
on macOS, `crash_win.ll` on Windows: `SIGSEGV`/`SIGBUS`/`SIGILL`/`SIGFPE`/`SIGABRT`/`SIGTRAP` on an alternate
stack, `SetUnhandledExceptionFilter`) and, when the game dies, writes one crash record - JSON lines, format
LCR1 - into the game's crash folder: build, version, OS, signal or exception, fault address, registers,
the backtrace as return addresses and the loaded images with their `LC_UUID` / CodeView GUID. The next
start finds, rotates (`keep_n`) and lists them, honours the player's consent (off: a local file, nothing
sent), and hands each to the game to show or to send through `ludic.telemetry` (which gains `line_max`,
for events longer than 2048 bytes). `ludic build` and `ludic bundle` keep the build's symbols by id
beside the output, never inside the bundle - a `.dSYM` keyed by `LC_UUID`, a `.pdb` by GUID and age -
and `ludic symbols [--json]` lists them for the studio.
