; linux_stdio_shim.ll — build-time bridge so the Ludic toolchain links on Linux.
;
; The self-hosted compiler emits the macOS/BSD libc standard-stream globals
; @__stdoutp / @__stderrp (that is how <stdio.h> spells `stdout`/`stderr` on
; Darwin). glibc instead exports `stdout`/`stderr` directly, so a Linux link of
; any Ludic binary fails with "undefined reference to __stderrp".
;
; This shim defines the two Darwin-named globals and, in a startup constructor,
; points them at glibc's real FILE* streams. It is pure LLVM IR — no C compiler
; and no .c source — so it keeps the toolchain's C-free guarantee intact. It is
; injected on Linux only, via LUDIC_CC (see .forgejo/workflows/ci.yml); macOS
; never links it (libc already provides __stdoutp/__stderrp).
;
; Kept deliberately triple-free: clang stamps the host target when it assembles
; it, so the same file works on linux/arm64 and linux/amd64 runners.

@stdout = external global ptr
@stderr = external global ptr

@__stdoutp = global ptr null
@__stderrp = global ptr null

@llvm.global_ctors = appending global [1 x { i32, ptr, ptr }]
  [{ i32, ptr, ptr } { i32 65535, ptr @__ludic_bind_std_streams, ptr null }]

define internal void @__ludic_bind_std_streams() {
entry:
  %o = load ptr, ptr @stdout
  store ptr %o, ptr @__stdoutp
  %e = load ptr, ptr @stderr
  store ptr %e, ptr @__stderrp
  ret void
}
