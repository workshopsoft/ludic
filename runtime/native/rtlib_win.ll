; ============================================================================
; rtlib_win.ll — the runtime's numeric, memory and clock helpers on Windows.
;
; The Windows counterpart of rtlib.ll, linked into any Windows program that uses the
; window layer (runtime/native/window.ludic). The helpers are rtlib.ll's, unchanged,
; apart from the clock:
;
;   clock_now_us() -> us     QueryPerformanceCounter, in microseconds
; ============================================================================

declare i32 @QueryPerformanceCounter(ptr)
declare void @Sleep(i32)
declare ptr @CreateWaitableTimerExW(ptr, ptr, i32, i32)
declare i32 @SetWaitableTimerEx(ptr, ptr, i32, ptr, ptr, ptr, i32)
declare i32 @WaitForSingleObject(ptr, i32)
declare i32 @QueryPerformanceFrequency(ptr)
declare void @llvm.memcpy.p0.p0.i64(ptr, ptr, i64, i1)
declare void @llvm.memset.p0.i64(ptr, i8, i64, i1)
declare float @sinf(float)
declare float @cosf(float)
declare float @tanf(float)
declare float @atan2f(float, float)
declare float @powf(float, float)
declare float @expf(float)
declare float @logf(float)
declare float @floorf(float)
declare float @fmodf(float, float)
declare double @ldexp(double, i32)
declare float @llvm.sqrt.f32(float)
declare float @llvm.fabs.f32(float)

; ---- Q16.16 <-> IEEE float ---------------------------------------------------
define i32 @fx_to_f32(i32 %fx) {
entry:
  %f = sitofp i32 %fx to float
  %s = fmul float %f, 0x3EF0000000000000
  %b = bitcast float %s to i32
  ret i32 %b
}
define i32 @f32_to_fx(i32 %bits) {
entry:
  %f = bitcast i32 %bits to float
  %s = fmul float %f, 65536.0
  %r = fptosi float %s to i32
  ret i32 %r
}

; ---- raw memory ---------------------------------------------------------------
define ptr @mem_off(ptr %p, i32 %off) {
entry:
  %q = getelementptr inbounds i8, ptr %p, i32 %off
  ret ptr %q
}
define i32 @mem_get_i32(ptr %p, i32 %off) {
entry:
  %q = getelementptr inbounds i8, ptr %p, i32 %off
  %v = load i32, ptr %q, align 1
  ret i32 %v
}
define void @mem_put_i32(ptr %p, i32 %off, i32 %v) {
entry:
  %q = getelementptr inbounds i8, ptr %p, i32 %off
  store i32 %v, ptr %q, align 1
  ret void
}
define i32 @mem_get_u16(ptr %p, i32 %off) {
entry:
  %q = getelementptr inbounds i8, ptr %p, i32 %off
  %v = load i16, ptr %q, align 1
  %z = zext i16 %v to i32
  ret i32 %z
}
define void @mem_put_u16(ptr %p, i32 %off, i32 %v) {
entry:
  %q = getelementptr inbounds i8, ptr %p, i32 %off
  %t = trunc i32 %v to i16
  store i16 %t, ptr %q, align 1
  ret void
}
define i32 @mem_get_u8(ptr %p, i32 %off) {
entry:
  %q = getelementptr inbounds i8, ptr %p, i32 %off
  %v = load i8, ptr %q
  %z = zext i8 %v to i32
  ret i32 %z
}
define void @mem_put_u8(ptr %p, i32 %off, i32 %v) {
entry:
  %q = getelementptr inbounds i8, ptr %p, i32 %off
  %t = trunc i32 %v to i8
  store i8 %t, ptr %q
  ret void
}
; float element i of a float buffer, as Q16.16 / as bits
define i32 @mem_get_f32(ptr %p, i32 %i) {
entry:
  %q = getelementptr inbounds float, ptr %p, i32 %i
  %f = load float, ptr %q, align 1
  %s = fmul float %f, 65536.0
  %r = fptosi float %s to i32
  ret i32 %r
}
define void @mem_put_f32(ptr %p, i32 %i, i32 %fx) {
entry:
  %q = getelementptr inbounds float, ptr %p, i32 %i
  %f = sitofp i32 %fx to float
  %s = fmul float %f, 0x3EF0000000000000
  store float %s, ptr %q, align 1
  ret void
}
define i32 @mem_get_f32_bits(ptr %p, i32 %i) {
entry:
  %q = getelementptr inbounds i32, ptr %p, i32 %i
  %v = load i32, ptr %q, align 1
  ret i32 %v
}
define void @mem_put_f32_bits(ptr %p, i32 %i, i32 %bits) {
entry:
  %q = getelementptr inbounds i32, ptr %p, i32 %i
  store i32 %bits, ptr %q, align 1
  ret void
}
define void @mem_copy(ptr %dst, ptr %src, i32 %n) {
entry:
  %n64 = sext i32 %n to i64
  call void @llvm.memcpy.p0.p0.i64(ptr %dst, ptr %src, i64 %n64, i1 false)
  ret void
}
define void @mem_set(ptr %dst, i32 %v, i32 %n) {
entry:
  %n64 = sext i32 %n to i64
  %b = trunc i32 %v to i8
  call void @llvm.memset.p0.i64(ptr %dst, i8 %b, i64 %n64, i1 false)
  ret void
}

