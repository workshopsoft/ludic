; ============================================================================
; crash_win.ll - crash capture behind ludic.crash (Windows x64).
;
; crash.ll's interface over SetUnhandledExceptionFilter. The Windows build of the toolchain
; links it (tools/ludic-cli/build.ludic) into a program that calls the lu_crash_* layer.
; It was written without a Windows machine: it is checked to compile (clang --target=
; x86_64-pc-windows-msvc) and its record format is the one crash.ll writes and the macOS
; tests exercise; the first run on Windows is the test of the rest.
;
;   lu_crash_install(dir, app, version, build) -> int
;       Install the filter and keep what it needs: the path prefix (converted to UTF-16),
;       the strings, the list of loaded modules (base, SizeOfImage, CodeView GUID and age,
;       path), 64 KiB of stack guaranteed to this thread so a stack overflow can be
;       reported. `dir` must exist. 0 on success, -1 for an empty dir.
;   lu_crash_uninstall()            the filter removed
;   lu_crash_context(text)          one line of game state for the next record
;   lu_crash_trigger(kind)          0 a wild store (access violation), 1 abort(), 2 an
;                                   illegal instruction, 3 a stack overflow
;
; WHAT THE FILTER MAY DO. It runs on the faulting thread after every handler in the
; program declined. It allocates nothing: CreateFileW, WriteFile and CloseHandle, plus
; RtlLookupFunctionEntry / RtlVirtualUnwind for the stack, which read the .pdata tables
; of the loaded images. The record is formatted by hand into a 4 KiB buffer flushed as it
; fills, so a record the filter did not finish is still a prefix of valid JSON lines. It
; returns EXCEPTION_CONTINUE_SEARCH, so Windows Error Reporting and the parent's exit code
; (the exception code, as an NTSTATUS such as 0xC0000005) are what they would have been.
; abort() does not reach a filter (the C runtime fails fast), so the C runtime's SIGABRT
; hook is set as well and writes the same record from a captured context.
;
; THE BACKTRACE is the OS unwinder's: the context's rip, then RtlVirtualUnwind over each
; frame (a function without unwind data is a leaf: its return address is at [rsp]), at
; most 64 frames, stopping when rsp does not rise.
;
; THE RECORD: JSON lines in <dir>\crash-<unix time>-<pid>.lcr; packages/ludic.crash/README.md.
; ============================================================================

declare ptr @SetUnhandledExceptionFilter(ptr)
declare ptr @CreateFileW(ptr, i32, i32, ptr, i32, i32, ptr)
declare i32 @WriteFile(ptr, ptr, i32, ptr, ptr)
declare i32 @CloseHandle(ptr)
declare i32 @GetCurrentProcessId()
declare i32 @GetCurrentThreadId()
declare ptr @GetCurrentProcess()
declare void @GetSystemTimeAsFileTime(ptr)
declare i32 @K32EnumProcessModules(ptr, ptr, i32, ptr)
declare i32 @GetModuleFileNameW(ptr, ptr, i32)
declare i32 @MultiByteToWideChar(i32, i32, ptr, i32, ptr, i32)
declare i32 @WideCharToMultiByte(i32, i32, ptr, i32, ptr, i32, ptr, ptr)
declare i32 @SetThreadStackGuarantee(ptr)
declare ptr @RtlLookupFunctionEntry(i64, ptr, ptr)
declare ptr @RtlVirtualUnwind(i32, i64, i64, ptr, ptr, ptr, ptr, ptr)
declare void @RtlCaptureContext(ptr)
declare ptr @signal(i32, ptr)
declare void @abort()
declare ptr @malloc(i64)
declare void @llvm.trap()

@C_on = internal global i32 0
@C_busy = internal global i32 0
@C_mtid = internal global i32 0
@C_plen = internal global i32 0
@C_wpath = internal global [1100 x i16] zeroinitializer
@C_wfull = internal global [1200 x i16] zeroinitializer
@C_app = internal global [160 x i8] zeroinitializer
@C_ver = internal global [160 x i8] zeroinitializer
@C_build = internal global [160 x i8] zeroinitializer
@C_ctx = internal global [256 x i8] zeroinitializer
@C_osv = internal global [64 x i8] zeroinitializer

