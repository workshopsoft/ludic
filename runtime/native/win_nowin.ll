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
declare ptr @malloc(i64)
declare i64 @strlen(ptr)
declare ptr @memcpy(ptr, ptr, i64)

; ---- the clipboard with no window: a copy the process keeps (a headless run's copy and paste, a test's); cocoa.ll's / win32.ll's
; system clipboard wins when linked
@clip_mem = internal global ptr null
define internal ptr @clip_dup(ptr %c) {
entry:
  %n = call i64 @strlen(ptr %c)
  %n1 = add i64 %n, 1
  %out = call ptr @malloc(i64 %n1)
  call ptr @memcpy(ptr %out, ptr %c, i64 %n1)
  ret ptr %out
}
define ptr @win_clip_get() {
entry:
  %m = load ptr, ptr @clip_mem
  %none = icmp eq ptr %m, null
  br i1 %none, label %empty, label %copy
copy:
  %d = call ptr @clip_dup(ptr %m)
  ret ptr %d
empty:
  %e = call ptr @malloc(i64 1)
  store i8 0, ptr %e
  ret ptr %e
}
define void @win_clip_set(ptr %text) {
entry:
  %d = call ptr @clip_dup(ptr %text)
  store ptr %d, ptr @clip_mem
  ret void
}

define i32 @win_focused() {
entry:
  ret i32 1
}
define void @win_cursor_make(i32 %slot, ptr %bytes, i32 %len, i32 %wi, i32 %hi_, i32 %hxi_, i32 %hyi_) {
entry:
  %w = sitofp i32 %wi to double
  %h = sitofp i32 %hi_ to double
  %hx = sitofp i32 %hxi_ to double
  %hy = sitofp i32 %hyi_ to double
  ret void
}
define void @win_cursor_use(i32 %slot) {
entry:
  ret void
}
