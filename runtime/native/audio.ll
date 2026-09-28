; ============================================================================
; audio.ll — the macOS audio backend, written in LLVM IR.
;
; Like cocoa.ll, this compiles no Objective-C and no C: it drives AVAudioEngine
; through the Objective-C runtime's C ABI (objc_getClass / sel_registerName /
; objc_msgSend). ludicc splices it in — alongside cocoa.ll — only when a
; windowed build actually uses Audio.* (g_uses_audio), and links AVFoundation
; then. A sound is decoded once into a PCM buffer and given a voice of its own
; on one shared engine; the opaque voice pointer is handed back to the Ludic
; side (audio.ludic), which keeps the handle table.
;
; A voice is a player node (the buffer, scheduled again on every play), a
; varispeed (the rate) and a small mixer (the volume and the pan), in that order
; into the engine's main mixer. It was an AVAudioPlayer until AVFAudio was found
; to keep a 64-byte AudioQueueOwner for good on every play after the clip had
; finished, whatever was called around it and even after the player was
; released: a valley's footsteps added one a play for as long as it ran. An
; engine's voice replays with nothing kept.
;
; Exposed to Ludic (through the snd_* intrinsics, all is_windowed()-guarded so
; they vanish from a headless build):
;   snd_load(path) -> voice       snd_play(v, loops, rate, vol)
;   snd_stop(v)                   snd_playing(v) -> bool
;   snd_set_volume(v, vol)        snd_set_rate(v, rate)        snd_set_pan(v, pan)
; loops: 0 = once, -1 = forever. rate / vol / pan are 16.16 fixed (value/65536).
; ============================================================================

declare ptr @objc_getClass(ptr)
declare ptr @sel_registerName(ptr)
declare ptr @objc_msgSend(ptr, ptr, ...)
declare ptr @objc_autoreleasePoolPush()
declare void @objc_autoreleasePoolPop(ptr)
declare ptr @malloc(i64)
declare i64 @clock_gettime_nsec_np(i32)

; the one engine every voice plays through, made with the first sound loaded
@snd_engine = internal global ptr null

; a voice is 64 bytes: node, varispeed, mixer, buffer (pointers at 0, 8, 16, 24), the buffer's
; frames (i64 at 32), whether it loops (i32 at 40), its length in seconds (double at 48) and when a
; one-shot ends on the uptime clock (i64 nanoseconds at 56)
@CLOCK_UPTIME_RAW = internal constant i32 8

@.a_nsstr = private unnamed_addr constant [9 x i8] c"NSString\00"
@.a_nsurl = private unnamed_addr constant [6 x i8] c"NSURL\00"
@.a_utf8  = private unnamed_addr constant [22 x i8] c"stringWithUTF8String:\00"
@.a_furl  = private unnamed_addr constant [17 x i8] c"fileURLWithPath:\00"
@.a_alloc = private unnamed_addr constant [6 x i8] c"alloc\00"
@.a_initv = private unnamed_addr constant [5 x i8] c"init\00"
@.a_rel   = private unnamed_addr constant [8 x i8] c"release\00"
@.c_file  = private unnamed_addr constant [12 x i8] c"AVAudioFile\00"
@.c_pcm   = private unnamed_addr constant [17 x i8] c"AVAudioPCMBuffer\00"
@.c_eng   = private unnamed_addr constant [14 x i8] c"AVAudioEngine\00"
@.c_node  = private unnamed_addr constant [18 x i8] c"AVAudioPlayerNode\00"
@.c_vs    = private unnamed_addr constant [21 x i8] c"AVAudioUnitVarispeed\00"
@.c_mix   = private unnamed_addr constant [17 x i8] c"AVAudioMixerNode\00"
@.a_finit = private unnamed_addr constant [22 x i8] c"initForReading:error:\00"
@.a_pfmt  = private unnamed_addr constant [17 x i8] c"processingFormat\00"
@.a_len   = private unnamed_addr constant [7 x i8] c"length\00"
@.a_binit = private unnamed_addr constant [33 x i8] c"initWithPCMFormat:frameCapacity:\00"
@.a_read  = private unnamed_addr constant [22 x i8] c"readIntoBuffer:error:\00"
@.a_mmix  = private unnamed_addr constant [14 x i8] c"mainMixerNode\00"
@.a_attach= private unnamed_addr constant [12 x i8] c"attachNode:\00"
@.a_conn  = private unnamed_addr constant [19 x i8] c"connect:to:format:\00"
@.a_start = private unnamed_addr constant [21 x i8] c"startAndReturnError:\00"
@.a_isrun = private unnamed_addr constant [10 x i8] c"isRunning\00"
@.a_sched = private unnamed_addr constant [49 x i8] c"scheduleBuffer:atTime:options:completionHandler:\00"
@.a_play  = private unnamed_addr constant [5 x i8] c"play\00"
@.a_stop  = private unnamed_addr constant [5 x i8] c"stop\00"
@.a_isply = private unnamed_addr constant [10 x i8] c"isPlaying\00"
@.a_svol  = private unnamed_addr constant [11 x i8] c"setVolume:\00"
@.a_srate = private unnamed_addr constant [9 x i8] c"setRate:\00"
@.a_span  = private unnamed_addr constant [8 x i8] c"setPan:\00"
@.a_srt   = private unnamed_addr constant [11 x i8] c"sampleRate\00"

