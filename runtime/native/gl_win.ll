; ============================================================================
; gl_win.ll — the window-independent half of the OpenGL backend on Windows.
;
; The Windows counterpart of gl.ll, linked with gl_thunks_win.ll and opengl32,
; gdi32 and user32 into any Windows program that uses Gl.*. The helpers below the
; context are gl.ll's, unchanged; what differs is how a context comes to exist and
; how the GL entry points are reached.
;
;   cgl_offscreen() -> ok    a hidden window's DC, a WGL 4.1 core context made
;                            current on it, and the entry-point table filled
;   gl_now_us() -> us        QueryPerformanceCounter, in microseconds
;
; Why a window at all: WGL makes a context from a device context with a pixel
; format, and only a window has one. The window is never shown; everything is
; drawn into FBOs exactly as on macOS.
;
; Why the table: opengl32.dll exports only OpenGL 1.1 by name. Every later entry
; point (glCreateShader, glBindVertexArray, ...) belongs to the driver and is found
; with wglGetProcAddress, which only answers while a context is current - so the
; generated thunks call through @lgl_p_* pointers that @lgl_win_load fills once,
; here, after the core context is made current.
; ============================================================================

declare ptr @CreateWindowExA(i32, ptr, ptr, i32, i32, i32, i32, i32, ptr, ptr, ptr, ptr)
declare ptr @GetDC(ptr)
declare i32 @ChoosePixelFormat(ptr, ptr)
declare i32 @SetPixelFormat(ptr, i32, ptr)
declare ptr @wglCreateContext(ptr)
declare i32 @wglMakeCurrent(ptr, ptr)
declare i32 @wglDeleteContext(ptr)
declare ptr @wglGetProcAddress(ptr)
declare i32 @QueryPerformanceCounter(ptr)
declare i32 @QueryPerformanceFrequency(ptr)
declare i32 @lgl_win_load()
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

@.wgl_class = private unnamed_addr constant [7 x i8] c"STATIC\00"
@.wgl_title = private unnamed_addr constant [6 x i8] c"Ludic\00"
@.wgl_arb   = private unnamed_addr constant [27 x i8] c"wglCreateContextAttribsARB\00"
; WGL_CONTEXT_MAJOR_VERSION_ARB 4, MINOR 1, WGL_CONTEXT_PROFILE_MASK_ARB = CORE
@.wgl_attrs = private unnamed_addr constant [7 x i32] [i32 8337, i32 4, i32 8338, i32 1, i32 37158, i32 1, i32 0]

@L_wgl_hwnd = internal global ptr null
@L_wgl_hdc  = internal global ptr null
@L_wgl_ctx  = internal global ptr null

define i32 @cgl_offscreen() {
entry:
  %cur = load ptr, ptr @L_wgl_ctx
  %have = icmp ne ptr %cur, null
  br i1 %have, label %ok, label %win
win:
  ; WS_POPUP, never shown
  %w = call ptr @CreateWindowExA(i32 0, ptr @.wgl_class, ptr @.wgl_title, i32 -2147483648, i32 0, i32 0, i32 16, i32 16, ptr null, ptr null, ptr null, ptr null)
  %wn = icmp eq ptr %w, null
  br i1 %wn, label %fail, label %pf
pf:
  store ptr %w, ptr @L_wgl_hwnd
  %hdc = call ptr @GetDC(ptr %w)
  store ptr %hdc, ptr @L_wgl_hdc
  ; PIXELFORMATDESCRIPTOR: nSize 40, nVersion 1, PFD_DRAW_TO_WINDOW|SUPPORT_OPENGL|DOUBLEBUFFER,
  ; 32-bit colour, 24 depth, 8 stencil
  %pfd = alloca [40 x i8], align 4
  call void @llvm.memset.p0.i64(ptr %pfd, i8 0, i64 40, i1 false)
  store i16 40, ptr %pfd
  %ver = getelementptr i8, ptr %pfd, i64 2
  store i16 1, ptr %ver
  %fl = getelementptr i8, ptr %pfd, i64 4
  store i32 37, ptr %fl
  %cb = getelementptr i8, ptr %pfd, i64 9
  store i8 32, ptr %cb
  %db = getelementptr i8, ptr %pfd, i64 23
  store i8 24, ptr %db
  %sb = getelementptr i8, ptr %pfd, i64 24
  store i8 8, ptr %sb
  %idx = call i32 @ChoosePixelFormat(ptr %hdc, ptr %pfd)
  %set = call i32 @SetPixelFormat(ptr %hdc, i32 %idx, ptr %pfd)
  %setz = icmp eq i32 %set, 0
  br i1 %setz, label %fail, label %legacy
legacy:
  ; a legacy context first: wglCreateContextAttribsARB is only reachable through one
  %old = call ptr @wglCreateContext(ptr %hdc)
  %oldn = icmp eq ptr %old, null
  br i1 %oldn, label %fail, label %arb
arb:
  %m1 = call i32 @wglMakeCurrent(ptr %hdc, ptr %old)
  %fp = call ptr @wglGetProcAddress(ptr @.wgl_arb)
  %fpi = ptrtoint ptr %fp to i64
  %nofp = icmp ult i64 %fpi, 4
  br i1 %nofp, label %drop, label %core
core:
  %ctx = call ptr %fp(ptr %hdc, ptr null, ptr @.wgl_attrs)
  %ctxn = icmp eq ptr %ctx, null
  br i1 %ctxn, label %drop, label %use
use:
  %m2 = call i32 @wglMakeCurrent(ptr %hdc, ptr %ctx)
  %d1 = call i32 @wglDeleteContext(ptr %old)
  store ptr %ctx, ptr @L_wgl_ctx
  %n = call i32 @lgl_win_load()
  br label %ok
drop:
  %m3 = call i32 @wglMakeCurrent(ptr null, ptr null)
  %d2 = call i32 @wglDeleteContext(ptr %old)
  br label %fail
ok:
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
; gl.ll reads gettimeofday; Windows has QueryPerformanceCounter, which is
; monotonic as well as fine-grained. Split into whole seconds and remainder so
; the multiply cannot overflow however long the machine has been up.
define i64 @gl_now_us() {
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

; ---- the window half, until there is one ------------------------------------
; gl.ludic names these on its is_windowed() branch. A headless build compiles that
; branch to nothing, but the names still have to resolve; a windowed Windows
; build will define them in the Win32 platform layer instead of here.
define i32 @win_gl_attach() {
entry:
  ret i32 0
}
define void @win_gl_resize(i32 %w, i32 %h) {
entry:
  ret void
}
define void @win_gl_swap() {
entry:
  ret void
}
define i32 @win_gl_scale() {
entry:
  ret i32 1
}
define void @win_gl_swap_interval(i32 %n) {
entry:
  ret void
}
define void @win_gl_drawable(ptr %out) {
entry:
  ret void
}
define void @win_gl_update() {
entry:
  ret void
}
define void @win_gl_retina(i32 %on) {
entry:
  ret void
}
define void @win_toggle_fullscreen() {
entry:
  ret void
}
