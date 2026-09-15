; ============================================================================
; gl.ll — the window-independent half of the OpenGL backend, in LLVM IR.
;
; Linked into any program that uses Gl.* (windowed or headless), together with
; gl_thunks.ll (the generated per-entry-point ABI thunks) and -framework OpenGL.
; Nothing here touches the window: the NSOpenGLContext lives in cocoa.ll.
;
;   cgl_offscreen() -> ok          a headless 4.1 core context (render into FBOs)
;   fx_to_f32(fx) -> bits          Q16.16 -> IEEE float bits (an int)
;   f32_to_fx(bits) -> fx          IEEE float bits -> Q16.16
;   mem_*                          raw little-endian reads/writes on a bytes buffer
;   f_*                            IEEE-754 float arithmetic on float bits
; ============================================================================

declare i32 @CGLChoosePixelFormat(ptr, ptr, ptr)
declare i32 @CGLCreateContext(ptr, ptr, ptr)
declare i32 @CGLSetCurrentContext(ptr)
declare i32 @CGLDestroyPixelFormat(ptr)
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
declare float @ldexpf(float, i32)
declare float @llvm.sqrt.f32(float)
declare float @llvm.fabs.f32(float)

define i32 @cgl_offscreen() {
entry:
  ; kCGLPFAAccelerated=73, kCGLPFAOpenGLProfile=99 -> kCGLOGLPVersion_GL4_Core (0x4100),
  ; kCGLPFAColorSize=8 -> 24, kCGLPFADepthSize=12 -> 24, 0
  %attrs = alloca [8 x i32], align 4
  %a0 = getelementptr [8 x i32], ptr %attrs, i32 0, i32 0
  store i32 73, ptr %a0
  %a1 = getelementptr [8 x i32], ptr %attrs, i32 0, i32 1
  store i32 99, ptr %a1
  %a2 = getelementptr [8 x i32], ptr %attrs, i32 0, i32 2
  store i32 16640, ptr %a2
  %a3 = getelementptr [8 x i32], ptr %attrs, i32 0, i32 3
  store i32 8, ptr %a3
  %a4 = getelementptr [8 x i32], ptr %attrs, i32 0, i32 4
  store i32 24, ptr %a4
  %a5 = getelementptr [8 x i32], ptr %attrs, i32 0, i32 5
  store i32 12, ptr %a5
  %a6 = getelementptr [8 x i32], ptr %attrs, i32 0, i32 6
  store i32 24, ptr %a6
  %a7 = getelementptr [8 x i32], ptr %attrs, i32 0, i32 7
  store i32 0, ptr %a7
  %pix = alloca ptr, align 8
  store ptr null, ptr %pix
  %npix = alloca i32, align 4
  %e1 = call i32 @CGLChoosePixelFormat(ptr %attrs, ptr %pix, ptr %npix)
  %p = load ptr, ptr %pix
  %nop = icmp eq ptr %p, null
  br i1 %nop, label %fail, label %mk
mk:
  %ctx = alloca ptr, align 8
  store ptr null, ptr %ctx
  %e2 = call i32 @CGLCreateContext(ptr %p, ptr null, ptr %ctx)
  %c = load ptr, ptr %ctx
  %e3 = call i32 @CGLDestroyPixelFormat(ptr %p)
  %noc = icmp eq ptr %c, null
  br i1 %noc, label %fail, label %cur
cur:
  %e4 = call i32 @CGLSetCurrentContext(ptr %c)
  ret i32 1
fail:
  ret i32 0
}

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
define i32 @f_ldexp(i32 %a, i32 %e) {
entry:
  %x = bitcast i32 %a to float
  %r = call float @ldexpf(float %x, i32 %e)
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
; Time.now() is whole seconds and Time.delta() is a fixed 60 Hz timestep, so
; neither can measure a frame. gettimeofday gives the wall clock in microseconds,
; which is what frame pacing and hitch measurement actually need.
; macOS arm64: struct timeval is { time_t tv_sec (i64), suseconds_t tv_usec (i32) }
%struct.timeval64 = type { i64, i32 }
declare i32 @gettimeofday(ptr, ptr)

define i64 @gl_now_us() {
entry:
  %tv = alloca %struct.timeval64, align 8
  %r = call i32 @gettimeofday(ptr %tv, ptr null)
  %secp = getelementptr inbounds %struct.timeval64, ptr %tv, i32 0, i32 0
  %usp = getelementptr inbounds %struct.timeval64, ptr %tv, i32 0, i32 1
  %sec = load i64, ptr %secp, align 8
  %us32 = load i32, ptr %usp, align 8
  %us = sext i32 %us32 to i64
  %m = mul i64 %sec, 1000000
  %t = add i64 %m, %us
  ret i64 %t
}

; headless on macOS: no window, so nothing for a graphics API to make a surface on
define weak ptr @win_native_window() {
entry:
  ret ptr null
}
define weak ptr @win_native_instance() {
entry:
  ret ptr null
}
; the drawable's size, for a graphics API that follows the window without a GL context (render3d's
; Vulkan resize check); headless there is no window, so 0 x 0. cocoa.ll's real one wins when linked.
define weak void @win_gl_drawable(ptr %out) {
entry:
  store i32 0, ptr %out
  %o1 = getelementptr i32, ptr %out, i32 1
  store i32 0, ptr %o1
  ret void
}
