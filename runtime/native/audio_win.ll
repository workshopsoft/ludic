; ============================================================================
; audio_win.ll — the Windows audio backend, written in LLVM IR.
;
; audio.ll's contract over XAudio2 (xaudio2_9.dll, on every Windows 10 and 11).
; ludicc links it into a windowed Windows build that uses Audio.*, with xaudio2
; and ole32. A sound is loaded once into a player and the opaque player pointer
; goes back to audio.ludic, which keeps the handle table.
;
;   snd_load(path) -> player      snd_play(p, loops, rate, vol)
;   snd_stop(p)                   snd_playing(p) -> bool
;   snd_set_volume(p, vol)        snd_set_rate(p, rate)        snd_set_pan(p, pan)
; loops: 0 = once, -1 = forever, n = n more times. rate / vol / pan are 16.16 fixed.
;
; A player is one XAudio2 source voice holding one clip, which is what an
; AVAudioPlayer is: firing it again restarts it rather than layering a copy.
;
; Only RIFF WAVE is read - PCM or IEEE float, any rate and channel count - because
; that is what a Ludic game ships (AVAudioPlayer also reads MP3 and AAC; a game that
; wants those on Windows wants a decoder here first).
;
; The clip's bytes come through @lp_pak_open when the program has it, so a sound
; inside a shipped game's pack loads like every other asset. On macOS
; AVAudioPlayer takes a filesystem path and the pack is invisible to it, which is
; the reason Maroon Lake's sound_load() copies clips out of the pack; here the
; first Audio.load already succeeds. lp_pak_open is referenced weakly: a program
; that never opens a file has no pack runtime, and then the file is opened directly.
;
; COM, spoken from IR: every object's first word is its vtable, and a method is a
; load from a fixed slot. The slots are xaudio2.h's declaration order:
;   IXAudio2              5 CreateSourceVoice  7 CreateMasteringVoice
;   IXAudio2Voice         0 GetVoiceDetails  12 SetVolume  16 SetOutputMatrix  18 DestroyVoice
;   IXAudio2SourceVoice   (after the 19 above) 19 Start  20 Stop  21 SubmitSourceBuffer
;                         22 FlushSourceBuffers  25 GetState  26 SetFrequencyRatio
; IXAudio2Voice does not derive from IUnknown, so its slot 0 is GetVoiceDetails.
; ============================================================================

declare i32 @CoInitializeEx(ptr, i32)
declare i32 @XAudio2Create(ptr, i32, i32)
declare extern_weak ptr @lp_pak_open(ptr, ptr)
declare ptr @_fsopen(ptr, ptr, i32)
declare i32 @_fseeki64(ptr, i64, i32)
declare i64 @_ftelli64(ptr)
declare i64 @fread(ptr, i64, i64, ptr)
declare i32 @fclose(ptr)
declare ptr @malloc(i64)
declare void @free(ptr)
declare void @llvm.memset.p0.i64(ptr, i8, i64, i1)
declare void @llvm.memcpy.p0.p0.i64(ptr, ptr, i64, i1)

@.a_rb = private unnamed_addr constant [3 x i8] c"rb\00"

@A_xa     = internal global ptr null      ; IXAudio2
@A_master = internal global ptr null      ; IXAudio2MasteringVoice
@A_mch    = internal global i32 2         ; the mastering voice's channel count
@A_tried  = internal global i32 0         ; the engine is attempted once, not per clip

; the method in slot %slot of a COM object's vtable
define internal ptr @a_fn(ptr %obj, i64 %slot) {
entry:
  %vt = load ptr, ptr %obj
  %p = getelementptr ptr, ptr %vt, i64 %slot
  %f = load ptr, ptr %p
  ret ptr %f
}

