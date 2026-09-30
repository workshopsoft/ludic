# ludic.crash

What a game does about the crash it had last time. The runtime's crash handler writes a small
record when the game dies; the next start finds the records here, keeps the newest few, and hands
them to the game: to show ("the game crashed last time") and, if the player allows it, to send.
Uses [`ludic.base`](../ludic.base/README.md) and nothing else.

```ludic skip
import "ludic.crash"
```

The design, end to end:

1. **The game crashes.** `runtime/native/crash.ll` (macOS) or `crash_win.ll` (Windows), linked into
   any program that calls this package, catches the signal or exception and writes one **crash
   record** file into the crash folder. It then lets the OS report the crash as it would have.
2. **The next start** (`crash_start`) reads the folder, deletes all but the newest `keep_n`, and lists
   the pending records.
3. **The game** shows them and, with the player's consent, sends each as one raw event through
   [`ludic.telemetry`](../ludic.telemetry/README.md) (`crash_record`, below).
4. **The studio** (or a service) turns the addresses in a record into function names with the symbols
   `ludic build` / `ludic bundle` kept for that build (`ludic symbols`,
   [docs/SHIPPING.md](../../docs/SHIPPING.md#crash-reports-and-symbols)) and sends PostHog an
   `$exception` event whose frames are already resolved. PostHog cannot read minidumps or Windows PDBs,
   so the symbolication is ours.

## Config and port

```ludic skip
property CrashConfig {
  dir        # the crash folder, under the game's save root; "" installs nothing
  keep_n (5) # records kept: the newest, pending or handled; the rest are deleted at each start
  enabled (true)   # off: no handler is installed, so no record is made (the folder is still read)
  app, version, build   # the game's name and version, and a build id: they go in every record
}
port CrashWorld {
  consent: fn() -> bool    # the player's switch: may a record leave this machine (unbound: no)
}
```

```ludic skip
bind CrashWorld { consent: fn my_crash_reports_switch }
```

**Consent.** `enabled` decides whether a record is made at all. `consent` decides whether it may
leave: with it off (or unbound) a record is a local file and nothing more - `crash_sendable` is 0,
`crash_next_send` is -1, and the game can still show the "crashed last time" panel from
`crash_pending`. A player who turns capture off at run time calls `crash_set_enabled(false)`.

## API

| | |
| --- | --- |
| `crash_config(c)` | before the start |
| `crash_start() -> int` | once at boot, before the game can crash: read and rotate the folder, then (when `enabled`) install the handler. Answers how many records wait from earlier runs |
| `crash_set_enabled(on)`, `crash_installed()`, `crash_dir()` | the switch at run time, and what is on |
| `crash_context(text)` | one line of what the game is doing (a scene, a map), written into the next record |
| `crash_pending() -> int`, `crash_file(i)` | the pending records, newest first |
| `crash_record(i) -> CrashRecord`, `crash_text(i)` | parsed once and kept (`ok`, `complete`, `app`, `version`, `build`, `context`, `os`, `os_version`, `arch`, `time`, `pid`, `tid`, `main_thread`, `sig`, `signame`, `code`, `addr`, `pc`, `frames`, `images`, `text`); `crash_text` is the file whole |
| `crash_parse(text) -> CrashRecord` | a record's text parsed, for a tool |
| `crash_sendable() -> int`, `crash_next_send() -> int` | how many may go (0 without consent); the next one to send (always 0, settling one moves the rest up) or -1 |
| `crash_mark_sent(i)`, `crash_dismiss(i)` | settle a pending record: it becomes `.sent` or `.dismissed` and is no longer pending |
| `crash_facts() -> Queue<CrashFact>` | `{ what, count }`: `CRASH_FOUND` when a start finds records |
| `crash_exit_name(code) -> string`, `crash_exit_is_crash(code)` | for a launcher: what a child's exit code says (below) |
| `crash_trigger(kind)` | a crash on purpose, for a test or a debug button: 0 a wild store, 1 `abort`, 2 a trap, 3 `SIGFPE` (Windows: a stack overflow), 4 a stack overflow (macOS) |
| `crash_reset()` | back to before `crash_start` (tests) |

It is not a `System`: it runs from the first frame of a launcher, before any world exists.

### Sending: through telemetry

`ludic.telemetry` keeps lines of at most `line_max` bytes (2048 by default: a crash record is a few
kilobytes), so the game sets `line_max = 32768` on its `TelemetryConfig`, then writes the glue,
because two mechanics never meet in a package:

```ludic skip
function send_crashes(crash_st: mut CrashState, telemetry_st: mut TelemetryState) -> void {
  while crash_next_send(crash_st) >= 0 {
    let r = crash_record(crash_st, 0)
    let p = telemetry_props(telemetry_st)
    telemetry_str(p, "record_format", "lcr1")
    telemetry_str(p, "signame", r.signame)
    telemetry_str(p, "app_version", r.version)
    telemetry_str(p, "record", r.text)          # the file, whole: the studio parses and symbolizes it
    telemetry_event(telemetry_st, "crash_record", p)
    crash_mark_sent(crash_st, 0)                # telemetry keeps the event queued across a failed send
  }
}
```

`tests/telemetry_glue_test.ludic` runs exactly this.

### Showing: the launcher pattern

A launcher that starts the game (`Process.spawn`) sees how it ended in `Process.poll`: POSIX answers
`128 + the signal` (`139` for `SIGSEGV`), Windows the exception's NTSTATUS as a negative int
(`0xC0000005` is `-1073741819`). `crash_exit_is_crash(code)` says whether that was a crash and
`crash_exit_name(code)` names it. The launcher then calls `crash_start` itself, finds the record the
child left in the game's crash folder, and shows `crash_record(0)` - `signame`, `version`, `time`, the
top frame - with "send" (`crash_mark_sent` after the glue above) and "dismiss" (`crash_dismiss`).

## The folder

Records are `crash-<unix time>-<pid>.lcr`. Once the game deals with one, `crash_mark_sent` renames it
`.lcr.sent` and `crash_dismiss` renames it `.lcr.dismissed`; only `.lcr` is pending. The newest `keep_n`
of all three stay. The times have ten digits until 2286, so the names sort chronologically.

## The record format, LCR1

A crash record is **JSON Lines**: UTF-8, one JSON object per line, each ended by `\n`, told apart by
`"k"`. The handler flushes as it goes, so a record it could not finish is a prefix of valid lines:
read line by line, skip a line that does not parse, and treat a record with no `end` line as
truncated (`complete` false). Field order below is the order written.

```
{"k":"crash","v":1,"producer":"ludic","app":"Maroon Lake","version":"0.1.0","build":"b-42","context":"scene=forest","os":"macos","os_version":"26.3","arch":"arm64","pid":58532,"tid":33343456,"main":true,"time":1790788239,"sig":11,"signame":"SIGSEGV","code":2,"addr":"0x10","pc":"0x102c5e148","sp":"0x16c9abfe0","fp":"0x16d1a6d80","lr":"0x102c5e158"}
{"k":"frame","i":0,"pc":"0x102c5e148","via":"pc"}
{"k":"frame","i":1,"pc":"0x102c5e158","via":"lr"}
{"k":"frame","i":2,"pc":"0x183ef0850","via":"scan"}
{"k":"image","path":"/Applications/Maroon Lake.app/Contents/MacOS/Maroon Lake","base":"0x102c58000","size":"0x8000","uuid":"8545D571-AC52-396B-8403-1DD2B282BA3B","main":true}
{"k":"image","path":"/usr/lib/system/libsystem_c.dylib","base":"0x183e77000","size":"0x82048","uuid":"EB569350-0696-3397-838E-0344948107C0"}
{"k":"end","frames":3,"images":2}
```

**`crash`** (exactly one, the first line)

| field | |
| --- | --- |
| `v` | the format's version, `1`. A reader refuses a larger one |
| `producer` | `"ludic"` |
| `app`, `version`, `build` | what the game gave `CrashConfig` (strings, `""` when not given; up to 159 bytes) |
| `context` | what the game last passed to `crash_context` (`""` when never; up to 255 bytes) |
| `os` | `"macos"` or `"windows"` |
| `os_version` | macOS: `kern.osproductversion` (`"26.3"`). Windows: `major.minor.build` (`"10.0.26100"`) |
| `arch` | `"arm64"` or `"x86_64"` |
| `pid`, `tid` | the process and the crashing thread (a number) |
| `main` | whether the crashing thread is the main thread (Windows: the one that called `crash_start`) |
| `time` | seconds since 1970, when the handler ran |
| `sig` | the POSIX signal number (macOS: `4` SIGILL, `5` SIGTRAP, `6` SIGABRT, `8` SIGFPE, `10` SIGBUS, `11` SIGSEGV). Windows: `0`, or `22` for `abort()` |
| `signame` | `"SIGSEGV"` ... on macOS; on Windows the exception (`"EXCEPTION_ACCESS_VIOLATION"`, `"EXCEPTION_STACK_OVERFLOW"`, `"EXCEPTION_ILLEGAL_INSTRUCTION"`, `"EXCEPTION_INT_DIVIDE_BY_ZERO"`, `"STATUS_STACK_BUFFER_OVERRUN"`, `"EXCEPTION_BREAKPOINT"`, ..., `"EXCEPTION"` for any other) or `"SIGABRT"` |
| `code` | macOS: the signal's `si_code`. Windows: the exception code as an unsigned decimal (`3221225477` is `0xC0000005`); `0` for `abort()` |
| `addr` | the address the fault touched (`si_addr`; Windows: the address an access violation touched, else the exception address), as `"0x..."` hex |
| `pc`, `sp`, `fp`, `lr` | registers of the crashing thread, `"0x..."` (`lr` is `"0x0"` on Windows and on x86_64) |

**`frame`** (zero or more): `i` counts from 0, `pc` is the address as `"0x..."`, `via` says how it was
found:

- `pc` - frame 0, the faulting instruction itself;
- `lr` - the link register, when it is a return address (arm64): a frameless leaf's caller, but also
  possibly a stale value inside a function that has called something since;
- `scan` - a return address found on the stack (macOS): in a loaded image's code and right after a
  call instruction, from the stack pointer up. ludicc's functions keep no frame-pointer chain, so the
  stack is scanned; a stale return address in a dead slot can appear as an extra frame, and a frame
  whose call was not a `BL`/`BLR` is missing;
- `unwind` - Windows: the OS unwinder's (`RtlVirtualUnwind`) next frame.

At most 64 frames. A frame after the first is a **return address**: look up `pc - 1` (the call site),
not `pc`.

**`image`** (zero or more): the program, every image a frame landed in, and every image that is not
the operating system's. `path`, `base` (where it is loaded: the Mach-O header's address, the PE's
module handle), `size` (`"0x..."` bytes of code: `__TEXT`'s size, the PE's `SizeOfImage`), and

- `uuid`: macOS the image's `LC_UUID`; Windows the CodeView **GUID** (`"11223344-5566-7788-99AA-BBCCDDEEFF10"`,
  the first three fields little-endian as a PDB writes it), absent when the image has none;
