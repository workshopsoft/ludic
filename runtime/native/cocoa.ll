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
%NSPoint = type { double, double }

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
; #89 — cursor capture: NSCursor hide/unhide (ref-counted) + the CoreGraphics
; mouse-association / relative-delta calls.
declare i32 @CGAssociateMouseAndMouseCursorPosition(i32)
declare void @CGGetLastMouseDelta(ptr, ptr)
declare i32 @CGWarpMouseCursorPosition(%NSPoint)

@.c_app    = private unnamed_addr constant [14 x i8] c"NSApplication\00"
@.c_win    = private unnamed_addr constant [9 x i8]  c"NSWindow\00"
@.c_str    = private unnamed_addr constant [9 x i8]  c"NSString\00"
@.c_date   = private unnamed_addr constant [7 x i8]  c"NSDate\00"
@.c_view   = private unnamed_addr constant [7 x i8]  c"NSView\00"
@.c_gctx   = private unnamed_addr constant [18 x i8] c"NSGraphicsContext\00"
@.c_ludic  = private unnamed_addr constant [10 x i8] c"LudicView\00"
@.c_cursor = private unnamed_addr constant [9 x i8]  c"NSCursor\00"
@.c_screen = private unnamed_addr constant [9 x i8]  c"NSScreen\00"
@.s_cpts   = private unnamed_addr constant [22 x i8] c"convertPointToScreen:\00"
@.s_main   = private unnamed_addr constant [11 x i8] c"mainScreen\00"
@.s_frame  = private unnamed_addr constant [6 x i8]  c"frame\00"
@.s_hide   = private unnamed_addr constant [5 x i8]  c"hide\00"
@.s_unhide = private unnamed_addr constant [7 x i8]  c"unhide\00"
@.s_iskey  = private unnamed_addr constant [12 x i8] c"isKeyWindow\00"

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
@.s_modf   = private unnamed_addr constant [14 x i8] c"modifierFlags\00"
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

; #51 — native hardware bindings (mouse position, GameController, NSTouch).
@.s_mloc   = private unnamed_addr constant [34 x i8] c"mouseLocationOutsideOfEventStream\00"
; GameController.framework selectors (poll GCController.controllers each frame)
@.c_gc     = private unnamed_addr constant [13 x i8] c"GCController\00"
@.s_ctrls  = private unnamed_addr constant [12 x i8] c"controllers\00"
@.s_count  = private unnamed_addr constant [6 x i8]  c"count\00"
@.s_objidx = private unnamed_addr constant [15 x i8] c"objectAtIndex:\00"
@.s_extgp  = private unnamed_addr constant [16 x i8] c"extendedGamepad\00"
@.s_press  = private unnamed_addr constant [10 x i8] c"isPressed\00"
@.s_value  = private unnamed_addr constant [6 x i8]  c"value\00"
@.s_btnA   = private unnamed_addr constant [8 x i8]  c"buttonA\00"
@.s_btnB   = private unnamed_addr constant [8 x i8]  c"buttonB\00"
@.s_btnX   = private unnamed_addr constant [8 x i8]  c"buttonX\00"
@.s_btnY   = private unnamed_addr constant [8 x i8]  c"buttonY\00"
@.s_lsh    = private unnamed_addr constant [13 x i8] c"leftShoulder\00"
@.s_rsh    = private unnamed_addr constant [14 x i8] c"rightShoulder\00"
@.s_ltr    = private unnamed_addr constant [12 x i8] c"leftTrigger\00"
@.s_rtr    = private unnamed_addr constant [13 x i8] c"rightTrigger\00"
@.s_bmenu  = private unnamed_addr constant [11 x i8] c"buttonMenu\00"
@.s_bopt   = private unnamed_addr constant [14 x i8] c"buttonOptions\00"
@.s_lsb    = private unnamed_addr constant [21 x i8] c"leftThumbstickButton\00"
@.s_rsb    = private unnamed_addr constant [22 x i8] c"rightThumbstickButton\00"
@.s_dpad   = private unnamed_addr constant [5 x i8]  c"dpad\00"
@.s_up     = private unnamed_addr constant [3 x i8]  c"up\00"
@.s_down   = private unnamed_addr constant [5 x i8]  c"down\00"
@.s_left   = private unnamed_addr constant [5 x i8]  c"left\00"
@.s_right  = private unnamed_addr constant [6 x i8]  c"right\00"
@.s_lstick = private unnamed_addr constant [15 x i8] c"leftThumbstick\00"
@.s_rstick = private unnamed_addr constant [16 x i8] c"rightThumbstick\00"
@.s_xaxis  = private unnamed_addr constant [6 x i8]  c"xAxis\00"
@.s_yaxis  = private unnamed_addr constant [6 x i8]  c"yAxis\00"
; NSTouch selectors (trackpad, indirect touches)
@.s_setatt = private unnamed_addr constant [22 x i8] c"setAllowedTouchTypes:\00"
@.s_tmatch = private unnamed_addr constant [29 x i8] c"touchesMatchingPhase:inView:\00"
@.s_normp  = private unnamed_addr constant [19 x i8] c"normalizedPosition\00"
@.s_allobj = private unnamed_addr constant [11 x i8] c"allObjects\00"
@.s_tbegan = private unnamed_addr constant [23 x i8] c"touchesBeganWithEvent:\00"
@.s_tmoved = private unnamed_addr constant [23 x i8] c"touchesMovedWithEvent:\00"
@.s_tended = private unnamed_addr constant [23 x i8] c"touchesEndedWithEvent:\00"
@.s_tcancl = private unnamed_addr constant [27 x i8] c"touchesCancelledWithEvent:\00"
@.enc_te   = private unnamed_addr constant [5 x i8]  c"v@:@\00"

@W_app     = internal global ptr null
@W_win     = internal global ptr null
@W_view    = internal global ptr null
@W_fb      = internal global ptr null
@W_fbw     = internal global i32 320
@W_fbh     = internal global i32 240
@W_scale   = internal global i32 3
@W_key     = internal global i32 0
@W_running = internal global i32 1
@W_apphidden = internal global i32 0   ; App.window_hide: an ordered-out window is not a closed one
; #50 device layer — a 256-bit held-key set (8 i32) tracked from keyDown/keyUp,
; and the mouse state (position, button mask, per-frame wheel delta).
@W_held    = internal global [8 x i32] zeroinitializer
@W_mx      = internal global i32 0
@W_my      = internal global i32 0
@W_mbtn    = internal global i32 0
@W_wheel   = internal global i32 0
; #51 — up to 8 trackpad touch points, [active, x, y] each (framebuffer pixels),
; refreshed by the view's touchesBegan/Moved/Ended handlers.
@W_touch   = internal global [24 x i32] zeroinitializer
; #89 — cursor capture. @W_cursor_mode is the desired mode (0 normal, 1 hidden,
; 2 locked+relative, 3 confined). @W_cursor_hidden / @W_cursor_assoc track the
; currently-applied NSCursor hide (ref-counted, so we only toggle on a change) and
; the CGAssociateMouseAndMouseCursorPosition state, so focus loss auto-releases and
; refocus re-acquires without unbalancing the hide counter.
@W_cursor_mode   = internal global i32 0
@W_cursor_hidden = internal global i32 0
@W_cursor_assoc  = internal global i32 1

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
  ; a window already open (the runtime opens a game's before main) is retitled, not
  ; opened again - as win32.ll's win_open does
  %have = load ptr, ptr @W_win
  %again = icmp ne ptr %have, null
  br i1 %again, label %retitle, label %make
retitle:
  call void @win_set_title(ptr %title)
  ret void
make:
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
  ; #51 — the four NSTouch phase handlers, all routed to @ludic_touches.
  %sel_tb = call ptr @sel_registerName(ptr @.s_tbegan)
  %mt1 = call i8 @class_addMethod(ptr %cls, ptr %sel_tb, ptr @ludic_touches, ptr @.enc_te)
  %sel_tm = call ptr @sel_registerName(ptr @.s_tmoved)
  %mt2 = call i8 @class_addMethod(ptr %cls, ptr %sel_tm, ptr @ludic_touches, ptr @.enc_te)
  %sel_te = call ptr @sel_registerName(ptr @.s_tended)
  %mt3 = call i8 @class_addMethod(ptr %cls, ptr %sel_te, ptr @ludic_touches, ptr @.enc_te)
  %sel_tc = call ptr @sel_registerName(ptr @.s_tcancl)
  %mt4 = call i8 @class_addMethod(ptr %cls, ptr %sel_tc, ptr @ludic_touches, ptr @.enc_te)
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
  ; NSWindowStyleMaskTitled|Closable|Resizable = 11, NSBackingStoreBuffered = 2
  %win = call ptr (ptr, ptr, %CGRect, i64, i64, i8) @objc_msgSend(ptr %w0, ptr %sel_initw, %CGRect %rect, i64 11, i64 2, i8 0)
  store ptr %win, ptr @W_win
  ; NSWindowCollectionBehaviorFullScreenPrimary = 1 << 7: the green button and toggleFullScreen: work
  %sel_cb = call ptr @sel_registerName(ptr @.s_setcb)
  %acb = call ptr (ptr, ptr, i64) @objc_msgSend(ptr %win, ptr %sel_cb, i64 128)

  %strcls = call ptr @objc_getClass(ptr @.c_str)
  %sel_utf8 = call ptr @sel_registerName(ptr @.s_utf8)
  %nstitle = call ptr (ptr, ptr, ptr) @objc_msgSend(ptr %strcls, ptr %sel_utf8, ptr %title)
  %sel_title = call ptr @sel_registerName(ptr @.s_title)
  %a2 = call ptr (ptr, ptr, ptr) @objc_msgSend(ptr %win, ptr %sel_title, ptr %nstitle)

  %v0 = call ptr @objc_msgSend(ptr %cls, ptr %sel_alloc)
  %sel_initf = call ptr @sel_registerName(ptr @.s_initf)
  %view = call ptr (ptr, ptr, %CGRect) @objc_msgSend(ptr %v0, ptr %sel_initf, %CGRect %rect)
  store ptr %view, ptr @W_view
  ; #51 — accept indirect (trackpad) touches. NSTouchTypeMaskIndirect = 1<<0.
  %sel_att = call ptr @sel_registerName(ptr @.s_setatt)
  %att = call ptr (ptr, ptr, i64) @objc_msgSend(ptr %view, ptr %sel_att, i64 1)
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
; keyDown switch: arrows -> WASD, return, escape -> 27, else the first character).
; #88: escape delivers key 27 (left to the game), not 'q' — so the held-key set
; stays consistent with @W_key and a shipped game owns Esc (pause).
; A key in the typing block is its PHYSICAL position, named for what it types on a US
; layout (win32.ll keys its held set the same way): keyCode is already a position, so the
; kVK_ANSI_* codes map straight through and AZERTY's Z-labelled key is 'w' like everywhere
; else. Anything outside the table falls back to the character it types.
@C_kc2key = internal constant [51 x i8] [i8 97, i8 115, i8 100, i8 102, i8 104, i8 103, i8 122, i8 120, i8 99, i8 118, i8 0, i8 98, i8 113, i8 119, i8 101, i8 114, i8 121, i8 116, i8 49, i8 50, i8 51, i8 52, i8 54, i8 53, i8 61, i8 57, i8 55, i8 45, i8 56, i8 48, i8 93, i8 111, i8 117, i8 91, i8 105, i8 112, i8 0, i8 108, i8 106, i8 39, i8 107, i8 59, i8 92, i8 44, i8 47, i8 110, i8 109, i8 46, i8 0, i8 0, i8 96]