; [[cls alloc] init]
define internal ptr @snd_new(ptr %clsname) {
entry:
  %cls = call ptr @objc_getClass(ptr %clsname)
  %sa = call ptr @sel_registerName(ptr @.a_alloc)
  %o0 = call ptr (ptr, ptr) @objc_msgSend(ptr %cls, ptr %sa)
  %si = call ptr @sel_registerName(ptr @.a_initv)
  %o = call ptr (ptr, ptr) @objc_msgSend(ptr %o0, ptr %si)
  ret ptr %o
}

; the engine, made the first time a sound is loaded
define internal ptr @snd_engine_get() {
entry:
  %e = load ptr, ptr @snd_engine
  %have = icmp ne ptr %e, null
  br i1 %have, label %done, label %make
make:
  %n = call ptr @snd_new(ptr @.c_eng)
  store ptr %n, ptr @snd_engine
  br label %done
done:
  %r = load ptr, ptr @snd_engine
  ret ptr %r
}

; the engine running: after a start, and again after the output device changed (which stops it)
define internal void @snd_engine_run(ptr %e) {
entry:
  %nil = icmp eq ptr %e, null
  br i1 %nil, label %out, label %ask
ask:
  %sr = call ptr @sel_registerName(ptr @.a_isrun)
  %run = call i8 (ptr, ptr) @objc_msgSend(ptr %e, ptr %sr)
  %on = icmp ne i8 %run, 0
  br i1 %on, label %out, label %start
start:
  %ss = call ptr @sel_registerName(ptr @.a_start)
  %ok = call i8 (ptr, ptr, ptr) @objc_msgSend(ptr %e, ptr %ss, ptr null)
  br label %out
out:
  ret void
}