- `age`: Windows, the CodeView age; `timestamp`: Windows, the PE's `TimeDateStamp`;
- `"main":true` on the game's own executable.

**`end`** (the last line, when the handler finished): `frames` and `images` are how many lines of each
it wrote.

### Reading an address

For a frame `pc`, find the image with `base <= pc < base + size`. The symbol file of that image is
the one `ludic symbols` lists under the same id: macOS `build/symbols/<uuid>/<name>.dSYM`; Windows
`build/symbols/<GUID without dashes><age in hex>/<name>.pdb`. On macOS the address in the file is
`pc - base + vmaddr`, where `vmaddr` is `__TEXT`'s address in the binary (`0x100000000` for an
arm64 executable); the dSYM's symbol table names functions (the IR carries no DWARF, so there are no
lines). On Windows it is the RVA, `pc - base`.

## The handler

What `runtime/native/crash.ll` does and why it is safe to do inside a crash - the header of the file
says it too:

- It installs `SIGSEGV`, `SIGBUS`, `SIGILL`, `SIGFPE`, `SIGABRT` and `SIGTRAP` handlers with
  `sigaction`, on an alternate stack of the installing thread (so a stack overflow there is caught),
  with `SA_RESETHAND | SA_NODEFER`: the default action is back the moment the handler is entered, so a
  fault inside it kills the process at once, and after the record the signal is raised again so the OS
  reports the crash as it would have (Crash Reporter, the parent's `128 + signal`). A handler that
  hangs is ended after five seconds by a timer that re-raises the original signal; the timer is
  cancelled as soon as the record is written, so the OS's own crash handling (which can be slow on a
  busy machine) is never cut short.
