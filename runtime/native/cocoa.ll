; ============================================================================
; cocoa.ll — the macOS window, written in LLVM IR.
;
; This is what replaced plat_cocoa.m. There is no Objective-C source and no C
; source in a Ludic build: the window is opened by talking to the Objective-C
; runtime through its C ABI (objc_getClass / sel_registerName / objc_msgSend)
; and to Quartz through CoreGraphics, exactly as a compiled .m file would, only
; written at the level ludicc itself emits. ludicc splices this module in when
; it links a windowed macOS binary.
;
; The one piece that genuinely needs a class is the view: AppKit paints through
; -drawRect:, so a class is built at runtime with objc_allocateClassPair and
; @ludic_drawRect is installed as its IMP. On arm64 the unused NSRect argument
; simply stays in registers we never read, so the IMP needs no struct in its
; signature.
;
; Exposed to Ludic (through the win_* intrinsics):
;   win_open(w, h, scale, title)  win_poll() -> key   win_present(fb, w, h)
;   win_running() -> bool         win_close()
; ============================================================================

%CGRect = type { double, double, double, double }

declare ptr @objc_getClass(ptr)
declare ptr @sel_registerName(ptr)
declare ptr @objc_msgSend(ptr, ptr, ...)
declare ptr @objc_allocateClassPair(ptr, ptr, i64)
declare void @objc_registerClassPair(ptr)
declare i8 @class_addMethod(ptr, ptr, ptr, ptr)
declare ptr @CGColorSpaceCreateDeviceRGB()
declare ptr @CGBitmapContextCreate(ptr, i64, i64, i64, i64, ptr, i32)
declare ptr @CGBitmapContextCreateImage(ptr)
declare void @CGContextDrawImage(ptr, %CGRect, ptr)
declare void @CGContextSetInterpolationQuality(ptr, i32)
declare void @CGContextTranslateCTM(ptr, double, double)
declare void @CGContextScaleCTM(ptr, double, double)
declare void @CGContextSaveGState(ptr)
declare void @CGContextRestoreGState(ptr)
declare void @CGImageRelease(ptr)
declare void @CGContextRelease(ptr)
declare void @CGColorSpaceRelease(ptr)
declare i32 @usleep(i32)

@.c_app    = private unnamed_addr constant [14 x i8] c"NSApplication\00"
@.c_win    = private unnamed_addr constant [9 x i8]  c"NSWindow\00"
@.c_str    = private unnamed_addr constant [9 x i8]  c"NSString\00"
@.c_date   = private unnamed_addr constant [7 x i8]  c"NSDate\00"
@.c_view   = private unnamed_addr constant [7 x i8]  c"NSView\00"
@.c_gctx   = private unnamed_addr constant [18 x i8] c"NSGraphicsContext\00"
@.c_ludic  = private unnamed_addr constant [10 x i8] c"LudicView\00"