; Load a sound file into a voice; returns the voice (or null).
define ptr @snd_load(ptr %path) {
entry:
  %pool = call ptr @objc_autoreleasePoolPush()
  %strcls = call ptr @objc_getClass(ptr @.a_nsstr)
  %sel_u = call ptr @sel_registerName(ptr @.a_utf8)
  %s = call ptr (ptr, ptr, ptr) @objc_msgSend(ptr %strcls, ptr %sel_u, ptr %path)
  %urlcls = call ptr @objc_getClass(ptr @.a_nsurl)
  %sel_f = call ptr @sel_registerName(ptr @.a_furl)
  %url = call ptr (ptr, ptr, ptr) @objc_msgSend(ptr %urlcls, ptr %sel_f, ptr %s)
  %srel = call ptr @sel_registerName(ptr @.a_rel)
  %sa = call ptr @sel_registerName(ptr @.a_alloc)
  %fcls = call ptr @objc_getClass(ptr @.c_file)
  %nocls = icmp eq ptr %fcls, null
  br i1 %nocls, label %fail, label %open
open:
  %f0 = call ptr (ptr, ptr) @objc_msgSend(ptr %fcls, ptr %sa)
  %sfi = call ptr @sel_registerName(ptr @.a_finit)
  %file = call ptr (ptr, ptr, ptr, ptr) @objc_msgSend(ptr %f0, ptr %sfi, ptr %url, ptr null)
  %nofile = icmp eq ptr %file, null
  br i1 %nofile, label %fail, label %read
read:
  %spf = call ptr @sel_registerName(ptr @.a_pfmt)
  %fmt = call ptr (ptr, ptr) @objc_msgSend(ptr %file, ptr %spf)
  %sl = call ptr @sel_registerName(ptr @.a_len)
  %frames = call i64 (ptr, ptr) @objc_msgSend(ptr %file, ptr %sl)
  %fr32 = trunc i64 %frames to i32
  %pcmcls = call ptr @objc_getClass(ptr @.c_pcm)
  %b0 = call ptr (ptr, ptr) @objc_msgSend(ptr %pcmcls, ptr %sa)
  %sbi = call ptr @sel_registerName(ptr @.a_binit)
  %buf = call ptr (ptr, ptr, ptr, i32) @objc_msgSend(ptr %b0, ptr %sbi, ptr %fmt, i32 %fr32)
  %nobuf = icmp eq ptr %buf, null
  br i1 %nobuf, label %fail_file, label %fill
fill:
  %srd = call ptr @sel_registerName(ptr @.a_read)
  %rok = call i8 (ptr, ptr, ptr, ptr) @objc_msgSend(ptr %file, ptr %srd, ptr %buf, ptr null)
  %good = icmp ne i8 %rok, 0
  br i1 %good, label %voice, label %fail_buf
voice:
  %e = call ptr @snd_engine_get()
  %smm = call ptr @sel_registerName(ptr @.a_mmix)
  %main = call ptr (ptr, ptr) @objc_msgSend(ptr %e, ptr %smm)
  %node = call ptr @snd_new(ptr @.c_node)
  %vs = call ptr @snd_new(ptr @.c_vs)
  %mix = call ptr @snd_new(ptr @.c_mix)
  %sat = call ptr @sel_registerName(ptr @.a_attach)
  %a1 = call ptr (ptr, ptr, ptr) @objc_msgSend(ptr %e, ptr %sat, ptr %node)
  %a2 = call ptr (ptr, ptr, ptr) @objc_msgSend(ptr %e, ptr %sat, ptr %vs)
  %a3 = call ptr (ptr, ptr, ptr) @objc_msgSend(ptr %e, ptr %sat, ptr %mix)
  %sc = call ptr @sel_registerName(ptr @.a_conn)
  %c1 = call ptr (ptr, ptr, ptr, ptr, ptr) @objc_msgSend(ptr %e, ptr %sc, ptr %node, ptr %vs, ptr %fmt)
  %c2 = call ptr (ptr, ptr, ptr, ptr, ptr) @objc_msgSend(ptr %e, ptr %sc, ptr %vs, ptr %mix, ptr %fmt)
  %c3 = call ptr (ptr, ptr, ptr, ptr, ptr) @objc_msgSend(ptr %e, ptr %sc, ptr %mix, ptr %main, ptr %fmt)
  call void @snd_engine_run(ptr %e)
  %rf = call ptr (ptr, ptr) @objc_msgSend(ptr %file, ptr %srel)
  %ssr = call ptr @sel_registerName(ptr @.a_srt)
  %rate = call double (ptr, ptr) @objc_msgSend(ptr %fmt, ptr %ssr)
  %frd = sitofp i64 %frames to double
  %ratepos = fcmp ogt double %rate, 0.0
  %rate1 = select i1 %ratepos, double %rate, double 4.8e+04
  %secs = fdiv double %frd, %rate1
  %v = call ptr @malloc(i64 64)
  store ptr %node, ptr %v
  %v8 = getelementptr i8, ptr %v, i64 8
  store ptr %vs, ptr %v8
  %v16 = getelementptr i8, ptr %v, i64 16
  store ptr %mix, ptr %v16
  %v24 = getelementptr i8, ptr %v, i64 24
  store ptr %buf, ptr %v24
  %v32 = getelementptr i8, ptr %v, i64 32
  store i64 %frames, ptr %v32
  %v40 = getelementptr i8, ptr %v, i64 40
  store i32 0, ptr %v40
  %v48 = getelementptr i8, ptr %v, i64 48
  store double %secs, ptr %v48
  %v56 = getelementptr i8, ptr %v, i64 56
  store i64 0, ptr %v56
  call void @objc_autoreleasePoolPop(ptr %pool)
  ret ptr %v
fail_buf:
  %rb = call ptr (ptr, ptr) @objc_msgSend(ptr %buf, ptr %srel)
  br label %fail_file
fail_file:
  %rf2 = call ptr (ptr, ptr) @objc_msgSend(ptr %file, ptr %srel)
  br label %fail
fail:
  call void @objc_autoreleasePoolPop(ptr %pool)
  ret ptr null
}

