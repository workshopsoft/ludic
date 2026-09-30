; ============================================================================
; win_nowin.ll — the window layer in a headless Windows build.
;
; window.ludic and render3d name win_resize / win_scale / win_drawable on their
; is_windowed() branches. A headless build compiles those branches to nothing, but the
; names still have to resolve; a windowed build links win32_window.ll, which defines
; them on the real window, in place of this file.
; ============================================================================

define void @win_resize(i32 %w, i32 %h) {
entry:
  ret void
}
define i32 @win_scale() {
entry:
  ret i32 1
}
define void @win_drawable(ptr %out) {
entry:
  ret void
}
define void @win_retina(i32 %on) {
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
; macOS only (cocoa.ll): the CAMetalLayer MoltenVK presents to
define ptr @win_metal_layer() {
entry:
  ret ptr null
}
; the window is always drawn to here (cocoa.ll asks macOS whether it is covered)
define i32 @win_visible() {
entry:
  ret i32 1
}

define void @win_set_title(ptr %title) {
entry:
  ret void
}