; what the active layout types on a position: not read on macOS yet, so the caller names
; the key after its US position
define i32 @win_key_char(i32 %k) {
entry:
  ret i32 0
}

define i32 @ev_keyval(ptr %ev) {
entry:
  %sel_kc = call ptr @sel_registerName(ptr @.s_keycd)
  %kc = call i16 (ptr, ptr) @objc_msgSend(ptr %ev, ptr %sel_kc)
  %kc32 = zext i16 %kc to i32
  %inpos = icmp ult i32 %kc32, 51
  br i1 %inpos, label %bypos, label %special
bypos:
  %pp = getelementptr [51 x i8], ptr @C_kc2key, i64 0, i32 %kc32
  %p8 = load i8, ptr %pp
  %pos = zext i8 %p8 to i32
  %named = icmp ne i32 %pos, 0
  br i1 %named, label %haspos, label %special
haspos:
  ret i32 %pos
special:
  switch i32 %kc32, label %chars [
    i32 126, label %vw
    i32 125, label %vs
    i32 123, label %va
    i32 124, label %vd
    i32 49,  label %vspace
    i32 36,  label %vret
    i32 53,  label %vesc
    i32 51,  label %vbksp
    ; the keys that type nothing: charactersIgnoringModifiers answers them with
    ; NSF1FunctionKey and its neighbours, 0xF700 and up, which is outside the 256-bit held
    ; set - so a game could not bind an F-key, Home, Delete or the numpad at all. They get
    ; the same codes win32.ll's w_keyval gives them.
    i32 122, label %vf1
    i32 120, label %vf2
    i32 99,  label %vf3
    i32 118, label %vf4
    i32 96,  label %vf5
    i32 97,  label %vf6
    i32 98,  label %vf7
    i32 100, label %vf8
    i32 101, label %vf9
    i32 109, label %vf10
    i32 103, label %vf11
    i32 111, label %vf12
    i32 115, label %vhome
    i32 119, label %vend
    i32 116, label %vpgup
    i32 121, label %vpgdn
    i32 114, label %vins
    i32 117, label %vdel
    i32 57,  label %vcaps
    i32 82,  label %vnp0
    i32 83,  label %vnp1
    i32 84,  label %vnp2
    i32 85,  label %vnp3
    i32 86,  label %vnp4
    i32 87,  label %vnp5
    i32 88,  label %vnp6
    i32 89,  label %vnp7
    i32 91,  label %vnp8
    i32 92,  label %vnp9
    i32 67,  label %vnpmul
    i32 69,  label %vnpadd
    i32 78,  label %vnpsub
    i32 65,  label %vnpdec
    i32 75,  label %vnpdiv
    i32 76,  label %vret
  ]
vw:     ret i32 128
vs:     ret i32 129
va:     ret i32 130
vd:     ret i32 131
vspace: ret i32 32
vret:   ret i32 10
vesc:   ret i32 27
vf1:    ret i32 132
vf2:    ret i32 133
vf3:    ret i32 134
vf4:    ret i32 135
vf5:    ret i32 136
vf6:    ret i32 137
vf7:    ret i32 138
vf8:    ret i32 139
vf9:    ret i32 140
vf10:   ret i32 141
vf11:   ret i32 142
vf12:   ret i32 143
vhome:  ret i32 144
vend:   ret i32 145
vpgup:  ret i32 146
vpgdn:  ret i32 147
vins:   ret i32 148
vdel:   ret i32 149
vcaps:  ret i32 150
vnp0:   ret i32 152
vnp1:   ret i32 153
vnp2:   ret i32 154
vnp3:   ret i32 155
vnp4:   ret i32 156
vnp5:   ret i32 157
vnp6:   ret i32 158
vnp7:   ret i32 159
vnp8:   ret i32 160
vnp9:   ret i32 161
vnpmul: ret i32 162
vnpadd: ret i32 163
vnpsub: ret i32 164
vnpdec: ret i32 165
vnpdiv: ret i32 166
; kVK_Delete (51), the key marked delete or backspace: AppKit reports its character as
; NSDeleteCharacter (127), and Key.Backspace is 8
vbksp:  ret i32 8
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
  ; charactersIgnoringModifiers still honours Shift, so Shift+W arrives as 'W' and a game
  ; holding 'w' to walk stopped dead the moment the player held Shift to run. Fold A-Z to
  ; a-z: the held set is keyed by the key, Shift itself is reported separately (code 16).
  %isupA = icmp sge i32 %c32, 65
  %isupB = icmp sle i32 %c32, 90
  %isupper = and i1 %isupA, %isupB
  %lower = add i32 %c32, 32
  %folded = select i1 %isupper, i32 %lower, i32 %c32
  ret i32 %folded
none:
  ret i32 0
}

; Drain the event queue, remembering the last key pressed. Arrow keys map onto
; WASD; escape delivers key 27 and 'q' is an ordinary key (#88 — a windowed game
; owns Esc/quit; the headless rt_poll keeps its own 'q' = quit for scripted tests).
; #50: also track the held-key set (keyDown/keyUp) and the mouse.
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
  br i1 %isup, label %keyup, label %notup
keyup:                                          ; #50 — release the held key
  %uv = call i32 @ev_keyval(ptr %ev)
  call void @win_held_bit(i32 %uv, i32 0)
  br label %forward
notup:
  %isflags = icmp eq i64 %ty, 12               ; NSEventTypeFlagsChanged: modifier keys
  br i1 %isflags, label %flags, label %mouse
flags:                                          ; Shift is held-key 16 (ctrl 17, alt 18): a run modifier
  %sel_mf = call ptr @sel_registerName(ptr @.s_modf)
  %mf = call i64 (ptr, ptr) @objc_msgSend(ptr %ev, ptr %sel_mf)
  %mf_sh = and i64 %mf, 131072                  ; NSEventModifierFlagShift = 1 << 17
  %sh_on = icmp ne i64 %mf_sh, 0
  %sh_i = zext i1 %sh_on to i32
  call void @win_held_bit(i32 16, i32 %sh_i)
  %mf_ct = and i64 %mf, 262144                  ; NSEventModifierFlagControl = 1 << 18
  %ct_on = icmp ne i64 %mf_ct, 0
  %ct_i = zext i1 %ct_on to i32
  call void @win_held_bit(i32 17, i32 %ct_i)
  %mf_al = and i64 %mf, 524288                  ; NSEventModifierFlagOption = 1 << 19
  %al_on = icmp ne i64 %mf_al, 0
  %al_i = zext i1 %al_on to i32
  call void @win_held_bit(i32 18, i32 %al_i)
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
    i32 51,  label %k_bksp
  ]
k_w:     store i32 119, ptr @W_key  br label %forward
k_s:     store i32 115, ptr @W_key  br label %forward
k_a:     store i32 97,  ptr @W_key  br label %forward
k_d:     store i32 100, ptr @W_key  br label %forward
k_space: store i32 32,  ptr @W_key  br label %forward
k_ret:   store i32 10,  ptr @W_key  br label %forward
k_bksp:  store i32 8,   ptr @W_key  br label %forward
k_esc:
  ; Escape is delivered as key 27 and left to the game (pause menus etc.).
  ; It used to force-quit the window, which a shipped game cannot tolerate.
  store i32 27, ptr @W_key
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
  ; 'q' is an ordinary key in a windowed game (the headless test driver keeps its
  ; own 'q' = quit in rt_poll); a shipped game must not die on a typo.
  br label %forward
forward:
  ; key events are consumed by win_poll itself; forwarding them to -sendEvent:
  ; hits an unhandled responder chain and AppKit plays the system "funk" beep.
  ; Mouse / other events are still forwarded so the window behaves normally.
  %fwd_isdown = icmp eq i64 %ty, 10
  %fwd_isup = icmp eq i64 %ty, 11
  %fwd_iskey = or i1 %fwd_isdown, %fwd_isup
  br i1 %fwd_iskey, label %pump, label %dosend
dosend:
  %fwd = call ptr (ptr, ptr, ptr) @objc_msgSend(ptr %app, ptr %sel_send, ptr %ev)
  br label %pump
