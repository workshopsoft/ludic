; ============================================================================
; win32.ll — the Windows window, written in LLVM IR.
;
; The counterpart of cocoa.ll, to the same contracts, spoken to user32 and
; xinput through their C ABI. ludicc links it into a windowed Windows binary;
; the GL half (win_gl_*) is win32_gl.ll, linked only when the program uses Gl.*,
; so a software-framebuffer game never names a WGL function.
;
;   win_open(w, h, scale, title)  win_poll() -> key   win_present(fb, w, h)
;   win_running() -> bool         win_close()
;   win_held(out)  win_mouse(out)  win_pad(out)  win_touch(out)  win_cursor_mode(m)
;   splash_show(bytes, len, bg)   splash_hide()      app_set_icon(bytes, len)
;
; Units and conventions carried over from cocoa.ll, because the Ludic side reads
; them without knowing which platform filled them:
;
;   held keys   a 256-bit set of Ludic key codes: letters lowercase, digits and
;               punctuation as their unshifted character, Space 32, Enter 10,
;               Esc 27, Backspace 8, Tab 9, Shift 16, Ctrl 17, Alt 18, and the
;               arrows at 128 129 130 131 (up down left right)
;   frame key   the last key pressed this frame, arrows reported as w s a d
;   mouse       framebuffer pixels (client pixels / scale), top-left origin;
;               buttons bit0 left, bit1 right; wheel in notches, up positive
;   pads        SDL button order, Q16.16 axes with Y down
;
; The process is per-monitor DPI aware: a client pixel is a screen pixel, the
; backing scale is 1, and a 1280x720 window is 1280x720 pixels on any display.
;
; Keys are read from the message queue before dispatch rather than from WM_CHAR:
; TranslateMessage is never called, so no character messages are produced, and a
; key's character comes from MapVirtualKeyA. The system keys (Alt, F10) are never
; handed to DefWindowProc, whose menu loop would stall the game's frame loop -
; Alt+F4 is honoured here instead.
; ============================================================================

declare ptr @GetModuleHandleA(ptr)
declare i16 @RegisterClassExA(ptr)
declare ptr @CreateWindowExA(i32, ptr, ptr, i32, i32, i32, i32, i32, ptr, ptr, ptr, ptr)
declare i64 @DefWindowProcA(ptr, i32, i64, i64)
declare i32 @ShowWindow(ptr, i32)
declare i32 @SetForegroundWindow(ptr)
declare i32 @PeekMessageA(ptr, ptr, i32, i32, i32)
declare i64 @DispatchMessageA(ptr)
declare ptr @GetDC(ptr)
declare i32 @AdjustWindowRectEx(ptr, i32, i32, i32)
declare i32 @GetSystemMetrics(i32)
declare i32 @GetClientRect(ptr, ptr)
declare i32 @ClientToScreen(ptr, ptr)
declare i32 @ScreenToClient(ptr, ptr)
declare i32 @GetCursorPos(ptr)
declare i32 @ClipCursor(ptr)
declare ptr @SetCursor(ptr)
declare ptr @LoadCursorA(ptr, ptr)
declare ptr @GetForegroundWindow()
declare i32 @IsWindow(ptr)
declare ptr @SetCapture(ptr)
declare i32 @ReleaseCapture()
declare i32 @MapVirtualKeyA(i32, i32)
declare i16 @GetKeyState(i32)
declare i32 @RegisterRawInputDevices(ptr, i32, i32)
declare i32 @GetRawInputData(ptr, i32, ptr, ptr, i32)
declare i32 @SetProcessDpiAwarenessContext(ptr)
declare i32 @StretchDIBits(ptr, i32, i32, i32, i32, i32, i32, i32, i32, ptr, ptr, i32, i32)
declare void @Sleep(i32)
declare i32 @XInputGetState(i32, ptr)
declare void @llvm.memset.p0.i64(ptr, i8, i64, i1)

@.w_class = private unnamed_addr constant [12 x i8] c"LudicWindow\00"

; shared with win32_gl.ll, which declares them external
@W_hwnd    = global ptr null
@W_hdc     = global ptr null
@W_fbw     = global i32 320
@W_fbh     = global i32 240
@W_scale   = global i32 3

@W_fb      = internal global ptr null
@W_key     = internal global i32 0
@W_running = internal global i32 1
@W_held    = internal global [8 x i32] zeroinitializer
@W_mx      = internal global i32 0
@W_my      = internal global i32 0
@W_mbtn    = internal global i32 0
@W_wheel   = internal global i32 0
; raw mouse motion since the last win_mouse, for cursor mode 2
@W_rawdx   = internal global i32 0
@W_rawdy   = internal global i32 0
; 0 normal, 1 hidden, 2 locked (relative), 3 confined; see win_cursor_maintain
@W_cursor_mode   = internal global i32 0
@W_cursor_hidden = internal global i32 0
@W_clipped       = internal global i32 0

