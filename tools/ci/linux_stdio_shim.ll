; linux_stdio_shim.ll — build-time bridge so the Ludic toolchain links on Linux.
;
; The self-hosted compiler emits the macOS/BSD libc standard-stream globals
; @__stdoutp / @__stderrp (that is how <stdio.h> spells `stdout`/`stderr` on
; Darwin). glibc instead exports `stdout`/`stderr` directly, so a Linux link of
; any Ludic binary fails with "undefined reference to __stderrp".
;
; This shim defines the two Darwin-named globals and, in a startup constructor,
; points them at glibc's real FILE* streams. It also supplies _NSGetExecutablePath,
; which the asset-pack boot (emit_pak.ludic) calls to find the directory beside the
; executable: Darwin has it, glibc does not, and without it every Linux link of the
; seed failed - which is why CI stopped publishing releases after v0.7.0. It is pure LLVM IR — no C compiler
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

; _NSGetExecutablePath(buf, &size) -> 0 on success: the running executable's path,
; NUL-terminated, from /proc/self/exe. Same contract as Darwin's (the size is the
; buffer's capacity in; -1 back when the path does not fit or cannot be read).
declare i64 @readlink(ptr, ptr, i64)
@.ludic_self_exe = private unnamed_addr constant [15 x i8] c"/proc/self/exe\00"

define i32 @_NSGetExecutablePath(ptr %buf, ptr %szp) {
entry:
  %sz = load i32, ptr %szp
  %cap = sub i32 %sz, 1
  %cap64 = sext i32 %cap to i64
  %n = call i64 @readlink(ptr @.ludic_self_exe, ptr %buf, i64 %cap64)
  %bad = icmp slt i64 %n, 0
  %full = icmp sge i64 %n, %cap64
  %no = or i1 %bad, %full
  br i1 %no, label %fail, label %ok
ok:
  %end = getelementptr i8, ptr %buf, i64 %n
  store i8 0, ptr %end
  ret i32 0
fail:
  ret i32 -1
}