@.s_shared = private unnamed_addr constant [18 x i8] c"sharedApplication\00"
@.s_policy = private unnamed_addr constant [21 x i8] c"setActivationPolicy:\00"
@.s_alloc  = private unnamed_addr constant [6 x i8]  c"alloc\00"
@.s_initw  = private unnamed_addr constant [45 x i8] c"initWithContentRect:styleMask:backing:defer:\00"
@.s_initf  = private unnamed_addr constant [15 x i8] c"initWithFrame:\00"
@.s_title  = private unnamed_addr constant [10 x i8] c"setTitle:\00"
@.s_utf8   = private unnamed_addr constant [22 x i8] c"stringWithUTF8String:\00"
@.s_setcv  = private unnamed_addr constant [16 x i8] c"setContentView:\00"
@.s_center = private unnamed_addr constant [7 x i8]  c"center\00"
@.s_mkey   = private unnamed_addr constant [22 x i8] c"makeKeyAndOrderFront:\00"
@.s_mfirst = private unnamed_addr constant [20 x i8] c"makeFirstResponder:\00"
@.s_act    = private unnamed_addr constant [27 x i8] c"activateIgnoringOtherApps:\00"
@.s_next   = private unnamed_addr constant [48 x i8] c"nextEventMatchingMask:untilDate:inMode:dequeue:\00"
@.s_send   = private unnamed_addr constant [11 x i8] c"sendEvent:\00"
@.s_dpast  = private unnamed_addr constant [12 x i8] c"distantPast\00"
@.s_type   = private unnamed_addr constant [5 x i8]  c"type\00"
@.s_keycd  = private unnamed_addr constant [8 x i8]  c"keyCode\00"
@.s_chars  = private unnamed_addr constant [28 x i8] c"charactersIgnoringModifiers\00"
@.s_length = private unnamed_addr constant [7 x i8]  c"length\00"
@.s_charat = private unnamed_addr constant [18 x i8] c"characterAtIndex:\00"
@.s_locwin = private unnamed_addr constant [17 x i8] c"locationInWindow\00"
@.s_scrly  = private unnamed_addr constant [16 x i8] c"scrollingDeltaY\00"
@.s_disp   = private unnamed_addr constant [8 x i8]  c"display\00"
@.s_visib  = private unnamed_addr constant [10 x i8] c"isVisible\00"
@.s_curctx = private unnamed_addr constant [15 x i8] c"currentContext\00"
@.s_cgctx  = private unnamed_addr constant [10 x i8] c"CGContext\00"
@.s_drawr  = private unnamed_addr constant [10 x i8] c"drawRect:\00"
@.s_afr    = private unnamed_addr constant [23 x i8] c"acceptsFirstResponder\00\00"
@.mode     = private unnamed_addr constant [22 x i8] c"kCFRunLoopDefaultMode\00"
@.enc_draw = private unnamed_addr constant [36 x i8] c"v@:{CGRect={CGPoint=dd}{CGSize=dd}}\00"
@.enc_bool = private unnamed_addr constant [4 x i8]  c"c@:\00"

@W_app     = internal global ptr null
@W_win     = internal global ptr null
@W_view    = internal global ptr null
@W_fb      = internal global ptr null
@W_fbw     = internal global i32 320
@W_fbh     = internal global i32 240
@W_scale   = internal global i32 3
@W_key     = internal global i32 0
@W_running = internal global i32 1
; #50 device layer — a 256-bit held-key set (8 i32) tracked from keyDown/keyUp,
; and the mouse state (position, button mask, per-frame wheel delta).
@W_held    = internal global [8 x i32] zeroinitializer
@W_mx      = internal global i32 0
@W_my      = internal global i32 0
@W_mbtn    = internal global i32 0
@W_wheel   = internal global i32 0

; -drawRect: — blit the framebuffer into the view.
; The NSRect argument is ignored, so it never appears in this signature.
define internal void @ludic_drawRect(ptr %self, ptr %sel) {
entry:
  %fb = load ptr, ptr @W_fb
  %null = icmp eq ptr %fb, null
  br i1 %null, label %out, label %draw
draw:
  %w32 = load i32, ptr @W_fbw
  %h32 = load i32, ptr @W_fbh
  %sc32 = load i32, ptr @W_scale
  %w = sext i32 %w32 to i64
  %h = sext i32 %h32 to i64
  %stride = mul i64 %w, 4

  %cs = call ptr @CGColorSpaceCreateDeviceRGB()
  ; kCGImageAlphaNoneSkipFirst (6) | kCGBitmapByteOrder32Little (8192)
  %bmp = call ptr @CGBitmapContextCreate(ptr %fb, i64 %w, i64 %h, i64 8, i64 %stride, ptr %cs, i32 8198)
  %img = call ptr @CGBitmapContextCreateImage(ptr %bmp)

  %gcls = call ptr @objc_getClass(ptr @.c_gctx)
  %sel_cur = call ptr @sel_registerName(ptr @.s_curctx)
  %gctx = call ptr @objc_msgSend(ptr %gcls, ptr %sel_cur)
  %sel_cg = call ptr @sel_registerName(ptr @.s_cgctx)
  %ctx = call ptr @objc_msgSend(ptr %gctx, ptr %sel_cg)

  call void @CGContextSetInterpolationQuality(ptr %ctx, i32 1)   ; kCGInterpolationNone
  %scd = sitofp i32 %sc32 to double
  %wd = sitofp i32 %w32 to double
  %hd = sitofp i32 %h32 to double
  %dw = fmul double %wd, %scd
  %dh = fmul double %hd, %scd

  ; The framebuffer's row 0 is the top row, and a CGImage built over it carries
  ; that orientation, so drawing it into the view's context lands right-side-up
  ; with no CTM flip. (Adding one here mirrors the game vertically — verified by
  ; drawing four different corners and looking at the window.)
  %r0 = insertvalue %CGRect undef, double 0.0, 0
  %r1 = insertvalue %CGRect %r0, double 0.0, 1
  %r2 = insertvalue %CGRect %r1, double %dw, 2
  %r3 = insertvalue %CGRect %r2, double %dh, 3
  call void @CGContextDrawImage(ptr %ctx, %CGRect %r3, ptr %img)

  call void @CGImageRelease(ptr %img)
  call void @CGContextRelease(ptr %bmp)
  call void @CGColorSpaceRelease(ptr %cs)
  br label %out
out:
  ret void
}