; ---- the window procedure ---------------------------------------------------
; Only what is SENT to a window arrives here (posted input is read in win_poll).
define internal i64 @ludic_wndproc(ptr %hwnd, i32 %msg, i64 %wp, i64 %lp) {
entry:
  switch i32 %msg, label %def [
    i32 16, label %close          ; WM_CLOSE: end the run; the game decides what quitting does
    i32 20, label %erase          ; WM_ERASEBKGND: the frame covers it, and erasing flickers
    i32 8,  label %blur           ; WM_KILLFOCUS
    i32 32, label %setcur         ; WM_SETCURSOR
  ]
close:
  store i32 0, ptr @W_running
  ret i64 0
erase:
  ret i64 1
blur:
  ; a key held when focus went away never sends its key-up to this window: drop them all,
  ; or the hiker walks on by himself after an Alt-Tab
  call void @llvm.memset.p0.i64(ptr @W_held, i8 0, i64 32, i1 false)
  store i32 0, ptr @W_mbtn
  br label %def
setcur:
  ; a hidden cursor is hidden by answering WM_SETCURSOR with no cursor over the client
  ; area, which needs no ShowCursor counter to keep balanced
  %hid = load i32, ptr @W_cursor_hidden
  %ishid = icmp ne i32 %hid, 0
  %hit = and i64 %lp, 65535
  %client = icmp eq i64 %hit, 1                 ; HTCLIENT
  %both = and i1 %ishid, %client
  br i1 %both, label %nocur, label %def
nocur:
  %c = call ptr @SetCursor(ptr null)
  ret i64 1
def:
  %r = call i64 @DefWindowProcA(ptr %hwnd, i32 %msg, i64 %wp, i64 %lp)
  ret i64 %r
}

define void @win_open(i32 %w, i32 %h, i32 %scale, ptr %title) {
entry:
  %wc = alloca [80 x i8], align 8
  %rc = alloca [16 x i8], align 4
  %rid = alloca [16 x i8], align 8
  store i32 %w, ptr @W_fbw
  store i32 %h, ptr @W_fbh
  store i32 %scale, ptr @W_scale
  %have = load ptr, ptr @W_hwnd
  %again = icmp ne ptr %have, null
  br i1 %again, label %out, label %make
make:
  ; DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2 = -4
  %dpi = call i32 @SetProcessDpiAwarenessContext(ptr inttoptr (i64 -4 to ptr))
  %inst = call ptr @GetModuleHandleA(ptr null)
  ; WNDCLASSEXA: cbSize 0, style 4, lpfnWndProc 8, hInstance 24, hCursor 40, lpszClassName 64
  call void @llvm.memset.p0.i64(ptr %wc, i8 0, i64 80, i1 false)
  store i32 80, ptr %wc
  %wst = getelementptr i8, ptr %wc, i64 4
  store i32 35, ptr %wst                        ; CS_OWNDC | CS_HREDRAW | CS_VREDRAW
  %wwp = getelementptr i8, ptr %wc, i64 8
  store ptr @ludic_wndproc, ptr %wwp
  %whi = getelementptr i8, ptr %wc, i64 24
  store ptr %inst, ptr %whi
  %arrow = call ptr @LoadCursorA(ptr null, ptr inttoptr (i64 32512 to ptr))   ; IDC_ARROW
  %whc = getelementptr i8, ptr %wc, i64 40
  store ptr %arrow, ptr %whc
  %wcn = getelementptr i8, ptr %wc, i64 64
  store ptr @.w_class, ptr %wcn
  %atom = call i16 @RegisterClassExA(ptr %wc)
  ; the client area is w*scale x h*scale pixels; the frame goes round it
  %pw = mul i32 %w, %scale
  %ph = mul i32 %h, %scale
  call void @llvm.memset.p0.i64(ptr %rc, i8 0, i64 16, i1 false)
  %rcr = getelementptr i8, ptr %rc, i64 8
  store i32 %pw, ptr %rcr
  %rcb = getelementptr i8, ptr %rc, i64 12
  store i32 %ph, ptr %rcb
  %adj = call i32 @AdjustWindowRectEx(ptr %rc, i32 13565952, i32 0, i32 0)   ; WS_OVERLAPPEDWINDOW
  %rl = load i32, ptr %rc
  %rtp = getelementptr i8, ptr %rc, i64 4
  %rt = load i32, ptr %rtp
  %rr = load i32, ptr %rcr
  %rb = load i32, ptr %rcb
  %ww = sub i32 %rr, %rl
  %wh = sub i32 %rb, %rt
  ; centred on the primary display
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
  ; WS_OVERLAPPEDWINDOW | WS_VISIBLE
  %hwnd = call ptr @CreateWindowExA(i32 0, ptr @.w_class, ptr %title, i32 282001408, i32 %x, i32 %y, i32 %ww, i32 %wh, ptr null, ptr null, ptr %inst, ptr null)
  %nowin = icmp eq ptr %hwnd, null
  br i1 %nowin, label %out, label %show
show:
  store ptr %hwnd, ptr @W_hwnd
  %hdc = call ptr @GetDC(ptr %hwnd)
  store ptr %hdc, ptr @W_hdc
  %s1 = call i32 @ShowWindow(ptr %hwnd, i32 5)   ; SW_SHOW
  %s2 = call i32 @SetForegroundWindow(ptr %hwnd)
  ; RAWINPUTDEVICE { usUsagePage 1, usUsage 2 (mouse), dwFlags 0, hwndTarget }: the raw
  ; motion cursor mode 2 turns into mouse_dx / mouse_dy
  call void @llvm.memset.p0.i64(ptr %rid, i8 0, i64 16, i1 false)
  store i16 1, ptr %rid
  %ru = getelementptr i8, ptr %rid, i64 2
  store i16 2, ptr %ru
  %rh = getelementptr i8, ptr %rid, i64 8
  store ptr %hwnd, ptr %rh
  %reg = call i32 @RegisterRawInputDevices(ptr %rid, i32 1, i32 16)
  store i32 1, ptr @W_running
  br label %out
out:
  ret void
}

