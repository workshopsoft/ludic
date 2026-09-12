; ============================================================================
; win32_gl.ll — OpenGL on the Windows window (cocoa.ll's win_gl_* half).
;
; Linked into a windowed Windows program that uses Gl.*, beside win32.ll (the
; window) and gl_win.ll (which makes a 4.1 core context on a DC and fills the
; entry-point table). A headless build links gl_win_nowin.ll in its place.
;
;   win_gl_attach() -> ok      the context on the window's DC (0 = no window yet)
;   win_gl_resize(w, h)        client area of w x h pixels, centred
;   win_gl_swap()              SwapBuffers, paced by the swap interval
;   win_gl_scale() -> 1        the process is DPI aware: one pixel is one pixel
;   win_gl_drawable(out)       the client area in pixels
;   win_toggle_fullscreen()    borderless, over the monitor the window is on
; ============================================================================

@W_hwnd  = external global ptr
@W_hdc   = external global ptr
@W_fbw   = external global i32
@W_fbh   = external global i32
@W_scale = external global i32

declare ptr @lgl_wgl_core(ptr, i32)
declare ptr @wglGetProcAddress(ptr)
declare i32 @SwapBuffers(ptr)
declare i32 @GetClientRect(ptr, ptr)
declare i32 @AdjustWindowRectEx(ptr, i32, i32, i32)
declare i32 @SetWindowPos(ptr, ptr, i32, i32, i32, i32, i32)
declare i32 @GetSystemMetrics(i32)
declare i64 @GetWindowLongPtrA(ptr, i32)
declare i64 @SetWindowLongPtrA(ptr, i32, i64)
declare i32 @GetWindowRect(ptr, ptr)
declare ptr @MonitorFromWindow(ptr, i32)
declare i32 @GetMonitorInfoA(ptr, ptr)
declare void @llvm.memset.p0.i64(ptr, i8, i64, i1)

@.wgl_swapint = private unnamed_addr constant [19 x i8] c"wglSwapIntervalEXT\00"

@W_glctx    = internal global ptr null
@W_fs       = internal global i32 0
@W_fs_style = internal global i64 0
@W_fs_rect  = internal global [4 x i32] zeroinitializer

define i32 @win_gl_attach() {
entry:
  %have = load ptr, ptr @W_glctx
  %again = icmp ne ptr %have, null
  br i1 %again, label %ok, label %make
make:
  %hdc = load ptr, ptr @W_hdc
  %nodc = icmp eq ptr %hdc, null
  br i1 %nodc, label %fail, label %ctx
ctx:
  ; 24-bit colour with 8 of alpha, 24 depth, 8 stencil, double-buffered: cocoa.ll's format
  %c = call ptr @lgl_wgl_core(ptr %hdc, i32 8)
  %noc = icmp eq ptr %c, null
  br i1 %noc, label %fail, label %keep
keep:
  store ptr %c, ptr @W_glctx
  call void @win_gl_swap_interval(i32 1)
  br label %ok
ok:
  ret i32 1
fail:
  ret i32 0
}

define void @win_gl_resize(i32 %w, i32 %h) {
entry:
  %rc = alloca [16 x i8], align 4
  %hwnd = load ptr, ptr @W_hwnd
  %nowin = icmp eq ptr %hwnd, null
  br i1 %nowin, label %out, label %go
go:
  store i32 %w, ptr @W_fbw
  store i32 %h, ptr @W_fbh
  store i32 1, ptr @W_scale
  %fs = load i32, ptr @W_fs
  %isfs = icmp ne i32 %fs, 0
  br i1 %isfs, label %out, label %size
size:
  call void @llvm.memset.p0.i64(ptr %rc, i8 0, i64 16, i1 false)
  %rcr = getelementptr i8, ptr %rc, i64 8
  store i32 %w, ptr %rcr
  %rcb = getelementptr i8, ptr %rc, i64 12
  store i32 %h, ptr %rcb
  %style64 = call i64 @GetWindowLongPtrA(ptr %hwnd, i32 -16)   ; GWL_STYLE
  %style = trunc i64 %style64 to i32
  %adj = call i32 @AdjustWindowRectEx(ptr %rc, i32 %style, i32 0, i32 0)
  %l = load i32, ptr %rc
  %tp = getelementptr i8, ptr %rc, i64 4
  %t = load i32, ptr %tp
  %r = load i32, ptr %rcr
  %b = load i32, ptr %rcb
  %ww = sub i32 %r, %l
  %wh = sub i32 %b, %t
  %sw = call i32 @GetSystemMetrics(i32 0)
  %sh = call i32 @GetSystemMetrics(i32 1)
  %dx = sub i32 %sw, %ww
  %x0 = sdiv i32 %dx, 2
  %xneg = icmp slt i32 %x0, 0
  %x = select i1 %xneg, i32 0, i32 %x0
  %dy = sub i32 %sh, %wh
  %y0 = sdiv i32 %dy, 2
  %yneg = icmp slt i32 %y0, 0
  %y = select i1 %yneg, i32 0, i32 %y0
  %sp = call i32 @SetWindowPos(ptr %hwnd, ptr null, i32 %x, i32 %y, i32 %ww, i32 %wh, i32 20)   ; SWP_NOZORDER | SWP_NOACTIVATE
  br label %out
out:
  ret void
}

define void @win_gl_swap() {
entry:
  %c = load ptr, ptr @W_glctx
  %noc = icmp eq ptr %c, null
  br i1 %noc, label %out, label %go
go:
  %hdc = load ptr, ptr @W_hdc
  %r = call i32 @SwapBuffers(ptr %hdc)
  br label %out
out:
  ret void
}

define i32 @win_gl_scale() {
entry:
  ret i32 1
}

; 1 = vsync (set at attach), 0 = free-running; wglSwapIntervalEXT is a driver extension,
; reachable only through the current context
define void @win_gl_swap_interval(i32 %n) {
entry:
  %c = load ptr, ptr @W_glctx
  %noc = icmp eq ptr %c, null
  br i1 %noc, label %out, label %find
find:
  %fp = call ptr @wglGetProcAddress(ptr @.wgl_swapint)
  %fpi = ptrtoint ptr %fp to i64
  %fpa = add i64 %fpi, 1
  %bad = icmp ult i64 %fpa, 5
  br i1 %bad, label %out, label %call
call:
  %r = call i32 %fp(i32 %n)
  br label %out
out:
  ret void
}

define void @win_gl_drawable(ptr %out) {
entry:
  %rc = alloca [16 x i8], align 4
  %hwnd = load ptr, ptr @W_hwnd
  %nowin = icmp eq ptr %hwnd, null
  br i1 %nowin, label %none, label %go
go:
  %g = call i32 @GetClientRect(ptr %hwnd, ptr %rc)
  %rp = getelementptr i8, ptr %rc, i64 8
  %w = load i32, ptr %rp
  %bp = getelementptr i8, ptr %rc, i64 12
  %h = load i32, ptr %bp
  store i32 %w, ptr %out
  %o1 = getelementptr i32, ptr %out, i32 1
  store i32 %h, ptr %o1
  ; a minimised window has no client area; keep the last real size for the mouse mapping
  %zw = icmp sle i32 %w, 0
  %zh = icmp sle i32 %h, 0
  %gone = or i1 %zw, %zh
  br i1 %gone, label %done, label %track
track:
  store i32 %w, ptr @W_fbw
  store i32 %h, ptr @W_fbh
  br label %done
done:
  ret void
none:
  store i32 0, ptr %out
  %o1n = getelementptr i32, ptr %out, i32 1
  store i32 0, ptr %o1n
  ret void
}

; WGL needs no notice that its window changed size
define void @win_gl_update() {
entry:
  ret void
}

; The Retina switch: on Windows the process is DPI aware and always draws one pixel per
; screen pixel, which is what "on" means on macOS; there is no lower-resolution surface
; for "off" to fall back to, so it changes nothing.
define void @win_gl_retina(i32 %on) {
entry:
  ret void
}

; Borderless full screen over the window's monitor, and back to the frame and the
; rectangle it had. (Exclusive full screen would change the display mode under a
; player's other windows; nothing in the game needs it.)
define void @win_toggle_fullscreen() {
entry:
  %mi = alloca [40 x i8], align 4
  %hwnd = load ptr, ptr @W_hwnd
  %nowin = icmp eq ptr %hwnd, null
  br i1 %nowin, label %out, label %which
which:
  %fs = load i32, ptr @W_fs
  %isfs = icmp ne i32 %fs, 0
  br i1 %isfs, label %leave, label %enter
enter:
  %style = call i64 @GetWindowLongPtrA(ptr %hwnd, i32 -16)
  store i64 %style, ptr @W_fs_style
  %gr = call i32 @GetWindowRect(ptr %hwnd, ptr @W_fs_rect)
  %mon = call ptr @MonitorFromWindow(ptr %hwnd, i32 2)          ; MONITOR_DEFAULTTONEAREST
  call void @llvm.memset.p0.i64(ptr %mi, i8 0, i64 40, i1 false)
  store i32 40, ptr %mi
  %gm = call i32 @GetMonitorInfoA(ptr %mon, ptr %mi)
  ; MONITORINFO.rcMonitor at 4
  %mlp = getelementptr i8, ptr %mi, i64 4
  %ml = load i32, ptr %mlp
  %mtp = getelementptr i8, ptr %mi, i64 8
  %mt = load i32, ptr %mtp
  %mrp = getelementptr i8, ptr %mi, i64 12
  %mr = load i32, ptr %mrp
  %mbp = getelementptr i8, ptr %mi, i64 16
  %mb = load i32, ptr %mbp
  ; drop WS_OVERLAPPEDWINDOW (0x00CF0000), add WS_POPUP (0x80000000)
  %bare = and i64 %style, -13565953
  %popup = or i64 %bare, 2147483648
  %sl = call i64 @SetWindowLongPtrA(ptr %hwnd, i32 -16, i64 %popup)
  %fw = sub i32 %mr, %ml
  %fh = sub i32 %mb, %mt
  %sp = call i32 @SetWindowPos(ptr %hwnd, ptr null, i32 %ml, i32 %mt, i32 %fw, i32 %fh, i32 544)   ; SWP_FRAMECHANGED | SWP_NOOWNERZORDER
  store i32 1, ptr @W_fs
  br label %out
leave:
  %saved = load i64, ptr @W_fs_style
  %sl2 = call i64 @SetWindowLongPtrA(ptr %hwnd, i32 -16, i64 %saved)
  %l = load i32, ptr @W_fs_rect
  %tp = getelementptr i32, ptr @W_fs_rect, i32 1
  %t = load i32, ptr %tp
  %rp = getelementptr i32, ptr @W_fs_rect, i32 2
  %r = load i32, ptr %rp
  %bp = getelementptr i32, ptr @W_fs_rect, i32 3
  %b = load i32, ptr %bp
  %ww = sub i32 %r, %l
  %wh = sub i32 %b, %t
  %sp2 = call i32 @SetWindowPos(ptr %hwnd, ptr null, i32 %l, i32 %t, i32 %ww, i32 %wh, i32 548)   ; ... | SWP_NOZORDER
  store i32 0, ptr @W_fs
  br label %out
out:
  ret void
}