; ---- IEEE float arithmetic on bit patterns ------------------------------------
define i32 @f_add(i32 %a, i32 %b) {
entry:
  %x = bitcast i32 %a to float
  %y = bitcast i32 %b to float
  %r = fadd float %x, %y
  %o = bitcast float %r to i32
  ret i32 %o
}
define i32 @f_sub(i32 %a, i32 %b) {
entry:
  %x = bitcast i32 %a to float
  %y = bitcast i32 %b to float
  %r = fsub float %x, %y
  %o = bitcast float %r to i32
  ret i32 %o
}
define i32 @f_mul(i32 %a, i32 %b) {
entry:
  %x = bitcast i32 %a to float
  %y = bitcast i32 %b to float
  %r = fmul float %x, %y
  %o = bitcast float %r to i32
  ret i32 %o
}
define i32 @f_div(i32 %a, i32 %b) {
entry:
  %x = bitcast i32 %a to float
  %y = bitcast i32 %b to float
  %r = fdiv float %x, %y
  %o = bitcast float %r to i32
  ret i32 %o
}
define i32 @f_neg(i32 %a) {
entry:
  %x = bitcast i32 %a to float
  %r = fneg float %x
  %o = bitcast float %r to i32
  ret i32 %o
}
define i32 @f_sqrt(i32 %a) {
entry:
  %x = bitcast i32 %a to float
  %r = call float @llvm.sqrt.f32(float %x)
  %o = bitcast float %r to i32
  ret i32 %o
}
define i32 @f_abs(i32 %a) {
entry:
  %x = bitcast i32 %a to float
  %r = call float @llvm.fabs.f32(float %x)
  %o = bitcast float %r to i32
  ret i32 %o
}
define i32 @f_sin(i32 %a) {
entry:
  %x = bitcast i32 %a to float
  %r = call float @sinf(float %x)
  %o = bitcast float %r to i32
  ret i32 %o
}
define i32 @f_cos(i32 %a) {
entry:
  %x = bitcast i32 %a to float
  %r = call float @cosf(float %x)
  %o = bitcast float %r to i32
  ret i32 %o
}
define i32 @f_tan(i32 %a) {
entry:
  %x = bitcast i32 %a to float
  %r = call float @tanf(float %x)
  %o = bitcast float %r to i32
  ret i32 %o
}
define i32 @f_atan2(i32 %a, i32 %b) {
entry:
  %x = bitcast i32 %a to float
  %y = bitcast i32 %b to float
  %r = call float @atan2f(float %x, float %y)
  %o = bitcast float %r to i32
  ret i32 %o
}
define i32 @f_pow(i32 %a, i32 %b) {
entry:
  %x = bitcast i32 %a to float
  %y = bitcast i32 %b to float
  %r = call float @powf(float %x, float %y)
  %o = bitcast float %r to i32
  ret i32 %o
}
define i32 @f_exp(i32 %a) {
entry:
  %x = bitcast i32 %a to float
  %r = call float @expf(float %x)
  %o = bitcast float %r to i32
  ret i32 %o
}
define i32 @f_log(i32 %a) {
entry:
  %x = bitcast i32 %a to float
  %r = call float @logf(float %x)
  %o = bitcast float %r to i32
  ret i32 %o
}
define i32 @f_floor(i32 %a) {
entry:
  %x = bitcast i32 %a to float
  %r = call float @floorf(float %x)
  %o = bitcast float %r to i32
  ret i32 %o
}
define i32 @f_mod(i32 %a, i32 %b) {
entry:
  %x = bitcast i32 %a to float
  %y = bitcast i32 %b to float
  %r = call float @fmodf(float %x, float %y)
  %o = bitcast float %r to i32
  ret i32 %o
}
; no ldexpf in the UCRT: ldexp on the widened value is exact for every float
define i32 @f_ldexp(i32 %a, i32 %e) {
entry:
  %x = bitcast i32 %a to float
  %xd = fpext float %x to double
  %rd = call double @ldexp(double %xd, i32 %e)
  %r = fptrunc double %rd to float
  %o = bitcast float %r to i32
  ret i32 %o
}
define i32 @f_min(i32 %a, i32 %b) {
entry:
  %x = bitcast i32 %a to float
  %y = bitcast i32 %b to float
  %c = fcmp olt float %x, %y
  %r = select i1 %c, float %x, float %y
  %o = bitcast float %r to i32
  ret i32 %o
}
define i32 @f_max(i32 %a, i32 %b) {
entry:
  %x = bitcast i32 %a to float
  %y = bitcast i32 %b to float
  %c = fcmp ogt float %x, %y
  %r = select i1 %c, float %x, float %y
  %o = bitcast float %r to i32
  ret i32 %o
}
define i32 @f_lt(i32 %a, i32 %b) {
entry:
  %x = bitcast i32 %a to float
  %y = bitcast i32 %b to float
  %c = fcmp olt float %x, %y
  %z = zext i1 %c to i32
  ret i32 %z
}
define i32 @f_from_int(i32 %a) {
entry:
  %f = sitofp i32 %a to float
  %o = bitcast float %f to i32
  ret i32 %o
}
define i32 @f_to_int(i32 %a) {
entry:
  %x = bitcast i32 %a to float
  %r = fptosi float %x to i32
  ret i32 %r
}

