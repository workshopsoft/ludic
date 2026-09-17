; ============================================================================
; process_win.ll — child processes behind Process.* (Windows, CreateProcessW).
;
; process.ll's interface. ludicc links it when a Windows program uses Process.*.
;
;   lu_proc_spawn(path, argv, cmdline) -> int   CreateProcessW(path, cmdline): a handle
;                                               0..15, or -1. argv is POSIX's and unused;
;                                               cmdline was quoted by process.ludic.
;   lu_proc_poll(h) -> int                      -1 while running, else GetExitCodeProcess
;   lu_proc_kill(h)                             TerminateProcess, exit code 137
;   lu_proc_free(h)                             CloseHandle
;
; The child inherits the environment and the working directory and no handles, and is
; started with CREATE_NO_WINDOW: a GUI parent starting a console program must not flash a
; console window up (a GUI child ignores the flag). Paths and the command line cross in
; UTF-8 and are converted to UTF-16 here.
;
; An exit code is a DWORD. One that reads as -1 (0xFFFFFFFF) is reported as 255, so -1
; always means "still running"; an NTSTATUS crash code such as 0xC0000005 arrives as a
; negative int.
; ============================================================================

declare ptr @malloc(i64)
declare void @free(ptr)
declare void @llvm.memset.p0.i64(ptr, i8, i64, i1)
declare i32 @MultiByteToWideChar(i32, i32, ptr, i32, ptr, i32)
declare i32 @CreateProcessW(ptr, ptr, ptr, ptr, i32, i32, ptr, ptr, ptr, ptr)
declare i32 @WaitForSingleObject(ptr, i32)
declare i32 @GetExitCodeProcess(ptr, ptr)
declare i32 @TerminateProcess(ptr, i32)
declare i32 @CloseHandle(ptr)

@P_handle = internal global [16 x ptr] zeroinitializer
@P_state  = internal global [16 x i32] zeroinitializer     ; 0 free, 1 running, 2 ended
@P_code   = internal global [16 x i32] zeroinitializer

define internal i1 @pr_bad(i32 %h) {
entry:
  %lo = icmp slt i32 %h, 0
  %hi = icmp sgt i32 %h, 15
  %bad = or i1 %lo, %hi
  ret i1 %bad
}

; a fresh NUL-terminated UTF-16 copy of a UTF-8 string (CP_UTF8 = 65001), or null
define internal ptr @pr_wide(ptr %s) {
entry:
  %n = call i32 @MultiByteToWideChar(i32 65001, i32 0, ptr %s, i32 -1, ptr null, i32 0)
  %bad = icmp sle i32 %n, 0
  br i1 %bad, label %none, label %conv
none:
  ret ptr null
conv:
  %n64 = sext i32 %n to i64
  %bytes = mul i64 %n64, 2
  %w = call ptr @malloc(i64 %bytes)
  %r = call i32 @MultiByteToWideChar(i32 65001, i32 0, ptr %s, i32 -1, ptr %w, i32 %n)
  ret ptr %w
}