; -acceptsFirstResponder — so the view receives key events
define internal i8 @ludic_yes(ptr %self, ptr %sel) {
entry:
  ret i8 1
}

define void @win_open(i32 %w, i32 %h, i32 %scale, ptr %title) {
entry:
  store i32 %w, ptr @W_fbw
  store i32 %h, ptr @W_fbh
  store i32 %scale, ptr @W_scale

  %appcls = call ptr @objc_getClass(ptr @.c_app)
  %sel_sh = call ptr @sel_registerName(ptr @.s_shared)
  %app = call ptr @objc_msgSend(ptr %appcls, ptr %sel_sh)
  store ptr %app, ptr @W_app
  %sel_pol = call ptr @sel_registerName(ptr @.s_policy)
  %a1 = call ptr (ptr, ptr, i64) @objc_msgSend(ptr %app, ptr %sel_pol, i64 0)

  ; build the view class once: NSView + drawRect: + acceptsFirstResponder
  %viewsuper = call ptr @objc_getClass(ptr @.c_view)
  %cls = call ptr @objc_allocateClassPair(ptr %viewsuper, ptr @.c_ludic, i64 0)
  %sel_draw = call ptr @sel_registerName(ptr @.s_drawr)
  %m1 = call i8 @class_addMethod(ptr %cls, ptr %sel_draw, ptr @ludic_drawRect, ptr @.enc_draw)
  %sel_afr = call ptr @sel_registerName(ptr @.s_afr)
  %m2 = call i8 @class_addMethod(ptr %cls, ptr %sel_afr, ptr @ludic_yes, ptr @.enc_bool)
  call void @objc_registerClassPair(ptr %cls)

  %wd = sitofp i32 %w to double
  %hd = sitofp i32 %h to double
  %scd = sitofp i32 %scale to double
  %pw = fmul double %wd, %scd
  %ph = fmul double %hd, %scd
  %r0 = insertvalue %CGRect undef, double 0.0, 0
  %r1 = insertvalue %CGRect %r0, double 0.0, 1
  %r2 = insertvalue %CGRect %r1, double %pw, 2
  %rect = insertvalue %CGRect %r2, double %ph, 3

  %wincls = call ptr @objc_getClass(ptr @.c_win)
  %sel_alloc = call ptr @sel_registerName(ptr @.s_alloc)
  %w0 = call ptr @objc_msgSend(ptr %wincls, ptr %sel_alloc)
  %sel_initw = call ptr @sel_registerName(ptr @.s_initw)
  ; NSWindowStyleMaskTitled|Closable = 3, NSBackingStoreBuffered = 2
  %win = call ptr (ptr, ptr, %CGRect, i64, i64, i8) @objc_msgSend(ptr %w0, ptr %sel_initw, %CGRect %rect, i64 3, i64 2, i8 0)
  store ptr %win, ptr @W_win

  %strcls = call ptr @objc_getClass(ptr @.c_str)
  %sel_utf8 = call ptr @sel_registerName(ptr @.s_utf8)
  %nstitle = call ptr (ptr, ptr, ptr) @objc_msgSend(ptr %strcls, ptr %sel_utf8, ptr %title)
  %sel_title = call ptr @sel_registerName(ptr @.s_title)
  %a2 = call ptr (ptr, ptr, ptr) @objc_msgSend(ptr %win, ptr %sel_title, ptr %nstitle)

  %v0 = call ptr @objc_msgSend(ptr %cls, ptr %sel_alloc)
  %sel_initf = call ptr @sel_registerName(ptr @.s_initf)
  %view = call ptr (ptr, ptr, %CGRect) @objc_msgSend(ptr %v0, ptr %sel_initf, %CGRect %rect)
  store ptr %view, ptr @W_view
  %sel_setcv = call ptr @sel_registerName(ptr @.s_setcv)
  %a3 = call ptr (ptr, ptr, ptr) @objc_msgSend(ptr %win, ptr %sel_setcv, ptr %view)
  %sel_center = call ptr @sel_registerName(ptr @.s_center)
  %a4 = call ptr @objc_msgSend(ptr %win, ptr %sel_center)
  %sel_mkey = call ptr @sel_registerName(ptr @.s_mkey)
  %a5 = call ptr (ptr, ptr, ptr) @objc_msgSend(ptr %win, ptr %sel_mkey, ptr null)
  %sel_mfirst = call ptr @sel_registerName(ptr @.s_mfirst)
  %a6 = call ptr (ptr, ptr, ptr) @objc_msgSend(ptr %win, ptr %sel_mfirst, ptr %view)
  %sel_act = call ptr @sel_registerName(ptr @.s_act)
  %a7 = call ptr (ptr, ptr, i8) @objc_msgSend(ptr %app, ptr %sel_act, i8 1)
  ret void
}

