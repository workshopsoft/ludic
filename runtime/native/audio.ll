; ============================================================================
; audio.ll — the macOS audio backend, written in LLVM IR.
;
; Like cocoa.ll, this compiles no Objective-C and no C: it drives AVAudioPlayer
; through the Objective-C runtime's C ABI (objc_getClass / sel_registerName /
; objc_msgSend). ludicc splices it in — alongside cocoa.ll — only when a
; windowed build actually uses Audio.* (g_uses_audio), and links AVFoundation
; then. A sound is loaded once into an AVAudioPlayer and the opaque player
; pointer is handed back to the Ludic side (audio.ludic), which keeps the handle
; table; these functions just operate on one player at a time.
;
; Exposed to Ludic (through the snd_* intrinsics, all is_windowed()-guarded so
; they vanish from a headless build):
;   snd_load(path) -> player      snd_play(p, loops, rate, vol)
;   snd_stop(p)                   snd_playing(p) -> bool
;   snd_set_volume(p, vol)        snd_set_rate(p, rate)        snd_set_pan(p, pan)
; loops: 0 = once, -1 = forever. rate / vol are 16.16 fixed (value/65536).
; ============================================================================

declare ptr @objc_getClass(ptr)
declare ptr @sel_registerName(ptr)
declare ptr @objc_msgSend(ptr, ptr, ...)

@.a_avp   = private unnamed_addr constant [14 x i8] c"AVAudioPlayer\00"
@.a_nsstr = private unnamed_addr constant [9 x i8]  c"NSString\00"
@.a_nsurl = private unnamed_addr constant [6 x i8]  c"NSURL\00"
@.a_utf8  = private unnamed_addr constant [22 x i8] c"stringWithUTF8String:\00"
@.a_furl  = private unnamed_addr constant [17 x i8] c"fileURLWithPath:\00"
@.a_alloc = private unnamed_addr constant [6 x i8]  c"alloc\00"
@.a_init  = private unnamed_addr constant [29 x i8] c"initWithContentsOfURL:error:\00"
@.a_enrat = private unnamed_addr constant [15 x i8] c"setEnableRate:\00"
@.a_prep  = private unnamed_addr constant [14 x i8] c"prepareToPlay\00"
@.a_svol  = private unnamed_addr constant [11 x i8] c"setVolume:\00"
@.a_srate = private unnamed_addr constant [9 x i8]  c"setRate:\00"
@.a_sloop = private unnamed_addr constant [18 x i8] c"setNumberOfLoops:\00"
@.a_sctime= private unnamed_addr constant [16 x i8] c"setCurrentTime:\00"
@.a_play  = private unnamed_addr constant [5 x i8]  c"play\00"
@.a_stop  = private unnamed_addr constant [5 x i8]  c"stop\00"
@.a_isply = private unnamed_addr constant [10 x i8] c"isPlaying\00"
@.a_span  = private unnamed_addr constant [8 x i8]  c"setPan:\00"

; Load a sound file into an AVAudioPlayer; returns the player (or null).
define ptr @snd_load(ptr %path) {
entry:
  %strcls = call ptr @objc_getClass(ptr @.a_nsstr)
  %sel_u = call ptr @sel_registerName(ptr @.a_utf8)
  %s = call ptr (ptr, ptr, ptr) @objc_msgSend(ptr %strcls, ptr %sel_u, ptr %path)
  %urlcls = call ptr @objc_getClass(ptr @.a_nsurl)
  %sel_f = call ptr @sel_registerName(ptr @.a_furl)
  %url = call ptr (ptr, ptr, ptr) @objc_msgSend(ptr %urlcls, ptr %sel_f, ptr %s)
  %avpcls = call ptr @objc_getClass(ptr @.a_avp)
  %nocls = icmp eq ptr %avpcls, null
  br i1 %nocls, label %fail, label %alloc
alloc:
  %sel_a = call ptr @sel_registerName(ptr @.a_alloc)
  %p0 = call ptr (ptr, ptr) @objc_msgSend(ptr %avpcls, ptr %sel_a)
  %sel_i = call ptr @sel_registerName(ptr @.a_init)
  ; initWithContentsOfURL:error: — pass NULL for the NSError** out-parameter.
  %p = call ptr (ptr, ptr, ptr, ptr) @objc_msgSend(ptr %p0, ptr %sel_i, ptr %url, ptr null)
  %nop = icmp eq ptr %p, null
  br i1 %nop, label %fail, label %ready
ready:
  ; enable rate control so setRate: takes effect, and pre-buffer.
  %sel_er = call ptr @sel_registerName(ptr @.a_enrat)
  %e = call ptr (ptr, ptr, i8) @objc_msgSend(ptr %p, ptr %sel_er, i8 1)
  %sel_pr = call ptr @sel_registerName(ptr @.a_prep)
  %pr = call ptr (ptr, ptr) @objc_msgSend(ptr %p, ptr %sel_pr)
  ret ptr %p
fail:
  ret ptr null
}