; the loaded modules: base, SizeOfImage, CodeView GUID, age, time stamp, path (UTF-8), flags
; (1 the program, 2 Windows' own, 4 a frame landed in it, 8 has a GUID)
@C_in = internal global i32 0
@C_ib = internal global [1024 x i64] zeroinitializer
@C_isz = internal global [1024 x i64] zeroinitializer
@C_iu = internal global [16384 x i8] zeroinitializer
@C_ia = internal global [1024 x i32] zeroinitializer
@C_it = internal global [1024 x i32] zeroinitializer
@C_ip = internal global [196608 x i8] zeroinitializer
@C_if = internal global [1024 x i32] zeroinitializer

define internal i64 @cr_write(i64 %fd, ptr %p, i64 %n) {
entry:
  %h = inttoptr i64 %fd to ptr
  %w = alloca i32, align 4
  store i32 0, ptr %w
  %n32 = trunc i64 %n to i32
  %ok = call i32 @WriteFile(ptr %h, ptr %p, i32 %n32, ptr %w, ptr null)
  %z = icmp eq i32 %ok, 0
  %wv = load i32, ptr %w
  %w64 = zext i32 %wv to i64
  %r = select i1 %z, i64 -1, i64 %w64
  ret i64 %r
}

@C_fd = internal global i64 -1
@C_n = internal global i32 0
@C_ob = internal global [4096 x i8] zeroinitializer

define internal void @cr_flush() {
entry:
  %n = load i32, ptr @C_n
  %fd = load i64, ptr @C_fd
  %z = icmp sle i32 %n, 0
  br i1 %z, label %out, label %w
w:
  %n64 = sext i32 %n to i64
  br label %loop
loop:
  %off = phi i64 [ 0, %w ], [ %off2, %cont ]
  %left = sub i64 %n64, %off
  %p = getelementptr i8, ptr @C_ob, i64 %off
  %r = call i64 @cr_write(i64 %fd, ptr %p, i64 %left)
  %bad = icmp sle i64 %r, 0
  br i1 %bad, label %done, label %cont
cont:
  %off2 = add i64 %off, %r
  %more = icmp slt i64 %off2, %n64
  br i1 %more, label %loop, label %done
done:
  store i32 0, ptr @C_n
  br label %out
out:
  ret void
}

define internal void @cr_putc(i8 %c) {
entry:
  %n = load i32, ptr @C_n
  %p = getelementptr i8, ptr @C_ob, i32 %n
  store i8 %c, ptr %p
  %n2 = add i32 %n, 1
  store i32 %n2, ptr @C_n
  %full = icmp sge i32 %n2, 4096
  br i1 %full, label %fl, label %out
fl:
  call void @cr_flush()
  br label %out
out:
  ret void
}

define internal void @cr_puts(ptr %s) {
entry:
  br label %loop
loop:
  %i = phi i64 [ 0, %entry ], [ %i2, %put ]
  %p = getelementptr i8, ptr %s, i64 %i
  %c = load i8, ptr %p
  %end = icmp eq i8 %c, 0
  br i1 %end, label %done, label %put
put:
  call void @cr_putc(i8 %c)
  %i2 = add i64 %i, 1
  br label %loop
done:
  ret void
}

define internal i8 @cr_hd(i32 %d, i8 %a) {
entry:
  %lt = icmp slt i32 %d, 10
  %d8 = trunc i32 %d to i8
  %dig = add i8 %d8, 48
  %al0 = sub i8 %d8, 10
  %al = add i8 %al0, %a
  %r = select i1 %lt, i8 %dig, i8 %al
  ret i8 %r
}

; a JSON string body: quote, backslash and control bytes escaped, everything else raw
define internal void @cr_puts_json(ptr %s) {
entry:
  br label %loop
loop:
  %i = phi i64 [ 0, %entry ], [ %i2, %next ]
  %p = getelementptr i8, ptr %s, i64 %i
  %c = load i8, ptr %p
  %end = icmp eq i8 %c, 0
  br i1 %end, label %done, label %chk
chk:
  %q = icmp eq i8 %c, 34
  %b = icmp eq i8 %c, 92
  %qb = or i1 %q, %b
  br i1 %qb, label %esc, label %ctl
esc:
  call void @cr_putc(i8 92)
  call void @cr_putc(i8 %c)
  br label %next
ctl:
  %lo = icmp ult i8 %c, 32
  br i1 %lo, label %u, label %raw
u:
  call void @cr_putc(i8 92)
  call void @cr_putc(i8 117)
  call void @cr_putc(i8 48)
  call void @cr_putc(i8 48)
  %c32 = zext i8 %c to i32
  %h = lshr i32 %c32, 4
  %l = and i32 %c32, 15
  %hc = call i8 @cr_hd(i32 %h, i8 97)
  %lc = call i8 @cr_hd(i32 %l, i8 97)
  call void @cr_putc(i8 %hc)
  call void @cr_putc(i8 %lc)
  br label %next
raw:
  call void @cr_putc(i8 %c)
  br label %next
next:
  %i2 = add i64 %i, 1
  br label %loop
done:
  ret void
}

define internal void @cr_q(ptr %s) {
entry:
  call void @cr_putc(i8 34)
  call void @cr_puts_json(ptr %s)
  call void @cr_putc(i8 34)
  ret void
}

; the digits of an unsigned number into tmp[0..24) from the right; answers where they start
define internal i32 @cr_fmt(ptr %tmp, i64 %v) {
entry:
  br label %loop
loop:
  %i = phi i32 [ 24, %entry ], [ %i2, %loop ]
  %x = phi i64 [ %v, %entry ], [ %x2, %loop ]
  %d = urem i64 %x, 10
  %x2 = udiv i64 %x, 10
  %i2 = sub i32 %i, 1
  %c = add i64 %d, 48
  %c8 = trunc i64 %c to i8
  %p = getelementptr i8, ptr %tmp, i32 %i2
  store i8 %c8, ptr %p
  %more = icmp ne i64 %x2, 0
  br i1 %more, label %loop, label %done
done:
  ret i32 %i2
}

define internal void @cr_udec(i64 %v) {
entry:
  %tmp = alloca [24 x i8], align 8
  %s = call i32 @cr_fmt(ptr %tmp, i64 %v)
  br label %loop
loop:
  %i = phi i32 [ %s, %entry ], [ %i2, %loop ]
  %p = getelementptr i8, ptr %tmp, i32 %i
  %c = load i8, ptr %p
  call void @cr_putc(i8 %c)
  %i2 = add i32 %i, 1
  %more = icmp slt i32 %i2, 24
  br i1 %more, label %loop, label %done
done:
  ret void
}

define internal void @cr_dec(i64 %v) {
entry:
  %neg = icmp slt i64 %v, 0
  br i1 %neg, label %n, label %p
n:
  call void @cr_putc(i8 45)
  %m = sub i64 0, %v
  call void @cr_udec(i64 %m)
  ret void
p:
  call void @cr_udec(i64 %v)
  ret void
}

define internal void @cr_hex(i64 %v) {
entry:
  call void @cr_putc(i8 48)
  call void @cr_putc(i8 120)
  br label %loop
loop:
  %sh = phi i32 [ 60, %entry ], [ %sh2, %next ]
  %st = phi i1 [ false, %entry ], [ %st2, %next ]
  %shl = zext i32 %sh to i64
  %d64 = lshr i64 %v, %shl
  %d = and i64 %d64, 15
  %nz = icmp ne i64 %d, 0
  %last = icmp eq i32 %sh, 0
  %e0 = or i1 %st, %nz
  %emit = or i1 %e0, %last
  br i1 %emit, label %put, label %next
put:
  %d32 = trunc i64 %d to i32
  %c = call i8 @cr_hd(i32 %d32, i8 97)
  call void @cr_putc(i8 %c)
  br label %next
next:
  %st2 = or i1 %e0, %last
  %sh2 = sub i32 %sh, 4
  %cont = icmp sge i32 %sh2, 0
  br i1 %cont, label %loop, label %done
done:
  ret void
}

; a 16-byte id as 8-4-4-4-12 upper-case hex
define internal void @cr_uuid(ptr %u) {
entry:
  br label %loop
loop:
  %i = phi i32 [ 0, %entry ], [ %i2, %next ]
  %p = getelementptr i8, ptr %u, i32 %i
  %b = load i8, ptr %p
  %b32 = zext i8 %b to i32
  %h = lshr i32 %b32, 4
  %l = and i32 %b32, 15
  %hc = call i8 @cr_hd(i32 %h, i8 65)
  %lc = call i8 @cr_hd(i32 %l, i8 65)
  call void @cr_putc(i8 %hc)
  call void @cr_putc(i8 %lc)
  %d3 = icmp eq i32 %i, 3
  %d5 = icmp eq i32 %i, 5
  %d7 = icmp eq i32 %i, 7
  %d9 = icmp eq i32 %i, 9
  %a = or i1 %d3, %d5
  %b2 = or i1 %d7, %d9
  %dash = or i1 %a, %b2
  br i1 %dash, label %dd, label %next
dd:
  call void @cr_putc(i8 45)
  br label %next
next:
  %i2 = add i32 %i, 1
  %more = icmp slt i32 %i2, 16
  br i1 %more, label %loop, label %done
done:
  ret void
}

; copy a C string into dst (cap bytes including the NUL), truncating; answers the length
define internal i32 @cr_copy(ptr %dst, ptr %src, i32 %cap) {
entry:
  %isnull = icmp eq ptr %src, null
  br i1 %isnull, label %fin0, label %loop
loop:
  %i = phi i32 [ 0, %entry ], [ %i2, %put ]
  %room = sub i32 %cap, 1
  %full = icmp sge i32 %i, %room
  br i1 %full, label %fin, label %rd
rd:
  %sp = getelementptr i8, ptr %src, i32 %i
  %c = load i8, ptr %sp
  %end = icmp eq i8 %c, 0
  br i1 %end, label %fin, label %put
put:
  %dp = getelementptr i8, ptr %dst, i32 %i
  store i8 %c, ptr %dp
  %i2 = add i32 %i, 1
  br label %loop
fin:
  %n = phi i32 [ %i, %loop ], [ %i, %rd ]
  %ep = getelementptr i8, ptr %dst, i32 %n
  store i8 0, ptr %ep
  ret i32 %n
fin0:
  store i8 0, ptr %dst
  ret i32 0
}

define internal i1 @cr_starts(ptr %s, ptr %pre) {
entry:
  br label %loop
loop:
  %i = phi i64 [ 0, %entry ], [ %i2, %next ]
  %pp = getelementptr i8, ptr %pre, i64 %i
  %pc = load i8, ptr %pp
  %end = icmp eq i8 %pc, 0
  br i1 %end, label %yes, label %cmp
cmp:
  %sp = getelementptr i8, ptr %s, i64 %i
  %sc = load i8, ptr %sp
  %eq = icmp eq i8 %sc, %pc
  br i1 %eq, label %next, label %no
next:
  %i2 = add i64 %i, 1
  br label %loop
yes:
  ret i1 true
no:
  ret i1 false
}

; the digits of v at dst; answers how many
define internal i32 @cr_num_to(ptr %dst, i64 %v) {
entry:
  %tmp = alloca [24 x i8], align 8
  %s = call i32 @cr_fmt(ptr %tmp, i64 %v)
  br label %loop
loop:
  %i = phi i32 [ %s, %entry ], [ %i2, %loop ]
  %o = sub i32 %i, %s
  %p = getelementptr i8, ptr %tmp, i32 %i
  %c = load i8, ptr %p
  %d = getelementptr i8, ptr %dst, i32 %o
  store i8 %c, ptr %d
  %i2 = add i32 %i, 1
  %more = icmp slt i32 %i2, 24
  br i1 %more, label %loop, label %done
done:
  %n = sub i32 24, %s
  ret i32 %n
}

; lower-case compare of the start of s with a lower-case prefix
define internal i1 @cr_istarts(ptr %s, ptr %pre) {
entry:
  br label %loop
loop:
  %i = phi i64 [ 0, %entry ], [ %i2, %next ]
  %pp = getelementptr i8, ptr %pre, i64 %i
  %pc = load i8, ptr %pp
  %end = icmp eq i8 %pc, 0
  br i1 %end, label %yes, label %cmp
cmp:
  %sp = getelementptr i8, ptr %s, i64 %i
  %sc = load i8, ptr %sp
  %up = icmp ult i8 %sc, 91
  %ge = icmp uge i8 %sc, 65
  %isup = and i1 %up, %ge
  %lc = add i8 %sc, 32
  %l = select i1 %isup, i8 %lc, i8 %sc
  %eq = icmp eq i8 %l, %pc
  br i1 %eq, label %next, label %no
next:
  %i2 = add i64 %i, 1
  br label %loop
yes:
  ret i1 true
no:
  ret i1 false
}

; a GUID's 16 bytes as text: the first three fields are little-endian
define internal void @cr_guid(ptr %u) {
entry:
  br label %loop
loop:
  %i = phi i32 [ 0, %entry ], [ %i2, %next ]
  ; the byte order of xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx over the stored bytes
  %lt4 = icmp slt i32 %i, 4
  %lt6 = icmp slt i32 %i, 6
  %lt8 = icmp slt i32 %i, 8
  %r4 = sub i32 3, %i
  %r6 = sub i32 9, %i
  %r8 = sub i32 13, %i
  %a = select i1 %lt8, i32 %r8, i32 %i
  %b = select i1 %lt6, i32 %r6, i32 %a
  %idx = select i1 %lt4, i32 %r4, i32 %b
  %p = getelementptr i8, ptr %u, i32 %idx
  %by = load i8, ptr %p
  %b32 = zext i8 %by to i32
  %h = lshr i32 %b32, 4
  %l = and i32 %b32, 15
  %hc = call i8 @cr_hd(i32 %h, i8 65)
  %lc = call i8 @cr_hd(i32 %l, i8 65)
  call void @cr_putc(i8 %hc)
  call void @cr_putc(i8 %lc)
  %d3 = icmp eq i32 %i, 3
  %d5 = icmp eq i32 %i, 5
  %d7 = icmp eq i32 %i, 7
  %d9 = icmp eq i32 %i, 9
  %x = or i1 %d3, %d5
  %y = or i1 %d7, %d9
  %dash = or i1 %x, %y
  br i1 %dash, label %dd, label %next
dd:
  call void @cr_putc(i8 45)
  br label %next
next:
  %i2 = add i32 %i, 1
  %more = icmp slt i32 %i2, 16
  br i1 %more, label %loop, label %done
done:
  ret void
}

; the loaded modules, once, at install (a module loaded later is not in the record)
define internal void @cr_snapshot() {
entry:
  %mods = alloca [1024 x ptr], align 8
  %need = alloca i32, align 4
  %wb = alloca [260 x i16], align 2
  %ub = alloca [1024 x i8], align 8
  store i32 0, ptr @C_in
  store i32 0, ptr %need
  %self = call ptr @GetCurrentProcess()
  %ok = call i32 @K32EnumProcessModules(ptr %self, ptr %mods, i32 8192, ptr %need)
  %nb = load i32, ptr %need
  %n0 = udiv i32 %nb, 8
  %cap = icmp ugt i32 %n0, 1024
  %n = select i1 %cap, i32 1024, i32 %n0
  br label %loop
loop:
  %i = phi i32 [ 0, %entry ], [ %i2, %next ]
  %more = icmp slt i32 %i, %n
  br i1 %more, label %mod, label %done
mod:
  %mp = getelementptr ptr, ptr %mods, i32 %i
  %hm = load ptr, ptr %mp
  %base = ptrtoint ptr %hm to i64
  %lfp = getelementptr i8, ptr %hm, i64 60
  %lf = load i32, ptr %lfp
  %lf64 = zext i32 %lf to i64
  %pe = getelementptr i8, ptr %hm, i64 %lf64
  %sig = load i32, ptr %pe
  %ispe = icmp eq i32 %sig, 17744
  br i1 %ispe, label %hdr, label %next
hdr:
  %tsp = getelementptr i8, ptr %pe, i64 8
  %ts = load i32, ptr %tsp
  %szp = getelementptr i8, ptr %pe, i64 80
  %sz = load i32, ptr %szp
  %sz64 = zext i32 %sz to i64
  %ddp = getelementptr i8, ptr %pe, i64 184
  %drva = load i32, ptr %ddp
  %dszp = getelementptr i8, ptr %pe, i64 188
  %dsz = load i32, ptr %dszp
  %dn = udiv i32 %dsz, 28
  %ix = load i32, ptr @C_in
  %ub16 = mul i32 %ix, 16
  %up = getelementptr i8, ptr @C_iu, i32 %ub16
  br label %dl
dl:
  %j = phi i32 [ 0, %hdr ], [ %j2, %dln ]
  %jm = icmp slt i32 %j, %dn
  %hasrva = icmp ne i32 %drva, 0
  %scan = and i1 %jm, %hasrva
  br i1 %scan, label %de, label %noguid
de:
  %joff = mul i32 %j, 28
  %rv = add i32 %drva, %joff
  %rv64 = zext i32 %rv to i64
  %ep = getelementptr i8, ptr %hm, i64 %rv64
  %typp = getelementptr i8, ptr %ep, i64 12
  %typ = load i32, ptr %typp
  %iscv = icmp eq i32 %typ, 2
  br i1 %iscv, label %cv, label %dln
cv:
  %rawp = getelementptr i8, ptr %ep, i64 20
  %raw = load i32, ptr %rawp
  %raw64 = zext i32 %raw to i64
  %cvp = getelementptr i8, ptr %hm, i64 %raw64
  %cvsig = load i32, ptr %cvp
  %isrsds = icmp eq i32 %cvsig, 1396986706
  br i1 %isrsds, label %guid, label %dln
guid:
  %gsrc = getelementptr i8, ptr %cvp, i64 4
  br label %gcp
gcp:
  %g = phi i32 [ 0, %guid ], [ %g2, %gcp ]
  %gs = getelementptr i8, ptr %gsrc, i32 %g
  %gc = load i8, ptr %gs
  %gd = getelementptr i8, ptr %up, i32 %g
  store i8 %gc, ptr %gd
  %g2 = add i32 %g, 1
  %gm = icmp slt i32 %g2, 16
  br i1 %gm, label %gcp, label %gage
gage:
  %agp = getelementptr i8, ptr %cvp, i64 20
  %age = load i32, ptr %agp
  br label %record
dln:
  %j2 = add i32 %j, 1
  br label %dl
noguid:
  br label %record
record:
  %hasg = phi i32 [ 8, %gage ], [ 0, %noguid ]
  %agev = phi i32 [ %age, %gage ], [ 0, %noguid ]
  %w = call i32 @GetModuleFileNameW(ptr %hm, ptr %wb, i32 260)
  %wz = icmp eq i32 %w, 0
  store i8 0, ptr %ub
  br i1 %wz, label %nopath, label %conv
conv:
  %cn = call i32 @WideCharToMultiByte(i32 65001, i32 0, ptr %wb, i32 -1, ptr %ub, i32 1024, ptr null, ptr null)
  br label %nopath
nopath:
  %pb = mul i32 %ix, 192
  %pd = getelementptr i8, ptr @C_ip, i32 %pb
  %cl = call i32 @cr_copy(ptr %pd, ptr %ub, i32 192)
  %isexe = icmp eq i32 %ix, 0
  %f1 = select i1 %isexe, i32 1, i32 0
  %sys = call i1 @cr_istarts(ptr %pd, ptr @k0)
  %f2 = select i1 %sys, i32 2, i32 0
  %f12 = or i32 %f1, %f2
  %fl = or i32 %f12, %hasg
  %bp = getelementptr i64, ptr @C_ib, i32 %ix
  store i64 %base, ptr %bp
  %zp = getelementptr i64, ptr @C_isz, i32 %ix
  store i64 %sz64, ptr %zp
  %fp = getelementptr i32, ptr @C_if, i32 %ix
  store i32 %fl, ptr %fp
  %ap = getelementptr i32, ptr @C_ia, i32 %ix
  store i32 %agev, ptr %ap
  %tp = getelementptr i32, ptr @C_it, i32 %ix
  store i32 %ts, ptr %tp
  %ix1 = add i32 %ix, 1
  store i32 %ix1, ptr @C_in
  br label %next
next:
  %i2 = add i32 %i, 1
  br label %loop
done:
  ret void
}

define internal i32 @cr_find(i64 %pc) {
entry:
  %n = load i32, ptr @C_in
  br label %loop
loop:
  %i = phi i32 [ 0, %entry ], [ %i2, %next ]
  %more = icmp slt i32 %i, %n
  br i1 %more, label %chk, label %none
chk:
  %bp = getelementptr i64, ptr @C_ib, i32 %i
  %b = load i64, ptr %bp
  %zp = getelementptr i64, ptr @C_isz, i32 %i
  %z = load i64, ptr %zp
  %e = add i64 %b, %z
  %ge = icmp uge i64 %pc, %b
  %lt = icmp ult i64 %pc, %e
  %in = and i1 %ge, %lt
  br i1 %in, label %hit, label %next
hit:
  ret i32 %i
next:
  %i2 = add i32 %i, 1
  br label %loop
none:
  ret i32 -1
}

define internal void @cr_frame(i32 %idx, i64 %pc, ptr %via) {
entry:
  call void @cr_puts(ptr @k1)
  %i64 = sext i32 %idx to i64
  call void @cr_udec(i64 %i64)
  call void @cr_puts(ptr @k2)
  call void @cr_hex(i64 %pc)
  call void @cr_puts(ptr @k3)
  call void @cr_puts(ptr %via)
  call void @cr_puts(ptr @k4)
  %img = call i32 @cr_find(i64 %pc)
  %has = icmp sge i32 %img, 0
  br i1 %has, label %mark, label %out
mark:
  %fp = getelementptr i32, ptr @C_if, i32 %img
  %f = load i32, ptr %fp
  %f2 = or i32 %f, 4
  store i32 %f2, ptr %fp
  br label %out
out:
  ret void
}

; the frames, by the OS unwinder, from a copy of the context; answers how many
define internal i32 @cr_walk(ptr %ctxin) {
entry:
  %ctx = alloca [1232 x i8], align 16
  %base = alloca i64, align 8
  %hd = alloca ptr, align 8
  %est = alloca i64, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 16 %ctx, ptr align 16 %ctxin, i64 1232, i1 false)
  %ripp = getelementptr i8, ptr %ctx, i64 248
  %rspp = getelementptr i8, ptr %ctx, i64 152
  br label %loop
loop:
  %i = phi i32 [ 0, %entry ], [ %i2, %step ]
  %lim = icmp slt i32 %i, 64
  br i1 %lim, label %look, label %done
look:
  %rip = load i64, ptr %ripp
  %rsp = load i64, ptr %rspp
  %z = icmp eq i64 %rip, 0
  br i1 %z, label %done, label %emit
emit:
  %first = icmp eq i32 %i, 0
  %via = select i1 %first, ptr @k5, ptr @k6
  call void @cr_frame(i32 %i, i64 %rip, ptr %via)
  %fe = call ptr @RtlLookupFunctionEntry(i64 %rip, ptr %base, ptr null)
  %leaf = icmp eq ptr %fe, null
  br i1 %leaf, label %isleaf, label %unwind
isleaf:
  %sp = inttoptr i64 %rsp to ptr
  %ra = load i64, ptr %sp
  store i64 %ra, ptr %ripp
  %rsp2 = add i64 %rsp, 8
  store i64 %rsp2, ptr %rspp
  br label %step
unwind:
  %b = load i64, ptr %base
  %r = call ptr @RtlVirtualUnwind(i32 0, i64 %b, i64 %rip, ptr %fe, ptr %ctx, ptr %hd, ptr %est, ptr null)
  br label %step
step:
  %i2 = add i32 %i, 1
  %nrsp = load i64, ptr %rspp
  %rose = icmp ugt i64 %nrsp, %rsp
  br i1 %rose, label %loop, label %done2
done2:
  ret i32 %i2
done:
  ret i32 %i
}
declare void @llvm.memcpy.p0.p0.i64(ptr, ptr, i64, i1)