finish:
  call void @win_cursor_maintain()      ; #89 — keep the cursor state (auto-release on focus loss)
  ; a closed window ends the run
  %win = load ptr, ptr @W_win
  %hw = icmp ne ptr %win, null
  br i1 %hw, label %checkvis, label %done
checkvis:
  %ah = load i32, ptr @W_apphidden
  %byapp = icmp ne i32 %ah, 0
  br i1 %byapp, label %done, label %checkvis2
checkvis2:
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
  ; #89 — restore the cursor so it is never left hidden / dissociated after quit.
  store i32 0, ptr @W_cursor_mode
  call void @cursor_apply(i32 0, i32 1)
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
  ; #51 — read the live cursor position from the window (points, origin
  ; bottom-left) and convert to framebuffer pixels, y-flipped so row 0 is the
  ; top, matching the framebuffer the game draws into.
  ; #89 — only mode 2 (true lock / FPS mouselook) dissociates the OS cursor, so its
  ; mouseLocation is frozen; accumulate CGGetLastMouseDelta into a virtual cursor
  ; (clamped to the framebuffer) so Input.mouse_dx/dy report the motion and
  ; Input.mouse_x/y give a reticle position. Mode 3 (confined) keeps the cursor
  ; ASSOCIATED, so it stays on the absolute path below — absolute mouse aim
  ; (aim_mode 0) works in a confined-cursor game, which is the whole point.
  %cmode = load i32, ptr @W_cursor_mode
  %isrel = icmp eq i32 %cmode, 2
  br i1 %isrel, label %reldelta, label %abspos
reldelta:
  %dxp = alloca i32
  %dyp = alloca i32
  call void @CGGetLastMouseDelta(ptr %dxp, ptr %dyp)
  %ddx = load i32, ptr %dxp
  %ddy = load i32, ptr %dyp
  %omx = load i32, ptr @W_mx
  %omy = load i32, ptr @W_my
  %nmx = add i32 %omx, %ddx
  %nmy = add i32 %omy, %ddy
  ; clamp x to [0, fbw-1]
  %fbwv = load i32, ptr @W_fbw
  %fbwm = sub i32 %fbwv, 1
  %xlo = icmp slt i32 %nmx, 0
  %nmx1 = select i1 %xlo, i32 0, i32 %nmx
  %xhi = icmp sgt i32 %nmx1, %fbwm
  %nmx2 = select i1 %xhi, i32 %fbwm, i32 %nmx1
  ; clamp y to [0, fbh-1]
  %fbhv = load i32, ptr @W_fbh
  %fbhm = sub i32 %fbhv, 1
  %ylo = icmp slt i32 %nmy, 0
  %nmy1 = select i1 %ylo, i32 0, i32 %nmy
  %yhi = icmp sgt i32 %nmy1, %fbhm
  %nmy2 = select i1 %yhi, i32 %fbhm, i32 %nmy1
  store i32 %nmx2, ptr @W_mx
  store i32 %nmy2, ptr @W_my
  ; the raw motion too: a clamped cursor stops turning at the edge, the delta must not
  %p4r = getelementptr i32, ptr %out, i32 4
  store i32 %ddx, ptr %p4r
  %p5r = getelementptr i32, ptr %out, i32 5
  store i32 %ddy, ptr %p5r
  br label %emit
abspos:
  %p4a = getelementptr i32, ptr %out, i32 4
  store i32 0, ptr %p4a
  %p5a = getelementptr i32, ptr %out, i32 5
  store i32 0, ptr %p5a
  %win = load ptr, ptr @W_win
  %nowin = icmp eq ptr %win, null
  br i1 %nowin, label %emit, label %qpos
qpos:
  %sel_ml = call ptr @sel_registerName(ptr @.s_mloc)
  %pt = call %NSPoint (ptr, ptr) @objc_msgSend(ptr %win, ptr %sel_ml)
  %px = extractvalue %NSPoint %pt, 0
  %py = extractvalue %NSPoint %pt, 1
  %sc = load i32, ptr @W_scale
  %scd = sitofp i32 %sc to double
  %fbh = load i32, ptr @W_fbh
  %fbhd = sitofp i32 %fbh to double
  %fx = fdiv double %px, %scd
  %fyy = fdiv double %py, %scd
  %fy = fsub double %fbhd, %fyy
  %ix0 = fptosi double %fx to i32
  %iy0 = fptosi double %fy to i32
  ; clamp the reported position to [0, fbw-1] x [0, fbh-1] so the reticle stays in
  ; the play area even when the (hidden) OS cursor strays past the window edge.
  %fbwa = load i32, ptr @W_fbw
  %fbwam = sub i32 %fbwa, 1
  %fbham = sub i32 %fbh, 1
  %axlo = icmp slt i32 %ix0, 0
  %ix1 = select i1 %axlo, i32 0, i32 %ix0
  %axhi = icmp sgt i32 %ix1, %fbwam
  %ix = select i1 %axhi, i32 %fbwam, i32 %ix1
  %aylo = icmp slt i32 %iy0, 0
  %iy1 = select i1 %aylo, i32 0, i32 %iy0
  %ayhi = icmp sgt i32 %iy1, %fbham
  %iy = select i1 %ayhi, i32 %fbham, i32 %iy1
  store i32 %ix, ptr @W_mx
  store i32 %iy, ptr @W_my
  br label %emit
emit:
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

; ============================================================================
; #89 — cursor capture. Apply the currently-wanted hidden / associated state,
; toggling only on a change so the ref-counted [NSCursor hide]/[unhide] stays
; balanced across frames and focus changes.
define void @cursor_apply(i32 %wh, i32 %wa) {
entry:
  %ch = load i32, ptr @W_cursor_hidden
  %hdiff = icmp ne i32 %ch, %wh
  br i1 %hdiff, label %doh, label %skiph
doh:
  %curscls = call ptr @objc_getClass(ptr @.c_cursor)
  %wanth = icmp ne i32 %wh, 0
  br i1 %wanth, label %hide, label %unhide
hide:
  %selhide = call ptr @sel_registerName(ptr @.s_hide)
  %r1 = call ptr (ptr, ptr) @objc_msgSend(ptr %curscls, ptr %selhide)
  br label %storeh
unhide:
  %selunh = call ptr @sel_registerName(ptr @.s_unhide)
  %r2 = call ptr (ptr, ptr) @objc_msgSend(ptr %curscls, ptr %selunh)
  br label %storeh
storeh:
  store i32 %wh, ptr @W_cursor_hidden
  br label %skiph
skiph:
  %ca = load i32, ptr @W_cursor_assoc
  %adiff = icmp ne i32 %ca, %wa
  br i1 %adiff, label %doa, label %skipa
doa:
  %rc = call i32 @CGAssociateMouseAndMouseCursorPosition(i32 %wa)
  store i32 %wa, ptr @W_cursor_assoc
  br label %skipa
skipa:
  ret void
}

; Re-derive the wanted state from the mode + window key status, then apply it.
; Called on a mode change and once per frame from win_poll, so losing focus
; (Cmd-Tab) auto-releases the cursor and refocusing re-acquires it.
define void @win_cursor_maintain() {
entry:
  %mode = load i32, ptr @W_cursor_mode
  %win = load ptr, ptr @W_win
  %nowin = icmp eq ptr %win, null
  br i1 %nowin, label %release, label %askkey
askkey:
  %selk = call ptr @sel_registerName(ptr @.s_iskey)
  %k8 = call i8 (ptr, ptr) @objc_msgSend(ptr %win, ptr %selk)
  %iskey = icmp ne i8 %k8, 0
  br i1 %iskey, label %keyed, label %release
release:
  ; not focused (or no window): show the cursor and reconnect it
  call void @cursor_apply(i32 0, i32 1)
  ret void
keyed:
  ; want_hidden for every capture mode: 1 (hidden), 2 (locked) and 3 (confined).
  ; A confined-cursor game hides the OS cursor and draws its own reticle.
  %h1 = icmp eq i32 %mode, 1
  %h2 = icmp eq i32 %mode, 2
  %h3 = icmp eq i32 %mode, 3
  %hor = or i1 %h1, %h2
  %wh = or i1 %hor, %h3
  %whi = zext i1 %wh to i32
  ; dissociate (relative deltas) ONLY for mode 2 (true lock / FPS mouselook).
  ; Mode 3 (confined) stays associated so its absolute position stays valid.
  %a2 = icmp eq i32 %mode, 2
  %wa = xor i1 %a2, true
  %wai = zext i1 %wa to i32
  call void @cursor_apply(i32 %whi, i32 %wai)
  ; mode 3 (confined): physically hold the cursor inside the window each frame.
  %ism3 = icmp eq i32 %mode, 3
  br i1 %ism3, label %confine, label %noconf
confine:
  call void @win_cursor_confine()
  br label %noconf
noconf:
  ret void
}