define i32 @lu_proc_spawn(ptr %path, ptr %argv, ptr %cmdline) {
entry:
  %si = alloca [104 x i8], align 8        ; STARTUPINFOW
  %pi = alloca [24 x i8], align 8         ; PROCESS_INFORMATION
  br label %find
find:
  %i = phi i32 [ 0, %entry ], [ %i1, %next ]
  %stp = getelementptr [16 x i32], ptr @P_state, i32 0, i32 %i
  %st = load i32, ptr %stp
  %free = icmp eq i32 %st, 0
  br i1 %free, label %conv, label %next
next:
  %i1 = add i32 %i, 1
  %more = icmp slt i32 %i1, 16
  br i1 %more, label %find, label %fail
conv:
  %wpath = call ptr @pr_wide(ptr %path)
  %wcmd = call ptr @pr_wide(ptr %cmdline)
  %np = icmp eq ptr %wpath, null
  %nc = icmp eq ptr %wcmd, null
  %either = or i1 %np, %nc
  br i1 %either, label %cleanup_fail, label %spawn
spawn:
  call void @llvm.memset.p0.i64(ptr %si, i8 0, i64 104, i1 false)
  store i32 104, ptr %si
  call void @llvm.memset.p0.i64(ptr %pi, i8 0, i64 24, i1 false)
  ; CREATE_NO_WINDOW = 0x08000000; no inherited handles, the parent's environment and directory
  %ok = call i32 @CreateProcessW(ptr %wpath, ptr %wcmd, ptr null, ptr null, i32 0, i32 134217728, ptr null, ptr null, ptr %si, ptr %pi)
  %failed = icmp eq i32 %ok, 0
  br i1 %failed, label %cleanup_fail, label %keep
keep:
  call void @free(ptr %wpath)
  call void @free(ptr %wcmd)
  %hproc = load ptr, ptr %pi
  %thp = getelementptr i8, ptr %pi, i64 8
  %hthr = load ptr, ptr %thp
  %c = call i32 @CloseHandle(ptr %hthr)
  %hp = getelementptr [16 x ptr], ptr @P_handle, i32 0, i32 %i
  store ptr %hproc, ptr %hp
  store i32 1, ptr %stp
  %cp = getelementptr [16 x i32], ptr @P_code, i32 0, i32 %i
  store i32 -1, ptr %cp
  ret i32 %i
cleanup_fail:
  %fp = icmp eq ptr %wpath, null
  br i1 %fp, label %fc, label %freep
freep:
  call void @free(ptr %wpath)
  br label %fc
fc:
  %fcm = icmp eq ptr %wcmd, null
  br i1 %fcm, label %fail, label %freec
freec:
  call void @free(ptr %wcmd)
  br label %fail
fail:
  ret i32 -1
}

define i32 @lu_proc_poll(i32 %h) {
entry:
  %code = alloca i32, align 4
  %bad = call i1 @pr_bad(i32 %h)
  br i1 %bad, label %none, label %look
look:
  %stp = getelementptr [16 x i32], ptr @P_state, i32 0, i32 %h
  %st = load i32, ptr %stp
  %cp = getelementptr [16 x i32], ptr @P_code, i32 0, i32 %h
  %done = icmp eq i32 %st, 2
  br i1 %done, label %cached, label %isrun
isrun:
  %run = icmp eq i32 %st, 1
  br i1 %run, label %ask, label %none
ask:
  %hp = getelementptr [16 x ptr], ptr @P_handle, i32 0, i32 %h
  %hproc = load ptr, ptr %hp
  %w = call i32 @WaitForSingleObject(ptr %hproc, i32 0)
  %ended = icmp eq i32 %w, 0                     ; WAIT_OBJECT_0
  br i1 %ended, label %getcode, label %running
running:
  ret i32 -1
getcode:
  store i32 255, ptr %code
  %g = call i32 @GetExitCodeProcess(ptr %hproc, ptr %code)
  %v = load i32, ptr %code
  %neg1 = icmp eq i32 %v, -1
  %v2 = select i1 %neg1, i32 255, i32 %v
  %gfail = icmp eq i32 %g, 0
  %v3 = select i1 %gfail, i32 255, i32 %v2
  store i32 %v3, ptr %cp
  store i32 2, ptr %stp
  ret i32 %v3
cached:
  %c = load i32, ptr %cp
  ret i32 %c
none:
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
  %hp = getelementptr [16 x ptr], ptr @P_handle, i32 0, i32 %h
  %hproc = load ptr, ptr %hp
  %t = call i32 @TerminateProcess(ptr %hproc, i32 137)
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
  %used = icmp ne i32 %st, 0
  br i1 %used, label %close, label %out
close:
  %hp = getelementptr [16 x ptr], ptr @P_handle, i32 0, i32 %h
  %hproc = load ptr, ptr %hp
  %c = call i32 @CloseHandle(ptr %hproc)
  store ptr null, ptr %hp
  store i32 0, ptr %stp
  br label %out
out:
  ret void
}
