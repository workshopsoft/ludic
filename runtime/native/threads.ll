; ============================================================================
; threads.ll — OS threads behind Job.parallel_for and Sync.* (macOS / POSIX, pthreads).
;
; Linked into any program that uses Job.*, Promise.* or Sync.* (selfhost/main.ludic,
; tools/ludic-cli/build.ludic). threads_win.ll is the same interface over Win32.
;
;   thr_cpu_count() -> int              logical cores, 1 .. 64
;   thr_is_worker() -> int              1 on a pool thread, 0 elsewhere (the debug guard)
;   thr_parallel_for(count, fn, ctx)    fn(i, ctx) for every i in [0, count); returns when done
;   thr_mutex_new() -> ptr              a real mutex; thr_lock / thr_unlock / thr_trylock
;   thr_atomic_add(p, d) -> int         *p += d atomically; the new value
;   thr_cas(p, expect, next) -> int     compare-and-swap on *p; 1 when it swapped
;   thr_load(p) / thr_store(p, v)       an atomic read / write of *p
;
; The pool: one worker per core but one, started on the first parallel_for and parked on a
; condition variable between batches. A batch is (fn, ctx, count); every thread, the caller
; included, claims the next chunk of indices with one atomic add and runs it, so no index is run
; twice or skipped. The caller then waits until every worker has reported the batch finished.
; A parallel_for from inside a worker, or with no workers, runs inline. Only one thread outside
; the pool (the main thread) may start batches.
; ============================================================================

declare i32 @pthread_create(ptr, ptr, ptr, ptr)
declare i32 @pthread_detach(ptr)
declare i32 @pthread_mutex_init(ptr, ptr)
declare i32 @pthread_mutex_lock(ptr)
declare i32 @pthread_mutex_unlock(ptr)
declare i32 @pthread_mutex_trylock(ptr)
declare i32 @pthread_cond_init(ptr, ptr)
declare i32 @pthread_cond_wait(ptr, ptr)
declare i32 @pthread_cond_broadcast(ptr)
declare i64 @sysconf(i32)
declare ptr @malloc(i64)

@T_worker = thread_local global i32 0
@T_ready  = internal global i32 0
@T_n      = internal global i32 0      ; worker threads started
@T_lock   = internal global ptr null
@T_work   = internal global ptr null   ; signalled when a batch is ready
@T_done   = internal global ptr null   ; signalled when the last worker finishes a batch
@T_gen    = internal global i32 0      ; batch number, under @T_lock
@T_active = internal global i32 0      ; workers still on the current batch, under @T_lock
@T_fn     = internal global ptr null
@T_ctx    = internal global ptr null
@T_count  = internal global i32 0
@T_chunk  = internal global i32 1
@T_next   = internal global i32 0      ; the next unclaimed index, claimed by compare-and-swap