; #89 — confine the (hidden) cursor to the content area in mode 3. Because mode 3
; keeps the cursor ASSOCIATED (so absolute mouse aim works), the OS cursor is still
; free to leave the window; without this a click outside would land outside and drop
; focus. Each frame we read the window-local cursor point, and if it has strayed past
; the content rect we warp it back to the nearest inside point. Only warps when the
; cursor is actually out, so an in-window cursor is untouched.
define void @win_cursor_confine() {
entry:
  %win = load ptr, ptr @W_win
  %nowin = icmp eq ptr %win, null
  br i1 %nowin, label %done, label %go
go:
  %sel_ml = call ptr @sel_registerName(ptr @.s_mloc)
  %pt = call %NSPoint (ptr, ptr) @objc_msgSend(ptr %win, ptr %sel_ml)
  %px = extractvalue %NSPoint %pt, 0
  %py = extractvalue %NSPoint %pt, 1
  ; content bounds in points: [0, fbw*scale] x [0, fbh*scale]
  %sc = load i32, ptr @W_scale
  %scd = sitofp i32 %sc to double
  %fbw = load i32, ptr @W_fbw
  %fbh = load i32, ptr @W_fbh
  %fbwd = sitofp i32 %fbw to double
  %fbhd = sitofp i32 %fbh to double
  %cw = fmul double %fbwd, %scd
  %ch = fmul double %fbhd, %scd
  %cwm = fsub double %cw, 1.000000e+00
  %chm = fsub double %ch, 1.000000e+00
  ; clamp px to [1, cw-1]
  %pxlo = fcmp olt double %px, 1.000000e+00
  %px1 = select i1 %pxlo, double 1.000000e+00, double %px
  %pxhi = fcmp ogt double %px1, %cwm
  %cpx = select i1 %pxhi, double %cwm, double %px1
  ; clamp py to [1, ch-1]
  %pylo = fcmp olt double %py, 1.000000e+00
  %py1 = select i1 %pylo, double 1.000000e+00, double %py
  %pyhi = fcmp ogt double %py1, %chm
  %cpy = select i1 %pyhi, double %chm, double %py1
  ; warp only if the cursor actually strayed
  %dx = fcmp one double %cpx, %px
  %dy = fcmp one double %cpy, %py
  %need = or i1 %dx, %dy
  br i1 %need, label %warp, label %done
warp:
  ; clamped window-local point -> global screen coords (bottom-left origin, y up)
  %cp0 = insertvalue %NSPoint undef, double %cpx, 0
  %cp = insertvalue %NSPoint %cp0, double %cpy, 1
  %sel_cps = call ptr @sel_registerName(ptr @.s_cpts)
  %gp = call %NSPoint (ptr, ptr, %NSPoint) @objc_msgSend(ptr %win, ptr %sel_cps, %NSPoint %cp)
  %gx = extractvalue %NSPoint %gp, 0
  %gy = extractvalue %NSPoint %gp, 1
  ; main screen height for the flip to CG global coords (top-left origin, y down)
  %scrcls = call ptr @objc_getClass(ptr @.c_screen)
  %sel_main = call ptr @sel_registerName(ptr @.s_main)
  %scr = call ptr (ptr, ptr) @objc_msgSend(ptr %scrcls, ptr %sel_main)
  %sel_fr = call ptr @sel_registerName(ptr @.s_frame)
  %fr = call %CGRect (ptr, ptr) @objc_msgSend(ptr %scr, ptr %sel_fr)
  %sh = extractvalue %CGRect %fr, 3
  %warpy = fsub double %sh, %gy
  %wp0 = insertvalue %NSPoint undef, double %gx, 0
  %wp = insertvalue %NSPoint %wp0, double %warpy, 1
  %rc = call i32 @CGWarpMouseCursorPosition(%NSPoint %wp)
  br label %done
done:
  ret void
}

; the Ludic entry point: set the desired cursor mode and apply it now.
define void @win_cursor_mode(i32 %mode) {
entry:
  store i32 %mode, ptr @W_cursor_mode
  call void @win_cursor_maintain()
  ret void
}

; ============================================================================
; #51 — gamepad, via GameController.framework.
;
; Each frame win_pad() walks [GCController controllers] and, for every connected
; controller that exposes an -extendedGamepad, packs its state into the caller's
; buffer: six words per pad — [connected, button-mask, lx, ly, rx, ly] — for up
; to four pads. Axes are 16.16 fixed (float value * 65536); the stick Y is
; negated so "down" is positive, matching the SDL axis convention the device
; layer maps onto. The button mask follows SDL_GameControllerButton order:
;   0 A  1 B  2 X  3 Y  4 Back  5 Guide  6 Start  7 LStick  8 RStick
;   9 LShoulder  10 RShoulder  11 DPadUp  12 DPadDown  13 DPadLeft  14 DPadRight
;   15 LTrigger  16 RTrigger
; nil property messaging returns 0, so a controller missing a given button
; simply reports it unpressed. This whole binding is DCE'd out of a headless
; build (win_pad is only reached on the is_windowed() branch).
; ============================================================================

; Is the button property named %name pressed on extended-gamepad %egp? 0 or 1.
define i32 @gc_pressed(ptr %egp, ptr %name) {
entry:
  %sel = call ptr @sel_registerName(ptr %name)
  %btn = call ptr (ptr, ptr) @objc_msgSend(ptr %egp, ptr %sel)
  %nil = icmp eq ptr %btn, null
  br i1 %nil, label %zero, label %ask
ask:
  %selp = call ptr @sel_registerName(ptr @.s_press)
  %b = call i8 (ptr, ptr) @objc_msgSend(ptr %btn, ptr %selp)
  %bi = zext i8 %b to i32
  %r = and i32 %bi, 1
  ret i32 %r
zero:
  ret i32 0
}

; Two-level version: %grp names a sub-object (e.g. "dpad"), %dir the button on
; it (e.g. "up").
define i32 @gc_pressed2(ptr %egp, ptr %grp, ptr %dir) {
entry:
  %selg = call ptr @sel_registerName(ptr %grp)
  %g = call ptr (ptr, ptr) @objc_msgSend(ptr %egp, ptr %selg)
  %nil = icmp eq ptr %g, null
  br i1 %nil, label %zero, label %ask
ask:
  %r = call i32 @gc_pressed(ptr %g, ptr %dir)
  ret i32 %r
zero:
  ret i32 0
}

; The value of axis %axis on stick %stick, as 16.16 fixed. 0 if either is nil.
define i32 @gc_axis(ptr %egp, ptr %stick, ptr %axis) {
entry:
  %sels = call ptr @sel_registerName(ptr %stick)
  %st = call ptr (ptr, ptr) @objc_msgSend(ptr %egp, ptr %sels)
  %n1 = icmp eq ptr %st, null
  br i1 %n1, label %zero, label %a2
a2:
  %sela = call ptr @sel_registerName(ptr %axis)
  %ax = call ptr (ptr, ptr) @objc_msgSend(ptr %st, ptr %sela)
  %n2 = icmp eq ptr %ax, null
  br i1 %n2, label %zero, label %read
read:
  %selv = call ptr @sel_registerName(ptr @.s_value)
  %f = call float (ptr, ptr) @objc_msgSend(ptr %ax, ptr %selv)
  %scaled = fmul float %f, 6.5536e+04
  %i = fptosi float %scaled to i32
  ret i32 %i
zero:
  ret i32 0
}

; The full SDL-ordered button mask for one extended gamepad.
define i32 @gc_mask(ptr %egp) {
entry:
  %a  = call i32 @gc_pressed(ptr %egp, ptr @.s_btnA)
  %b  = call i32 @gc_pressed(ptr %egp, ptr @.s_btnB)
  %x  = call i32 @gc_pressed(ptr %egp, ptr @.s_btnX)
  %y  = call i32 @gc_pressed(ptr %egp, ptr @.s_btnY)
  %bk = call i32 @gc_pressed(ptr %egp, ptr @.s_bopt)
  %st = call i32 @gc_pressed(ptr %egp, ptr @.s_bmenu)
  %ls = call i32 @gc_pressed(ptr %egp, ptr @.s_lsb)
  %rs = call i32 @gc_pressed(ptr %egp, ptr @.s_rsb)
  %lsh = call i32 @gc_pressed(ptr %egp, ptr @.s_lsh)
  %rsh = call i32 @gc_pressed(ptr %egp, ptr @.s_rsh)
  %du = call i32 @gc_pressed2(ptr %egp, ptr @.s_dpad, ptr @.s_up)
  %dd = call i32 @gc_pressed2(ptr %egp, ptr @.s_dpad, ptr @.s_down)
  %dl = call i32 @gc_pressed2(ptr %egp, ptr @.s_dpad, ptr @.s_left)
  %dr = call i32 @gc_pressed2(ptr %egp, ptr @.s_dpad, ptr @.s_right)
  %lt = call i32 @gc_pressed(ptr %egp, ptr @.s_ltr)
  %rt = call i32 @gc_pressed(ptr %egp, ptr @.s_rtr)
  %s1  = shl i32 %b,  1
  %s2  = shl i32 %x,  2
  %s3  = shl i32 %y,  3
  %s4  = shl i32 %bk, 4
  %s6  = shl i32 %st, 6
  %s7  = shl i32 %ls, 7
  %s8  = shl i32 %rs, 8
  %s9  = shl i32 %lsh, 9
  %s10 = shl i32 %rsh, 10
  %s11 = shl i32 %du, 11
  %s12 = shl i32 %dd, 12
  %s13 = shl i32 %dl, 13
  %s14 = shl i32 %dr, 14
  %s15 = shl i32 %lt, 15
  %s16 = shl i32 %rt, 16
  %o0 = or i32 %a, %s1
  %o1 = or i32 %o0, %s2
  %o2 = or i32 %o1, %s3
  %o3 = or i32 %o2, %s4
  %o4 = or i32 %o3, %s6
  %o5 = or i32 %o4, %s7
  %o6 = or i32 %o5, %s8
  %o7 = or i32 %o6, %s9
  %o8 = or i32 %o7, %s10
  %o9 = or i32 %o8, %s11
  %o10 = or i32 %o9, %s12
  %o11 = or i32 %o10, %s13
  %o12 = or i32 %o11, %s14
  %o13 = or i32 %o12, %s15
  %o14 = or i32 %o13, %s16
  ret i32 %o14
}

