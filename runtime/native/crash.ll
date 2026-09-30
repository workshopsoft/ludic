; ============================================================================
; crash.ll - crash capture behind ludic.crash (macOS, POSIX signals).
;
; Linked into any program that calls the lu_crash_* layer (tools/ludic-cli/build.ludic's
; native_link_flags, which `ludic build`, `ludic test` and `ludic bundle` all say). crash_win.ll is the same interface over SetUnhandledExceptionFilter.
;
;   lu_crash_install(dir, app, version, build) -> int
;       Install the handlers: SIGSEGV SIGBUS SIGILL SIGFPE SIGABRT SIGTRAP, on an alternate
;       stack of the calling thread (so a stack overflow on it is caught), and keep every
;       string the handler will need in static buffers. `dir` must exist. 0 on success,
;       -1 for an empty dir. Calling it again only replaces the strings.
;   lu_crash_uninstall()            the default action for all six again
;   lu_crash_context(text)          one line of game state for the next record
;   lu_crash_trigger(kind)          0 a wild store, 1 abort(), 2 a trap, 3 SIGFPE, 4 a stack
;                                   overflow. For tests and a "crash now" debug button.
;
; WHAT THE HANDLER MAY DO. It runs on the faulting thread, possibly inside malloc or the
; loader, so it calls nothing that allocates or locks: only open, write, close, getpid,
; time, nanosleep, raise and pthread_self-style reads, all async-signal-safe or plain
; reads. Everything else - the image table, the strings, the file name prefix - was made
; before the crash, in install and in dyld's add-image callback. The record is formatted
; by hand into a 4 KiB buffer that is flushed with write(2) as it fills, so a record the
; handler did not finish is still a prefix of valid JSON lines.
;
; THE BACKTRACE is a scan, not a frame-pointer walk and not _Unwind_Backtrace. ludicc's functions
; keep no frame-pointer chain (they save x29 and never set it), and the unwinder takes dyld's
; and its own locks and allocates, which a crash inside either would deadlock on. So: frame 0 is
; the pc from the signal context; then the lr register when it is a return address; then every
; word from sp up to the top of the crashing thread's own stack (pthread_get_stackaddr_np: the walk
; cannot leave mapped memory) that is a return address - inside a loaded image's __TEXT, and on
; arm64 right after a BL, BLR or BLRAA (the word before it is one of those). At most 64 frames,
; 1 MiB of stack. Stale return addresses in dead slots of live frames can show up as extra
; frames ("via": "scan"); a missing one is a frame whose call was not a BL/BLR.
;
; A fault INSIDE the handler meets the default action at once (SA_RESETHAND | SA_NODEFER), and a
; handler that hangs is ended after 5 seconds by a timer (alarm, cancelled as soon as the record is written) that re-raises the ORIGINAL signal, so the exit status is the crash's, so a crash never turns into a
; frozen process.
;
; THE RECORD is JSON lines, written to <dir>/crash-<unix time>-<pid>.lcr; see
; packages/ludic.crash/README.md for every field. After it, the signal is raised again with
; the default action (SA_RESETHAND), so the OS reports the crash as it would have.
;
; arm64 and x86_64 macOS are read from the context; only arm64 is exercised by the tests.
; ============================================================================

declare i32 @open(ptr, i32, ...)
declare i32 @close(i32)
declare i64 @write(i32, ptr, i64)
declare i32 @getpid()
declare i64 @time(ptr)
declare i32 @nanosleep(ptr, ptr)
declare void @_exit(i32)
declare i32 @raise(i32)
declare i32 @alarm(i32)
declare void @abort()
declare ptr @malloc(i64)
declare i32 @sigaction(i32, ptr, ptr)
declare i32 @sigaltstack(ptr, ptr)
declare ptr @pthread_self()
declare ptr @pthread_get_stackaddr_np(ptr)
declare i64 @pthread_get_stacksize_np(ptr)
declare i32 @pthread_threadid_np(ptr, ptr)
declare i32 @pthread_main_np()
declare i32 @uname(ptr)
declare i32 @sysctlbyname(ptr, ptr, ptr, ptr, i64)
declare void @_dyld_register_func_for_add_image(ptr)
declare i32 @_dyld_image_count()
declare ptr @_dyld_get_image_header(i32)
declare ptr @_dyld_get_image_name(i32)

@C_on = internal global i32 0
@C_busy = internal global i32 0
@C_reg = internal global i32 0
@C_arch = internal global i32 1
@C_plen = internal global i32 0
@C_path = internal global [1024 x i8] zeroinitializer
@C_full = internal global [1100 x i8] zeroinitializer
@C_app = internal global [160 x i8] zeroinitializer
@C_ver = internal global [160 x i8] zeroinitializer
@C_build = internal global [160 x i8] zeroinitializer
@C_ctx = internal global [256 x i8] zeroinitializer
@C_osv = internal global [64 x i8] zeroinitializer

; the loaded images: base, size of __TEXT, LC_UUID, path, flags (1 main executable,
; 2 system library, 4 a frame landed in it, 8 has a uuid)
@C_in = internal global i32 0
@C_lo = internal global i64 -1
@C_hi = internal global i64 0
@C_sig = internal global i32 0
@C_ib = internal global [1024 x i64] zeroinitializer
@C_isz = internal global [1024 x i64] zeroinitializer
@C_iu = internal global [16384 x i8] zeroinitializer
@C_ip = internal global [196608 x i8] zeroinitializer
@C_if = internal global [1024 x i32] zeroinitializer