; #50 — set (%on != 0) or clear a key's bit in the 256-bit held set @W_held.
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

; #50 — the ASCII value an NSEvent key event maps to (same mapping as win_poll's
; keyDown switch: arrows -> WASD, return, escape -> 'q', else the first character).
define i32 @ev_keyval(ptr %ev) {
entry:
  %sel_kc = call ptr @sel_registerName(ptr @.s_keycd)
  %kc = call i16 (ptr, ptr) @objc_msgSend(ptr %ev, ptr %sel_kc)
  %kc32 = zext i16 %kc to i32
  switch i32 %kc32, label %chars [
    i32 126, label %vw
    i32 125, label %vs
    i32 123, label %va
    i32 124, label %vd
    i32 49,  label %vspace
    i32 36,  label %vret
    i32 53,  label %vesc
  ]
vw:     ret i32 119
vs:     ret i32 115
va:     ret i32 97
vd:     ret i32 100
vspace: ret i32 32
vret:   ret i32 10
vesc:   ret i32 113
chars:
  %sel_ch = call ptr @sel_registerName(ptr @.s_chars)
  %sel_len = call ptr @sel_registerName(ptr @.s_length)
  %sel_cat = call ptr @sel_registerName(ptr @.s_charat)
  %s = call ptr (ptr, ptr) @objc_msgSend(ptr %ev, ptr %sel_ch)
  %cl = call i64 (ptr, ptr) @objc_msgSend(ptr %s, ptr %sel_len)
  %has = icmp sgt i64 %cl, 0
  br i1 %has, label %take, label %none
take:
  %c = call i16 (ptr, ptr, i64) @objc_msgSend(ptr %s, ptr %sel_cat, i64 0)
  %c32 = zext i16 %c to i32
  ret i32 %c32
none:
  ret i32 0
}