- It allocates nothing and takes no lock. Everything it needs - the path prefix, the strings, the
  table of loaded images (base, size, `LC_UUID`, path) - is made before the crash, by
  `crash_start` and by dyld's add-image callback. It calls `open`, `write`, `close`, `getpid`, `time`,
  `nanosleep`, `raise` and `alarm`, and reads the thread's stack bounds.
- The record is formatted by hand into a 4 KiB buffer flushed with `write` as it fills.
- The stack is scanned rather than unwound (`_Unwind_Backtrace` takes dyld's locks and allocates).
- Only the thread that called `crash_start` has the alternate stack: a stack overflow on another
  thread ends the process without a record (the record of any other fault on it is written).
- Linux is not covered.

`runtime/native/crash_win.ll` is the same over `SetUnhandledExceptionFilter` (plus the C runtime's
`SIGABRT` hook, since `abort()` fails fast past every filter), with `RtlVirtualUnwind` for the stack
and 64 KiB of stack guaranteed to the thread for the overflow case. It returns
`EXCEPTION_CONTINUE_SEARCH`, so Windows Error Reporting still runs and the parent still sees the
exception code. **It was written without a Windows machine**: it compiles
(`clang --target=x86_64-pc-windows-msvc`), its format is the one the macOS tests exercise, and its first
run on Windows is the test of the rest.

## Tests

```bash
ludic test packages/ludic.crash
```

The record parser, the folder (finding, rotation, settling), consent, the exit codes, the telemetry
glue, and - on the machine's own runtime - the test binary started as its own child with a test's name
and a folder: it installs the handler and dies of a wild store, `abort`, a trap and a stack overflow,
and the parent finds and reads each record.