define internal ptr @snd_part(ptr %v, i64 %off) {
entry:
  %a = getelementptr i8, ptr %v, i64 %off
  %p = load ptr, ptr %a
  ret ptr %p
}

; a 16.16 value as a float
define internal float @snd_fx(i32 %x) {
entry:
  %f = sitofp i32 %x to float
  %r = fdiv float %f, 6.5536e+04
  ret float %r
}

; Rewind to the start and play, applying loops / rate / volume: the buffer scheduled again over
; whatever was playing, looping when loops is -1.
define void @snd_play(ptr %v, i32 %loops, i32 %rate, i32 %vol) {
entry:
  %nil = icmp eq ptr %v, null
  br i1 %nil, label %out, label %go
go:
  ; play autoreleases an AVAudioTime: its own pool, so a sound played before a frame's pool keeps nothing
  %pool = call ptr @objc_autoreleasePoolPush()
  %e = load ptr, ptr @snd_engine
  call void @snd_engine_run(ptr %e)
  %node = call ptr @snd_part(ptr %v, i64 0)
  %vs = call ptr @snd_part(ptr %v, i64 8)
  %mix = call ptr @snd_part(ptr %v, i64 16)
  %buf = call ptr @snd_part(ptr %v, i64 24)
  %sst = call ptr @sel_registerName(ptr @.a_stop)
  %r0 = call ptr (ptr, ptr) @objc_msgSend(ptr %node, ptr %sst)
  %sv = call ptr @sel_registerName(ptr @.a_svol)
  %vf = call float @snd_fx(i32 %vol)
  %r1 = call ptr (ptr, ptr, float) @objc_msgSend(ptr %mix, ptr %sv, float %vf)
  %sr = call ptr @sel_registerName(ptr @.a_srate)
  %rf = call float @snd_fx(i32 %rate)
  %r2 = call ptr (ptr, ptr, float) @objc_msgSend(ptr %vs, ptr %sr, float %rf)
  %loop = icmp eq i32 %loops, -1
  %opt = select i1 %loop, i64 3, i64 2          ; AVAudioPlayerNodeBufferLoops (1) | Interrupts (2)
  %lp = zext i1 %loop to i32
  %v40 = getelementptr i8, ptr %v, i64 40
  store i32 %lp, ptr %v40
  %ssc = call ptr @sel_registerName(ptr @.a_sched)
  %r3 = call ptr (ptr, ptr, ptr, ptr, i64, ptr) @objc_msgSend(ptr %node, ptr %ssc, ptr %buf, ptr null, i64 %opt, ptr null)
  %sp = call ptr @sel_registerName(ptr @.a_play)
  %r4 = call ptr (ptr, ptr) @objc_msgSend(ptr %node, ptr %sp)
  ; a one-shot ends its length (at this rate) from now
  %v48 = getelementptr i8, ptr %v, i64 48
  %secs = load double, ptr %v48
  %rpos = fcmp ogt float %rf, 0.0
  %rf1 = select i1 %rpos, float %rf, float 1.0
  %rd = fpext float %rf1 to double
  %dur = fdiv double %secs, %rd
  %durns = fmul double %dur, 1.0e+09
  %dns = fptosi double %durns to i64
  %clk = load i32, ptr @CLOCK_UPTIME_RAW
  %now = call i64 @clock_gettime_nsec_np(i32 %clk)
  %end = add i64 %now, %dns
  %v56 = getelementptr i8, ptr %v, i64 56
  store i64 %end, ptr %v56
  call void @objc_autoreleasePoolPop(ptr %pool)
  br label %out
out:
  ret void
}

