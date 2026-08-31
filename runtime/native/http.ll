; ============================================================================
; http.ll — the macOS HTTP transport, written in LLVM IR.
;
; Like cocoa.ll / audio.ll, no Objective-C and no C source: this drives
; NSURLConnection through the objc runtime's C ABI, and runs the (blocking)
; request on a detached pthread so the game's frame loop never stalls. TLS is
; the system's, on by default with certificate verification — an https:// URL
; just works. ludicc splices this in and links Foundation only when a program
; uses Http.*.
;
; A small fixed pool of slots (0..HTTP_SLOTS-1) each hold one in-flight request:
; the pending NSURLRequest, the worker's pthread id, and — once the worker
; finishes — the status code, a malloc'd copy of the body bytes, and the
; retained NSHTTPURLResponse (so header queries can be answered later). The done
; flag is an atomic released by the worker and acquired by the poller, so the
; body / status / response the poller reads are the ones the worker wrote.
;
; Exposed to Ludic (through the http_* intrinsics):
;   http_req_new(method, url) -> req       http_req_header(req, name, val)
;   http_req_body(req, bytes, len)         http_send(slot, req)
;   http_done(slot) -> bool                http_status(slot) -> int
;   http_body(slot) -> ptr                 http_blen(slot) -> int
;   http_header(slot, name) -> cstr        http_free(slot)
; ============================================================================

declare ptr @objc_getClass(ptr)
declare ptr @sel_registerName(ptr)
declare ptr @objc_msgSend(ptr, ptr, ...)
declare ptr @malloc(i64)
declare void @free(ptr)
declare ptr @memcpy(ptr, ptr, i64)
declare i32 @pthread_create(ptr, ptr, ptr, ptr)
declare i32 @pthread_detach(ptr)

@.h_nsurl  = private unnamed_addr constant [6 x i8]  c"NSURL\00"
@.h_nsstr  = private unnamed_addr constant [9 x i8]  c"NSString\00"
@.h_nsdata = private unnamed_addr constant [7 x i8]  c"NSData\00"
@.h_murl   = private unnamed_addr constant [20 x i8] c"NSMutableURLRequest\00"
@.h_conn   = private unnamed_addr constant [16 x i8] c"NSURLConnection\00"
@.h_pool   = private unnamed_addr constant [18 x i8] c"NSAutoreleasePool\00"

@.h_urlws  = private unnamed_addr constant [15 x i8] c"URLWithString:\00"
@.h_utf8   = private unnamed_addr constant [22 x i8] c"stringWithUTF8String:\00"
@.h_reqw   = private unnamed_addr constant [16 x i8] c"requestWithURL:\00"
@.h_smeth  = private unnamed_addr constant [15 x i8] c"setHTTPMethod:\00"
@.h_shdr   = private unnamed_addr constant [29 x i8] c"setValue:forHTTPHeaderField:\00"
@.h_sbody  = private unnamed_addr constant [13 x i8] c"setHTTPBody:\00"
@.h_dwbl   = private unnamed_addr constant [22 x i8] c"dataWithBytes:length:\00"
@.h_bytes  = private unnamed_addr constant [6 x i8]  c"bytes\00"
@.h_length = private unnamed_addr constant [7 x i8]  c"length\00"
@.h_ssync  = private unnamed_addr constant [48 x i8] c"sendSynchronousRequest:returningResponse:error:\00"
@.h_status = private unnamed_addr constant [11 x i8] c"statusCode\00"
@.h_vhdr   = private unnamed_addr constant [25 x i8] c"valueForHTTPHeaderField:\00"
@.h_utf8g  = private unnamed_addr constant [11 x i8] c"UTF8String\00"
@.h_alloc  = private unnamed_addr constant [6 x i8]  c"alloc\00"
@.h_init   = private unnamed_addr constant [5 x i8]  c"init\00"
@.h_drain  = private unnamed_addr constant [6 x i8]  c"drain\00"
@.h_retain = private unnamed_addr constant [7 x i8]  c"retain\00"
@.h_rel    = private unnamed_addr constant [8 x i8]  c"release\00"
@.h_empty  = private unnamed_addr constant [1 x i8]  c"\00"