; 1 when the engine and its mastering voice exist. A machine with no audio device
; fails here once and every later call is silent, as a headless build is.
define internal i32 @a_engine() {
entry:
  %xap = alloca ptr, align 8
  %mvp = alloca ptr, align 8
  %det = alloca [16 x i8], align 4
  %have = load ptr, ptr @A_xa
  %up = icmp ne ptr %have, null
  br i1 %up, label %yes, label %first
first:
  %tried = load i32, ptr @A_tried
  %again = icmp ne i32 %tried, 0
  br i1 %again, label %no, label %make
make:
  store i32 1, ptr @A_tried
  ; COINIT_MULTITHREADED; S_FALSE (already initialised) and RPC_E_CHANGED_MODE are both fine
  %ci = call i32 @CoInitializeEx(ptr null, i32 0)
  store ptr null, ptr %xap
  %hr = call i32 @XAudio2Create(ptr %xap, i32 0, i32 0)          ; XAUDIO2_USE_DEFAULT_PROCESSOR
  %bad = icmp slt i32 %hr, 0
  br i1 %bad, label %no, label %master
master:
  %xa = load ptr, ptr %xap
  store ptr %xa, ptr @A_xa
  store ptr null, ptr %mvp
  %cmv = call ptr @a_fn(ptr %xa, i64 7)
  ; default channels and rate, no flags, the default device, no effects, AudioCategory_GameEffects (6)
  %hr2 = call i32 %cmv(ptr %xa, ptr %mvp, i32 0, i32 0, i32 0, ptr null, ptr null, i32 6)
  %bad2 = icmp slt i32 %hr2, 0
  br i1 %bad2, label %nomaster, label %details
nomaster:
  store ptr null, ptr @A_xa
  br label %no
details:
  %mv = load ptr, ptr %mvp
  store ptr %mv, ptr @A_master
  call void @llvm.memset.p0.i64(ptr %det, i8 0, i64 16, i1 false)
  %gvd = call ptr @a_fn(ptr %mv, i64 0)
  call void %gvd(ptr %mv, ptr %det)
  %chp = getelementptr i8, ptr %det, i64 8                        ; XAUDIO2_VOICE_DETAILS.InputChannels
  %ch = load i32, ptr %chp
  store i32 %ch, ptr @A_mch
  br label %yes
yes:
  ret i32 1
no:
  ret i32 0
}