define internal ptr @cr_excname(i32 %code) {
entry:
  switch i32 %code, label %other [
    i32 -1073741819, label %av
    i32 -1073741571, label %so
    i32 -1073741795, label %ill
    i32 -1073741676, label %idiv
    i32 -1073741674, label %priv
    i32 -1073740791, label %fast
    i32 -2147483645, label %bp
    i32 -1073741818, label %inpage
    i32 -1073741684, label %fdiv
    i32 -1073741683, label %fovf
    i32 -1073741786, label %noncont
  ]
av:
  ret ptr @k7
so:
  ret ptr @k8
ill:
  ret ptr @k9
idiv:
  ret ptr @k10
priv:
  ret ptr @k11
fast:
  ret ptr @k12
bp:
  ret ptr @k13
inpage:
  ret ptr @k14
fdiv:
  ret ptr @k15
fovf:
  ret ptr @k16
noncont:
  ret ptr @k17
other:
  ret ptr @k18
}

; the record: code (an NTSTATUS, or 0 for abort), sig (0, or 22 for abort), addr, and a CONTEXT
define internal void @cr_record(i32 %code, i32 %sig, i64 %addr, ptr %ctx) {
entry:
  %ft = alloca i64, align 8
  %tmp = alloca [24 x i8], align 8
  %wr = alloca i32, align 4
  %cx = cmpxchg ptr @C_busy, i32 0, i32 1 seq_cst seq_cst
  %won = extractvalue { i32, i1 } %cx, 1
  br i1 %won, label %go, label %out
go:
  %pid = call i32 @GetCurrentProcessId()
  %tid = call i32 @GetCurrentThreadId()
  call void @GetSystemTimeAsFileTime(ptr %ft)
  %fv = load i64, ptr %ft
  %secs = udiv i64 %fv, 10000000
  %now = sub i64 %secs, 11644473600
  ; <prefix>digits-pid.lcr, in UTF-16
  %pl = load i32, ptr @C_plen
  %pl64 = zext i32 %pl to i64
  br label %cp
cp:
  %ci = phi i64 [ 0, %go ], [ %ci2, %cp ]
  %csp = getelementptr i16, ptr @C_wpath, i64 %ci
  %cc = load i16, ptr %csp
  %cdp = getelementptr i16, ptr @C_wfull, i64 %ci
  store i16 %cc, ptr %cdp
  %ci2 = add i64 %ci, 1
  %cm = icmp ult i64 %ci2, %pl64
  br i1 %cm, label %cp, label %num1
num1:
  %s1 = call i32 @cr_fmt(ptr %tmp, i64 %now)
  %off1 = call i32 @cr_widen(ptr @C_wfull, i32 %pl, ptr %tmp, i32 %s1, i32 24)
  %off2 = call i32 @cr_wput(ptr @C_wfull, i32 %off1, i16 45)
  %pid64 = zext i32 %pid to i64
  %s2 = call i32 @cr_fmt(ptr %tmp, i64 %pid64)
  %off3 = call i32 @cr_widen(ptr @C_wfull, i32 %off2, ptr %tmp, i32 %s2, i32 24)
  %off4 = call i32 @cr_wput(ptr @C_wfull, i32 %off3, i16 46)
  %off5 = call i32 @cr_wput(ptr @C_wfull, i32 %off4, i16 108)
  %off6 = call i32 @cr_wput(ptr @C_wfull, i32 %off5, i16 99)
  %off7 = call i32 @cr_wput(ptr @C_wfull, i32 %off6, i16 114)
  %off8 = call i32 @cr_wput(ptr @C_wfull, i32 %off7, i16 0)
  ; GENERIC_WRITE, no sharing, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL
  %h = call ptr @CreateFileW(ptr @C_wfull, i32 1073741824, i32 0, ptr null, i32 2, i32 128, ptr null)
  %hi = ptrtoint ptr %h to i64
  %bad = icmp eq i64 %hi, -1
  br i1 %bad, label %out, label %write
write:
  store i64 %hi, ptr @C_fd
  store i32 0, ptr @C_n
  %ripp = getelementptr i8, ptr %ctx, i64 248
  %rspp = getelementptr i8, ptr %ctx, i64 152
  %rbpp = getelementptr i8, ptr %ctx, i64 160
  %rip = load i64, ptr %ripp
  %rsp = load i64, ptr %rspp
  %rbp = load i64, ptr %rbpp
  %mt = load i32, ptr @C_mtid
  %ismain = icmp eq i32 %mt, %tid
  call void @cr_puts(ptr @k19)
  call void @cr_q(ptr @C_app)
  call void @cr_puts(ptr @k20)
  call void @cr_q(ptr @C_ver)
  call void @cr_puts(ptr @k21)
  call void @cr_q(ptr @C_build)
  call void @cr_puts(ptr @k22)
  call void @cr_q(ptr @C_ctx)
  call void @cr_puts(ptr @k23)
  call void @cr_q(ptr @C_osv)
  call void @cr_puts(ptr @k24)
  call void @cr_udec(i64 %pid64)
  call void @cr_puts(ptr @k25)
  %tid64 = zext i32 %tid to i64
  call void @cr_udec(i64 %tid64)
  call void @cr_puts(ptr @k26)
  %mains = select i1 %ismain, ptr @k27, ptr @k28
  call void @cr_puts(ptr %mains)
  call void @cr_puts(ptr @k29)
  call void @cr_udec(i64 %now)
  call void @cr_puts(ptr @k30)
  %sig64 = zext i32 %sig to i64
  call void @cr_udec(i64 %sig64)
  call void @cr_puts(ptr @k31)
  %isabrt = icmp eq i32 %sig, 22
  %en = call ptr @cr_excname(i32 %code)
  %sn = select i1 %isabrt, ptr @k32, ptr %en
  call void @cr_puts(ptr %sn)
  call void @cr_puts(ptr @k33)
  %code64 = zext i32 %code to i64
  call void @cr_udec(i64 %code64)
  call void @cr_puts(ptr @k34)
  call void @cr_hex(i64 %addr)
  call void @cr_puts(ptr @k35)
  call void @cr_hex(i64 %rip)
  call void @cr_puts(ptr @k36)
  call void @cr_hex(i64 %rsp)
  call void @cr_puts(ptr @k37)
  call void @cr_hex(i64 %rbp)
  call void @cr_puts(ptr @k38)
  call void @cr_flush()
  %frames = call i32 @cr_walk(ptr %ctx)
  call void @cr_flush()
  %nimg = load i32, ptr @C_in
  br label %iloop
iloop:
  %ii = phi i32 [ 0, %write ], [ %ii2, %inext ]
  %icount = phi i32 [ 0, %write ], [ %icount2, %inext ]
  %imore = icmp slt i32 %ii, %nimg
  br i1 %imore, label %ichk, label %idone
ichk:
  %ifp = getelementptr i32, ptr @C_if, i32 %ii
  %if = load i32, ptr %ifp
  %sysbit = and i32 %if, 2
  %nonsys = icmp eq i32 %sysbit, 0
  %usedbit = and i32 %if, 5
  %used = icmp ne i32 %usedbit, 0
  %want = or i1 %nonsys, %used
  br i1 %want, label %iemit, label %inext
iemit:
  %ipb = mul i32 %ii, 192
  %ipp = getelementptr i8, ptr @C_ip, i32 %ipb
  %ibp = getelementptr i64, ptr @C_ib, i32 %ii
  %ib = load i64, ptr %ibp
  %izp = getelementptr i64, ptr @C_isz, i32 %ii
  %iz = load i64, ptr %izp
  call void @cr_puts(ptr @k39)
  call void @cr_q(ptr %ipp)
  call void @cr_puts(ptr @k40)
  call void @cr_hex(i64 %ib)
  call void @cr_puts(ptr @k41)
  call void @cr_hex(i64 %iz)
  call void @cr_putc(i8 34)
  %itp = getelementptr i32, ptr @C_it, i32 %ii
  %its = load i32, ptr %itp
  call void @cr_puts(ptr @k42)
  %its64 = zext i32 %its to i64
  call void @cr_udec(i64 %its64)
  %hasu = and i32 %if, 8
  %hu = icmp ne i32 %hasu, 0
  br i1 %hu, label %iuuid, label %itail
iuuid:
  call void @cr_puts(ptr @k43)
  %iub = mul i32 %ii, 16
  %iup = getelementptr i8, ptr @C_iu, i32 %iub
  call void @cr_guid(ptr %iup)
  call void @cr_putc(i8 34)
  call void @cr_puts(ptr @k44)
  %iap = getelementptr i32, ptr @C_ia, i32 %ii
  %iage = load i32, ptr %iap
  %iage64 = zext i32 %iage to i64
  call void @cr_udec(i64 %iage64)
  br label %itail
itail:
  %mb = and i32 %if, 1
  %ism = icmp ne i32 %mb, 0
  br i1 %ism, label %imain, label %iend
imain:
  call void @cr_puts(ptr @k45)
  br label %iend
iend:
  call void @cr_puts(ptr @k46)
  %icw = add i32 %icount, 1
  br label %inext
inext:
  %icount2 = phi i32 [ %icount, %ichk ], [ %icw, %iend ]
  %ii2 = add i32 %ii, 1
  br label %iloop
idone:
  call void @cr_puts(ptr @k47)
  %fr64 = sext i32 %frames to i64
  call void @cr_udec(i64 %fr64)
  call void @cr_puts(ptr @k48)
  %ic64 = sext i32 %icount to i64
  call void @cr_udec(i64 %ic64)
  call void @cr_puts(ptr @k46)
  call void @cr_flush()
  %cl = call i32 @CloseHandle(ptr %h)
  br label %out
out:
  ret void
}