; set (%on != 0) or clear a key's bit in the 256-bit held set
define void @win_held_bit(i32 %k, i32 %on) {
entry:
  %lo = icmp slt i32 %k, 0
  %hi = icmp sgt i32 %k, 255
  %oob = or i1 %lo, %hi
  br i1 %oob, label %ret, label %go
go:
  %w = ashr i32 %k, 5
  %b = and i32 %k, 31
  %m = shl i32 1, %b
  %p = getelementptr [8 x i32], ptr @W_held, i32 0, i32 %w
  %cur = load i32, ptr %p
  %onb = icmp ne i32 %on, 0
  br i1 %onb, label %set, label %clr
set:
  %sv = or i32 %cur, %m
  store i32 %sv, ptr %p
  br label %ret
clr:
  %nm = xor i32 %m, -1
  %cv = and i32 %cur, %nm
  store i32 %cv, ptr %p
  br label %ret
ret:
  ret void
}

; the unshifted character a virtual key types, 0 for none (F-keys, Home, ...)
define internal i32 @w_vk_char(i32 %vk) {
entry:
  %c = call i32 @MapVirtualKeyA(i32 %vk, i32 2)  ; MAPVK_VK_TO_CHAR; the top bit marks a dead key
  %c7 = and i32 %c, 32767
  ret i32 %c7
}