; Player: voice 0, file bytes 8, sample data 16, data bytes 24, channels 28, started 32.
define ptr @snd_load(ptr %path) {
entry:
  %wfx = alloca [20 x i8], align 4                                ; WAVEFORMATEX, 18 bytes packed
  %vpp = alloca ptr, align 8
  %offp = alloca i32, align 4
  %fmtok = alloca i32, align 4
  %doffp = alloca i32, align 4
  %dlenp = alloca i32, align 4
  %nopath = icmp eq ptr %path, null
  br i1 %nopath, label %fail, label %eng
eng:
  %e = call i32 @a_engine()
  %noeng = icmp eq i32 %e, 0
  br i1 %noeng, label %fail, label %open
open:
  %haspak = icmp ne ptr @lp_pak_open, null
  br i1 %haspak, label %viapak, label %direct
viapak:
  %fp = call ptr @lp_pak_open(ptr %path, ptr @.a_rb)
  br label %opened
direct:
  %fd = call ptr @_fsopen(ptr %path, ptr @.a_rb, i32 64)          ; _SH_DENYNO
  br label %opened
opened:
  %f = phi ptr [ %fp, %viapak ], [ %fd, %direct ]
  %nof = icmp eq ptr %f, null
  br i1 %nof, label %fail, label %size
size:
  %s1 = call i32 @_fseeki64(ptr %f, i64 0, i32 2)
  %n64 = call i64 @_ftelli64(ptr %f)
  %s2 = call i32 @_fseeki64(ptr %f, i64 0, i32 0)
  %small = icmp slt i64 %n64, 44
  %huge = icmp sgt i64 %n64, 2147483647
  %nogo = or i1 %small, %huge
  br i1 %nogo, label %closefail, label %read
closefail:
  %c0 = call i32 @fclose(ptr %f)
  br label %fail
read:
  %buf = call ptr @malloc(i64 %n64)
  %rd = call i64 @fread(ptr %buf, i64 1, i64 %n64, ptr %f)
  %c1 = call i32 @fclose(ptr %f)
  %n = trunc i64 %rd to i32
  %riff = load i32, ptr %buf
  %isriff = icmp eq i32 %riff, 1179011410                          ; "RIFF"
  %wavep = getelementptr i8, ptr %buf, i64 8
  %wave = load i32, ptr %wavep
  %iswave = icmp eq i32 %wave, 1163280727                          ; "WAVE"
  %okhdr = and i1 %isriff, %iswave
  br i1 %okhdr, label %chunks, label %freefail
chunks:
  store i32 12, ptr %offp
  store i32 0, ptr %fmtok
  store i32 -1, ptr %doffp
  store i32 0, ptr %dlenp
  br label %walk
walk:
  %off = load i32, ptr %offp
  %hdrend = add i32 %off, 8
  %fits = icmp sle i32 %hdrend, %n
  br i1 %fits, label %chunk, label %walked
chunk:
  %idp = getelementptr i8, ptr %buf, i32 %off
  %id = load i32, ptr %idp, align 1
  %szo = add i32 %off, 4
  %szp = getelementptr i8, ptr %buf, i32 %szo
  %sz = load i32, ptr %szp, align 1
  %isfmt = icmp eq i32 %id, 544501094                              ; "fmt "
  br i1 %isfmt, label %fmt, label %notfmt
fmt:
  %fmtbig = icmp sge i32 %sz, 16
  br i1 %fmtbig, label %fmtcopy, label %advance
fmtcopy:
  %body = getelementptr i8, ptr %buf, i32 %hdrend
  call void @llvm.memset.p0.i64(ptr %wfx, i8 0, i64 20, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr %wfx, ptr %body, i64 16, i1 false)   ; cbSize stays 0
  store i32 1, ptr %fmtok
  br label %advance
notfmt:
  %isdata = icmp eq i32 %id, 1635017060                            ; "data"
  br i1 %isdata, label %data, label %advance
data:
  store i32 %hdrend, ptr %doffp
  %left = sub i32 %n, %hdrend
  %over = icmp sgt i32 %sz, %left
  %dl = select i1 %over, i32 %left, i32 %sz
  store i32 %dl, ptr %dlenp
  br label %advance
advance:
  ; chunks are padded to an even length; a negative size would walk backwards, so stop
  %neg = icmp slt i32 %sz, 0
  br i1 %neg, label %walked, label %step
step:
  %pad = and i32 %sz, 1
  %adv = add i32 %sz, %pad
  %next = add i32 %hdrend, %adv
  store i32 %next, ptr %offp
  br label %walk
walked:
  %gotfmt = load i32, ptr %fmtok
  %hasfmt = icmp ne i32 %gotfmt, 0
  %doff = load i32, ptr %doffp
  %hasdata = icmp sge i32 %doff, 0
  %both = and i1 %hasfmt, %hasdata
  br i1 %both, label %format, label %freefail
format:
  ; WAVE_FORMAT_PCM (1) or WAVE_FORMAT_IEEE_FLOAT (3)
  %tag = load i16, ptr %wfx
  %pcm = icmp eq i16 %tag, 1
  %flt = icmp eq i16 %tag, 3
  %known = or i1 %pcm, %flt
  br i1 %known, label %voice, label %freefail
voice:
  %xa = load ptr, ptr @A_xa
  store ptr null, ptr %vpp
  %csv = call ptr @a_fn(ptr %xa, i64 5)
  ; no flags, a pitch range up to 4x, no callback, the mastering voice, no effects
  %hr = call i32 %csv(ptr %xa, ptr %vpp, ptr %wfx, i32 0, float 4.000000e+00, ptr null, ptr null, ptr null)
  %badv = icmp slt i32 %hr, 0
  br i1 %badv, label %freefail, label %keep
keep:
  %v = load ptr, ptr %vpp
  %p = call ptr @malloc(i64 40)
  store ptr %v, ptr %p
  %pbuf = getelementptr i8, ptr %p, i64 8
  store ptr %buf, ptr %pbuf
  %pdat = getelementptr i8, ptr %p, i64 16
  %dptr = getelementptr i8, ptr %buf, i32 %doff
  store ptr %dptr, ptr %pdat
  %plen = getelementptr i8, ptr %p, i64 24
  %dlen = load i32, ptr %dlenp
  store i32 %dlen, ptr %plen
  %pch = getelementptr i8, ptr %p, i64 28
  %chp = getelementptr i8, ptr %wfx, i64 2
  %ch16 = load i16, ptr %chp
  %ch = zext i16 %ch16 to i32
  store i32 %ch, ptr %pch
  %pst = getelementptr i8, ptr %p, i64 32
  store i32 0, ptr %pst
  ret ptr %p
freefail:
  call void @free(ptr %buf)
  br label %fail
fail:
  ret ptr null
}