; UTF-16 helpers for the file name: append ASCII digits tmp[from..24) / one unit; answer the new length
define internal i32 @cr_widen(ptr %dst, i32 %at, ptr %tmp, i32 %from, i32 %end) {
entry:
  br label %loop
loop:
  %i = phi i32 [ %from, %entry ], [ %i2, %put ]
  %o = phi i32 [ %at, %entry ], [ %o2, %put ]
  %more = icmp slt i32 %i, %end
  br i1 %more, label %put, label %done
put:
  %sp = getelementptr i8, ptr %tmp, i32 %i
  %c = load i8, ptr %sp
  %c16 = zext i8 %c to i16
  %dp = getelementptr i16, ptr %dst, i32 %o
  store i16 %c16, ptr %dp
  %i2 = add i32 %i, 1
  %o2 = add i32 %o, 1
  br label %loop
done:
  ret i32 %o
}

define internal i32 @cr_wput(ptr %dst, i32 %at, i16 %c) {
entry:
  %dp = getelementptr i16, ptr %dst, i32 %at
  store i16 %c, ptr %dp
  %n = add i32 %at, 1
  ret i32 %n
}

; SetUnhandledExceptionFilter's callback: EXCEPTION_POINTERS (an EXCEPTION_RECORD pointer, a CONTEXT pointer)
define i32 @lu_crash_filter(ptr %ep) {
entry:
  %erp = load ptr, ptr %ep
  %cxp = getelementptr i8, ptr %ep, i64 8
  %ctx = load ptr, ptr %cxp
  %code = load i32, ptr %erp
  %eap = getelementptr i8, ptr %erp, i64 16
  %ea = load i64, ptr %eap
  %npp = getelementptr i8, ptr %erp, i64 24
  %np = load i32, ptr %npp
  %i1p = getelementptr i8, ptr %erp, i64 40
  %i1 = load i64, ptr %i1p
  ; an access violation or in-page error names the address it touched
  %isav = icmp eq i32 %code, -1073741819
  %isin = icmp eq i32 %code, -1073741818
  %isacc = or i1 %isav, %isin
  %has = icmp uge i32 %np, 2
  %useinfo = and i1 %isacc, %has
  %addr = select i1 %useinfo, i64 %i1, i64 %ea
  call void @cr_record(i32 %code, i32 0, i64 %addr, ptr %ctx)
  ret i32 0
}