define i32 @thr_cpu_count() {
entry:
  ; _SC_NPROCESSORS_ONLN is 58 on macOS
  %n = call i64 @sysconf(i32 58)
  %n32 = trunc i64 %n to i32
  %lo = icmp slt i32 %n32, 1
  %a = select i1 %lo, i32 1, i32 %n32
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

; claim chunks until the batch has none left, running each index
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

define internal ptr @t_worker(ptr %arg) {
entry:
  store i32 1, ptr @T_worker
  %lk = load ptr, ptr @T_lock
  %wk = load ptr, ptr @T_work
  %dn = load ptr, ptr @T_done
  %seen = alloca i32
  store i32 0, ptr %seen
  br label %park
park:
  %l0 = call i32 @pthread_mutex_lock(ptr %lk)
  br label %check
check:
  %g = load i32, ptr @T_gen
  %s = load i32, ptr %seen
  %same = icmp eq i32 %g, %s
  br i1 %same, label %sleep, label %go
sleep:
  %w0 = call i32 @pthread_cond_wait(ptr %wk, ptr %lk)
  br label %check
go:
  store i32 %g, ptr %seen
  %u0 = call i32 @pthread_mutex_unlock(ptr %lk)
  call void @t_run_chunks()
  %l1 = call i32 @pthread_mutex_lock(ptr %lk)
  %a = load i32, ptr @T_active
  %a1 = sub i32 %a, 1
  store i32 %a1, ptr @T_active
  %last = icmp eq i32 %a1, 0
  br i1 %last, label %signal, label %release
signal:
  %b0 = call i32 @pthread_cond_broadcast(ptr %dn)
  br label %release
release:
  %u1 = call i32 @pthread_mutex_unlock(ptr %lk)
  br label %park
}

define internal void @t_init() {
entry:
  %r = load i32, ptr @T_ready
  %have = icmp ne i32 %r, 0
  br i1 %have, label %out, label %make
make:
  ; generous sizes: pthread_mutex_t is 64 bytes and pthread_cond_t 48 on macOS
  %lk = call ptr @malloc(i64 128)
  %wk = call ptr @malloc(i64 128)
  %dn = call ptr @malloc(i64 128)
  %i0 = call i32 @pthread_mutex_init(ptr %lk, ptr null)
  %i1 = call i32 @pthread_cond_init(ptr %wk, ptr null)
  %i2 = call i32 @pthread_cond_init(ptr %dn, ptr null)
  store ptr %lk, ptr @T_lock
  store ptr %wk, ptr @T_work
  store ptr %dn, ptr @T_done
  %cores = call i32 @thr_cpu_count()
  %n = sub i32 %cores, 1
  %tid = alloca i64
  br label %spawn
spawn:
  %k = phi i32 [ 0, %make ], [ %k1, %started ]
  %more = icmp slt i32 %k, %n
  br i1 %more, label %start, label %ready
start:
  %rc = call i32 @pthread_create(ptr %tid, ptr null, ptr @t_worker, ptr null)
  %ok = icmp eq i32 %rc, 0
  br i1 %ok, label %detach, label %ready
detach:
  %t = load i64, ptr %tid
  %tp = inttoptr i64 %t to ptr
  %d = call i32 @pthread_detach(ptr %tp)
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
  %l0 = call i32 @pthread_mutex_lock(ptr %lk)
  store ptr %fn, ptr @T_fn
  store ptr %ctx, ptr @T_ctx
  store i32 %count, ptr @T_count
  ; about eight chunks a thread: small enough to share the work, large enough that claiming is cheap
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
  %b0 = call i32 @pthread_cond_broadcast(ptr %wk)
  %u0 = call i32 @pthread_mutex_unlock(ptr %lk)
  call void @t_run_chunks()
  %l1 = call i32 @pthread_mutex_lock(ptr %lk)
  br label %wait
wait:
  %act = load i32, ptr @T_active
  %busy = icmp sgt i32 %act, 0
  br i1 %busy, label %sleep, label %finished
sleep:
  %w0 = call i32 @pthread_cond_wait(ptr %dn, ptr %lk)
  br label %wait
finished:
  %u1 = call i32 @pthread_mutex_unlock(ptr %lk)
  br label %out
out:
  ret void
}

; ---- Sync.* --------------------------------------------------------------------------------------
define ptr @thr_mutex_new() {
entry:
  %m = call ptr @malloc(i64 128)
  %r = call i32 @pthread_mutex_init(ptr %m, ptr null)
  ret ptr %m
}
define void @thr_lock(ptr %m) {
entry:
  %r = call i32 @pthread_mutex_lock(ptr %m)
  ret void
}
define void @thr_unlock(ptr %m) {
entry:
  %r = call i32 @pthread_mutex_unlock(ptr %m)
  ret void
}
define i32 @thr_trylock(ptr %m) {
entry:
  %r = call i32 @pthread_mutex_trylock(ptr %m)
  %got = icmp eq i32 %r, 0
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
