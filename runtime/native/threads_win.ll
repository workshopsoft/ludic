; ============================================================================
; threads_win.ll — OS threads behind Job.parallel_for and Sync.* (Windows).
;
; The interface of threads.ll over Win32: CreateThread, SRWLOCK and CONDITION_VARIABLE (both
; zero-initialised, pointer-sized), GetActiveProcessorCount. See threads.ll for how the pool and a
; batch work; the two files differ only in the primitives underneath.
; ============================================================================

declare ptr @CreateThread(ptr, i64, ptr, ptr, i32, ptr)
declare i32 @CloseHandle(ptr)
declare void @AcquireSRWLockExclusive(ptr)
declare void @ReleaseSRWLockExclusive(ptr)
declare i8 @TryAcquireSRWLockExclusive(ptr)
declare i32 @SleepConditionVariableSRW(ptr, ptr, i32, i32)
declare void @WakeAllConditionVariable(ptr)
declare i32 @GetActiveProcessorCount(i16)
declare ptr @malloc(i64)

@T_worker = thread_local global i32 0
@T_ready  = internal global i32 0
@T_n      = internal global i32 0
@T_lock   = internal global ptr null
@T_work   = internal global ptr null
@T_done   = internal global ptr null
@T_gen    = internal global i32 0
@T_active = internal global i32 0
@T_fn     = internal global ptr null
@T_ctx    = internal global ptr null
@T_count  = internal global i32 0
@T_chunk  = internal global i32 1
@T_next   = internal global i32 0

; a zeroed pointer-sized object: an SRWLOCK or a CONDITION_VARIABLE
define internal ptr @t_zeroed() {
entry:
  %p = call ptr @malloc(i64 16)
  store i64 0, ptr %p
  %p8 = getelementptr i8, ptr %p, i64 8
  store i64 0, ptr %p8
  ret ptr %p
}

define i32 @thr_cpu_count() {
entry:
  ; ALL_PROCESSOR_GROUPS
  %n = call i32 @GetActiveProcessorCount(i16 -1)
  %lo = icmp slt i32 %n, 1
  %a = select i1 %lo, i32 1, i32 %n
  %hi = icmp sgt i32 %a, 64
  %b = select i1 %hi, i32 64, i32 %a
  ret i32 %b
}

define i32 @thr_is_worker() {
entry:
  %w = load i32, ptr @T_worker
  ret i32 %w
}

