; ============================================================================
; gl_win_nowin.ll — the window half of Gl.* in a headless Windows build.
;
; gl.ludic names win_gl_* on its is_windowed() branch. A headless build compiles that
; branch to nothing, but the names still have to resolve; a windowed build links
; win32_gl.ll, which defines them on the real window, in place of this file.
; ============================================================================

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

; headless: no window, so nothing for a graphics API to make a surface on (win32.ll has the real ones)
define ptr @win_native_window() {
entry:
  ret ptr null
}
define ptr @win_native_instance() {
entry:
  ret ptr null
}