; the C runtime's SIGABRT hook: abort() fails fast, so no filter ever sees it
define void @lu_crash_abort(i32 %sig) {
entry:
  %ctx = alloca [1232 x i8], align 16
  call void @RtlCaptureContext(ptr %ctx)
  call void @cr_record(i32 0, i32 22, i64 0, ptr %ctx)
  ret void
}

define i32 @lu_crash_install(ptr %dir, ptr %app, ptr %ver, ptr %build) {
entry:
  %guar = alloca i32, align 4
  %tmp = alloca [24 x i8], align 8
  %nodir = icmp eq ptr %dir, null
  br i1 %nodir, label %bad, label %chk
chk:
  %c0 = load i8, ptr %dir
  %empty = icmp eq i8 %c0, 0
  br i1 %empty, label %bad, label %cfg
bad:
  ret i32 -1
cfg:
  %n = call i32 @MultiByteToWideChar(i32 65001, i32 0, ptr %dir, i32 -1, ptr @C_wpath, i32 1000)
  %nbad = icmp sle i32 %n, 0
  br i1 %nbad, label %bad, label %pfx
pfx:
  ; n counts the NUL: the prefix continues over it. A separator unless one is there already.
  %len = sub i32 %n, 1
  %lm1 = sub i32 %len, 1
  %lp = getelementptr i16, ptr @C_wpath, i32 %lm1
  %lc = load i16, ptr %lp
  %s1 = icmp eq i16 %lc, 92
  %s2 = icmp eq i16 %lc, 47
  %ends = or i1 %s1, %s2
  br i1 %ends, label %nosep, label %sep
sep:
  %o1 = call i32 @cr_wput(ptr @C_wpath, i32 %len, i16 92)
  br label %word
nosep:
  br label %word
word:
  %o2 = phi i32 [ %o1, %sep ], [ %len, %nosep ]
  %o3 = call i32 @cr_wput(ptr @C_wpath, i32 %o2, i16 99)
  %o4 = call i32 @cr_wput(ptr @C_wpath, i32 %o3, i16 114)
  %o5 = call i32 @cr_wput(ptr @C_wpath, i32 %o4, i16 97)
  %o6 = call i32 @cr_wput(ptr @C_wpath, i32 %o5, i16 115)
  %o7 = call i32 @cr_wput(ptr @C_wpath, i32 %o6, i16 104)
  %o8 = call i32 @cr_wput(ptr @C_wpath, i32 %o7, i16 45)
  store i32 %o8, ptr @C_plen
  %a1 = call i32 @cr_copy(ptr @C_app, ptr %app, i32 160)
  %a2 = call i32 @cr_copy(ptr @C_ver, ptr %ver, i32 160)
  %a3 = call i32 @cr_copy(ptr @C_build, ptr %build, i32 160)
  ; Windows' version from the shared user data page: major, minor, build
  %maj = load i32, ptr inttoptr (i64 2147353196 to ptr)
  %min = load i32, ptr inttoptr (i64 2147353200 to ptr)
  %bld = load i32, ptr inttoptr (i64 2147353184 to ptr)
  %maj64 = zext i32 %maj to i64
  %min64 = zext i32 %min to i64
  %bld64 = zext i32 %bld to i64
  %v1 = call i32 @cr_num_to(ptr @C_osv, i64 %maj64)
  %vp1 = getelementptr i8, ptr @C_osv, i32 %v1
  store i8 46, ptr %vp1
  %vp2 = getelementptr i8, ptr %vp1, i32 1
  %v2 = call i32 @cr_num_to(ptr %vp2, i64 %min64)
  %vp3 = getelementptr i8, ptr %vp2, i32 %v2
  store i8 46, ptr %vp3
  %vp4 = getelementptr i8, ptr %vp3, i32 1
  %v3 = call i32 @cr_num_to(ptr %vp4, i64 %bld64)
  %vp5 = getelementptr i8, ptr %vp4, i32 %v3
  store i8 0, ptr %vp5
  call void @cr_snapshot()
  %tid = call i32 @GetCurrentThreadId()
  store i32 %tid, ptr @C_mtid
  store i32 65536, ptr %guar
  %sg = call i32 @SetThreadStackGuarantee(ptr %guar)
  %old = call ptr @SetUnhandledExceptionFilter(ptr @lu_crash_filter)
  %sa = call ptr @signal(i32 22, ptr @lu_crash_abort)
  store i32 1, ptr @C_on
  ret i32 0
}