define internal i64 @cr_write(i64 %fd, ptr %p, i64 %n) {
entry:
  %f = trunc i64 %fd to i32
  %r = call i64 @write(i32 %f, ptr %p, i64 %n)
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

; dyld calls this for every image already loaded, then for each one loaded later
define internal void @cr_add_image(ptr %mh, i64 %slide) {
entry:
  %n = load i32, ptr @C_in
  %full = icmp sge i32 %n, 1024
  br i1 %full, label %out, label %hdr
hdr:
  %magic = load i32, ptr %mh
  %is64 = icmp eq i32 %magic, -17958193
  br i1 %is64, label %scan, label %out
scan:
  %ftp = getelementptr i8, ptr %mh, i64 12
  %ft = load i32, ptr %ftp
  %ncp = getelementptr i8, ptr %mh, i64 16
  %nc = load i32, ptr %ncp
  %p0 = getelementptr i8, ptr %mh, i64 32
  %ub = mul i32 %n, 16
  %up = getelementptr i8, ptr @C_iu, i32 %ub
  br label %lc
lc:
  %i = phi i32 [ 0, %scan ], [ %i2, %lcn ]
  %p = phi ptr [ %p0, %scan ], [ %p2, %lcn ]
  %tsz = phi i64 [ 0, %scan ], [ %tsz2, %lcn ]
  %hu = phi i32 [ 0, %scan ], [ %hu2, %lcn ]
  %more = icmp slt i32 %i, %nc
  br i1 %more, label %lcb, label %fin
lcb:
  %cmd = load i32, ptr %p
  %szp = getelementptr i8, ptr %p, i64 4
  %sz = load i32, ptr %szp
  %isseg = icmp eq i32 %cmd, 25
  br i1 %isseg, label %seg, label %chkuuid
seg:
  %snp = getelementptr i8, ptr %p, i64 8
  %sn = load i64, ptr %snp, align 1
  %istext = icmp eq i64 %sn, 92738097012575
  %vsp = getelementptr i8, ptr %p, i64 32
  %vs = load i64, ptr %vsp, align 1
  %tsz3 = select i1 %istext, i64 %vs, i64 %tsz
  br label %lcn
chkuuid:
  %isu = icmp eq i32 %cmd, 27
  br i1 %isu, label %uu, label %lcn
uu:
  %usrc = getelementptr i8, ptr %p, i64 8
  br label %ucp
ucp:
  %j = phi i32 [ 0, %uu ], [ %j2, %ucp ]
  %sp = getelementptr i8, ptr %usrc, i32 %j
  %ch = load i8, ptr %sp
  %dp = getelementptr i8, ptr %up, i32 %j
  store i8 %ch, ptr %dp
  %j2 = add i32 %j, 1
  %jm = icmp slt i32 %j2, 16
  br i1 %jm, label %ucp, label %lcn
lcn:
  %tsz2 = phi i64 [ %tsz, %chkuuid ], [ %tsz3, %seg ], [ %tsz, %ucp ]
  %hu2 = phi i32 [ %hu, %chkuuid ], [ %hu, %seg ], [ 8, %ucp ]
  %p2 = getelementptr i8, ptr %p, i32 %sz
  %i2 = add i32 %i, 1
  %zsz = icmp eq i32 %sz, 0
  br i1 %zsz, label %fin, label %lc
fin:
  %tszf = phi i64 [ %tsz, %lc ], [ %tsz2, %lcn ]
  %huf = phi i32 [ %hu, %lc ], [ %hu2, %lcn ]
  ; the path: dyld's own name for this header
  %cnt = call i32 @_dyld_image_count()
  %pb = mul i32 %n, 192
  %pd = getelementptr i8, ptr @C_ip, i32 %pb
  store i8 0, ptr %pd
  br label %find
find:
  %k = phi i32 [ 0, %fin ], [ %k2, %findn ]
  %kd = icmp slt i32 %k, %cnt
  br i1 %kd, label %look, label %store
look:
  %h = call ptr @_dyld_get_image_header(i32 %k)
  %same = icmp eq ptr %h, %mh
  br i1 %same, label %got, label %findn
got:
  %nm = call ptr @_dyld_get_image_name(i32 %k)
  %cl = call i32 @cr_copy(ptr %pd, ptr %nm, i32 192)
  br label %store
findn:
  %k2 = add i32 %k, 1
  br label %find
store:
  %isexe = icmp eq i32 %ft, 2
  %f1 = select i1 %isexe, i32 1, i32 0
  %sys1 = call i1 @cr_starts(ptr %pd, ptr @k0)
  %sys2 = call i1 @cr_starts(ptr %pd, ptr @k1)
  %sys = or i1 %sys1, %sys2
  %f2 = select i1 %sys, i32 2, i32 0
  %f12 = or i32 %f1, %f2
  %flags = or i32 %f12, %huf
  %bp = getelementptr i64, ptr @C_ib, i32 %n
  %b = ptrtoint ptr %mh to i64
  store i64 %b, ptr %bp
  %zp = getelementptr i64, ptr @C_isz, i32 %n
  store i64 %tszf, ptr %zp
  %fp = getelementptr i32, ptr @C_if, i32 %n
  store i32 %flags, ptr %fp
  %enda = add i64 %b, %tszf
  %lo0 = load i64, ptr @C_lo
  %lolt = icmp ult i64 %b, %lo0
  %lo1 = select i1 %lolt, i64 %b, i64 %lo0
  store i64 %lo1, ptr @C_lo
  %hi0 = load i64, ptr @C_hi
  %hihi = icmp ugt i64 %enda, %hi0
  %hi1 = select i1 %hihi, i64 %enda, i64 %hi0
  store i64 %hi1, ptr @C_hi
  %n1 = add i32 %n, 1
  store atomic i32 %n1, ptr @C_in release, align 4
  br label %out
out:
  ret void
}

; the image holding pc, or -1
define internal i32 @cr_find(i64 %pc) {
entry:
  %lo = load i64, ptr @C_lo
  %hi = load i64, ptr @C_hi
  %below = icmp ult i64 %pc, %lo
  %above = icmp uge i64 %pc, %hi
  %out = or i1 %below, %above
  br i1 %out, label %none, label %go
go:
  %n = load atomic i32, ptr @C_in acquire, align 4
  br label %loop
loop:
  %i = phi i32 [ 0, %go ], [ %i2, %next ]
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
  call void @cr_puts(ptr @k2)
  %i64 = sext i32 %idx to i64
  call void @cr_udec(i64 %i64)
  call void @cr_puts(ptr @k3)
  call void @cr_hex(i64 %pc)
  call void @cr_puts(ptr @k4)
  call void @cr_puts(ptr %via)
  call void @cr_puts(ptr @k5)
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

; could w be a return address: inside a loaded image and, on arm64, right after a call
; (BL, BLR or BLRAA*: the word before it is one of those; instructions are fixed-width)
define internal i1 @cr_valid(i64 %w, i32 %arch) {
entry:
  %z = icmp eq i64 %w, 0
  br i1 %z, label %no, label %chk
chk:
  %img = call i32 @cr_find(i64 %w)
  %in = icmp sge i32 %img, 0
  br i1 %in, label %arm, label %no
arm:
  %isarm = icmp eq i32 %arch, 1
  br i1 %isarm, label %insn, label %yes
insn:
  %al = and i64 %w, 3
  %a = icmp eq i64 %al, 0
  br i1 %a, label %rd, label %no
rd:
  %pp = sub i64 %w, 4
  %img4 = call i32 @cr_find(i64 %pp)
  %in4 = icmp sge i32 %img4, 0
  br i1 %in4, label %rd2, label %no
rd2:
  %ptr = inttoptr i64 %pp to ptr
  %i = load i32, ptr %ptr
  %bl0 = and i32 %i, -67108864
  %isbl = icmp eq i32 %bl0, -1811939328
  %blr0 = and i32 %i, -993
  %isblr = icmp eq i32 %blr0, -700514304
  %blra0 = and i32 %i, -16779264
  %isblra = icmp eq i32 %blra0, -700512256
  %c1 = or i1 %isbl, %isblr
  %c2 = or i1 %c1, %isblra
  ret i1 %c2
yes:
  ret i1 true
no:
  ret i1 false
}

; the frames: pc, lr when it is a return address, then every return address found on the
; stack from sp up (a scan, see the header); answers how many were written
define internal i32 @cr_walk(i64 %pc, i64 %sp, i64 %lr, i32 %arch) {
entry:
  %self = call ptr @pthread_self()
  %topp = call ptr @pthread_get_stackaddr_np(ptr %self)
  %size = call i64 @pthread_get_stacksize_np(ptr %self)
  %hi = ptrtoint ptr %topp to i64
  %lo = sub i64 %hi, %size
  call void @cr_frame(i32 0, i64 %pc, ptr @k6)
  %lrok = call i1 @cr_valid(i64 %lr, i32 %arch)
  %lrne = icmp ne i64 %lr, %pc
  %dolr = and i1 %lrok, %lrne
  br i1 %dolr, label %emitlr, label %scan0
emitlr:
  call void @cr_frame(i32 1, i64 %lr, ptr @k7)
  br label %scan0
scan0:
  %i0 = phi i32 [ 2, %emitlr ], [ 1, %entry ]
  %last0 = phi i64 [ %lr, %emitlr ], [ %pc, %entry ]
  %inside = icmp uge i64 %sp, %lo
  %from0 = select i1 %inside, i64 %sp, i64 %lo
  %from = and i64 %from0, -8
  %cap = add i64 %from, 262144
  %stop = call i64 @cr_umin(i64 %hi, i64 %cap)
  %okrange = icmp ult i64 %from, %stop
  br i1 %okrange, label %loop, label %done
loop:
  %a = phi i64 [ %from, %scan0 ], [ %a2, %next ]
  %i = phi i32 [ %i0, %scan0 ], [ %i3, %next ]
  %last = phi i64 [ %last0, %scan0 ], [ %last3, %next ]
  %ap = inttoptr i64 %a to ptr
  %w = load i64, ptr %ap
  %dup = icmp eq i64 %w, %last
  br i1 %dup, label %skip, label %test
test:
  %v = call i1 @cr_valid(i64 %w, i32 %arch)
  br i1 %v, label %emit, label %skip
emit:
  call void @cr_frame(i32 %i, i64 %w, ptr @k8)
  %i1 = add i32 %i, 1
  br label %next
skip:
  %lastn = select i1 %dup, i64 0, i64 %last
  br label %next
next:
  %i3 = phi i32 [ %i1, %emit ], [ %i, %skip ]
  %last3 = phi i64 [ %last, %emit ], [ %lastn, %skip ]
  %a2 = add i64 %a, 8
  %more = icmp ult i64 %a2, %stop
  %room = icmp slt i32 %i3, 64
  %go = and i1 %more, %room
  br i1 %go, label %loop, label %done
done:
  %cnt = phi i32 [ %i0, %scan0 ], [ %i3, %next ]
  ret i32 %cnt
}

define internal i64 @cr_umin(i64 %a, i64 %b) {
entry:
  %lt = icmp ult i64 %a, %b
  %r = select i1 %lt, i64 %a, i64 %b
  ret i64 %r
}

define internal ptr @cr_signame(i32 %sig) {
entry:
  switch i32 %sig, label %other [
    i32 0, label %fence
    i32 4, label %ill
    i32 5, label %trap
    i32 6, label %abrt
    i32 8, label %fpe
    i32 10, label %bus
    i32 11, label %segv
  ]
fence:
  ret ptr @kfence
ill:
  ret ptr @k9
trap:
  ret ptr @k10
abrt:
  ret ptr @k11
fpe:
  ret ptr @k12
bus:
  ret ptr @k13
segv:
  ret ptr @k14
other:
  ret ptr @k15
}

; the safety: a handler still running 5 s after the crash ends the process with the ORIGINAL signal
define void @lu_crash_alarm(i32 %s) {
entry:
  %sa = alloca [16 x i8], align 8
  %sig = load i32, ptr @C_sig
  store ptr null, ptr %sa
  %mp = getelementptr i8, ptr %sa, i64 8
  store i32 0, ptr %mp
  %fp = getelementptr i8, ptr %sa, i64 12
  store i32 0, ptr %fp
  %r = call i32 @sigaction(i32 %sig, ptr %sa, ptr null)
  %q = call i32 @raise(i32 %sig)
  %ec = add i32 %sig, 128
  call void @_exit(i32 %ec)
  unreachable
}

define void @lu_crash_handler(i32 %sig, ptr %info, ptr %uc) {
entry:
  %ts = alloca [2 x i64], align 8
  %tid = alloca i64, align 8
  %asa = alloca [16 x i8], align 8
  %cx = cmpxchg ptr @C_busy, i32 0, i32 1 seq_cst seq_cst
  %won = extractvalue { i32, i1 } %cx, 1
  br i1 %won, label %go, label %lose
lose:
  store i64 0, ptr %ts
  %nsp = getelementptr i64, ptr %ts, i32 1
  store i64 1000000, ptr %nsp
  br label %wait
wait:
  %w = phi i32 [ 0, %lose ], [ %w2, %wait ]
  %nr = call i32 @nanosleep(ptr %ts, ptr null)
  %w2 = add i32 %w, 1
  %wm = icmp slt i32 %w2, 1000
  br i1 %wm, label %wait, label %givenup
givenup:
  %ec = add i32 %sig, 128
  call void @_exit(i32 %ec)
  unreachable
go:
  ; a handler that hangs (a lock it needed was held by the crash) is ended by SIGALRM
  store i32 %sig, ptr @C_sig
  store ptr @lu_crash_alarm, ptr %asa
  %asm = getelementptr i8, ptr %asa, i64 8
  store i32 0, ptr %asm
  %asf = getelementptr i8, ptr %asa, i64 12
  store i32 1, ptr %asf
  %asr = call i32 @sigaction(i32 14, ptr %asa, ptr null)
  %al = call i32 @alarm(i32 5)
  %pid = call i32 @getpid()
  %now = call i64 @time(ptr null)
  %pl = call i32 @cr_copy(ptr @C_full, ptr @C_path, i32 1024)
  %e1 = getelementptr i8, ptr @C_full, i32 %pl
  %n1 = call i32 @cr_num_to(ptr %e1, i64 %now)
  %o1 = add i32 %pl, %n1
  %d1 = getelementptr i8, ptr @C_full, i32 %o1
  store i8 45, ptr %d1
  %o2 = add i32 %o1, 1
  %e2 = getelementptr i8, ptr @C_full, i32 %o2
  %pid64 = sext i32 %pid to i64
  %n2 = call i32 @cr_num_to(ptr %e2, i64 %pid64)
  %o3 = add i32 %o2, %n2
  %e3 = getelementptr i8, ptr @C_full, i32 %o3
  store i8 46, ptr %e3
  %e4 = getelementptr i8, ptr %e3, i32 1
  store i8 108, ptr %e4
  %e5 = getelementptr i8, ptr %e3, i32 2
  store i8 99, ptr %e5
  %e6 = getelementptr i8, ptr %e3, i32 3
  store i8 114, ptr %e6
  %e7 = getelementptr i8, ptr %e3, i32 4
  store i8 0, ptr %e7
  %fd = call i32 (ptr, i32, ...) @open(ptr @C_full, i32 1537, i32 384)
  %fdok = icmp sge i32 %fd, 0
  br i1 %fdok, label %write, label %reraise
write:
  %fd64 = sext i32 %fd to i64
  store i64 %fd64, ptr @C_fd
  store i32 0, ptr @C_n
  ; the registers of the faulting thread
  %ucnull = icmp eq ptr %uc, null
  br i1 %ucnull, label %noctx, label %ctx
ctx:
  %mcp = getelementptr i8, ptr %uc, i64 48
  %mc = load ptr, ptr %mcp
  %arch = load i32, ptr @C_arch
  %isarm = icmp eq i32 %arch, 1
  %fpo = select i1 %isarm, i64 248, i64 64
  %spo = select i1 %isarm, i64 264, i64 72
  %pco = select i1 %isarm, i64 272, i64 144
  %lro = select i1 %isarm, i64 256, i64 -1
  %fpp = getelementptr i8, ptr %mc, i64 %fpo
  %spp = getelementptr i8, ptr %mc, i64 %spo
  %pcp = getelementptr i8, ptr %mc, i64 %pco
  %lrp = getelementptr i8, ptr %mc, i64 %lro
  %fpv = load i64, ptr %fpp
  %spv = load i64, ptr %spp
  %pcv = load i64, ptr %pcp
  %lrv0 = load i64, ptr %lrp
  %lrv = select i1 %isarm, i64 %lrv0, i64 0
  br label %have
noctx:
  br label %have
have:
  %fpr = phi i64 [ %fpv, %ctx ], [ 0, %noctx ]
  %spr = phi i64 [ %spv, %ctx ], [ 0, %noctx ]
  %pcr = phi i64 [ %pcv, %ctx ], [ 0, %noctx ]
  %lrr = phi i64 [ %lrv, %ctx ], [ 0, %noctx ]
  ; the signal's own fields
  %codep = getelementptr i8, ptr %info, i64 8
  %code = load i32, ptr %codep
  %adrp = getelementptr i8, ptr %info, i64 24
  %adr = load i64, ptr %adrp
  %tr = call i32 @pthread_threadid_np(ptr null, ptr %tid)
  %tidv = load i64, ptr %tid
  %ismain = call i32 @pthread_main_np()
  %mainb = icmp ne i32 %ismain, 0
  ; the header
  call void @cr_puts(ptr @k16)
  call void @cr_q(ptr @C_app)
  call void @cr_puts(ptr @k17)
  call void @cr_q(ptr @C_ver)
  call void @cr_puts(ptr @k18)
  call void @cr_q(ptr @C_build)
  call void @cr_puts(ptr @k19)
  call void @cr_q(ptr @C_ctx)
  call void @cr_puts(ptr @k20)
  call void @cr_q(ptr @C_osv)
  %a2 = load i32, ptr @C_arch
  %isarm2 = icmp eq i32 %a2, 1
  %archs = select i1 %isarm2, ptr @k21, ptr @k22
  call void @cr_puts(ptr @k23)
  call void @cr_puts(ptr %archs)
  call void @cr_puts(ptr @k24)
  call void @cr_udec(i64 %pid64)
  call void @cr_puts(ptr @k25)
  call void @cr_udec(i64 %tidv)
  call void @cr_puts(ptr @k26)
  %mains = select i1 %mainb, ptr @k27, ptr @k28
  call void @cr_puts(ptr %mains)
  call void @cr_puts(ptr @k29)
  call void @cr_udec(i64 %now)
  call void @cr_puts(ptr @k30)
  %sig64 = sext i32 %sig to i64
  call void @cr_udec(i64 %sig64)
  call void @cr_puts(ptr @k31)
  %sn = call ptr @cr_signame(i32 %sig)
  call void @cr_puts(ptr %sn)
  call void @cr_puts(ptr @k32)
  %code64 = sext i32 %code to i64
  call void @cr_dec(i64 %code64)
  call void @cr_puts(ptr @k33)
  call void @cr_hex(i64 %adr)
  call void @cr_puts(ptr @k34)
  call void @cr_hex(i64 %pcr)
  call void @cr_puts(ptr @k35)
  call void @cr_hex(i64 %spr)
  call void @cr_puts(ptr @k36)
  call void @cr_hex(i64 %fpr)
  call void @cr_puts(ptr @k37)
  call void @cr_hex(i64 %lrr)
  call void @cr_puts(ptr @k5)
  call void @cr_flush()
  %archw = load i32, ptr @C_arch
  %frames = call i32 @cr_walk(i64 %pcr, i64 %spr, i64 %lrr, i32 %archw)
  call void @cr_flush()
  ; the images: the program, every library a frame landed in, and every non-system one
  %nimg = load atomic i32, ptr @C_in acquire, align 4
  br label %iloop
iloop:
  %ii = phi i32 [ 0, %have ], [ %ii2, %inext ]
  %icount = phi i32 [ 0, %have ], [ %icount2, %inext ]
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
  call void @cr_puts(ptr @k38)
  call void @cr_q(ptr %ipp)
  call void @cr_puts(ptr @k39)
  call void @cr_hex(i64 %ib)
  call void @cr_puts(ptr @k40)
  call void @cr_hex(i64 %iz)
  call void @cr_putc(i8 34)
  %hasu = and i32 %if, 8
  %hu = icmp ne i32 %hasu, 0
  br i1 %hu, label %iuuid, label %itail
iuuid:
  call void @cr_puts(ptr @k41)
  %iub = mul i32 %ii, 16
  %iup = getelementptr i8, ptr @C_iu, i32 %iub
  call void @cr_uuid(ptr %iup)
  call void @cr_putc(i8 34)
  br label %itail
itail:
  %mb = and i32 %if, 1
  %ism = icmp ne i32 %mb, 0
  br i1 %ism, label %imain, label %iend
imain:
  call void @cr_puts(ptr @k42)
  br label %iend
iend:
  call void @cr_puts(ptr @k43)
  %icw = add i32 %icount, 1
  br label %inext
inext:
  %icount2 = phi i32 [ %icount, %ichk ], [ %icw, %iend ]
  %ii2 = add i32 %ii, 1
  br label %iloop
idone:
  call void @cr_puts(ptr @k44)
  %fr64 = sext i32 %frames to i64
  call void @cr_udec(i64 %fr64)
  call void @cr_puts(ptr @k45)
  %ic64 = sext i32 %icount to i64
  call void @cr_udec(i64 %ic64)
  call void @cr_puts(ptr @k43)
  call void @cr_flush()
  %cl = call i32 @close(i32 %fd)
  br label %reraise
reraise:
  ; the work is done: the safety timer must not run on into the OS's own crash handling
  ; (Crash Reporter can take long under load), or SIGALRM would end the process instead
  %al0 = call i32 @alarm(i32 0)
  ; the disposition is the default already (SA_RESETHAND): this ends the process the way
  ; the crash would have, whether the fault repeats or the signal was sent
  %rr = call i32 @raise(i32 %sig)
  ret void
}

; ---- the install ---------------------------------------------------------------

define internal void @cr_set_handler(i32 %sig, ptr %sa) {
entry:
  %r = call i32 @sigaction(i32 %sig, ptr %sa, ptr null)
  ret void
}

define i32 @lu_crash_install(ptr %dir, ptr %app, ptr %ver, ptr %build) {
entry:
  %sa = alloca [16 x i8], align 8
  %ss = alloca [24 x i8], align 8
  %ut = alloca [1280 x i8], align 8
  %len = alloca i64, align 8
  %nodir = icmp eq ptr %dir, null
  br i1 %nodir, label %bad, label %chk
chk:
  %c0 = load i8, ptr %dir
  %empty = icmp eq i8 %c0, 0
  br i1 %empty, label %bad, label %cfg
bad:
  ret i32 -1
cfg:
  %pl = call i32 @cr_copy(ptr @C_path, ptr %dir, i32 1000)
  %pe = getelementptr i8, ptr @C_path, i32 %pl
  %last = getelementptr i8, ptr %pe, i32 -1
  %lc = load i8, ptr %last
  %slash = icmp eq i8 %lc, 47
  br i1 %slash, label %noslash, label %addslash
addslash:
  store i8 47, ptr %pe
  br label %prefix
noslash:
  br label %prefix
prefix:
  %pe2 = phi ptr [ %pe, %addslash ], [ %last, %noslash ]
  %pe3 = getelementptr i8, ptr %pe2, i32 1
  %pfx = call i32 @cr_copy(ptr %pe3, ptr @k46, i32 16)
  %po = ptrtoint ptr %pe3 to i64
  %pb = ptrtoint ptr @C_path to i64
  %pd = sub i64 %po, %pb
  %pd32 = trunc i64 %pd to i32
  %plen = add i32 %pd32, %pfx
  store i32 %plen, ptr @C_plen
  %a1 = call i32 @cr_copy(ptr @C_app, ptr %app, i32 160)
  %a2 = call i32 @cr_copy(ptr @C_ver, ptr %ver, i32 160)
  %a3 = call i32 @cr_copy(ptr @C_build, ptr %build, i32 160)
  %was = load i32, ptr @C_on
  %again = icmp ne i32 %was, 0
  br i1 %again, label %done, label %first
first:
  ; the machine: arm64 or x86_64 from uname, the product version from sysctl
  %u = call i32 @uname(ptr %ut)
  %mp = getelementptr i8, ptr %ut, i64 1024
  %m0 = load i8, ptr %mp
  %isa = icmp eq i8 %m0, 97
  %arch = select i1 %isa, i32 1, i32 2
  store i32 %arch, ptr @C_arch
  store i64 60, ptr %len
  store i8 0, ptr @C_osv
  %sc = call i32 @sysctlbyname(ptr @k47, ptr @C_osv, ptr %len, ptr null, i64 0)
  ; the alternate stack of this thread
  %mem = call ptr @malloc(i64 131072)
  store ptr %mem, ptr %ss
  %szp = getelementptr i8, ptr %ss, i64 8
  store i64 131072, ptr %szp
  %flp = getelementptr i8, ptr %ss, i64 16
  store i32 0, ptr %flp
  %as = call i32 @sigaltstack(ptr %ss, ptr null)
  ; the images: dyld reports the loaded ones at once, and each later one as it comes
  %regd = load i32, ptr @C_reg
  %needreg = icmp eq i32 %regd, 0
  br i1 %needreg, label %reg, label %sigs
reg:
  store i32 1, ptr @C_reg
  call void @_dyld_register_func_for_add_image(ptr @cr_add_image)
  br label %sigs
sigs:
  ; sa_sigaction, no mask, sa_flags = SA_ONSTACK | SA_RESETHAND | SA_NODEFER | SA_SIGINFO: a fault inside
  ; the handler meets the default action at once, it never spins on a blocked signal
  store ptr @lu_crash_handler, ptr %sa
  %mkp = getelementptr i8, ptr %sa, i64 8
  store i32 0, ptr %mkp
  %sfp = getelementptr i8, ptr %sa, i64 12
  store i32 85, ptr %sfp
  call void @cr_set_handler(i32 4, ptr %sa)
  call void @cr_set_handler(i32 5, ptr %sa)
  call void @cr_set_handler(i32 6, ptr %sa)
  call void @cr_set_handler(i32 8, ptr %sa)
  call void @cr_set_handler(i32 10, ptr %sa)
  call void @cr_set_handler(i32 11, ptr %sa)
  store i32 1, ptr @C_on
  br label %done
done:
  ret i32 0
}

define void @lu_crash_uninstall() {
entry:
  %sa = alloca [16 x i8], align 8
  store ptr null, ptr %sa
  %mkp = getelementptr i8, ptr %sa, i64 8
  store i32 0, ptr %mkp
  %sfp = getelementptr i8, ptr %sa, i64 12
  store i32 0, ptr %sfp
  call void @cr_set_handler(i32 4, ptr %sa)
  call void @cr_set_handler(i32 5, ptr %sa)
  call void @cr_set_handler(i32 6, ptr %sa)
  call void @cr_set_handler(i32 8, ptr %sa)
  call void @cr_set_handler(i32 10, ptr %sa)
  call void @cr_set_handler(i32 11, ptr %sa)
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
    i32 3, label %fp
    i32 4, label %so
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
fp:
  %r = call i32 @raise(i32 8)
  ret void
so:
  %x = call i64 @cr_recurse(i64 0)
  store volatile i32 1, ptr @C_sink
  ret void
}
declare void @llvm.trap()

; lu_crash_fence(text): the allocation fence failing the run (exit 86: a frame kept memory, 87: a
; declared cap was passed) writes a record of its own before it exits. Not a signal: the handler is
; run by hand on a made-up context whose stack pointer is this frame's (so the stack scan names the
; frames under the fence), with signal number 0 - which names itself ALLOC_FENCE, raises nothing and
; says code 86 - and `text`, the fence's report (the frame, what was kept, the sites that grew),
; written first into the record's context, ahead of whatever the game said. A program that never
; called lu_crash_install has no folder, and this does nothing.
define void @lu_crash_fence(ptr %text) {
entry:
  %on = load i32, ptr @C_on
  %off = icmp eq i32 %on, 0
  br i1 %off, label %out, label %go
go:
  %old = alloca [256 x i8], align 8
  %info = alloca [32 x i8], align 8
  %uc = alloca [64 x i8], align 8
  %mc = alloca [512 x i8], align 16
  %o = call i32 @cr_copy(ptr %old, ptr @C_ctx, i32 256)
  %n1 = call i32 @cr_copy(ptr @C_ctx, ptr %text, i32 256)
  %room = icmp slt i32 %n1, 240
  br i1 %room, label %tail, label %fill
tail:
  %t1 = getelementptr i8, ptr @C_ctx, i32 %n1
  store i8 32, ptr %t1
  %t2 = getelementptr i8, ptr %t1, i32 1
  store i8 124, ptr %t2
  %t3 = getelementptr i8, ptr %t1, i32 2
  store i8 32, ptr %t3
  %n2 = add i32 %n1, 3
  %d2 = getelementptr i8, ptr @C_ctx, i32 %n2
  %cap2 = sub i32 256, %n2
  %n3 = call i32 @cr_copy(ptr %d2, ptr %old, i32 %cap2)
  br label %fill
fill:
  call void @llvm.memset.p0.i64(ptr %info, i8 0, i64 32, i1 false)
  call void @llvm.memset.p0.i64(ptr %uc, i8 0, i64 64, i1 false)
  call void @llvm.memset.p0.i64(ptr %mc, i8 0, i64 512, i1 false)
  %codep = getelementptr i8, ptr %info, i64 8
  store i32 86, ptr %codep
  %mcp = getelementptr i8, ptr %uc, i64 48
  store ptr %mc, ptr %mcp
  %sp = ptrtoint ptr %mc to i64
  %pc = ptrtoint ptr @lu_crash_fence to i64
  ; both architectures' register slots: arm64 fp 248, lr 256, sp 264, pc 272; x86_64 fp 64, sp 72, pc 144
  %a1 = getelementptr i8, ptr %mc, i64 248
  store i64 %sp, ptr %a1
  %a2 = getelementptr i8, ptr %mc, i64 264
  store i64 %sp, ptr %a2
  %a3 = getelementptr i8, ptr %mc, i64 272
  store i64 %pc, ptr %a3
  %a4 = getelementptr i8, ptr %mc, i64 64
  store i64 %sp, ptr %a4
  %a5 = getelementptr i8, ptr %mc, i64 72
  store i64 %sp, ptr %a5
  %a6 = getelementptr i8, ptr %mc, i64 144
  store i64 %pc, ptr %a6
  call void @lu_crash_handler(i32 0, ptr %info, ptr %uc)
  br label %out
out:
  ret void
}
declare void @llvm.memset.p0.i64(ptr, i8, i64, i1)

; ---- constants ----
@k0 = private unnamed_addr constant [10 x i8] c"/usr/lib/\00"
@k1 = private unnamed_addr constant [9 x i8] c"/System/\00"
@k2 = private unnamed_addr constant [18 x i8] c"{\22k\22:\22frame\22,\22i\22:\00"
@k3 = private unnamed_addr constant [8 x i8] c",\22pc\22:\22\00"
@k4 = private unnamed_addr constant [10 x i8] c"\22,\22via\22:\22\00"
@k5 = private unnamed_addr constant [4 x i8] c"\22}\0A\00"
@k6 = private unnamed_addr constant [3 x i8] c"pc\00"
@k7 = private unnamed_addr constant [3 x i8] c"lr\00"
@k8 = private unnamed_addr constant [5 x i8] c"scan\00"
@k9 = private unnamed_addr constant [7 x i8] c"SIGILL\00"
@k10 = private unnamed_addr constant [8 x i8] c"SIGTRAP\00"
@k11 = private unnamed_addr constant [8 x i8] c"SIGABRT\00"
@k12 = private unnamed_addr constant [7 x i8] c"SIGFPE\00"
@k13 = private unnamed_addr constant [7 x i8] c"SIGBUS\00"
@k14 = private unnamed_addr constant [8 x i8] c"SIGSEGV\00"
@k15 = private unnamed_addr constant [5 x i8] c"SIG?\00"
@kfence = private unnamed_addr constant [12 x i8] c"ALLOC_FENCE\00"
@k16 = private unnamed_addr constant [45 x i8] c"{\22k\22:\22crash\22,\22v\22:1,\22producer\22:\22ludic\22,\22app\22:\00"
@k17 = private unnamed_addr constant [12 x i8] c",\22version\22:\00"
@k18 = private unnamed_addr constant [10 x i8] c",\22build\22:\00"
@k19 = private unnamed_addr constant [12 x i8] c",\22context\22:\00"
@k20 = private unnamed_addr constant [28 x i8] c",\22os\22:\22macos\22,\22os_version\22:\00"
@k21 = private unnamed_addr constant [6 x i8] c"arm64\00"
@k22 = private unnamed_addr constant [7 x i8] c"x86_64\00"
@k23 = private unnamed_addr constant [10 x i8] c",\22arch\22:\22\00"
@k24 = private unnamed_addr constant [9 x i8] c"\22,\22pid\22:\00"
@k25 = private unnamed_addr constant [8 x i8] c",\22tid\22:\00"
@k26 = private unnamed_addr constant [9 x i8] c",\22main\22:\00"
@k27 = private unnamed_addr constant [5 x i8] c"true\00"
@k28 = private unnamed_addr constant [6 x i8] c"false\00"
@k29 = private unnamed_addr constant [9 x i8] c",\22time\22:\00"
@k30 = private unnamed_addr constant [8 x i8] c",\22sig\22:\00"
@k31 = private unnamed_addr constant [13 x i8] c",\22signame\22:\22\00"
@k32 = private unnamed_addr constant [10 x i8] c"\22,\22code\22:\00"
@k33 = private unnamed_addr constant [10 x i8] c",\22addr\22:\22\00"
@k34 = private unnamed_addr constant [9 x i8] c"\22,\22pc\22:\22\00"
@k35 = private unnamed_addr constant [9 x i8] c"\22,\22sp\22:\22\00"
@k36 = private unnamed_addr constant [9 x i8] c"\22,\22fp\22:\22\00"
@k37 = private unnamed_addr constant [9 x i8] c"\22,\22lr\22:\22\00"
@k38 = private unnamed_addr constant [21 x i8] c"{\22k\22:\22image\22,\22path\22:\00"
@k39 = private unnamed_addr constant [10 x i8] c",\22base\22:\22\00"
@k40 = private unnamed_addr constant [11 x i8] c"\22,\22size\22:\22\00"
@k41 = private unnamed_addr constant [10 x i8] c",\22uuid\22:\22\00"
@k42 = private unnamed_addr constant [13 x i8] c",\22main\22:true\00"
@k43 = private unnamed_addr constant [3 x i8] c"}\0A\00"
@k44 = private unnamed_addr constant [21 x i8] c"{\22k\22:\22end\22,\22frames\22:\00"
@k45 = private unnamed_addr constant [11 x i8] c",\22images\22:\00"
@k46 = private unnamed_addr constant [7 x i8] c"crash-\00"
@k47 = private unnamed_addr constant [22 x i8] c"kern.osproductversion\00"