; *p += d atomically, as a compare-and-swap retry loop (the toolchains' clang has no atomicrw);
; the new value
define internal i32 @t_add(ptr %p, i32 %d) {
entry:
  br label %retry
retry:
  %old = load atomic i32, ptr %p acquire, align 4
  %new = add i32 %old, %d
  %r = cmpxchg ptr %p, i32 %old, i32 %new release acquire
  %ok = extractvalue { i32, i1 } %r, 1
  br i1 %ok, label %done, label %retry
done:
  ret i32 %new
}

define internal void @t_run_chunks() {
entry:
  br label %claim
claim:
  %chunk = load i32, ptr @T_chunk
  %count = load i32, ptr @T_count
  %claimed = call i32 @t_add(ptr @T_next, i32 %chunk)
  %start = sub i32 %claimed, %chunk
  %past = icmp sge i32 %start, %count
  br i1 %past, label %done, label %body
body:
  %end0 = add i32 %start, %chunk
  %over = icmp sgt i32 %end0, %count
  %end = select i1 %over, i32 %count, i32 %end0
  %fn = load ptr, ptr @T_fn
  %ctx = load ptr, ptr @T_ctx
  br label %loop
loop:
  %i = phi i32 [ %start, %body ], [ %i1, %run ]
  %more = icmp slt i32 %i, %end
  br i1 %more, label %run, label %claim
run:
  call void %fn(i32 %i, ptr %ctx)
  %i1 = add i32 %i, 1
  br label %loop
done:
  ret void
}

define internal i32 @t_worker(ptr %arg) {
entry:
  store i32 1, ptr @T_worker
  %lk = load ptr, ptr @T_lock
  %wk = load ptr, ptr @T_work
  %dn = load ptr, ptr @T_done
  %seen = alloca i32
  store i32 0, ptr %seen
  br label %park
park:
  call void @AcquireSRWLockExclusive(ptr %lk)
  br label %check
check:
  %g = load i32, ptr @T_gen
  %s = load i32, ptr %seen
  %same = icmp eq i32 %g, %s
  br i1 %same, label %sleep, label %go
sleep:
  %w0 = call i32 @SleepConditionVariableSRW(ptr %wk, ptr %lk, i32 -1, i32 0)
  br label %check
go:
  store i32 %g, ptr %seen
  call void @ReleaseSRWLockExclusive(ptr %lk)
  call void @t_run_chunks()
  call void @AcquireSRWLockExclusive(ptr %lk)
  %a = load i32, ptr @T_active
  %a1 = sub i32 %a, 1
  store i32 %a1, ptr @T_active
  %last = icmp eq i32 %a1, 0
  br i1 %last, label %signal, label %release
signal:
  call void @WakeAllConditionVariable(ptr %dn)
  br label %release
release:
  call void @ReleaseSRWLockExclusive(ptr %lk)
  br label %park
}

define internal void @t_init() {
entry:
  %r = load i32, ptr @T_ready
  %have = icmp ne i32 %r, 0
  br i1 %have, label %out, label %make
make:
  %lk = call ptr @t_zeroed()
  %wk = call ptr @t_zeroed()
  %dn = call ptr @t_zeroed()
  store ptr %lk, ptr @T_lock
  store ptr %wk, ptr @T_work
  store ptr %dn, ptr @T_done
  %cores = call i32 @thr_cpu_count()
  %n = sub i32 %cores, 1
  br label %spawn
spawn:
  %k = phi i32 [ 0, %make ], [ %k1, %started ]
  %more = icmp slt i32 %k, %n
  br i1 %more, label %start, label %ready
start:
  %t = call ptr @CreateThread(ptr null, i64 0, ptr @t_worker, ptr null, i32 0, ptr null)
  %bad = icmp eq ptr %t, null
  br i1 %bad, label %ready, label %close
close:
  %c = call i32 @CloseHandle(ptr %t)
  br label %started
started:
  %k1 = add i32 %k, 1
  store i32 %k1, ptr @T_n
  br label %spawn
ready:
  store i32 1, ptr @T_ready
  br label %out
out:
  ret void
}

define void @thr_parallel_for(i32 %count, ptr %fn, ptr %ctx) {
entry:
  %none = icmp sle i32 %count, 0
  br i1 %none, label %out, label %init
init:
  call void @t_init()
  %n = load i32, ptr @T_n
  %w = load i32, ptr @T_worker
  %nowork = icmp eq i32 %n, 0
  %small = icmp slt i32 %count, 2
  %inworker = icmp ne i32 %w, 0
  %a = or i1 %nowork, %small
  %inline = or i1 %a, %inworker
  br i1 %inline, label %serial, label %batch
serial:
  %si = phi i32 [ 0, %init ], [ %si1, %srun ]
  %smore = icmp slt i32 %si, %count
  br i1 %smore, label %srun, label %out
srun:
  call void %fn(i32 %si, ptr %ctx)
  %si1 = add i32 %si, 1
  br label %serial
batch:
  %lk = load ptr, ptr @T_lock
  %wk = load ptr, ptr @T_work
  %dn = load ptr, ptr @T_done
  call void @AcquireSRWLockExclusive(ptr %lk)
  store ptr %fn, ptr @T_fn
  store ptr %ctx, ptr @T_ctx
  store i32 %count, ptr @T_count
  %threads = add i32 %n, 1
  %per = mul i32 %threads, 8
  %c0 = sdiv i32 %count, %per
  %tiny = icmp slt i32 %c0, 1
  %chunk = select i1 %tiny, i32 1, i32 %c0
  store i32 %chunk, ptr @T_chunk
  store atomic i32 0, ptr @T_next release, align 4
  store i32 %n, ptr @T_active
  %g = load i32, ptr @T_gen
  %g1 = add i32 %g, 1
  store i32 %g1, ptr @T_gen
  call void @WakeAllConditionVariable(ptr %wk)
  call void @ReleaseSRWLockExclusive(ptr %lk)
  call void @t_run_chunks()
  call void @AcquireSRWLockExclusive(ptr %lk)
  br label %wait
wait:
  %act = load i32, ptr @T_active
  %busy = icmp sgt i32 %act, 0
  br i1 %busy, label %sleep, label %finished
sleep:
  %w0 = call i32 @SleepConditionVariableSRW(ptr %dn, ptr %lk, i32 -1, i32 0)
  br label %wait
finished:
  call void @ReleaseSRWLockExclusive(ptr %lk)
  br label %out
out:
  ret void
}

; ---- Sync.* --------------------------------------------------------------------------------------
define ptr @thr_mutex_new() {
entry:
  %m = call ptr @t_zeroed()
  ret ptr %m
}
define void @thr_lock(ptr %m) {
entry:
  call void @AcquireSRWLockExclusive(ptr %m)
  ret void
}
define void @thr_unlock(ptr %m) {
entry:
  call void @ReleaseSRWLockExclusive(ptr %m)
  ret void
}
define i32 @thr_trylock(ptr %m) {
entry:
  %r = call i8 @TryAcquireSRWLockExclusive(ptr %m)
  %got = icmp ne i8 %r, 0
  %v = zext i1 %got to i32
  ret i32 %v
}
define i32 @thr_atomic_add(ptr %p, i32 %d) {
entry:
  %new = call i32 @t_add(ptr %p, i32 %d)
  ret i32 %new
}
define i32 @thr_cas(ptr %p, i32 %expect, i32 %next) {
entry:
  %r = cmpxchg ptr %p, i32 %expect, i32 %next release acquire
  %ok = extractvalue { i32, i1 } %r, 1
  %v = zext i1 %ok to i32
  ret i32 %v
}
define i32 @thr_load(ptr %p) {
entry:
  %v = load atomic i32, ptr %p acquire, align 4
  ret i32 %v
}
define void @thr_store(ptr %p, i32 %v) {
entry:
  store atomic i32 %v, ptr %p release, align 4
  ret void
}