define void @lu_crash_uninstall() {
entry:
  %old = call ptr @SetUnhandledExceptionFilter(ptr null)
  %sa = call ptr @signal(i32 22, ptr null)
  store i32 0, ptr @C_on
  ret void
}

define void @lu_crash_context(ptr %text) {
entry:
  %n = call i32 @cr_copy(ptr @C_ctx, ptr %text, i32 256)
  ret void
}

@C_sink = internal global i32 0

define internal i64 @cr_recurse(i64 %n) {
entry:
  %buf = alloca [256 x i8], align 8
  store volatile i8 1, ptr %buf
  %r = call i64 @cr_recurse(i64 %n)
  %v = load volatile i8, ptr %buf
  %v64 = zext i8 %v to i64
  %s = add i64 %r, %v64
  ret i64 %s
}

define void @lu_crash_trigger(i32 %kind) {
entry:
  switch i32 %kind, label %wild [
    i32 1, label %ab
    i32 2, label %tr
    i32 3, label %so
  ]
wild:
  store volatile i32 7, ptr inttoptr (i64 16 to ptr)
  ret void
ab:
  call void @abort()
  unreachable
tr:
  call void @llvm.trap()
  unreachable
so:
  %x = call i64 @cr_recurse(i64 0)
  store volatile i32 1, ptr @C_sink
  ret void
}