; Fill the caller's 24-word buffer: [connected, mask, lx, ly, rx, ry] per pad.
define void @win_pad(ptr %out) {
entry:
  br label %clr
clr:
  %ci = phi i32 [ 0, %entry ], [ %cn, %clrb ]
  %cd = icmp sge i32 %ci, 24
  br i1 %cd, label %start, label %clrb
clrb:
  %cp = getelementptr i32, ptr %out, i32 %ci
  store i32 0, ptr %cp
  %cn = add i32 %ci, 1
  br label %clr
start:
  %gccls = call ptr @objc_getClass(ptr @.c_gc)
  %nocls = icmp eq ptr %gccls, null
  br i1 %nocls, label %done, label %getarr
getarr:
  %selc = call ptr @sel_registerName(ptr @.s_ctrls)
  %arr = call ptr (ptr, ptr) @objc_msgSend(ptr %gccls, ptr %selc)
  %noarr = icmp eq ptr %arr, null
  br i1 %noarr, label %done, label %count
count:
  %seln = call ptr @sel_registerName(ptr @.s_count)
  %n64 = call i64 (ptr, ptr) @objc_msgSend(ptr %arr, ptr %seln)
  %n = trunc i64 %n64 to i32
  br label %loop
loop:
  %p = phi i32 [ 0, %count ], [ %pn, %cont ]
  %lt4 = icmp slt i32 %p, 4
  %ltn = icmp slt i32 %p, %n
  %ok = and i1 %lt4, %ltn
  br i1 %ok, label %body, label %done
body:
  %seloi = call ptr @sel_registerName(ptr @.s_objidx)
  %p64 = sext i32 %p to i64
  %ctl = call ptr (ptr, ptr, i64) @objc_msgSend(ptr %arr, ptr %seloi, i64 %p64)
  %selg = call ptr @sel_registerName(ptr @.s_extgp)
  %egp = call ptr (ptr, ptr) @objc_msgSend(ptr %ctl, ptr %selg)
  %noegp = icmp eq ptr %egp, null
  br i1 %noegp, label %cont, label %pack
pack:
  %base = mul i32 %p, 6
  %b0 = getelementptr i32, ptr %out, i32 %base
  store i32 1, ptr %b0
  %mask = call i32 @gc_mask(ptr %egp)
  %i1 = add i32 %base, 1
  %b1 = getelementptr i32, ptr %out, i32 %i1
  store i32 %mask, ptr %b1
  %lx = call i32 @gc_axis(ptr %egp, ptr @.s_lstick, ptr @.s_xaxis)
  %i2 = add i32 %base, 2
  %b2 = getelementptr i32, ptr %out, i32 %i2
  store i32 %lx, ptr %b2
  %lyr = call i32 @gc_axis(ptr %egp, ptr @.s_lstick, ptr @.s_yaxis)
  %ly = sub i32 0, %lyr
  %i3 = add i32 %base, 3
  %b3 = getelementptr i32, ptr %out, i32 %i3
  store i32 %ly, ptr %b3
  %rx = call i32 @gc_axis(ptr %egp, ptr @.s_rstick, ptr @.s_xaxis)
  %i4 = add i32 %base, 4
  %b4 = getelementptr i32, ptr %out, i32 %i4
  store i32 %rx, ptr %b4
  %ryr = call i32 @gc_axis(ptr %egp, ptr @.s_rstick, ptr @.s_yaxis)
  %ry = sub i32 0, %ryr
  %i5 = add i32 %base, 5
  %b5 = getelementptr i32, ptr %out, i32 %i5
  store i32 %ry, ptr %b5
  br label %cont
cont:
  %pn = add i32 %p, 1
  br label %loop
done:
  ret void
}

; ============================================================================
; #51 — touch, via NSTouch (trackpad / indirect touches).
;
; The view's touchesBegan/Moved/Ended/Cancelled handlers all funnel through
; @ludic_touches, which resnapshots the set of touches currently down into
; @W_touch as [active, x, y] per point (framebuffer pixels; normalizedPosition
; is 0..1, origin bottom-left, so y is flipped). win_touch() copies that out.
; ============================================================================
define internal void @ludic_touches(ptr %self, ptr %sel, ptr %event) {
entry:
  br label %clr
clr:
  %ci = phi i32 [ 0, %entry ], [ %cn, %clrb ]
  %cd = icmp sge i32 %ci, 24
  br i1 %cd, label %get, label %clrb
clrb:
  %cp = getelementptr [24 x i32], ptr @W_touch, i32 0, i32 %ci
  store i32 0, ptr %cp
  %cn = add i32 %ci, 1
  br label %clr
get:
  %selm = call ptr @sel_registerName(ptr @.s_tmatch)
  ; NSTouchPhaseTouching = Began|Moved|Stationary = 1|2|4 = 7
  %set = call ptr (ptr, ptr, i64, ptr) @objc_msgSend(ptr %event, ptr %selm, i64 7, ptr %self)
  %noset = icmp eq ptr %set, null
  br i1 %noset, label %ret, label %toarr
toarr:
  %sela = call ptr @sel_registerName(ptr @.s_allobj)
  %arr = call ptr (ptr, ptr) @objc_msgSend(ptr %set, ptr %sela)
  %noarr = icmp eq ptr %arr, null
  br i1 %noarr, label %ret, label %count
count:
  %seln = call ptr @sel_registerName(ptr @.s_count)
  %n64 = call i64 (ptr, ptr) @objc_msgSend(ptr %arr, ptr %seln)
  %n = trunc i64 %n64 to i32
  br label %loop
loop:
  %i = phi i32 [ 0, %count ], [ %ni, %cont ]
  %lt8 = icmp slt i32 %i, 8
  %ltn = icmp slt i32 %i, %n
  %ok = and i1 %lt8, %ltn
  br i1 %ok, label %body, label %ret
body:
  %seloi = call ptr @sel_registerName(ptr @.s_objidx)
  %i64v = sext i32 %i to i64
  %t = call ptr (ptr, ptr, i64) @objc_msgSend(ptr %arr, ptr %seloi, i64 %i64v)
  %selnp = call ptr @sel_registerName(ptr @.s_normp)
  %np = call %NSPoint (ptr, ptr) @objc_msgSend(ptr %t, ptr %selnp)
  %nx = extractvalue %NSPoint %np, 0
  %ny = extractvalue %NSPoint %np, 1
  %fbw = load i32, ptr @W_fbw
  %fbh = load i32, ptr @W_fbh
  %fbwd = sitofp i32 %fbw to double
  %fbhd = sitofp i32 %fbh to double
  %xd = fmul double %nx, %fbwd
  %ny1 = fsub double 1.0, %ny
  %yd = fmul double %ny1, %fbhd
  %xi = fptosi double %xd to i32
  %yi = fptosi double %yd to i32
  %base = mul i32 %i, 3
  %o0 = getelementptr [24 x i32], ptr @W_touch, i32 0, i32 %base
  store i32 1, ptr %o0
  %j1 = add i32 %base, 1
  %o1 = getelementptr [24 x i32], ptr @W_touch, i32 0, i32 %j1
  store i32 %xi, ptr %o1
  %j2 = add i32 %base, 2
  %o2 = getelementptr [24 x i32], ptr @W_touch, i32 0, i32 %j2
  store i32 %yi, ptr %o2
  br label %cont
cont:
  %ni = add i32 %i, 1
  br label %loop
ret:
  ret void
}

; Copy the 24-word touch snapshot into the caller's buffer.
define void @win_touch(ptr %out) {
entry:
  br label %loop
loop:
  %i = phi i32 [ 0, %entry ], [ %ni, %body ]
  %done = icmp sge i32 %i, 24
  br i1 %done, label %ret, label %body
body:
  %sp = getelementptr [24 x i32], ptr @W_touch, i32 0, i32 %i
  %v = load i32, ptr %sp
  %dp = getelementptr i32, ptr %out, i32 %i
  store i32 %v, ptr %dp
  %ni = add i32 %i, 1
  br label %loop
ret:
  ret void
}