; HTTP_SLOTS = 8
@H_req    = internal global [8 x ptr] zeroinitializer
@H_resp   = internal global [8 x ptr] zeroinitializer
@H_body   = internal global [8 x ptr] zeroinitializer
@H_blen   = internal global [8 x i32] zeroinitializer
@H_status = internal global [8 x i32] zeroinitializer
@H_done   = internal global [8 x i32] zeroinitializer

; --- request construction ---------------------------------------------------

; Build an NSMutableURLRequest for `method` + `url`; returns it retained.
define ptr @hs_req_new(ptr %method, ptr %url) {
entry:
  %strcls = call ptr @objc_getClass(ptr @.h_nsstr)
  %sel_u = call ptr @sel_registerName(ptr @.h_utf8)
  %nsurlstr = call ptr (ptr, ptr, ptr) @objc_msgSend(ptr %strcls, ptr %sel_u, ptr %url)
  %urlcls = call ptr @objc_getClass(ptr @.h_nsurl)
  %sel_uw = call ptr @sel_registerName(ptr @.h_urlws)
  %nsurl = call ptr (ptr, ptr, ptr) @objc_msgSend(ptr %urlcls, ptr %sel_uw, ptr %nsurlstr)
  %nou = icmp eq ptr %nsurl, null
  br i1 %nou, label %fail, label %mk
mk:
  %reqcls = call ptr @objc_getClass(ptr @.h_murl)
  %sel_rw = call ptr @sel_registerName(ptr @.h_reqw)
  %req = call ptr (ptr, ptr, ptr) @objc_msgSend(ptr %reqcls, ptr %sel_rw, ptr %nsurl)
  %nor = icmp eq ptr %req, null
  br i1 %nor, label %fail, label %setm
setm:
  %mstr = call ptr (ptr, ptr, ptr) @objc_msgSend(ptr %strcls, ptr %sel_u, ptr %method)
  %sel_m = call ptr @sel_registerName(ptr @.h_smeth)
  %rm = call ptr (ptr, ptr, ptr) @objc_msgSend(ptr %req, ptr %sel_m, ptr %mstr)
  ; retain so it survives the caller's autorelease context until http_send.
  %sel_ret = call ptr @sel_registerName(ptr @.h_retain)
  %rr = call ptr (ptr, ptr) @objc_msgSend(ptr %req, ptr %sel_ret)
  ret ptr %req
fail:
  ret ptr null
}

define void @hs_req_header(ptr %req, ptr %name, ptr %val) {
entry:
  %nil = icmp eq ptr %req, null
  br i1 %nil, label %out, label %go
go:
  %strcls = call ptr @objc_getClass(ptr @.h_nsstr)
  %sel_u = call ptr @sel_registerName(ptr @.h_utf8)
  %n = call ptr (ptr, ptr, ptr) @objc_msgSend(ptr %strcls, ptr %sel_u, ptr %name)
  %v = call ptr (ptr, ptr, ptr) @objc_msgSend(ptr %strcls, ptr %sel_u, ptr %val)
  %sel_sh = call ptr @sel_registerName(ptr @.h_shdr)
  %r = call ptr (ptr, ptr, ptr, ptr) @objc_msgSend(ptr %req, ptr %sel_sh, ptr %v, ptr %n)
  br label %out
out:
  ret void
}

define void @hs_req_body(ptr %req, ptr %bytes, i32 %len) {
entry:
  %nil = icmp eq ptr %req, null
  br i1 %nil, label %out, label %go
go:
  %datacls = call ptr @objc_getClass(ptr @.h_nsdata)
  %sel_d = call ptr @sel_registerName(ptr @.h_dwbl)
  %l64 = sext i32 %len to i64
  %data = call ptr (ptr, ptr, ptr, i64) @objc_msgSend(ptr %datacls, ptr %sel_d, ptr %bytes, i64 %l64)
  %sel_sb = call ptr @sel_registerName(ptr @.h_sbody)
  %r = call ptr (ptr, ptr, ptr) @objc_msgSend(ptr %req, ptr %sel_sb, ptr %data)
  br label %out
out:
  ret void
}

; --- the worker + dispatch --------------------------------------------------