; Drain the event queue, remembering the last key pressed. Arrow keys map onto
; WASD and escape onto 'q', matching what the C backend did. #50: also track the
; held-key set (keyDown/keyUp) and the mouse (buttons, position, wheel).
define i32 @win_poll() {
entry:
  store i32 0, ptr @W_key
  %app = load ptr, ptr @W_app
  %none = icmp eq ptr %app, null
  br i1 %none, label %done, label %setup
setup:
  %sel_next = call ptr @sel_registerName(ptr @.s_next)
  %sel_send = call ptr @sel_registerName(ptr @.s_send)
  %sel_dp = call ptr @sel_registerName(ptr @.s_dpast)
  %sel_type = call ptr @sel_registerName(ptr @.s_type)
  %sel_kc = call ptr @sel_registerName(ptr @.s_keycd)
  %sel_ch = call ptr @sel_registerName(ptr @.s_chars)
  %sel_len = call ptr @sel_registerName(ptr @.s_length)
  %sel_cat = call ptr @sel_registerName(ptr @.s_charat)
  %sel_utf8 = call ptr @sel_registerName(ptr @.s_utf8)
  %datecls = call ptr @objc_getClass(ptr @.c_date)
  %strcls = call ptr @objc_getClass(ptr @.c_str)
  %mode = call ptr (ptr, ptr, ptr) @objc_msgSend(ptr %strcls, ptr %sel_utf8, ptr @.mode)
  br label %pump
pump:
  %date = call ptr @objc_msgSend(ptr %datecls, ptr %sel_dp)
  %ev = call ptr (ptr, ptr, i64, ptr, ptr, i8) @objc_msgSend(ptr %app, ptr %sel_next, i64 -1, ptr %date, ptr %mode, i8 1)
  %got = icmp ne ptr %ev, null
  br i1 %got, label %handle, label %finish
handle:
  %ty = call i64 (ptr, ptr) @objc_msgSend(ptr %ev, ptr %sel_type)
  %iskey = icmp eq i64 %ty, 10                 ; NSEventTypeKeyDown
  br i1 %iskey, label %key, label %notkey
notkey:
  %isup = icmp eq i64 %ty, 11                  ; NSEventTypeKeyUp
  br i1 %isup, label %keyup, label %mouse
keyup:                                          ; #50 — release the held key
  %uv = call i32 @ev_keyval(ptr %ev)
  call void @win_held_bit(i32 %uv, i32 0)
  br label %forward
mouse:                                          ; #50 — mouse buttons + wheel
  %ml_d = icmp eq i64 %ty, 1                    ; NSEventTypeLeftMouseDown
  br i1 %ml_d, label %lset, label %ml_u
lset:
  %lb = load i32, ptr @W_mbtn
  %lb2 = or i32 %lb, 1
  store i32 %lb2, ptr @W_mbtn
  br label %forward
ml_u:
  %ml_up = icmp eq i64 %ty, 2                   ; NSEventTypeLeftMouseUp
  br i1 %ml_up, label %lclr, label %mr_d
lclr:
  %lc = load i32, ptr @W_mbtn
  %lc2 = and i32 %lc, -2
  store i32 %lc2, ptr @W_mbtn
  br label %forward
mr_d:
  %mrd = icmp eq i64 %ty, 3                     ; NSEventTypeRightMouseDown
  br i1 %mrd, label %rset, label %mr_u
rset:
  %rb = load i32, ptr @W_mbtn
  %rb2 = or i32 %rb, 2
  store i32 %rb2, ptr @W_mbtn
  br label %forward
mr_u:
  %mru = icmp eq i64 %ty, 4                     ; NSEventTypeRightMouseUp
  br i1 %mru, label %rclr, label %scroll
rclr:
  %rc = load i32, ptr @W_mbtn
  %rc2 = and i32 %rc, -3
  store i32 %rc2, ptr @W_mbtn
  br label %forward
scroll:
  %isw = icmp eq i64 %ty, 22                    ; NSEventTypeScrollWheel
  br i1 %isw, label %wdo, label %forward
wdo:
  %sel_sy = call ptr @sel_registerName(ptr @.s_scrly)
  %dy = call double (ptr, ptr) @objc_msgSend(ptr %ev, ptr %sel_sy)
  %dyi = fptosi double %dy to i32
  %wv = load i32, ptr @W_wheel
  %wv2 = add i32 %wv, %dyi
  store i32 %wv2, ptr @W_wheel
  br label %forward
key:
  %kdv = call i32 @ev_keyval(ptr %ev)          ; #50 — press the held key
  call void @win_held_bit(i32 %kdv, i32 1)
  %kc = call i16 (ptr, ptr) @objc_msgSend(ptr %ev, ptr %sel_kc)
  %kc32 = zext i16 %kc to i32
  switch i32 %kc32, label %fromchars [
    i32 126, label %k_w
    i32 125, label %k_s
    i32 123, label %k_a
    i32 124, label %k_d
    i32 49,  label %k_space
    i32 36,  label %k_ret
    i32 53,  label %k_esc
  ]
k_w:     store i32 119, ptr @W_key  br label %forward
k_s:     store i32 115, ptr @W_key  br label %forward
k_a:     store i32 97,  ptr @W_key  br label %forward
k_d:     store i32 100, ptr @W_key  br label %forward
k_space: store i32 32,  ptr @W_key  br label %forward
k_ret:   store i32 10,  ptr @W_key  br label %forward
k_esc:
  store i32 113, ptr @W_key
  store i32 0, ptr @W_running
  br label %forward
fromchars:
  %chars = call ptr (ptr, ptr) @objc_msgSend(ptr %ev, ptr %sel_ch)
  %clen = call i64 (ptr, ptr) @objc_msgSend(ptr %chars, ptr %sel_len)
  %hasch = icmp sgt i64 %clen, 0
  br i1 %hasch, label %takechar, label %forward
takechar:
  %ch = call i16 (ptr, ptr, i64) @objc_msgSend(ptr %chars, ptr %sel_cat, i64 0)
  %ch32 = zext i16 %ch to i32
  store i32 %ch32, ptr @W_key
  %isq = icmp eq i32 %ch32, 113
  br i1 %isq, label %quit, label %forward
quit:
  store i32 0, ptr @W_running
  br label %forward
forward:
  %fwd = call ptr (ptr, ptr, ptr) @objc_msgSend(ptr %app, ptr %sel_send, ptr %ev)
  br label %pump
finish:
  ; a closed window ends the run
  %win = load ptr, ptr @W_win
  %hw = icmp ne ptr %win, null
  br i1 %hw, label %checkvis, label %done
checkvis:
  %sel_vis = call ptr @sel_registerName(ptr @.s_visib)
  %vis = call i8 (ptr, ptr) @objc_msgSend(ptr %win, ptr %sel_vis)
  %gone = icmp eq i8 %vis, 0
  br i1 %gone, label %closed, label %done
closed:
  store i32 0, ptr @W_running
  br label %done
done:
  %k = load i32, ptr @W_key
  ret i32 %k
}

define void @win_present(ptr %fb, i32 %w, i32 %h) {
entry:
  store ptr %fb, ptr @W_fb
  store i32 %w, ptr @W_fbw
  store i32 %h, ptr @W_fbh
  %view = load ptr, ptr @W_view
  %none = icmp eq ptr %view, null
  br i1 %none, label %out, label %show
show:
  %sel_disp = call ptr @sel_registerName(ptr @.s_disp)
  %d = call ptr @objc_msgSend(ptr %view, ptr %sel_disp)
  %u = call i32 @usleep(i32 16000)             ; ~60 fps
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
  store i32 0, ptr @W_running
  ret void
}

; #50 — copy the 8-word held-key set into the caller's buffer.
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

; #50 — write [x, y, button-mask, wheel-delta] into the caller's buffer, then
; reset the accumulated wheel delta (it is per-frame). Position is tracked in
; window points; buttons and wheel come from the event pump above.
define void @win_mouse(ptr %out) {
entry:
  %mx = load i32, ptr @W_mx
  %p0 = getelementptr i32, ptr %out, i32 0
  store i32 %mx, ptr %p0
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