; Rewind to the start and play, applying loops / rate / volume.
define void @snd_play(ptr %p, i32 %loops, i32 %rate, i32 %vol) {
entry:
  %nil = icmp eq ptr %p, null
  br i1 %nil, label %out, label %go
go:
  %vf = sitofp i32 %vol to float
  %v = fdiv float %vf, 6.5536e+04
  %sel_v = call ptr @sel_registerName(ptr @.a_svol)
  %rv = call ptr (ptr, ptr, float) @objc_msgSend(ptr %p, ptr %sel_v, float %v)
  %rf = sitofp i32 %rate to float
  %r = fdiv float %rf, 6.5536e+04
  %sel_r = call ptr @sel_registerName(ptr @.a_srate)
  %rr = call ptr (ptr, ptr, float) @objc_msgSend(ptr %p, ptr %sel_r, float %r)
  %l64 = sext i32 %loops to i64
  %sel_l = call ptr @sel_registerName(ptr @.a_sloop)
  %rl = call ptr (ptr, ptr, i64) @objc_msgSend(ptr %p, ptr %sel_l, i64 %l64)
  %sel_ct = call ptr @sel_registerName(ptr @.a_sctime)
  %rc = call ptr (ptr, ptr, double) @objc_msgSend(ptr %p, ptr %sel_ct, double 0.0)
  %sel_p = call ptr @sel_registerName(ptr @.a_play)
  %rp = call ptr (ptr, ptr) @objc_msgSend(ptr %p, ptr %sel_p)
  br label %out
out:
  ret void
}

define void @snd_stop(ptr %p) {
entry:
  %nil = icmp eq ptr %p, null
  br i1 %nil, label %out, label %go
go:
  %sel_s = call ptr @sel_registerName(ptr @.a_stop)
  %rs = call ptr (ptr, ptr) @objc_msgSend(ptr %p, ptr %sel_s)
  %sel_ct = call ptr @sel_registerName(ptr @.a_sctime)
  %rc = call ptr (ptr, ptr, double) @objc_msgSend(ptr %p, ptr %sel_ct, double 0.0)
  br label %out
out:
  ret void
}

define i32 @snd_playing(ptr %p) {
entry:
  %nil = icmp eq ptr %p, null
  br i1 %nil, label %zero, label %ask
ask:
  %sel_ip = call ptr @sel_registerName(ptr @.a_isply)
  %b = call i8 (ptr, ptr) @objc_msgSend(ptr %p, ptr %sel_ip)
  %bi = zext i8 %b to i32
  %r = and i32 %bi, 1
  ret i32 %r
zero:
  ret i32 0
}

define void @snd_set_volume(ptr %p, i32 %vol) {
entry:
  %nil = icmp eq ptr %p, null
  br i1 %nil, label %out, label %go
go:
  %vf = sitofp i32 %vol to float
  %v = fdiv float %vf, 6.5536e+04
  %sel_v = call ptr @sel_registerName(ptr @.a_svol)
  %rv = call ptr (ptr, ptr, float) @objc_msgSend(ptr %p, ptr %sel_v, float %v)
  br label %out
out:
  ret void
}

; Stereo position, -1.0 (hard left) .. 1.0 (hard right). AVAudioPlayer's own pan, so it
; costs nothing and needs no mixer: a one-shot can be placed before it is fired.
define void @snd_set_pan(ptr %p, i32 %pan) {
entry:
  %nil = icmp eq ptr %p, null
  br i1 %nil, label %out, label %go
go:
  %pf = sitofp i32 %pan to float
  %v = fdiv float %pf, 6.5536e+04
  %sel_p = call ptr @sel_registerName(ptr @.a_span)
  %rp = call ptr (ptr, ptr, float) @objc_msgSend(ptr %p, ptr %sel_p, float %v)
  br label %out
out:
  ret void
}

define void @snd_set_rate(ptr %p, i32 %rate) {
entry:
  %nil = icmp eq ptr %p, null
  br i1 %nil, label %out, label %go
go:
  %rf = sitofp i32 %rate to float
  %r = fdiv float %rf, 6.5536e+04
  %sel_r = call ptr @sel_registerName(ptr @.a_srate)
  %rr = call ptr (ptr, ptr, float) @objc_msgSend(ptr %p, ptr %sel_r, float %r)
  br label %out
out:
  ret void
}