; ============================================================================
; OpenGL on the window (Gl.* — runtime/native/gl.ludic). An NSOpenGLContext is
; attached to the existing LudicView, at the display's backing resolution, with
; a 4.1 core profile. The CPU framebuffer path above is untouched: a Gl program
; simply never calls Screen.show, so -drawRect: finds @W_fb null and paints
; nothing. The window-independent GL pieces (offscreen CGL contexts, ABI thunks)
; live in gl.ll so a headless build never references the window.
;
;   win_gl_attach() -> ok      create the context on @W_view (0 = no window yet)
;   win_gl_resize(w, h)        content size in points, scale 1 (mouse mapping follows)
;   win_gl_swap()              flushBuffer (vsync'd)
;   win_gl_scale() -> int      backing pixels per point (2 on Retina)
; ============================================================================

@.c_pixfmt   = private unnamed_addr constant [20 x i8] c"NSOpenGLPixelFormat\00"
@.c_glctx    = private unnamed_addr constant [16 x i8] c"NSOpenGLContext\00"
@.s_initattr = private unnamed_addr constant [20 x i8] c"initWithAttributes:\00"
@.s_initfmt  = private unnamed_addr constant [29 x i8] c"initWithFormat:shareContext:\00"
@.s_setview  = private unnamed_addr constant [9 x i8]  c"setView:\00"
@.s_makecur  = private unnamed_addr constant [19 x i8] c"makeCurrentContext\00"
@.s_flushbuf = private unnamed_addr constant [12 x i8] c"flushBuffer\00"
@.s_ctxupd   = private unnamed_addr constant [7 x i8]  c"update\00"
@.s_setvals  = private unnamed_addr constant [24 x i8] c"setValues:forParameter:\00"
@.s_bestres  = private unnamed_addr constant [37 x i8] c"setWantsBestResolutionOpenGLSurface:\00"
@.s_bscale   = private unnamed_addr constant [19 x i8] c"backingScaleFactor\00"
@.s_setcsize = private unnamed_addr constant [16 x i8] c"setContentSize:\00"
@.s_togfs    = private unnamed_addr constant [18 x i8] c"toggleFullScreen:\00"
@.s_bounds   = private unnamed_addr constant [7 x i8]  c"bounds\00"
@.s_setcb    = private unnamed_addr constant [23 x i8] c"setCollectionBehavior:\00"

@W_glctx  = internal global ptr null
@W_glscale = internal global i32 1

define i32 @win_gl_attach() {
entry:
  %view = load ptr, ptr @W_view
  %noview = icmp eq ptr %view, null
  br i1 %noview, label %fail, label %go
go:
  %sel_alloc = call ptr @sel_registerName(ptr @.s_alloc)
  ; Retina: ask for a backing-resolution surface before the context is attached
  %sel_br = call ptr @sel_registerName(ptr @.s_bestres)
  %r0 = call ptr (ptr, ptr, i8) @objc_msgSend(ptr %view, ptr %sel_br, i8 1)
  ; NSOpenGLPixelFormatAttribute[]: OpenGLProfile=99 -> 4.1 core (0x4100),
  ; ColorSize=8 -> 24, AlphaSize=11 -> 8, DepthSize=12 -> 24, StencilSize=13 -> 8,
  ; DoubleBuffer=5, Accelerated=73, 0
  %attrs = alloca [14 x i32], align 4
  %a0 = getelementptr [14 x i32], ptr %attrs, i32 0, i32 0
  store i32 99, ptr %a0
  %a1 = getelementptr [14 x i32], ptr %attrs, i32 0, i32 1
  store i32 16640, ptr %a1
  %a2 = getelementptr [14 x i32], ptr %attrs, i32 0, i32 2
  store i32 8, ptr %a2
  %a3 = getelementptr [14 x i32], ptr %attrs, i32 0, i32 3
  store i32 24, ptr %a3
  %a4 = getelementptr [14 x i32], ptr %attrs, i32 0, i32 4
  store i32 11, ptr %a4
  %a5 = getelementptr [14 x i32], ptr %attrs, i32 0, i32 5
  store i32 8, ptr %a5
  %a6 = getelementptr [14 x i32], ptr %attrs, i32 0, i32 6
  store i32 12, ptr %a6
  %a7 = getelementptr [14 x i32], ptr %attrs, i32 0, i32 7
  store i32 24, ptr %a7
  %a8 = getelementptr [14 x i32], ptr %attrs, i32 0, i32 8
  store i32 13, ptr %a8
  %a9 = getelementptr [14 x i32], ptr %attrs, i32 0, i32 9
  store i32 8, ptr %a9
  %a10 = getelementptr [14 x i32], ptr %attrs, i32 0, i32 10
  store i32 5, ptr %a10
  %a11 = getelementptr [14 x i32], ptr %attrs, i32 0, i32 11
  store i32 73, ptr %a11
  %a12 = getelementptr [14 x i32], ptr %attrs, i32 0, i32 12
  store i32 0, ptr %a12
  %a13 = getelementptr [14 x i32], ptr %attrs, i32 0, i32 13
  store i32 0, ptr %a13

  %pfcls = call ptr @objc_getClass(ptr @.c_pixfmt)
  %pf0 = call ptr @objc_msgSend(ptr %pfcls, ptr %sel_alloc)
  %sel_ia = call ptr @sel_registerName(ptr @.s_initattr)
  %pf = call ptr (ptr, ptr, ptr) @objc_msgSend(ptr %pf0, ptr %sel_ia, ptr %attrs)
  %nopf = icmp eq ptr %pf, null
  br i1 %nopf, label %fail, label %ctx
ctx:
  %ccls = call ptr @objc_getClass(ptr @.c_glctx)
  %c0 = call ptr @objc_msgSend(ptr %ccls, ptr %sel_alloc)
  %sel_if = call ptr @sel_registerName(ptr @.s_initfmt)
  %c = call ptr (ptr, ptr, ptr, ptr) @objc_msgSend(ptr %c0, ptr %sel_if, ptr %pf, ptr null)
  %noc = icmp eq ptr %c, null
  br i1 %noc, label %fail, label %attach
attach:
  %sel_sv = call ptr @sel_registerName(ptr @.s_setview)
  %r1 = call ptr (ptr, ptr, ptr) @objc_msgSend(ptr %c, ptr %sel_sv, ptr %view)
  %sel_mc = call ptr @sel_registerName(ptr @.s_makecur)
  %r2 = call ptr @objc_msgSend(ptr %c, ptr %sel_mc)
  ; swap interval 1 (NSOpenGLCPSwapInterval = 222)
  %one = alloca i32, align 4
  store i32 1, ptr %one
  %sel_sp = call ptr @sel_registerName(ptr @.s_setvals)
  %r3 = call ptr (ptr, ptr, ptr, i64) @objc_msgSend(ptr %c, ptr %sel_sp, ptr %one, i64 222)
  store ptr %c, ptr @W_glctx
  ; backing scale factor of the window (2.0 on Retina)
  %win = load ptr, ptr @W_win
  %sel_bs = call ptr @sel_registerName(ptr @.s_bscale)
  %bs = call double (ptr, ptr) @objc_msgSend(ptr %win, ptr %sel_bs)
  %bsi = fptosi double %bs to i32
  %bsok = icmp sgt i32 %bsi, 0
  %bsv = select i1 %bsok, i32 %bsi, i32 1
  store i32 %bsv, ptr @W_glscale
  ret i32 1
fail:
  ret i32 0
}

define void @win_gl_resize(i32 %w, i32 %h) {
entry:
  %win = load ptr, ptr @W_win
  %nowin = icmp eq ptr %win, null
  br i1 %nowin, label %out, label %go
go:
  store i32 %w, ptr @W_fbw
  store i32 %h, ptr @W_fbh
  store i32 1, ptr @W_scale
  %wd = sitofp i32 %w to double
  %hd = sitofp i32 %h to double
  %s0 = insertvalue %NSPoint undef, double %wd, 0
  %sz = insertvalue %NSPoint %s0, double %hd, 1
  %sel_cs = call ptr @sel_registerName(ptr @.s_setcsize)
  %r0 = call ptr (ptr, ptr, %NSPoint) @objc_msgSend(ptr %win, ptr %sel_cs, %NSPoint %sz)
  %sel_center = call ptr @sel_registerName(ptr @.s_center)
  %r1 = call ptr @objc_msgSend(ptr %win, ptr %sel_center)
  %c = load ptr, ptr @W_glctx
  %noc = icmp eq ptr %c, null
  br i1 %noc, label %out, label %upd
upd:
  %sel_u = call ptr @sel_registerName(ptr @.s_ctxupd)
  %r2 = call ptr @objc_msgSend(ptr %c, ptr %sel_u)
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
  %sel_fb = call ptr @sel_registerName(ptr @.s_flushbuf)
  %r = call ptr @objc_msgSend(ptr %c, ptr %sel_fb)
  br label %out
out:
  ret void
}

define i32 @win_gl_scale() {
entry:
  %s = load i32, ptr @W_glscale
  ret i32 %s
}

; swap interval: 1 = vsync (the default set at attach), 0 = free-running
define void @win_gl_swap_interval(i32 %n) {
entry:
  %c = load ptr, ptr @W_glctx
  %noc = icmp eq ptr %c, null
  br i1 %noc, label %out, label %go
go:
  %v = alloca i32, align 4
  store i32 %n, ptr %v
  %sel_sp = call ptr @sel_registerName(ptr @.s_setvals)
  %r = call ptr (ptr, ptr, ptr, i64) @objc_msgSend(ptr %c, ptr %sel_sp, ptr %v, i64 222)
  br label %out
out:
  ret void
}

; ============================================================================
; window size, full screen and the drawable (the game's video settings)
; ============================================================================
; the view's drawable in pixels -> out[0], out[1]; also keeps the points size the
; mouse conversion uses in step with a window the user resized or made full screen
define void @win_gl_drawable(ptr %out) {
entry:
  %view = load ptr, ptr @W_view
  %noview = icmp eq ptr %view, null
  br i1 %noview, label %none, label %go
go:
  %sel_b = call ptr @sel_registerName(ptr @.s_bounds)
  %r = call %CGRect (ptr, ptr) @objc_msgSend(ptr %view, ptr %sel_b)
  %w = extractvalue %CGRect %r, 2
  %h = extractvalue %CGRect %r, 3
  %sc = load i32, ptr @W_glscale
  %scd = sitofp i32 %sc to double
  %pw = fmul double %w, %scd
  %ph = fmul double %h, %scd
  %iw = fptosi double %pw to i32
  %ih = fptosi double %ph to i32
  store i32 %iw, ptr %out
  %p1 = getelementptr i32, ptr %out, i32 1
  store i32 %ih, ptr %p1
  %ipw = fptosi double %w to i32
  %iph = fptosi double %h to i32
  store i32 %ipw, ptr @W_fbw
  store i32 %iph, ptr @W_fbh
  ret void
none:
  store i32 0, ptr %out
  %p1n = getelementptr i32, ptr %out, i32 1
  store i32 0, ptr %p1n
  ret void
}
; tell the context its view changed size
define void @win_gl_update() {
entry:
  %c = load ptr, ptr @W_glctx
  %noc = icmp eq ptr %c, null
  br i1 %noc, label %out, label %upd
upd:
  %sel_u = call ptr @sel_registerName(ptr @.s_ctxupd)
  %r = call ptr @objc_msgSend(ptr %c, ptr %sel_u)
  br label %out
out:
  ret void
}
define void @win_toggle_fullscreen() {
entry:
  %win = load ptr, ptr @W_win
  %nowin = icmp eq ptr %win, null
  br i1 %nowin, label %out, label %go
go:
  %sel_t = call ptr @sel_registerName(ptr @.s_togfs)
  %r = call ptr (ptr, ptr, ptr) @objc_msgSend(ptr %win, ptr %sel_t, ptr null)
  br label %out
out:
  ret void
}
; Retina (backing-resolution) drawable on or off: the pixel scale follows
define void @win_gl_retina(i32 %on) {
entry:
  %view = load ptr, ptr @W_view
  %noview = icmp eq ptr %view, null
  br i1 %noview, label %out, label %go
go:
  %sel_br = call ptr @sel_registerName(ptr @.s_bestres)
  %flag = trunc i32 %on to i8
  %r0 = call ptr (ptr, ptr, i8) @objc_msgSend(ptr %view, ptr %sel_br, i8 %flag)
  %win = load ptr, ptr @W_win
  %sel_bs = call ptr @sel_registerName(ptr @.s_bscale)
  %bs = call double (ptr, ptr) @objc_msgSend(ptr %win, ptr %sel_bs)
  %bsi = fptosi double %bs to i32
  %bsok = icmp sgt i32 %bsi, 0
  %bsv = select i1 %bsok, i32 %bsi, i32 1
  %ison = icmp ne i32 %on, 0
  %scale = select i1 %ison, i32 %bsv, i32 1
  store i32 %scale, ptr @W_glscale
  call void @win_gl_update()
  br label %out
out:
  ret void
}

; ============================================================================
; The boot splash.
;
; A game that loads 165 MB of terrain, models and audio spends a noticeable
; moment doing it, and until it is done there is nothing on screen: the window
; is not open yet, because opening it is part of what the game does once it has
; something to draw. From the outside that is indistinguishable from a launch
; that failed.
;
; splash_show puts a borderless window on screen with the game's own artwork in
; it. It is called from @lp_pak_boot, before main, so it appears while the
; process is still starting rather than after the expensive part - which is the
; only ordering that helps.
;
; The image comes from the pack as bytes rather than a path, because by the time
; this runs the pack is mounted and the file it came from may not exist on disk
; at all. NSImage reads PNG, JPEG and TIFF from an NSData without being told
; which it is.
;
; The game decides when it goes away, with App.splash_hide(). Nothing hides it
; automatically: only the game knows whether its first real frame is ready, and
; a splash that vanishes before it is leaves the same black gap it was there to
; cover.
;
;   splash_show(bytes, len, bg)   bg is 0xRRGGBB, painted behind the image
;   splash_hide()                 orders it out; safe when there is no splash
; ============================================================================

@.c_image   = private unnamed_addr constant [8 x i8]  c"NSImage\00"
@.c_imgview = private unnamed_addr constant [12 x i8] c"NSImageView\00"
@.c_data    = private unnamed_addr constant [7 x i8]  c"NSData\00"
@.c_color   = private unnamed_addr constant [8 x i8]  c"NSColor\00"
@.s_datawb  = private unnamed_addr constant [22 x i8] c"dataWithBytes:length:\00"
@.s_initdat = private unnamed_addr constant [14 x i8] c"initWithData:\00"
@.s_size    = private unnamed_addr constant [5 x i8]  c"size\00"
@.s_setimg  = private unnamed_addr constant [10 x i8] c"setImage:\00"
@.s_imgscl  = private unnamed_addr constant [17 x i8] c"setImageScaling:\00"
@.s_ofr     = private unnamed_addr constant [21 x i8] c"orderFrontRegardless\00"
@.s_oout    = private unnamed_addr constant [10 x i8] c"orderOut:\00"
@.s_setlvl  = private unnamed_addr constant [10 x i8] c"setLevel:\00"
@.s_setopq  = private unnamed_addr constant [11 x i8] c"setOpaque:\00"
@.s_shadow  = private unnamed_addr constant [14 x i8] c"setHasShadow:\00"
@.s_srgb    = private unnamed_addr constant [35 x i8] c"colorWithSRGBRed:green:blue:alpha:\00"
@.s_setbg   = private unnamed_addr constant [20 x i8] c"setBackgroundColor:\00"
@.s_finlau  = private unnamed_addr constant [16 x i8] c"finishLaunching\00"

@.s_setappicon = private unnamed_addr constant [25 x i8] c"setApplicationIconImage:\00"

; ---------------------------------------------------------------------------
; app_set_icon(bytes, len) - the Dock tile, the Cmd-Tab switcher, the About box.
;
; A BUNDLED app gets this from CFBundleIconFile and needs nothing here. A plain
; binary - which is what `ludic build` produces and what a developer runs all day
; - has no bundle and therefore no icon at all: macOS draws the generic green
; "exec" tile for it. That is not a cosmetic difference to someone who only ever
; sees the game that way.
;
; Bytes, not a path, for the same reason splash_show takes bytes: the caller has
; already resolved it through the pack. NSData copies them, so the caller may free
; its buffer immediately. Anything unreadable leaves the existing icon alone.
define void @app_set_icon(ptr %bytes, i32 %len) {
entry:
  %nodata = icmp eq ptr %bytes, null
  %empty = icmp sle i32 %len, 0
  %skip = or i1 %nodata, %empty
  br i1 %skip, label %out, label %go
go:
  %appcls = call ptr @objc_getClass(ptr @.c_app)
  %sel_sh = call ptr @sel_registerName(ptr @.s_shared)
  %nsapp = call ptr @objc_msgSend(ptr %appcls, ptr %sel_sh)
  %datacls = call ptr @objc_getClass(ptr @.c_data)
  %sel_dwb = call ptr @sel_registerName(ptr @.s_datawb)
  %lz = zext i32 %len to i64
  %data = call ptr (ptr, ptr, ptr, i64) @objc_msgSend(ptr %datacls, ptr %sel_dwb, ptr %bytes, i64 %lz)
  %imgcls = call ptr @objc_getClass(ptr @.c_image)
  %sel_alloc = call ptr @sel_registerName(ptr @.s_alloc)
  %i0 = call ptr @objc_msgSend(ptr %imgcls, ptr %sel_alloc)
  %sel_iwd = call ptr @sel_registerName(ptr @.s_initdat)
  %img = call ptr (ptr, ptr, ptr) @objc_msgSend(ptr %i0, ptr %sel_iwd, ptr %data)
  %noimg = icmp eq ptr %img, null
  br i1 %noimg, label %out, label %set
set:
  %sel_seti = call ptr @sel_registerName(ptr @.s_setappicon)
  %r = call ptr (ptr, ptr, ptr) @objc_msgSend(ptr %nsapp, ptr %sel_seti, ptr %img)
  br label %out
out:
  ret void
}

@W_splash = internal global ptr null

define void @splash_show(ptr %bytes, i32 %len, i32 %bg) {
entry:
  ; only ever one, and nothing to show without bytes
  %had = load ptr, ptr @W_splash
  %again = icmp ne ptr %had, null
  %nodata = icmp eq ptr %bytes, null
  %empty = icmp sle i32 %len, 0
  %skip0 = or i1 %again, %nodata
  %skip = or i1 %skip0, %empty
  br i1 %skip, label %out, label %app

app:
  ; the shared application, as a foreground app. win_open does this too; both
  ; are idempotent, and whichever runs first wins.
  %appcls = call ptr @objc_getClass(ptr @.c_app)
  %sel_sh = call ptr @sel_registerName(ptr @.s_shared)
  %nsapp = call ptr @objc_msgSend(ptr %appcls, ptr %sel_sh)
  %sel_pol = call ptr @sel_registerName(ptr @.s_policy)
  %p0 = call ptr (ptr, ptr, i64) @objc_msgSend(ptr %nsapp, ptr %sel_pol, i64 0)

  ; NSData over the packed bytes, then an NSImage from it
  %datacls = call ptr @objc_getClass(ptr @.c_data)
  %sel_dwb = call ptr @sel_registerName(ptr @.s_datawb)
  %lz = zext i32 %len to i64
  %data = call ptr (ptr, ptr, ptr, i64) @objc_msgSend(ptr %datacls, ptr %sel_dwb, ptr %bytes, i64 %lz)
  %imgcls = call ptr @objc_getClass(ptr @.c_image)
  %sel_alloc = call ptr @sel_registerName(ptr @.s_alloc)
  %i0 = call ptr @objc_msgSend(ptr %imgcls, ptr %sel_alloc)
  %sel_iwd = call ptr @sel_registerName(ptr @.s_initdat)
  %img = call ptr (ptr, ptr, ptr) @objc_msgSend(ptr %i0, ptr %sel_iwd, ptr %data)
  %noimg = icmp eq ptr %img, null
  br i1 %noimg, label %out, label %size

size:
  ; the window takes the artwork's own size, so the game decides how big its
  ; splash is by the pixels it ships
  %sel_size = call ptr @sel_registerName(ptr @.s_size)
  %sz = call %NSPoint (ptr, ptr) @objc_msgSend(ptr %img, ptr %sel_size)
  %wd = extractvalue %NSPoint %sz, 0
  %ht = extractvalue %NSPoint %sz, 1
  %tiny = fcmp olt double %wd, 1.0
  br i1 %tiny, label %out, label %mkwin

mkwin:
  %r0 = insertvalue %CGRect undef, double 0.0, 0
  %r1 = insertvalue %CGRect %r0, double 0.0, 1
  %r2 = insertvalue %CGRect %r1, double %wd, 2
  %rect = insertvalue %CGRect %r2, double %ht, 3

  %appcls2 = call ptr @objc_getClass(ptr @.c_app)
  %sel_sh2 = call ptr @sel_registerName(ptr @.s_shared)
  %nsapp2 = call ptr @objc_msgSend(ptr %appcls2, ptr %sel_sh2)
  %wincls = call ptr @objc_getClass(ptr @.c_win)
  %w0 = call ptr @objc_msgSend(ptr %wincls, ptr %sel_alloc)
  %sel_initw = call ptr @sel_registerName(ptr @.s_initw)
  ; NSWindowStyleMaskBorderless = 0, NSBackingStoreBuffered = 2
  %win = call ptr (ptr, ptr, %CGRect, i64, i64, i8) @objc_msgSend(ptr %w0, ptr %sel_initw, %CGRect %rect, i64 0, i64 2, i8 0)

  ; the colour behind the artwork, so a splash with transparent edges or a
  ; non-matching aspect sits on the game's own backdrop rather than white
  %rr = lshr i32 %bg, 16
  %rm = and i32 %rr, 255
  %gg = lshr i32 %bg, 8
  %gm = and i32 %gg, 255
  %bm = and i32 %bg, 255
  %rf = sitofp i32 %rm to double
  %gf = sitofp i32 %gm to double
  %bf = sitofp i32 %bm to double
  %rn = fdiv double %rf, 255.0
  %gn = fdiv double %gf, 255.0
  %bn = fdiv double %bf, 255.0
  %colcls = call ptr @objc_getClass(ptr @.c_color)
  %sel_srgb = call ptr @sel_registerName(ptr @.s_srgb)
  %col = call ptr (ptr, ptr, double, double, double, double) @objc_msgSend(ptr %colcls, ptr %sel_srgb, double %rn, double %gn, double %bn, double 1.0)
  %sel_setbg = call ptr @sel_registerName(ptr @.s_setbg)
  %b0 = call ptr (ptr, ptr, ptr) @objc_msgSend(ptr %win, ptr %sel_setbg, ptr %col)

  %sel_opq = call ptr @sel_registerName(ptr @.s_setopq)
  %o0 = call ptr (ptr, ptr, i8) @objc_msgSend(ptr %win, ptr %sel_opq, i8 1)
  %sel_shd = call ptr @sel_registerName(ptr @.s_shadow)
  %s0 = call ptr (ptr, ptr, i8) @objc_msgSend(ptr %win, ptr %sel_shd, i8 1)
  ; NSStatusWindowLevel = 25: above the game's own window when it opens, so the
  ; splash is not covered by a window that has nothing in it yet
  %sel_lvl = call ptr @sel_registerName(ptr @.s_setlvl)
  %l0 = call ptr (ptr, ptr, i64) @objc_msgSend(ptr %win, ptr %sel_lvl, i64 25)

  ; an image view filling it, scaled proportionally (NSImageScaleProportionallyUpOrDown = 3)
  %ivcls = call ptr @objc_getClass(ptr @.c_imgview)
  %v0 = call ptr @objc_msgSend(ptr %ivcls, ptr %sel_alloc)
  %sel_initf = call ptr @sel_registerName(ptr @.s_initf)
  %view = call ptr (ptr, ptr, %CGRect) @objc_msgSend(ptr %v0, ptr %sel_initf, %CGRect %rect)
  %sel_simg = call ptr @sel_registerName(ptr @.s_setimg)
  %v1 = call ptr (ptr, ptr, ptr) @objc_msgSend(ptr %view, ptr %sel_simg, ptr %img)
  %sel_scl = call ptr @sel_registerName(ptr @.s_imgscl)
  %v2 = call ptr (ptr, ptr, i64) @objc_msgSend(ptr %view, ptr %sel_scl, i64 3)
  %sel_setcv = call ptr @sel_registerName(ptr @.s_setcv)
  %v3 = call ptr (ptr, ptr, ptr) @objc_msgSend(ptr %win, ptr %sel_setcv, ptr %view)

  %sel_center = call ptr @sel_registerName(ptr @.s_center)
  %c0 = call ptr @objc_msgSend(ptr %win, ptr %sel_center)
  ; orderFrontRegardless, not makeKeyAndOrderFront: the process has not finished
  ; launching and is not the active app yet, and a splash has nothing to type into
  ; The application has to have finished launching before AppKit will map a
  ; window; without this the window exists, draws into its backing store, and is
  ; never composited - which looks exactly like the splash not working.
  %sel_fl = call ptr @sel_registerName(ptr @.s_finlau)
  %fl = call ptr @objc_msgSend(ptr %nsapp2, ptr %sel_fl)
  %sel_actv = call ptr @sel_registerName(ptr @.s_act)
  %av = call ptr (ptr, ptr, i8) @objc_msgSend(ptr %nsapp2, ptr %sel_actv, i8 1)
  %sel_ofr = call ptr @sel_registerName(ptr @.s_ofr)
  %f0 = call ptr @objc_msgSend(ptr %win, ptr %sel_ofr)
  %sel_disp = call ptr @sel_registerName(ptr @.s_disp)
  %d0 = call ptr @objc_msgSend(ptr %win, ptr %sel_disp)

  ; Turn the run loop a few times so the window is mapped and composited now,
  ; rather than whenever the game next happens to pump events - which, during the
  ; asset load this is covering, is never. Once composited the backing store
  ; survives a busy main thread, so it stays on screen while the game loads.
  %np = alloca i32
  store i32 0, ptr %np
  br label %pump
pump:
  %pi = load i32, ptr %np
  %pdone = icmp sge i32 %pi, 24
  br i1 %pdone, label %kept, label %pumpgo
pumpgo:
  %strcls2 = call ptr @objc_getClass(ptr @.c_str)
  %sel_u8 = call ptr @sel_registerName(ptr @.s_utf8)
  %mode2 = call ptr (ptr, ptr, ptr) @objc_msgSend(ptr %strcls2, ptr %sel_u8, ptr @.mode)
  %datecls2 = call ptr @objc_getClass(ptr @.c_date)
  %sel_dp2 = call ptr @sel_registerName(ptr @.s_dpast)
  %date2 = call ptr @objc_msgSend(ptr %datecls2, ptr %sel_dp2)
  %sel_nx = call ptr @sel_registerName(ptr @.s_next)
  %ev = call ptr (ptr, ptr, i64, ptr, ptr, i8) @objc_msgSend(ptr %nsapp2, ptr %sel_nx, i64 -1, ptr %date2, ptr %mode2, i8 1)
  %noev = icmp eq ptr %ev, null
  br i1 %noev, label %pumpnx, label %pumpsend
pumpsend:
  %sel_sd = call ptr @sel_registerName(ptr @.s_send)
  %sd = call ptr (ptr, ptr, ptr) @objc_msgSend(ptr %nsapp2, ptr %sel_sd, ptr %ev)
  br label %pumpnx
pumpnx:
  %pi1 = add i32 %pi, 1
  store i32 %pi1, ptr %np
  br label %pump
kept:
  store ptr %win, ptr @W_splash
  br label %out
out:
  ret void
}

define void @splash_hide() {
entry:
  %win = load ptr, ptr @W_splash
  %none = icmp eq ptr %win, null
  br i1 %none, label %out, label %go
go:
  %sel_oo = call ptr @sel_registerName(ptr @.s_oout)
  %r = call ptr (ptr, ptr, ptr) @objc_msgSend(ptr %win, ptr %sel_oo, ptr null)
  store ptr null, ptr @W_splash
  br label %out
out:
  ret void
}

; ---- win_set_title --------------------------------------------------------------------
; Retitle the window the runtime opened before main: gl_open / gvk_open attach to that window
; rather than opening one, and the title the program asked for would otherwise be dropped in
; favour of the program's name. A no-op without a window.
define void @win_set_title(ptr %title) {
entry:
  %win = load ptr, ptr @W_win
  %nowin = icmp eq ptr %win, null
  %notitle = icmp eq ptr %title, null
  %skip = or i1 %nowin, %notitle
  br i1 %skip, label %out, label %go
go:
  %strcls = call ptr @objc_getClass(ptr @.c_str)
  %sel_utf8 = call ptr @sel_registerName(ptr @.s_utf8)
  %ns = call ptr (ptr, ptr, ptr) @objc_msgSend(ptr %strcls, ptr %sel_utf8, ptr %title)
  %none = icmp eq ptr %ns, null
  br i1 %none, label %out, label %set
set:
  %sel_title = call ptr @sel_registerName(ptr @.s_title)
  %r = call ptr (ptr, ptr, ptr) @objc_msgSend(ptr %win, ptr %sel_title, ptr %ns)
  br label %out
out:
  ret void
}

; ---- App.window_hide / App.window_show ------------------------------------------------
; The game's window leaves the screen and comes back with its view, layer and GL context
; untouched: a launcher steps aside while the game it started runs. The run does not end
; while the window is hidden this way (win_poll's closed-window check skips it). Both are
; no-ops before there is a window.
define void @app_window_hide() {
entry:
  %win = load ptr, ptr @W_win
  %none = icmp eq ptr %win, null
  br i1 %none, label %out, label %go
go:
  store i32 1, ptr @W_apphidden
  %sel_oo = call ptr @sel_registerName(ptr @.s_oout)
  %r = call ptr (ptr, ptr, ptr) @objc_msgSend(ptr %win, ptr %sel_oo, ptr null)
  br label %out
out:
  ret void
}

define void @app_window_show() {
entry:
  %win = load ptr, ptr @W_win
  %none = icmp eq ptr %win, null
  br i1 %none, label %out, label %go
go:
  %sel_mk = call ptr @sel_registerName(ptr @.s_mkey)
  %r = call ptr (ptr, ptr, ptr) @objc_msgSend(ptr %win, ptr %sel_mk, ptr null)
  %app = load ptr, ptr @W_app
  %noapp = icmp eq ptr %app, null
  br i1 %noapp, label %shown, label %activate
activate:
  %sel_act = call ptr @sel_registerName(ptr @.s_act)
  %a = call ptr (ptr, ptr, i8) @objc_msgSend(ptr %app, ptr %sel_act, i8 1)
  br label %shown
shown:
  store i32 0, ptr @W_apphidden
  br label %out
out:
  ret void
}

; ---- the native window, for a graphics API that makes its own surface ------------------
; win32.ll's contract: on macOS the view the game draws in (a Metal-backed layer would hang
; off it); there is no module instance to hand over, so that one is null.
define ptr @win_native_window() {
entry:
  %v = load ptr, ptr @W_view
  ret ptr %v
}
define ptr @win_native_instance() {
entry:
  ret ptr null
}