; ---- a real monotonic microsecond clock -------------------------------------
; rtlib.ll reads gettimeofday; Windows has QueryPerformanceCounter, which is
; monotonic as well as fine-grained. Split into whole seconds and remainder so
; the multiply cannot overflow however long the machine has been up.
; Give the CPU back for `us` microseconds (rtlib.ll's clock_sleep_us on Windows).
;
; Not Sleep and not timeBeginPeriod: Sleep takes whole milliseconds and the scheduler's default
; granularity can be 15 ms, which no 60 fps limiter survives, and timeBeginPeriod lives in winmm,
; which this runtime does not link. A HIGH RESOLUTION waitable timer is kernel32 and is accurate to
; well under a millisecond. Older Windows without the high-resolution flag falls back to Sleep, and
; the caller's spin covers the slack either way.
@G_timer = internal global ptr null
define void @clock_sleep_us(i64 %us) {
entry:
  %pos = icmp sgt i64 %us, 0
  br i1 %pos, label %get, label %out
get:
  %have = load ptr, ptr @G_timer
  %need = icmp eq ptr %have, null
  br i1 %need, label %make, label %ready
make:
  ; CREATE_WAITABLE_TIMER_HIGH_RESOLUTION 2, TIMER_ALL_ACCESS 0x1F0003
  %t = call ptr @CreateWaitableTimerExW(ptr null, ptr null, i32 2, i32 2031619)
  store ptr %t, ptr @G_timer
  br label %ready
ready:
  %h = load ptr, ptr @G_timer
  %nohandle = icmp eq ptr %h, null
  br i1 %nohandle, label %doze, label %wait
wait:
  ; a NEGATIVE due time is relative, in 100 ns units
  %due = alloca i64, align 8
  %hundreds = mul i64 %us, 10
  %neg = sub i64 0, %hundreds
  store i64 %neg, ptr %due
  %set = call i32 @SetWaitableTimerEx(ptr %h, ptr %due, i32 0, ptr null, ptr null, ptr null, i32 0)
  %setok = icmp ne i32 %set, 0
  br i1 %setok, label %block, label %doze
block:
  %w = call i32 @WaitForSingleObject(ptr %h, i32 -1)
  br label %out
doze:
  %ms = sdiv i64 %us, 1000
  %mspos = icmp sgt i64 %ms, 0
  br i1 %mspos, label %ms_go, label %out
ms_go:
  %ms32 = trunc i64 %ms to i32
  call void @Sleep(i32 %ms32)
  br label %out
out:
  ret void
}

define i64 @clock_now_us() {
entry:
  %c = alloca i64, align 8
  %f = alloca i64, align 8
  %r1 = call i32 @QueryPerformanceCounter(ptr %c)
  %r2 = call i32 @QueryPerformanceFrequency(ptr %f)
  %cv = load i64, ptr %c
  %fv = load i64, ptr %f
  %sec = udiv i64 %cv, %fv
  %rem = urem i64 %cv, %fv
  %sus = mul i64 %sec, 1000000
  %rus = mul i64 %rem, 1000000
  %frac = udiv i64 %rus, %fv
  %t = add i64 %sus, %frac
  ret i64 %t
}