define void @snd_stop(ptr %v) {
entry:
  %nil = icmp eq ptr %v, null
  br i1 %nil, label %out, label %go
go:
  %node = call ptr @snd_part(ptr %v, i64 0)
  %sst = call ptr @sel_registerName(ptr @.a_stop)
  %r = call ptr (ptr, ptr) @objc_msgSend(ptr %node, ptr %sst)
  %v40 = getelementptr i8, ptr %v, i64 40
  store i32 0, ptr %v40
  %v56 = getelementptr i8, ptr %v, i64 56
  store i64 0, ptr %v56
  br label %out
out:
  ret void
}

; Playing while the node plays and, for a one-shot, until the time its buffer ends: a player node
; goes on "playing" silence after its buffer, and asking it where it is made two AVAudioTime objects a
; call that nothing gave back, so the end is worked out when it is played and only compared here.
define i32 @snd_playing(ptr %v) {
entry:
  %nil = icmp eq ptr %v, null
  br i1 %nil, label %zero, label %ask
ask:
  %node = call ptr @snd_part(ptr %v, i64 0)
  %sip = call ptr @sel_registerName(ptr @.a_isply)
  %b = call i8 (ptr, ptr) @objc_msgSend(ptr %node, ptr %sip)
  %on = icmp ne i8 %b, 0
  br i1 %on, label %loopq, label %zero
loopq:
  %v40 = getelementptr i8, ptr %v, i64 40
  %lp = load i32, ptr %v40
  %looping = icmp ne i32 %lp, 0
  br i1 %looping, label %one, label %clock
clock:
  %v56 = getelementptr i8, ptr %v, i64 56
  %end = load i64, ptr %v56
  %clk = load i32, ptr @CLOCK_UPTIME_RAW
  %now = call i64 @clock_gettime_nsec_np(i32 %clk)
  %left = icmp slt i64 %now, %end
  %li = zext i1 %left to i32
  ret i32 %li
one:
  ret i32 1
zero:
  ret i32 0
}

define void @snd_set_volume(ptr %v, i32 %vol) {
entry:
  %nil = icmp eq ptr %v, null
  br i1 %nil, label %out, label %go
go:
  %mix = call ptr @snd_part(ptr %v, i64 16)
  %sv = call ptr @sel_registerName(ptr @.a_svol)
  %f = call float @snd_fx(i32 %vol)
  %r = call ptr (ptr, ptr, float) @objc_msgSend(ptr %mix, ptr %sv, float %f)
  br label %out
out:
  ret void
}

; Stereo position, -1.0 (hard left) .. 1.0 (hard right): the voice's mixer's pan into the main
; mixer, so a one-shot can be placed before it is fired.
define void @snd_set_pan(ptr %v, i32 %pan) {
entry:
  %nil = icmp eq ptr %v, null
  br i1 %nil, label %out, label %go
go:
  %mix = call ptr @snd_part(ptr %v, i64 16)
  %sp = call ptr @sel_registerName(ptr @.a_span)
  %f = call float @snd_fx(i32 %pan)
  %r = call ptr (ptr, ptr, float) @objc_msgSend(ptr %mix, ptr %sp, float %f)
  br label %out
out:
  ret void
}

define void @snd_set_rate(ptr %v, i32 %rate) {
entry:
  %nil = icmp eq ptr %v, null
  br i1 %nil, label %out, label %go
go:
  %vs = call ptr @snd_part(ptr %v, i64 8)
  %sr = call ptr @sel_registerName(ptr @.a_srate)
  %f = call float @snd_fx(i32 %rate)
  %r = call ptr (ptr, ptr, float) @objc_msgSend(ptr %vs, ptr %sr, float %f)
  br label %out
out:
  ret void
}