; the held-set code of a virtual key (cocoa.ll's ev_keyval)
define internal i32 @w_keyval(i64 %vk64) {
entry:
  %vk = trunc i64 %vk64 to i32
  switch i32 %vk, label %chars [
    i32 38, label %up
    i32 40, label %down
    i32 37, label %left
    i32 39, label %right
    i32 32, label %space
    i32 13, label %enter
    i32 27, label %esc
    i32 16, label %shift
    i32 17, label %ctrl
    i32 18, label %alt
    i32 8,  label %bksp
    i32 9,  label %tab
  ]
up:    ret i32 128
down:  ret i32 129
left:  ret i32 130
right: ret i32 131
space: ret i32 32
enter: ret i32 10
esc:   ret i32 27
shift: ret i32 16
ctrl:  ret i32 17
alt:   ret i32 18
bksp:  ret i32 8
tab:   ret i32 9
chars:
  %c = call i32 @w_vk_char(i32 %vk)
  ; the held set is keyed by the key, not the case: fold A-Z (Shift is its own code)
  %isA = icmp sge i32 %c, 65
  %isZ = icmp sle i32 %c, 90
  %upper = and i1 %isA, %isZ
  %lower = add i32 %c, 32
  %f = select i1 %upper, i32 %lower, i32 %c
  ret i32 %f
}

; the frame key of a virtual key (cocoa.ll's win_poll): arrows as wasd, a letter in the
; case Shift gives it, and 0 for a key that types nothing
define internal i32 @w_framekey(i64 %vk64) {
entry:
  %vk = trunc i64 %vk64 to i32
  switch i32 %vk, label %chars [
    i32 38, label %up
    i32 40, label %down
    i32 37, label %left
    i32 39, label %right
    i32 32, label %space
    i32 13, label %enter
    i32 27, label %esc
    i32 16, label %none
    i32 17, label %none
    i32 18, label %none
  ]
up:    ret i32 119
down:  ret i32 115
left:  ret i32 97
right: ret i32 100
space: ret i32 32
enter: ret i32 10
esc:   ret i32 27
none:  ret i32 0
chars:
  %c = call i32 @w_vk_char(i32 %vk)
  %isA = icmp sge i32 %c, 65
  %isZ = icmp sle i32 %c, 90
  %upper = and i1 %isA, %isZ
  %ks = call i16 @GetKeyState(i32 16)
  %shifted = icmp slt i16 %ks, 0
  %keepup = and i1 %upper, %shifted
  %fold = xor i1 %keepup, true
  %dofold = and i1 %upper, %fold
  %lower = add i32 %c, 32
  %f = select i1 %dofold, i32 %lower, i32 %c
  ret i32 %f
}

; Drain the message queue: keys, buttons, the wheel and raw motion are read here,
; everything else is dispatched to the window procedure. Returns the frame key.
define i32 @win_poll() {
entry:
  %msg = alloca [48 x i8], align 8               ; MSG: message 8, wParam 16, lParam 24
  %rbuf = alloca [48 x i8], align 8              ; RAWINPUT (mouse): header 24, RAWMOUSE 24
  %rsz = alloca i32, align 4
  store i32 0, ptr @W_key
  %hwnd = load ptr, ptr @W_hwnd
  %nohwnd = icmp eq ptr %hwnd, null
  br i1 %nohwnd, label %done, label %pump
pump:
  %got = call i32 @PeekMessageA(ptr %msg, ptr null, i32 0, i32 0, i32 1)   ; PM_REMOVE
  %any = icmp ne i32 %got, 0
  br i1 %any, label %handle, label %finish
handle:
  %mp = getelementptr i8, ptr %msg, i64 8
  %m = load i32, ptr %mp
  %wpp = getelementptr i8, ptr %msg, i64 16
  %wp = load i64, ptr %wpp
  %lpp = getelementptr i8, ptr %msg, i64 24
  %lp = load i64, ptr %lpp
  switch i32 %m, label %dispatch [
    i32 256, label %kdown                         ; WM_KEYDOWN
    i32 260, label %kdown                         ; WM_SYSKEYDOWN
    i32 257, label %kup                           ; WM_KEYUP
    i32 261, label %kup                           ; WM_SYSKEYUP
    i32 513, label %ldown                         ; WM_LBUTTONDOWN
    i32 514, label %lup                           ; WM_LBUTTONUP
    i32 516, label %rdown                         ; WM_RBUTTONDOWN
    i32 517, label %rup                           ; WM_RBUTTONUP
    i32 522, label %wheel                         ; WM_MOUSEWHEEL
    i32 255, label %raw                           ; WM_INPUT
  ]
kdown:
  %hv = call i32 @w_keyval(i64 %wp)
  call void @win_held_bit(i32 %hv, i32 1)
  %isf4 = icmp eq i64 %wp, 115                    ; VK_F4
  %issys = icmp eq i32 %m, 260
  %altf4 = and i1 %isf4, %issys
  br i1 %altf4, label %quit, label %fkey
quit:
  store i32 0, ptr @W_running
  br label %pump
fkey:
  %fk = call i32 @w_framekey(i64 %wp)
  %hasfk = icmp ne i32 %fk, 0
  br i1 %hasfk, label %setfk, label %pump
setfk:
  store i32 %fk, ptr @W_key
  br label %pump
kup:
  %uv = call i32 @w_keyval(i64 %wp)
  call void @win_held_bit(i32 %uv, i32 0)
  br label %pump
ldown:
  %lb = load i32, ptr @W_mbtn
  %lb2 = or i32 %lb, 1
  store i32 %lb2, ptr @W_mbtn
  %cap1 = call ptr @SetCapture(ptr %hwnd)         ; so the release is seen outside the window too
  br label %dispatch
lup:
  %lc = load i32, ptr @W_mbtn
  %lc2 = and i32 %lc, -2
  store i32 %lc2, ptr @W_mbtn
  br label %release
rdown:
  %rbn = load i32, ptr @W_mbtn
  %rbn2 = or i32 %rbn, 2
  store i32 %rbn2, ptr @W_mbtn
  %cap2 = call ptr @SetCapture(ptr %hwnd)
  br label %dispatch
rup:
  %rcn = load i32, ptr @W_mbtn
  %rcn2 = and i32 %rcn, -3
  store i32 %rcn2, ptr @W_mbtn
  br label %release
release:
  %still = load i32, ptr @W_mbtn
  %nobtn = icmp eq i32 %still, 0
  br i1 %nobtn, label %uncap, label %dispatch
uncap:
  %rel = call i32 @ReleaseCapture()
  br label %dispatch
wheel:
  ; the high word of wParam is the signed delta, 120 to a notch, positive away from the user
  %hiw = lshr i64 %wp, 16
  %d16 = trunc i64 %hiw to i16
  %d32 = sext i16 %d16 to i32
  %notches = sdiv i32 %d32, 120
  %wv = load i32, ptr @W_wheel
  %wv2 = add i32 %wv, %notches
  store i32 %wv2, ptr @W_wheel
  br label %pump
raw:
  %hraw = inttoptr i64 %lp to ptr
  store i32 48, ptr %rsz
  %n = call i32 @GetRawInputData(ptr %hraw, i32 268435459, ptr %rbuf, ptr %rsz, i32 24)   ; RID_INPUT
  %okn = icmp sgt i32 %n, 43
  br i1 %okn, label %rawtype, label %dispatch
rawtype:
  %rtype = load i32, ptr %rbuf
  %ismouse = icmp eq i32 %rtype, 0                ; RIM_TYPEMOUSE
  %flp = getelementptr i8, ptr %rbuf, i64 24
  %fl = load i16, ptr %flp
  %abs = and i16 %fl, 1                           ; MOUSE_MOVE_ABSOLUTE (a tablet, a remote desktop)
  %isrel = icmp eq i16 %abs, 0
  %use = and i1 %ismouse, %isrel
  br i1 %use, label %rawadd, label %dispatch
rawadd:
  %rxp = getelementptr i8, ptr %rbuf, i64 36
  %rx = load i32, ptr %rxp
  %ryp = getelementptr i8, ptr %rbuf, i64 40
  %ry = load i32, ptr %ryp
  %ax = load i32, ptr @W_rawdx
  %ax2 = add i32 %ax, %rx
  store i32 %ax2, ptr @W_rawdx
  %ay = load i32, ptr @W_rawdy
  %ay2 = add i32 %ay, %ry
  store i32 %ay2, ptr @W_rawdy
  br label %dispatch
dispatch:
  %dm = call i64 @DispatchMessageA(ptr %msg)
  br label %pump
finish:
  call void @win_cursor_maintain()
  %alive = call i32 @IsWindow(ptr %hwnd)
  %dead = icmp eq i32 %alive, 0
  br i1 %dead, label %closed, label %done
closed:
  store i32 0, ptr @W_running
  br label %done
done:
  %k = load i32, ptr @W_key
  ret i32 %k
}

; A software framebuffer: w*h words of 0x00RRGGBB, row 0 at the top - which is
; exactly a top-down 32-bit DIB, so StretchDIBits takes it as it is.
define void @win_present(ptr %fb, i32 %w, i32 %h) {
entry:
  %bmi = alloca [44 x i8], align 4
  store ptr %fb, ptr @W_fb
  %hdc = load ptr, ptr @W_hdc
  %nodc = icmp eq ptr %hdc, null
  br i1 %nodc, label %out, label %draw
draw:
  ; BITMAPINFOHEADER: biSize 40, biWidth, biHeight negative (top-down), 1 plane, 32 bpp, BI_RGB
  call void @llvm.memset.p0.i64(ptr %bmi, i8 0, i64 44, i1 false)
  store i32 40, ptr %bmi
  %bw = getelementptr i8, ptr %bmi, i64 4
  store i32 %w, ptr %bw
  %nh = sub i32 0, %h
  %bh = getelementptr i8, ptr %bmi, i64 8
  store i32 %nh, ptr %bh
  %bp = getelementptr i8, ptr %bmi, i64 12
  store i16 1, ptr %bp
  %bb = getelementptr i8, ptr %bmi, i64 14
  store i16 32, ptr %bb
  %sc = load i32, ptr @W_scale
  %dw = mul i32 %w, %sc
  %dh = mul i32 %h, %sc
  %r = call i32 @StretchDIBits(ptr %hdc, i32 0, i32 0, i32 %dw, i32 %dh, i32 0, i32 0, i32 %w, i32 %h, ptr %fb, ptr %bmi, i32 0, i32 13369376)   ; DIB_RGB_COLORS, SRCCOPY
  call void @Sleep(i32 16)                        ; ~60 fps, as cocoa.ll's usleep
  br label %out
out:
  ret void
}

define i32 @win_running() {
entry:
  %r = load i32, ptr @W_running
  ret i32 %r
}

define void @win_close() {
entry:
  store i32 0, ptr @W_cursor_mode
  call void @win_cursor_maintain()
  store i32 0, ptr @W_running
  ret void
}

define void @win_held(ptr %out) {
entry:
  br label %loop
loop:
  %i = phi i32 [ 0, %entry ], [ %ni, %body ]
  %done = icmp sge i32 %i, 8
  br i1 %done, label %ret, label %body
body:
  %sp = getelementptr [8 x i32], ptr @W_held, i32 0, i32 %i
  %v = load i32, ptr %sp
  %dp = getelementptr i32, ptr %out, i32 %i
  store i32 %v, ptr %dp
  %ni = add i32 %i, 1
  br label %loop
ret:
  ret void
}

; [x, y, buttons, wheel, raw dx, raw dy]; the wheel and the raw motion are per call
define void @win_mouse(ptr %out) {
entry:
  %pt = alloca [8 x i8], align 4
  %mode = load i32, ptr @W_cursor_mode
  %isrel = icmp eq i32 %mode, 2
  %ddx = load i32, ptr @W_rawdx
  %ddy = load i32, ptr @W_rawdy
  store i32 0, ptr @W_rawdx
  store i32 0, ptr @W_rawdy
  %fbw = load i32, ptr @W_fbw
  %fbh = load i32, ptr @W_fbh
  %fbwm = sub i32 %fbw, 1
  %fbhm = sub i32 %fbh, 1
  br i1 %isrel, label %rel, label %abs
rel:
  ; locked: the OS cursor is held still, so the position is a virtual one moved by the
  ; raw motion and clamped to the framebuffer; the motion itself is reported unclamped
  %omx = load i32, ptr @W_mx
  %omy = load i32, ptr @W_my
  %nmx = add i32 %omx, %ddx
  %nmy = add i32 %omy, %ddy
  %p4r = getelementptr i32, ptr %out, i32 4
  store i32 %ddx, ptr %p4r
  %p5r = getelementptr i32, ptr %out, i32 5
  store i32 %ddy, ptr %p5r
  br label %clamp
abs:
  %p4a = getelementptr i32, ptr %out, i32 4
  store i32 0, ptr %p4a
  %p5a = getelementptr i32, ptr %out, i32 5
  store i32 0, ptr %p5a
  %hwnd = load ptr, ptr @W_hwnd
  %nowin = icmp eq ptr %hwnd, null
  br i1 %nowin, label %emit, label %qpos
qpos:
  %g = call i32 @GetCursorPos(ptr %pt)
  %s = call i32 @ScreenToClient(ptr %hwnd, ptr %pt)
  %cx = load i32, ptr %pt
  %cyp = getelementptr i8, ptr %pt, i64 4
  %cy = load i32, ptr %cyp
  %sc = load i32, ptr @W_scale
  %sc0 = icmp slt i32 %sc, 1
  %scv = select i1 %sc0, i32 1, i32 %sc
  %ax = sdiv i32 %cx, %scv
  %ay = sdiv i32 %cy, %scv
  br label %clamp
clamp:
  %ux = phi i32 [ %nmx, %rel ], [ %ax, %qpos ]
  %uy = phi i32 [ %nmy, %rel ], [ %ay, %qpos ]
  %xlo = icmp slt i32 %ux, 0
  %x1 = select i1 %xlo, i32 0, i32 %ux
  %xhi = icmp sgt i32 %x1, %fbwm
  %x2 = select i1 %xhi, i32 %fbwm, i32 %x1
  %ylo = icmp slt i32 %uy, 0
  %y1 = select i1 %ylo, i32 0, i32 %uy
  %yhi = icmp sgt i32 %y1, %fbhm
  %y2 = select i1 %yhi, i32 %fbhm, i32 %y1
  store i32 %x2, ptr @W_mx
  store i32 %y2, ptr @W_my
  br label %emit
emit:
  %mx = load i32, ptr @W_mx
  store i32 %mx, ptr %out
  %my = load i32, ptr @W_my
  %p1 = getelementptr i32, ptr %out, i32 1
  store i32 %my, ptr %p1
  %mb = load i32, ptr @W_mbtn
  %p2 = getelementptr i32, ptr %out, i32 2
  store i32 %mb, ptr %p2
  %wh = load i32, ptr @W_wheel
  %p3 = getelementptr i32, ptr %out, i32 3
  store i32 %wh, ptr %p3
  store i32 0, ptr @W_wheel
  ret void
}

; ---- the cursor ----------------------------------------------------------------
define internal void @w_cursor_hide(i32 %want) {
entry:
  %cur = load i32, ptr @W_cursor_hidden
  %same = icmp eq i32 %cur, %want
  br i1 %same, label %out, label %change
change:
  store i32 %want, ptr @W_cursor_hidden
  %hide = icmp ne i32 %want, 0
  br i1 %hide, label %none, label %arrow
none:
  %c0 = call ptr @SetCursor(ptr null)
  br label %out
arrow:
  %a = call ptr @LoadCursorA(ptr null, ptr inttoptr (i64 32512 to ptr))
  %c1 = call ptr @SetCursor(ptr %a)
  br label %out
out:
  ret void
}

; Re-derive the cursor from the mode and whether this window is in front, every frame:
; hidden for modes 1-3, held to the window's centre for 2, to its client area for 3,
; and all of it let go the moment another window comes forward. ClipCursor is global,
; so it is only released when this window was the one that set it.
define void @win_cursor_maintain() {
entry:
  %rc = alloca [16 x i8], align 4
  %hwnd = load ptr, ptr @W_hwnd
  %nowin = icmp eq ptr %hwnd, null
  br i1 %nowin, label %release, label %askfg
askfg:
  %fg = call ptr @GetForegroundWindow()
  %front = icmp eq ptr %fg, %hwnd
  br i1 %front, label %keyed, label %release
release:
  call void @w_cursor_hide(i32 0)
  %was = load i32, ptr @W_clipped
  %clipped = icmp ne i32 %was, 0
  br i1 %clipped, label %unclip, label %out
unclip:
  %u = call i32 @ClipCursor(ptr null)
  store i32 0, ptr @W_clipped
  br label %out
keyed:
  %mode = load i32, ptr @W_cursor_mode
  %any = icmp ne i32 %mode, 0
  %anyi = zext i1 %any to i32
  call void @w_cursor_hide(i32 %anyi)
  %is2 = icmp eq i32 %mode, 2
  %is3 = icmp eq i32 %mode, 3
  %holds = or i1 %is2, %is3
  br i1 %holds, label %rect, label %free
free:
  %fwas = load i32, ptr @W_clipped
  %fclipped = icmp ne i32 %fwas, 0
  br i1 %fclipped, label %unclip, label %out
rect:
  %gc = call i32 @GetClientRect(ptr %hwnd, ptr %rc)
  %tl = call i32 @ClientToScreen(ptr %hwnd, ptr %rc)
  %brp = getelementptr i8, ptr %rc, i64 8
  %br = call i32 @ClientToScreen(ptr %hwnd, ptr %brp)
  br i1 %is2, label %centre, label %clip
centre:
  %l = load i32, ptr %rc
  %tp = getelementptr i8, ptr %rc, i64 4
  %t = load i32, ptr %tp
  %r = load i32, ptr %brp
  %bp = getelementptr i8, ptr %rc, i64 12
  %b = load i32, ptr %bp
  %lr = add i32 %l, %r
  %cx = sdiv i32 %lr, 2
  %tb = add i32 %t, %b
  %cy = sdiv i32 %tb, 2
  %cx1 = add i32 %cx, 1
  %cy1 = add i32 %cy, 1
  store i32 %cx, ptr %rc
  store i32 %cy, ptr %tp
  store i32 %cx1, ptr %brp
  store i32 %cy1, ptr %bp
  br label %clip
clip:
  %cc = call i32 @ClipCursor(ptr %rc)
  store i32 1, ptr @W_clipped
  br label %out
out:
  ret void
}

define void @win_cursor_mode(i32 %mode) {
entry:
  store i32 %mode, ptr @W_cursor_mode
  call void @win_cursor_maintain()
  ret void
}

; ---- gamepads, through XInput --------------------------------------------------
; A stick value past its deadzone, rescaled so the edge of the deadzone is 0.0 and
; full deflection is 1.0, as Q16.16 (GameController does the same before macOS sees it).
define internal i32 @w_axis(i16 %v, i32 %dz) {
entry:
  %s = sext i16 %v to i32
  %neg = icmp slt i32 %s, 0
  %ms = sub i32 0, %s
  %a = select i1 %neg, i32 %ms, i32 %s
  %inside = icmp sle i32 %a, %dz
  br i1 %inside, label %zero, label %scale
zero:
  ret i32 0
scale:
  %past = sub i32 %a, %dz
  %range = sub i32 32767, %dz
  %p64 = sext i32 %past to i64
  %m = mul i64 %p64, 65536
  %r64 = sext i32 %range to i64
  %q = sdiv i64 %m, %r64
  %q32 = trunc i64 %q to i32
  %big = icmp sgt i32 %q32, 65536
  %cl = select i1 %big, i32 65536, i32 %q32
  %mneg = sub i32 0, %cl
  %res = select i1 %neg, i32 %mneg, i32 %cl
  ret i32 %res
}

; bit %from of %bits, moved to bit %to
define internal i32 @w_bit(i32 %bits, i32 %from, i32 %to) {
entry:
  %s = lshr i32 %bits, %from
  %b = and i32 %s, 1
  %o = shl i32 %b, %to
  ret i32 %o
}

; [connected, mask, lx, ly, rx, ry] for pads 0-3. XINPUT_STATE: dwPacketNumber 0, then
; XINPUT_GAMEPAD at 4: wButtons 4, bLeftTrigger 6, bRightTrigger 7, sThumbLX 8, LY 10, RX 12, RY 14.
define void @win_pad(ptr %out) {
entry:
  %st = alloca [16 x i8], align 4
  call void @llvm.memset.p0.i64(ptr %out, i8 0, i64 96, i1 false)
  br label %loop
loop:
  %p = phi i32 [ 0, %entry ], [ %pn, %next ]
  %more = icmp slt i32 %p, 4
  br i1 %more, label %ask, label %done
ask:
  call void @llvm.memset.p0.i64(ptr %st, i8 0, i64 16, i1 false)
  %r = call i32 @XInputGetState(i32 %p, ptr %st)
  %conn = icmp eq i32 %r, 0                       ; ERROR_SUCCESS
  br i1 %conn, label %pack, label %next
pack:
  %base = mul i32 %p, 6
  %o0 = getelementptr i32, ptr %out, i32 %base
  store i32 1, ptr %o0
  %btp = getelementptr i8, ptr %st, i64 4
  %bt16 = load i16, ptr %btp
  %bt = zext i16 %bt16 to i32
  ; XInput bits -> SDL order: A B X Y Back . Start LStick RStick LShoulder RShoulder Up Down Left Right
  %mA  = call i32 @w_bit(i32 %bt, i32 12, i32 0)
  %mB  = call i32 @w_bit(i32 %bt, i32 13, i32 1)
  %mX  = call i32 @w_bit(i32 %bt, i32 14, i32 2)
  %mY  = call i32 @w_bit(i32 %bt, i32 15, i32 3)
  %mBk = call i32 @w_bit(i32 %bt, i32 5,  i32 4)
  %mSt = call i32 @w_bit(i32 %bt, i32 4,  i32 6)
  %mLs = call i32 @w_bit(i32 %bt, i32 6,  i32 7)
  %mRs = call i32 @w_bit(i32 %bt, i32 7,  i32 8)
  %mLb = call i32 @w_bit(i32 %bt, i32 8,  i32 9)
  %mRb = call i32 @w_bit(i32 %bt, i32 9,  i32 10)
  %mU  = call i32 @w_bit(i32 %bt, i32 0,  i32 11)
  %mD  = call i32 @w_bit(i32 %bt, i32 1,  i32 12)
  %mL  = call i32 @w_bit(i32 %bt, i32 2,  i32 13)
  %mR  = call i32 @w_bit(i32 %bt, i32 3,  i32 14)
  ; the triggers are analogue; past XINPUT_GAMEPAD_TRIGGER_THRESHOLD (30) they are pressed
  %ltp = getelementptr i8, ptr %st, i64 6
  %lt8 = load i8, ptr %ltp
  %lt = zext i8 %lt8 to i32
  %ltd = icmp sgt i32 %lt, 30
  %ltb = zext i1 %ltd to i32
  %mLt = shl i32 %ltb, 15
  %rtp = getelementptr i8, ptr %st, i64 7
  %rt8 = load i8, ptr %rtp
  %rt = zext i8 %rt8 to i32
  %rtd = icmp sgt i32 %rt, 30
  %rtb = zext i1 %rtd to i32
  %mRt = shl i32 %rtb, 16
  %k1 = or i32 %mA, %mB
  %k2 = or i32 %k1, %mX
  %k3 = or i32 %k2, %mY
  %k4 = or i32 %k3, %mBk
  %k5 = or i32 %k4, %mSt
  %k6 = or i32 %k5, %mLs
  %k7 = or i32 %k6, %mRs
  %k8 = or i32 %k7, %mLb
  %k9 = or i32 %k8, %mRb
  %k10 = or i32 %k9, %mU
  %k11 = or i32 %k10, %mD
  %k12 = or i32 %k11, %mL
  %k13 = or i32 %k12, %mR
  %k14 = or i32 %k13, %mLt
  %mask = or i32 %k14, %mRt
  %i1 = add i32 %base, 1
  %o1 = getelementptr i32, ptr %out, i32 %i1
  store i32 %mask, ptr %o1
  ; XINPUT_GAMEPAD_LEFT_THUMB_DEADZONE 7849, RIGHT 8689; XInput's Y is up, Ludic's is down
  %lxp = getelementptr i8, ptr %st, i64 8
  %lxv = load i16, ptr %lxp
  %lx = call i32 @w_axis(i16 %lxv, i32 7849)
  %i2 = add i32 %base, 2
  %o2 = getelementptr i32, ptr %out, i32 %i2
  store i32 %lx, ptr %o2
  %lyp = getelementptr i8, ptr %st, i64 10
  %lyv = load i16, ptr %lyp
  %lyu = call i32 @w_axis(i16 %lyv, i32 7849)
  %ly = sub i32 0, %lyu
  %i3 = add i32 %base, 3
  %o3 = getelementptr i32, ptr %out, i32 %i3
  store i32 %ly, ptr %o3
  %rxp = getelementptr i8, ptr %st, i64 12
  %rxv = load i16, ptr %rxp
  %rx = call i32 @w_axis(i16 %rxv, i32 8689)
  %i4 = add i32 %base, 4
  %o4 = getelementptr i32, ptr %out, i32 %i4
  store i32 %rx, ptr %o4
  %ryp = getelementptr i8, ptr %st, i64 14
  %ryv = load i16, ptr %ryp
  %ryu = call i32 @w_axis(i16 %ryv, i32 8689)
  %ry = sub i32 0, %ryu
  %i5 = add i32 %base, 5
  %o5 = getelementptr i32, ptr %out, i32 %i5
  store i32 %ry, ptr %o5
  br label %next
next:
  %pn = add i32 %p, 1
  br label %loop
done:
  ret void
}

; Touch: a Windows PC reports its touchpad as a mouse, so there are no points.
define void @win_touch(ptr %out) {
entry:
  call void @llvm.memset.p0.i64(ptr %out, i8 0, i64 96, i1 false)
  ret void
}

; ---- the splash and the icon ---------------------------------------------------
; Not yet: both need an image decoder (WIC), and on Windows the icon a player sees on
; the taskbar and in Explorer is the one linked into the .exe, which `ludic bundle`
; will do. Until then these keep the contract - safe to call, change nothing.
define void @splash_show(ptr %bytes, i32 %len, i32 %bg) {
entry:
  ret void
}
define void @splash_hide() {
entry:
  ret void
}
define void @app_set_icon(ptr %bytes, i32 %len) {
entry:
  ret void
}