; The detached worker: run the blocking request for one slot and publish the
; result. arg is the slot index encoded as a pointer.
define ptr @hs_worker(ptr %arg) {
entry:
  %slot64 = ptrtoint ptr %arg to i64
  %slot = trunc i64 %slot64 to i32
  %poolcls = call ptr @objc_getClass(ptr @.h_pool)
  %sel_a = call ptr @sel_registerName(ptr @.h_alloc)
  %p0 = call ptr (ptr, ptr) @objc_msgSend(ptr %poolcls, ptr %sel_a)
  %sel_i = call ptr @sel_registerName(ptr @.h_init)
  %pool = call ptr (ptr, ptr) @objc_msgSend(ptr %p0, ptr %sel_i)

  %reqp = getelementptr [8 x ptr], ptr @H_req, i32 0, i32 %slot
  %req = load ptr, ptr %reqp

  %respslot = alloca ptr
  %errslot = alloca ptr
  store ptr null, ptr %respslot
  store ptr null, ptr %errslot
  %conncls = call ptr @objc_getClass(ptr @.h_conn)
  %sel_ss = call ptr @sel_registerName(ptr @.h_ssync)
  %data = call ptr (ptr, ptr, ptr, ptr, ptr) @objc_msgSend(ptr %conncls, ptr %sel_ss, ptr %req, ptr %respslot, ptr %errslot)

  %nodata = icmp eq ptr %data, null
  br i1 %nodata, label %publish, label %havebody
havebody:
  %sel_len = call ptr @sel_registerName(ptr @.h_length)
  %blen64 = call i64 (ptr, ptr) @objc_msgSend(ptr %data, ptr %sel_len)
  %blen = trunc i64 %blen64 to i32
  %sel_by = call ptr @sel_registerName(ptr @.h_bytes)
  %src = call ptr (ptr, ptr) @objc_msgSend(ptr %data, ptr %sel_by)
  ; malloc blen+1 and copy, NUL-terminating so the Ludic side can read text.
  %cap = add i64 %blen64, 1
  %buf = call ptr @malloc(i64 %cap)
  %cp = call ptr @memcpy(ptr %buf, ptr %src, i64 %blen64)
  %term = getelementptr i8, ptr %buf, i64 %blen64
  store i8 0, ptr %term
  %bodyp = getelementptr [8 x ptr], ptr @H_body, i32 0, i32 %slot
  store ptr %buf, ptr %bodyp
  %blenp = getelementptr [8 x i32], ptr @H_blen, i32 0, i32 %slot
  store i32 %blen, ptr %blenp
  br label %publish
publish:
  ; status + retained response (for later header queries), from the out-param.
  %resp = load ptr, ptr %respslot
  %noresp = icmp eq ptr %resp, null
  br i1 %noresp, label %done, label %withresp
withresp:
  %sel_ret = call ptr @sel_registerName(ptr @.h_retain)
  %rr = call ptr (ptr, ptr) @objc_msgSend(ptr %resp, ptr %sel_ret)
  %respp = getelementptr [8 x ptr], ptr @H_resp, i32 0, i32 %slot
  store ptr %resp, ptr %respp
  %sel_st = call ptr @sel_registerName(ptr @.h_status)
  %st64 = call i64 (ptr, ptr) @objc_msgSend(ptr %resp, ptr %sel_st)
  %st = trunc i64 %st64 to i32
  %stp = getelementptr [8 x i32], ptr @H_status, i32 0, i32 %slot
  store i32 %st, ptr %stp
  br label %done
done:
  ; release the request we retained in http_send, drain the pool, then publish
  ; the done flag last with release ordering so the reader sees the writes above.
  %sel_rel = call ptr @sel_registerName(ptr @.h_rel)
  %rrel = call ptr (ptr, ptr) @objc_msgSend(ptr %req, ptr %sel_rel)
  %sel_dr = call ptr @sel_registerName(ptr @.h_drain)
  %dr = call ptr (ptr, ptr) @objc_msgSend(ptr %pool, ptr %sel_dr)
  %donep = getelementptr [8 x i32], ptr @H_done, i32 0, i32 %slot
  store atomic i32 1, ptr %donep release, align 4
  ret ptr null
}

