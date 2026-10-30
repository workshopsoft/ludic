; ============================================================================
; http_none.ll - Http.* where there is no HTTP transport yet (Linux: a dedicated server, a CI runner). Same symbols as http.ll;
; every request is done at once with status 0 and no body, as an unreachable host answers. Linked by `ludic build` on a host that is
; not macOS (tools/ludic-cli/build.ludic http_link_flags).
; ============================================================================

define ptr @hs_req_new(ptr %method, ptr %url) {
entry:
  ret ptr null
}
define void @hs_req_header(ptr %req, ptr %name, ptr %val) {
entry:
  ret void
}
define void @hs_req_body(ptr %req, ptr %bytes, i32 %len) {
entry:
  ret void
}
define void @hs_send(i32 %slot, ptr %req) {
entry:
  ret void
}
define i32 @hs_done(i32 %slot) {
entry:
  ret i32 1
}
define i32 @hs_status(i32 %slot) {
entry:
  ret i32 0
}
define ptr @hs_body(i32 %slot) {
entry:
  ret ptr null
}
define i32 @hs_blen(i32 %slot) {
entry:
  ret i32 0
}
define ptr @hs_header(i32 %slot, ptr %name) {
entry:
  ret ptr null
}
define void @hs_free(i32 %slot) {
entry:
  ret void
}
define void @hs_save_to(i32 %slot, ptr %path) {
entry:
  ret void
}
define i32 @hs_received(i32 %slot) {
entry:
  ret i32 0
}
define i32 @hs_expected(i32 %slot) {
entry:
  ret i32 0
}
define void @hs_cancel(i32 %slot) {
entry:
  ret void
}