; a 16.16 value as a float, clamped to [lo, hi]
define internal float @a_fx(i32 %v, float %lo, float %hi) {
entry:
  %f = sitofp i32 %v to float
  %s = fdiv float %f, 6.553600e+04
  %under = fcmp olt float %s, %lo
  %s1 = select i1 %under, float %lo, float %s
  %over = fcmp ogt float %s1, %hi
  %s2 = select i1 %over, float %hi, float %s1
  ret float %s2
}

; stop the voice and drop what it had queued
define internal void @a_halt(ptr %p) {
entry:
  %v = load ptr, ptr %p
  %stop = call ptr @a_fn(ptr %v, i64 20)
  %r1 = call i32 %stop(ptr %v, i32 0, i32 0)
  %flush = call ptr @a_fn(ptr %v, i64 22)
  %r2 = call i32 %flush(ptr %v)
  %pst = getelementptr i8, ptr %p, i64 32
  store i32 0, ptr %pst
  ret void
}

; rewind to the start and play, with loops / rate / volume
define void @snd_play(ptr %p, i32 %loops, i32 %rate, i32 %vol) {
entry:
  %xb = alloca [48 x i8], align 8
  %nil = icmp eq ptr %p, null
  br i1 %nil, label %out, label %go
go:
  call void @a_halt(ptr %p)
  %v = load ptr, ptr %p
  ; XAUDIO2_BUFFER: Flags 0, AudioBytes 4, pAudioData 8, PlayBegin 16, PlayLength 20,
  ; LoopBegin 24, LoopLength 28, LoopCount 32, pContext 40
  call void @llvm.memset.p0.i64(ptr %xb, i8 0, i64 48, i1 false)
  store i32 64, ptr %xb                                            ; XAUDIO2_END_OF_STREAM
  %plen = getelementptr i8, ptr %p, i64 24
  %len = load i32, ptr %plen
  %xlen = getelementptr i8, ptr %xb, i64 4
  store i32 %len, ptr %xlen
  %pdat = getelementptr i8, ptr %p, i64 16
  %dat = load ptr, ptr %pdat
  %xdat = getelementptr i8, ptr %xb, i64 8
  store ptr %dat, ptr %xdat
  ; -1 forever (XAUDIO2_LOOP_INFINITE, 255); n more times, at most 254
  %forever = icmp slt i32 %loops, 0
  %many = icmp sgt i32 %loops, 254
  %capped = select i1 %many, i32 254, i32 %loops
  %count = select i1 %forever, i32 255, i32 %capped
  %xlc = getelementptr i8, ptr %xb, i64 32
  store i32 %count, ptr %xlc
  %submit = call ptr @a_fn(ptr %v, i64 21)
  %hr = call i32 %submit(ptr %v, ptr %xb, ptr null)
  %bad = icmp slt i32 %hr, 0
  br i1 %bad, label %out, label %levels
levels:
  %fv = call float @a_fx(i32 %vol, float 0.000000e+00, float 4.000000e+00)
  %setv = call ptr @a_fn(ptr %v, i64 12)
  %r3 = call i32 %setv(ptr %v, float %fv, i32 0)
  %fr = call float @a_fx(i32 %rate, float 0x3F847AE140000000, float 4.000000e+00)
  %setr = call ptr @a_fn(ptr %v, i64 26)
  %r4 = call i32 %setr(ptr %v, float %fr, i32 0)
  %start = call ptr @a_fn(ptr %v, i64 19)
  %r5 = call i32 %start(ptr %v, i32 0, i32 0)
  %pst = getelementptr i8, ptr %p, i64 32
  store i32 1, ptr %pst
  br label %out
out:
  ret void
}

define void @snd_stop(ptr %p) {
entry:
  %nil = icmp eq ptr %p, null
  br i1 %nil, label %out, label %go
go:
  call void @a_halt(ptr %p)
  br label %out
out:
  ret void
}

