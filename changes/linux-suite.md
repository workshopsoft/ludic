bump: patch
type: fix
**The toolchain's suites run on Linux again** (CI's runner):

- **The alloc fence no longer crashes off macOS.** Its heap scan called `malloc_size` without
  checking it was there, and its native-counter lookup passed macOS's `RTLD_DEFAULT` (-2) to glibc's
  `dlsym`, where it is 0. On glibc the fence counts the bytes asked for. The Vulkan loader's heap
  reading (`lvk_heap_bytes`) is 0 there instead of an unresolved symbol.
- **`Fs.list` reads glibc's `dirent`** (the name at byte 19, not macOS's 21). It returned an empty
  name for `.`, and `ludic fmt --lint` walked `dir/` until it ran out of memory.
- **`ludic build` and `ludic test` pass framework flags only on a Mac**; Linux's `ld` refused them.
- **`ludic test` skips a test that cannot link for want of a native library**: the compiler writes
  `; ludic-native-missing: <package> <target>` for a package that names native libraries but none for
  this target, and the report says `skip <file>  (<package> has no native library for <target>)`.
  Off macOS, a link that lacks only macOS's own runtime (the window layer, Http, the crash
  layer) is skipped the same way.
- **`ludic test <dir>` runs only the files with a `test` block**; a `*_test.ludic` module a test imports,
  or a checker program run by hand, is no longer compiled as a test of its own.