; Start the request on `slot` running on a detached worker thread.
define void @hs_send(i32 %slot, ptr %req) {
entry:
  ; reset the slot
  %donep = getelementptr [8 x i32], ptr @H_done, i32 0, i32 %slot
  store atomic i32 0, ptr %donep release, align 4
  %stp = getelementptr [8 x i32], ptr @H_status, i32 0, i32 %slot
  store i32 0, ptr %stp
  %bodyp = getelementptr [8 x ptr], ptr @H_body, i32 0, i32 %slot
  store ptr null, ptr %bodyp
  %blenp = getelementptr [8 x i32], ptr @H_blen, i32 0, i32 %slot
  store i32 0, ptr %blenp
  %respp = getelementptr [8 x ptr], ptr @H_resp, i32 0, i32 %slot
  store ptr null, ptr %respp
  %reqp = getelementptr [8 x ptr], ptr @H_req, i32 0, i32 %slot
  store ptr %req, ptr %reqp
  %tid = alloca i64
  %arg = inttoptr i32 %slot to ptr
  %rc = call i32 @pthread_create(ptr %tid, ptr null, ptr @hs_worker, ptr %arg)
  %t = load i64, ptr %tid
  %tp = inttoptr i64 %t to ptr
  %d = call i32 @pthread_detach(ptr %tp)
  ret void
}

; --- result accessors -------------------------------------------------------

define i32 @hs_done(i32 %slot) {
entry:
  %p = getelementptr [8 x i32], ptr @H_done, i32 0, i32 %slot
  %v = load atomic i32, ptr %p acquire, align 4
  ret i32 %v
}

define i32 @hs_status(i32 %slot) {
entry:
  %p = getelementptr [8 x i32], ptr @H_status, i32 0, i32 %slot
  %v = load i32, ptr %p
  ret i32 %v
}

define ptr @hs_body(i32 %slot) {
entry:
  %p = getelementptr [8 x ptr], ptr @H_body, i32 0, i32 %slot
  %v = load ptr, ptr %p
  ret ptr %v
}

define i32 @hs_blen(i32 %slot) {
entry:
  %p = getelementptr [8 x i32], ptr @H_blen, i32 0, i32 %slot
  %v = load i32, ptr %p
  ret i32 %v
}

; A response header value as a C string, or "" if absent / no response yet.
define ptr @hs_header(i32 %slot, ptr %name) {
entry:
  %rp = getelementptr [8 x ptr], ptr @H_resp, i32 0, i32 %slot
  %resp = load ptr, ptr %rp
  %nores = icmp eq ptr %resp, null
  br i1 %nores, label %empty, label %ask
ask:
  %strcls = call ptr @objc_getClass(ptr @.h_nsstr)
  %sel_u = call ptr @sel_registerName(ptr @.h_utf8)
  %ns = call ptr (ptr, ptr, ptr) @objc_msgSend(ptr %strcls, ptr %sel_u, ptr %name)
  %sel_vh = call ptr @sel_registerName(ptr @.h_vhdr)
  %val = call ptr (ptr, ptr, ptr) @objc_msgSend(ptr %resp, ptr %sel_vh, ptr %ns)
  %noval = icmp eq ptr %val, null
  br i1 %noval, label %empty, label %tocstr
tocstr:
  %sel_g = call ptr @sel_registerName(ptr @.h_utf8g)
  %c = call ptr (ptr, ptr) @objc_msgSend(ptr %val, ptr %sel_g)
  ret ptr %c
empty:
  ret ptr @.h_empty
}

; Free a slot's owned resources (the body copy and the retained response).
define void @hs_free(i32 %slot) {
entry:
  %bp = getelementptr [8 x ptr], ptr @H_body, i32 0, i32 %slot
  %b = load ptr, ptr %bp
  %nb = icmp eq ptr %b, null
  br i1 %nb, label %resp, label %fb
fb:
  call void @free(ptr %b)
  store ptr null, ptr %bp
  br label %resp
resp:
  %rp = getelementptr [8 x ptr], ptr @H_resp, i32 0, i32 %slot
  %r = load ptr, ptr %rp
  %nr = icmp eq ptr %r, null
  br i1 %nr, label %out, label %rr
rr:
  %sel_rel = call ptr @sel_registerName(ptr @.h_rel)
  %x = call ptr (ptr, ptr) @objc_msgSend(ptr %r, ptr %sel_rel)
  store ptr null, ptr %rp
  br label %out
out:
  ret void
}