; ---- constants ----
@k0 = private unnamed_addr constant [12 x i8] c"c:\5Cwindows\5C\00"
@k1 = private unnamed_addr constant [18 x i8] c"{\22k\22:\22frame\22,\22i\22:\00"
@k2 = private unnamed_addr constant [8 x i8] c",\22pc\22:\22\00"
@k3 = private unnamed_addr constant [10 x i8] c"\22,\22via\22:\22\00"
@k4 = private unnamed_addr constant [4 x i8] c"\22}\0A\00"
@k5 = private unnamed_addr constant [3 x i8] c"pc\00"
@k6 = private unnamed_addr constant [7 x i8] c"unwind\00"
@k7 = private unnamed_addr constant [27 x i8] c"EXCEPTION_ACCESS_VIOLATION\00"
@k8 = private unnamed_addr constant [25 x i8] c"EXCEPTION_STACK_OVERFLOW\00"
@k9 = private unnamed_addr constant [30 x i8] c"EXCEPTION_ILLEGAL_INSTRUCTION\00"
@k10 = private unnamed_addr constant [29 x i8] c"EXCEPTION_INT_DIVIDE_BY_ZERO\00"
@k11 = private unnamed_addr constant [27 x i8] c"EXCEPTION_PRIV_INSTRUCTION\00"
@k12 = private unnamed_addr constant [28 x i8] c"STATUS_STACK_BUFFER_OVERRUN\00"
@k13 = private unnamed_addr constant [21 x i8] c"EXCEPTION_BREAKPOINT\00"
@k14 = private unnamed_addr constant [24 x i8] c"EXCEPTION_IN_PAGE_ERROR\00"
@k15 = private unnamed_addr constant [29 x i8] c"EXCEPTION_FLT_DIVIDE_BY_ZERO\00"
@k16 = private unnamed_addr constant [23 x i8] c"EXCEPTION_FLT_OVERFLOW\00"
@k17 = private unnamed_addr constant [35 x i8] c"EXCEPTION_NONCONTINUABLE_EXCEPTION\00"
@k18 = private unnamed_addr constant [10 x i8] c"EXCEPTION\00"
@k19 = private unnamed_addr constant [45 x i8] c"{\22k\22:\22crash\22,\22v\22:1,\22producer\22:\22ludic\22,\22app\22:\00"
@k20 = private unnamed_addr constant [12 x i8] c",\22version\22:\00"
@k21 = private unnamed_addr constant [10 x i8] c",\22build\22:\00"
@k22 = private unnamed_addr constant [12 x i8] c",\22context\22:\00"
@k23 = private unnamed_addr constant [30 x i8] c",\22os\22:\22windows\22,\22os_version\22:\00"
@k24 = private unnamed_addr constant [24 x i8] c",\22arch\22:\22x86_64\22,\22pid\22:\00"
@k25 = private unnamed_addr constant [8 x i8] c",\22tid\22:\00"
@k26 = private unnamed_addr constant [9 x i8] c",\22main\22:\00"
@k27 = private unnamed_addr constant [5 x i8] c"true\00"
@k28 = private unnamed_addr constant [6 x i8] c"false\00"
@k29 = private unnamed_addr constant [9 x i8] c",\22time\22:\00"
@k30 = private unnamed_addr constant [8 x i8] c",\22sig\22:\00"
@k31 = private unnamed_addr constant [13 x i8] c",\22signame\22:\22\00"
@k32 = private unnamed_addr constant [8 x i8] c"SIGABRT\00"
@k33 = private unnamed_addr constant [10 x i8] c"\22,\22code\22:\00"
@k34 = private unnamed_addr constant [10 x i8] c",\22addr\22:\22\00"
@k35 = private unnamed_addr constant [9 x i8] c"\22,\22pc\22:\22\00"
@k36 = private unnamed_addr constant [9 x i8] c"\22,\22sp\22:\22\00"
@k37 = private unnamed_addr constant [9 x i8] c"\22,\22fp\22:\22\00"
@k38 = private unnamed_addr constant [15 x i8] c"\22,\22lr\22:\220x0\22}\0A\00"
@k39 = private unnamed_addr constant [21 x i8] c"{\22k\22:\22image\22,\22path\22:\00"
@k40 = private unnamed_addr constant [10 x i8] c",\22base\22:\22\00"
@k41 = private unnamed_addr constant [11 x i8] c"\22,\22size\22:\22\00"
@k42 = private unnamed_addr constant [14 x i8] c",\22timestamp\22:\00"
@k43 = private unnamed_addr constant [10 x i8] c",\22uuid\22:\22\00"
@k44 = private unnamed_addr constant [8 x i8] c",\22age\22:\00"
@k45 = private unnamed_addr constant [13 x i8] c",\22main\22:true\00"
@k46 = private unnamed_addr constant [3 x i8] c"}\0A\00"
@k47 = private unnamed_addr constant [21 x i8] c"{\22k\22:\22end\22,\22frames\22:\00"
@k48 = private unnamed_addr constant [11 x i8] c",\22images\22:\00"
