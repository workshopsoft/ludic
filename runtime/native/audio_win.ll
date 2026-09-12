; ============================================================================
; audio_win.ll — the Windows sound backend (audio.ll's snd_* contract).
;
; Silent for now: every clip fails to load and every call is a no-op, which is the
; contract a headless build already runs on, so a windowed game links and plays
; without sound until the XAudio2 backend replaces this file.
; ============================================================================

define ptr @snd_load(ptr %path) {
entry:
  ret ptr null
}
define void @snd_play(ptr %p, i32 %loops, i32 %rate, i32 %vol) {
entry:
  ret void
}
define void @snd_stop(ptr %p) {
entry:
  ret void
}
define i32 @snd_playing(ptr %p) {
entry:
  ret i32 0
}
define void @snd_set_volume(ptr %p, i32 %vol) {
entry:
  ret void
}
define void @snd_set_rate(ptr %p, i32 %rate) {
entry:
  ret void
}
define void @snd_set_pan(ptr %p, i32 %pan) {
entry:
  ret void
}
