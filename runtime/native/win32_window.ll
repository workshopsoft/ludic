; ============================================================================
; win32_window.ll — the window's size, scale and full screen on Windows (cocoa.ll's
; win_resize / win_scale / win_drawable half).
;
; Linked into a windowed Windows program that uses the window layer
; (runtime/native/window.ludic), beside win32.ll (the window). A headless build links
; win_nowin.ll in its place.
;
;   win_resize(w, h)           a client area of w x h at the display's scale, centred
;   win_scale() -> int         pixels per window unit: 1 at 100%, 2 at 175-200%, ...
;   win_drawable(out)          the client area in pixels
;   win_toggle_fullscreen()    borderless, over the monitor the window is on
;
; The units follow cocoa.ll's points and backing pixels: a game asks for a 960 x 540
; window, the display's whole-number scale (w_fit_scale, win32.ll) turns that into
; pixels, win_scale reports the factor as the Retina backing scale is reported,
; and the mouse keeps arriving in the game's own units because W_scale divides by it.
; ============================================================================

@W_hwnd  = external global ptr
@W_hdc   = external global ptr
@W_fbw   = external global i32
@W_fbh   = external global i32
@W_scale = external global i32

declare i32 @w_fit_scale(i32, i32, i32)
declare i32 @GetClientRect(ptr, ptr)
declare i32 @AdjustWindowRectEx(ptr, i32, i32, i32)
declare i32 @SetWindowPos(ptr, ptr, i32, i32, i32, i32, i32)
declare i32 @GetSystemMetrics(i32)
declare i32 @GetDpiForWindow(ptr)
declare i64 @GetWindowLongPtrA(ptr, i32)
declare i64 @SetWindowLongPtrA(ptr, i32, i64)
declare i32 @GetWindowRect(ptr, ptr)
declare ptr @MonitorFromWindow(ptr, i32)
declare i32 @GetMonitorInfoA(ptr, ptr)
declare void @llvm.memset.p0.i64(ptr, i8, i64, i1)

@W_pixscale = internal global i32 1
@W_fs       = internal global i32 0
@W_fs_style = internal global i64 0
@W_fs_rect  = internal global [4 x i32] zeroinitializer

define void @win_resize(i32 %w, i32 %h) {
entry:
  %rc = alloca [16 x i8], align 4
  %hwnd = load ptr, ptr @W_hwnd
  %nowin = icmp eq ptr %hwnd, null
  br i1 %nowin, label %out, label %go
go:
  %dpi = call i32 @GetDpiForWindow(ptr %hwnd)
  %s = call i32 @w_fit_scale(i32 %dpi, i32 %w, i32 %h)
  store i32 %s, ptr @W_pixscale
  store i32 %w, ptr @W_fbw
  store i32 %h, ptr @W_fbh
  store i32 %s, ptr @W_scale
  %fs = load i32, ptr @W_fs
  %isfs = icmp ne i32 %fs, 0
  br i1 %isfs, label %out, label %size
size:
  %pw = mul i32 %w, %s
  %ph = mul i32 %h, %s
  call void @llvm.memset.p0.i64(ptr %rc, i8 0, i64 16, i1 false)
  %rcr = getelementptr i8, ptr %rc, i64 8
  store i32 %pw, ptr %rcr
  %rcb = getelementptr i8, ptr %rc, i64 12
  store i32 %ph, ptr %rcb
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

define i32 @win_scale() {
entry:
  %s = load i32, ptr @W_pixscale
  ret i32 %s
}

; the client area in pixels -> out[0], out[1]; and the window size in the game's units,
; which the mouse mapping divides by, kept in step with a window the player resized
define void @win_drawable(ptr %out) {
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
  ; a minimised window has no client area; keep the last real size
  %zw = icmp sle i32 %w, 0
  %zh = icmp sle i32 %h, 0
  %gone = or i1 %zw, %zh
  br i1 %gone, label %done, label %track
track:
  %s = load i32, ptr @W_pixscale
  %uw = sdiv i32 %w, %s
  %uh = sdiv i32 %h, %s
  store i32 %uw, ptr @W_fbw
  store i32 %uh, ptr @W_fbh
  store i32 %s, ptr @W_scale
  br label %done
done:
  ret void
none:
  store i32 0, ptr %out
  %o1n = getelementptr i32, ptr %out, i32 1
  store i32 0, ptr %o1n
  ret void
}

; The Retina switch. The process is DPI aware and always draws one pixel per screen
; pixel, which is what "on" means on macOS; there is no lower-resolution surface for
; "off" to fall back to, so it changes nothing here.
define void @win_retina(i32 %on) {
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
