# ludic.nativeecho

The worked example of a package that carries a native library (phase 15). It exists to be copied
and to be tested: nothing in a game needs it.

```ludic
import "ludic.nativeecho"
```

- `package.ludic` names the library per target (`native "macos-arm64" "lib/macos-arm64/libnativeecho.dylib"`).
- `native/shim/nativeecho.c` is the whole library: a sum over a float slice, a scan that
  "calls back" once per value over a threshold, and the drain the package empties those records
  through.
- `native/build.sh` builds `lib/<target>/` through `tools/native/lib.sh` (no upstream to fetch).
- `native.ludic` declares the symbols; `echo.ludic` is the state, the verbs and the facts.

| | |
| --- | --- |
| `EchoState` | the slices that cross to C (made once), and the facts queue |
| `echo_put(st, x) -> bool`, `echo_clear(st)` | fill the slice |
| `echo_sum(st) -> float` | the sum, in C |
| `echo_scan(st, over) -> int` | C records each value over `over`; they arrive on `echo_facts(st)` as `EchoFact { index, value }` |
| `echo_lost() -> int`, `echo_twice(x: long) -> long` | the lost-record count, and a 64-bit round trip |

The rules it keeps are the shim rules in [packages/README.md](../README.md#native-libraries).
`ludic test packages/ludic.nativeecho` runs it against the real library.
