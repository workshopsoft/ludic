; ============================================================================
; process.ll — child processes behind Process.* (macOS / POSIX, posix_spawn).
;
; Linked into any program that uses Process.* (selfhost/main.ludic, tools/ludic-cli/build.ludic).
; process_win.ll is the same interface over CreateProcessW.
;
;   lu_proc_spawn(path, argv, cmdline) -> int   start path with the NULL-terminated argv
;                                               (argv[0] = path) and this process's
;                                               environment and working directory; a handle
;                                               0..15, or -1. cmdline is Windows' and unused.
;   lu_proc_poll(h) -> int                      -1 while running, else the exit code
;                                               (128 + signal when a signal ended it)
;   lu_proc_kill(h)                             SIGKILL
;   lu_proc_free(h)                             drop the handle; a running child is reaped
;                                               later, by whichever call next looks
;
; A slot is free (0), running (1), finished with its code cached (2), or let go while still
; running (3) - kept only so the child is reaped rather than left a zombie.
; ============================================================================

declare i32 @posix_spawn(ptr, ptr, ptr, ptr, ptr, ptr)
declare ptr @_NSGetEnviron()
declare i32 @waitpid(i32, ptr, i32)
declare i32 @kill(i32, i32)

@P_pid   = internal global [16 x i32] zeroinitializer
@P_state = internal global [16 x i32] zeroinitializer
@P_code  = internal global [16 x i32] zeroinitializer

define internal i1 @pr_bad(i32 %h) {
entry:
  %lo = icmp slt i32 %h, 0
  %hi = icmp sgt i32 %h, 15
  %bad = or i1 %lo, %hi
  ret i1 %bad
}

; Ask once, without waiting, whether slot i's child has ended. For a running slot the code
; is cached (state 2); a let-go slot becomes free. Returns 1 when it has ended.
define internal i32 @pr_reap(i32 %i) {
entry:
  %status = alloca i32, align 4
  %stp = getelementptr [16 x i32], ptr @P_state, i32 0, i32 %i
  %st = load i32, ptr %stp
  %run = icmp eq i32 %st, 1
  %gone = icmp eq i32 %st, 3
  %live = or i1 %run, %gone
  br i1 %live, label %ask, label %no
ask:
  %pidp = getelementptr [16 x i32], ptr @P_pid, i32 0, i32 %i
  %pid = load i32, ptr %pidp
  store i32 0, ptr %status
  %w = call i32 @waitpid(i32 %pid, ptr %status, i32 1)      ; WNOHANG
  %still = icmp eq i32 %w, 0
  br i1 %still, label %no, label %ended
ended:
  ; waitpid failing (the child is not ours to wait for any more) reads as 255
  %err = icmp slt i32 %w, 0
  %s = load i32, ptr %status
  %sig = and i32 %s, 127
  %exited = icmp eq i32 %sig, 0
  %hi = lshr i32 %s, 8
  %ecode = and i32 %hi, 255
  %scode = add i32 %sig, 128
  %c0 = select i1 %exited, i32 %ecode, i32 %scode
  %code = select i1 %err, i32 255, i32 %c0
  %cp = getelementptr [16 x i32], ptr @P_code, i32 0, i32 %i
  store i32 %code, ptr %cp
  %next = select i1 %run, i32 2, i32 0
  store i32 %next, ptr %stp
  ret i32 1
no:
  ret i32 0
}

define i32 @lu_proc_spawn(ptr %path, ptr %argv, ptr %cmdline) {
entry:
  %pidv = alloca i32, align 4
  br label %find
find:
  %i = phi i32 [ 0, %entry ], [ %i1, %next ]
  %stp = getelementptr [16 x i32], ptr @P_state, i32 0, i32 %i
  %st = load i32, ptr %stp
  %isgone = icmp eq i32 %st, 3
  br i1 %isgone, label %reap, label %check
reap:
  %r = call i32 @pr_reap(i32 %i)
  br label %check
check:
  %st2 = load i32, ptr %stp
  %free = icmp eq i32 %st2, 0
  br i1 %free, label %spawn, label %next
next:
  %i1 = add i32 %i, 1
  %more = icmp slt i32 %i1, 16
  br i1 %more, label %find, label %fail
spawn:
  %envpp = call ptr @_NSGetEnviron()
  %envp = load ptr, ptr %envpp
  store i32 0, ptr %pidv
  %rc = call i32 @posix_spawn(ptr %pidv, ptr %path, ptr null, ptr null, ptr %argv, ptr %envp)
  %ok = icmp eq i32 %rc, 0
  br i1 %ok, label %keep, label %fail
keep:
  %pid = load i32, ptr %pidv
  %pidp = getelementptr [16 x i32], ptr @P_pid, i32 0, i32 %i
  store i32 %pid, ptr %pidp
  store i32 1, ptr %stp
  %cp = getelementptr [16 x i32], ptr @P_code, i32 0, i32 %i
  store i32 -1, ptr %cp
  ret i32 %i
fail:
  ret i32 -1
}

define i32 @lu_proc_poll(i32 %h) {
entry:
  %bad = call i1 @pr_bad(i32 %h)
  br i1 %bad, label %none, label %look
look:
  %stp = getelementptr [16 x i32], ptr @P_state, i32 0, i32 %h
  %st = load i32, ptr %stp
  %run = icmp eq i32 %st, 1
  br i1 %run, label %ask, label %known
ask:
  %r = call i32 @pr_reap(i32 %h)
  %ended = icmp eq i32 %r, 1
  br i1 %ended, label %known, label %running
running:
  ret i32 -1
known:
  %st2 = load i32, ptr %stp
  %done = icmp eq i32 %st2, 2
  br i1 %done, label %code, label %none
code:
  %cp = getelementptr [16 x i32], ptr @P_code, i32 0, i32 %h
  %c = load i32, ptr %cp
  ret i32 %c
none:
  ; not a handle: nothing is running under it
  ret i32 255
}

define void @lu_proc_kill(i32 %h) {
entry:
  %bad = call i1 @pr_bad(i32 %h)
  br i1 %bad, label %out, label %look
look:
  %stp = getelementptr [16 x i32], ptr @P_state, i32 0, i32 %h
  %st = load i32, ptr %stp
  %run = icmp eq i32 %st, 1
  br i1 %run, label %go, label %out
go:
  %pidp = getelementptr [16 x i32], ptr @P_pid, i32 0, i32 %h
  %pid = load i32, ptr %pidp
  %k = call i32 @kill(i32 %pid, i32 9)
  br label %out
out:
  ret void
}

define void @lu_proc_free(i32 %h) {
entry:
  %bad = call i1 @pr_bad(i32 %h)
  br i1 %bad, label %out, label %look
look:
  %stp = getelementptr [16 x i32], ptr @P_state, i32 0, i32 %h
  %st = load i32, ptr %stp
  %run = icmp eq i32 %st, 1
  br i1 %run, label %try, label %drop
try:
  %r = call i32 @pr_reap(i32 %h)
  %ended = icmp eq i32 %r, 1
  br i1 %ended, label %drop, label %orphan
orphan:
  store i32 3, ptr %stp
  br label %out
drop:
  %st2 = load i32, ptr %stp
  %gone = icmp eq i32 %st2, 3
  br i1 %gone, label %out, label %clear
clear:
  store i32 0, ptr %stp
  br label %out
out:
  ret void
}