; playing: started, and the clip is still queued (it leaves the queue when it ends)
define i32 @snd_playing(ptr %p) {
entry:
  %state = alloca [24 x i8], align 8
  %nil = icmp eq ptr %p, null
  br i1 %nil, label %zero, label %started
started:
  %pst = getelementptr i8, ptr %p, i64 32
  %st = load i32, ptr %pst
  %was = icmp ne i32 %st, 0
  br i1 %was, label %ask, label %zero
ask:
  %v = load ptr, ptr %p
  call void @llvm.memset.p0.i64(ptr %state, i8 0, i64 24, i1 false)
  %gs = call ptr @a_fn(ptr %v, i64 25)
  call void %gs(ptr %v, ptr %state, i32 256)                       ; XAUDIO2_VOICE_NOSAMPLESPLAYED
  %qp = getelementptr i8, ptr %state, i64 8                        ; BuffersQueued
  %q = load i32, ptr %qp
  %busy = icmp ugt i32 %q, 0
  %r = zext i1 %busy to i32
  ret i32 %r
zero:
  ret i32 0
}

define void @snd_set_volume(ptr %p, i32 %vol) {
entry:
  %nil = icmp eq ptr %p, null
  br i1 %nil, label %out, label %go
go:
  %v = load ptr, ptr %p
  %fv = call float @a_fx(i32 %vol, float 0.000000e+00, float 4.000000e+00)
  %setv = call ptr @a_fn(ptr %v, i64 12)
  %r = call i32 %setv(ptr %v, float %fv, i32 0)
  br label %out
out:
  ret void
}

define void @snd_set_rate(ptr %p, i32 %rate) {
entry:
  %nil = icmp eq ptr %p, null
  br i1 %nil, label %out, label %go
go:
  %v = load ptr, ptr %p
  %fr = call float @a_fx(i32 %rate, float 0x3F847AE140000000, float 4.000000e+00)
  %setr = call ptr @a_fn(ptr %v, i64 26)
  %r = call i32 %setr(ptr %v, float %fr, i32 0)
  br label %out
out:
  ret void
}

; Stereo position, -1.0 (hard left) .. 1.0 (hard right), as a balance: the centre
; leaves both sides at full level and a side pan turns the other side down. A mono
; clip feeds both front channels; a stereo clip keeps its left and right. Channels
; beyond the front pair (a 5.1 device) get nothing, which is where a stereo mix sits.
define void @snd_set_pan(ptr %p, i32 %pan) {
entry:
  %mat = alloca [64 x float], align 4
  %nil = icmp eq ptr %p, null
  br i1 %nil, label %out, label %chk
chk:
  %mch = load i32, ptr @A_mch
  %stereo = icmp sge i32 %mch, 2
  %big = icmp sgt i32 %mch, 8
  %okm = xor i1 %big, true
  %usem = and i1 %stereo, %okm
  br i1 %usem, label %go, label %out
go:
  %pch = getelementptr i8, ptr %p, i64 28
  %ch = load i32, ptr %pch
  %f = call float @a_fx(i32 %pan, float -1.000000e+00, float 1.000000e+00)
  %rightward = fcmp ogt float %f, 0.000000e+00
  %l0 = fsub float 1.000000e+00, %f
  %left = select i1 %rightward, float %l0, float 1.000000e+00
  %r0 = fadd float 1.000000e+00, %f
  %right = select i1 %rightward, float 1.000000e+00, float %r0
  %mono = icmp eq i32 %ch, 1
  %two = icmp eq i32 %ch, 2
  %known = or i1 %mono, %two
  br i1 %known, label %fill, label %out
fill:
  ; the matrix is [destination][source], row-major
  call void @llvm.memset.p0.i64(ptr %mat, i8 0, i64 256, i1 false)
  store float %left, ptr %mat
  %ri = select i1 %mono, i64 1, i64 3                              ; mono: dst1,src0 = 1; stereo: dst1,src1 = 3
  %rp = getelementptr float, ptr %mat, i64 %ri
  store float %right, ptr %rp
  %v = load ptr, ptr %p
  %master = load ptr, ptr @A_master
  %setm = call ptr @a_fn(ptr %v, i64 16)
  %r = call i32 %setm(ptr %v, ptr %master, i32 %ch, i32 %mch, ptr %mat, i32 0)
  br label %out
out:
  ret void
}
