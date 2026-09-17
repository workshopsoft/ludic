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
;
; Streaming (Http.save_to), which a synchronous NSURLConnection cannot do:
;   hs_save_to(slot, path)                 hs_received(slot) -> int
;   hs_expected(slot) -> int               hs_cancel(slot)
; A slot given a path before hs_send is sent through one shared NSURLSession whose
; delegate - a class built at run time, like cocoa.ll's view - appends each chunk to the
; file as it arrives (URLSession:dataTask:didReceiveData:) and publishes the status and the
; done flag when the task ends (URLSession:task:didCompleteWithError:). The callbacks run
; on the session's own serial queue; the byte counters are atomics the poller reads.
; ============================================================================

declare ptr @objc_getClass(ptr)
declare ptr @sel_registerName(ptr)
declare ptr @objc_msgSend(ptr, ptr, ...)
declare ptr @malloc(i64)
declare void @free(ptr)
declare ptr @memcpy(ptr, ptr, i64)
declare i32 @pthread_create(ptr, ptr, ptr, ptr)
declare i32 @pthread_detach(ptr)
declare ptr @strdup(ptr)
declare ptr @fopen(ptr, ptr)
declare i64 @fwrite(ptr, i64, i64, ptr)
declare i32 @fclose(ptr)
declare ptr @objc_allocateClassPair(ptr, ptr, i64)
declare void @objc_registerClassPair(ptr)
declare i8 @class_addMethod(ptr, ptr, ptr, ptr)
declare ptr @objc_autoreleasePoolPush()
declare void @objc_autoreleasePoolPop(ptr)

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

@.h_nsobj  = private unnamed_addr constant [9 x i8]  c"NSObject\00"
@.h_dlgcls = private unnamed_addr constant [18 x i8] c"LudicHttpDelegate\00"
@.h_sesscl = private unnamed_addr constant [13 x i8] c"NSURLSession\00"
@.h_cfgcl  = private unnamed_addr constant [26 x i8] c"NSURLSessionConfiguration\00"
@.h_defcfg = private unnamed_addr constant [28 x i8] c"defaultSessionConfiguration\00"
@.h_swc    = private unnamed_addr constant [49 x i8] c"sessionWithConfiguration:delegate:delegateQueue:\00"
@.h_dtwr   = private unnamed_addr constant [21 x i8] c"dataTaskWithRequest:\00"
@.h_resume = private unnamed_addr constant [7 x i8]  c"resume\00"
@.h_cancel = private unnamed_addr constant [7 x i8]  c"cancel\00"
@.h_respg  = private unnamed_addr constant [9 x i8]  c"response\00"
@.h_cbexp  = private unnamed_addr constant [30 x i8] c"countOfBytesExpectedToReceive\00"
@.h_ecl    = private unnamed_addr constant [22 x i8] c"expectedContentLength\00"
@.h_seldat = private unnamed_addr constant [36 x i8] c"URLSession:dataTask:didReceiveData:\00"
@.h_seldon = private unnamed_addr constant [38 x i8] c"URLSession:task:didCompleteWithError:\00"
@.h_enc5   = private unnamed_addr constant [7 x i8]  c"v@:@@@\00"
@.h_rts    = private unnamed_addr constant [20 x i8] c"respondsToSelector:\00"
@.h_wb     = private unnamed_addr constant [3 x i8]  c"wb\00"
@.h_aenc   = private unnamed_addr constant [16 x i8] c"Accept-Encoding\00"
@.h_ident  = private unnamed_addr constant [9 x i8]  c"identity\00"

; HTTP_SLOTS = 8
@H_req    = internal global [8 x ptr] zeroinitializer
@H_resp   = internal global [8 x ptr] zeroinitializer
@H_body   = internal global [8 x ptr] zeroinitializer
@H_blen   = internal global [8 x i32] zeroinitializer
@H_status = internal global [8 x i32] zeroinitializer
@H_done   = internal global [8 x i32] zeroinitializer
; streaming (Http.save_to)
@H_path   = internal global [8 x ptr] zeroinitializer   ; strdup'd file path, set before send
@H_file   = internal global [8 x ptr] zeroinitializer   ; FILE* while the task runs
@H_task   = internal global [8 x ptr] zeroinitializer   ; the retained NSURLSessionDataTask
@H_recv   = internal global [8 x i32] zeroinitializer   ; body bytes written (atomic)
@H_exp    = internal global [8 x i32] zeroinitializer   ; Content-Length or -1 (atomic)
@H_werr   = internal global [8 x i32] zeroinitializer   ; a write to the file failed
@H_strm   = internal global [8 x i32] zeroinitializer   ; this slot was sent streaming
@H_sess   = internal global ptr null                    ; the shared streaming session

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
  %pathp = getelementptr [8 x ptr], ptr @H_path, i32 0, i32 %slot
  %path = load ptr, ptr %pathp
  %strm = icmp ne ptr %path, null
  br i1 %strm, label %stream, label %thread
stream:
  call void @hs_stream_start(i32 %slot, ptr %req, ptr %path)
  ret void
thread:
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
  ; only an HTTP response has headers (a file:// one does not)
  %sel_vh = call ptr @sel_registerName(ptr @.h_vhdr)
  %sel_rts = call ptr @sel_registerName(ptr @.h_rts)
  %has = call i8 (ptr, ptr, ptr) @objc_msgSend(ptr %resp, ptr %sel_rts, ptr %sel_vh)
  %nohdr = icmp eq i8 %has, 0
  br i1 %nohdr, label %empty, label %lookup
lookup:
  %strcls = call ptr @objc_getClass(ptr @.h_nsstr)
  %sel_u = call ptr @sel_registerName(ptr @.h_utf8)
  %ns = call ptr (ptr, ptr, ptr) @objc_msgSend(ptr %strcls, ptr %sel_u, ptr %name)
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
  call void @hs_stream_free(i32 %slot)
  ret void
}

; --- streaming (Http.save_to) -------------------------------------------------

define void @hs_save_to(i32 %slot, ptr %path) {
entry:
  %pp = getelementptr [8 x ptr], ptr @H_path, i32 0, i32 %slot
  %old = load ptr, ptr %pp
  %had = icmp ne ptr %old, null
  br i1 %had, label %drop, label %set
drop:
  call void @free(ptr %old)
  br label %set
set:
  %cp = call ptr @strdup(ptr %path)
  store ptr %cp, ptr %pp
  ret void
}

define i32 @hs_received(i32 %slot) {
entry:
  %p = getelementptr [8 x i32], ptr @H_recv, i32 0, i32 %slot
  %v = load atomic i32, ptr %p acquire, align 4
  ret i32 %v
}

define i32 @hs_expected(i32 %slot) {
entry:
  %p = getelementptr [8 x i32], ptr @H_exp, i32 0, i32 %slot
  %v = load atomic i32, ptr %p acquire, align 4
  ret i32 %v
}

; Stop a running streaming task; its completion callback then publishes status 0. An
; in-memory request cannot be interrupted and simply runs to its end.
define void @hs_cancel(i32 %slot) {
entry:
  %sp = getelementptr [8 x i32], ptr @H_strm, i32 0, i32 %slot
  %s = load i32, ptr %sp
  %is = icmp ne i32 %s, 0
  br i1 %is, label %task, label %out
task:
  %tp = getelementptr [8 x ptr], ptr @H_task, i32 0, i32 %slot
  %t = load ptr, ptr %tp
  %not = icmp eq ptr %t, null
  br i1 %not, label %out, label %go
go:
  %sel = call ptr @sel_registerName(ptr @.h_cancel)
  %r = call ptr (ptr, ptr) @objc_msgSend(ptr %t, ptr %sel)
  br label %out
out:
  ret void
}

define internal void @hs_stream_free(i32 %slot) {
entry:
  %tp = getelementptr [8 x ptr], ptr @H_task, i32 0, i32 %slot
  %t = load ptr, ptr %tp
  %not = icmp eq ptr %t, null
  br i1 %not, label %file, label %rel
rel:
  %sel = call ptr @sel_registerName(ptr @.h_rel)
  %r = call ptr (ptr, ptr) @objc_msgSend(ptr %t, ptr %sel)
  store ptr null, ptr %tp
  br label %file
file:
  %fp = getelementptr [8 x ptr], ptr @H_file, i32 0, i32 %slot
  %f = load ptr, ptr %fp
  %nof = icmp eq ptr %f, null
  br i1 %nof, label %path, label %close
close:
  %c = call i32 @fclose(ptr %f)
  store ptr null, ptr %fp
  br label %path
path:
  %pp = getelementptr [8 x ptr], ptr @H_path, i32 0, i32 %slot
  %p = load ptr, ptr %pp
  %nop = icmp eq ptr %p, null
  br i1 %nop, label %out, label %freep
freep:
  call void @free(ptr %p)
  store ptr null, ptr %pp
  br label %out
out:
  %sp = getelementptr [8 x i32], ptr @H_strm, i32 0, i32 %slot
  store i32 0, ptr %sp
  ret void
}

; the slot whose task this is, or -1
define internal i32 @hs_slot_of(ptr %task) {
entry:
  br label %loop
loop:
  %i = phi i32 [ 0, %entry ], [ %i1, %next ]
  %tp = getelementptr [8 x ptr], ptr @H_task, i32 0, i32 %i
  %t = load ptr, ptr %tp
  %hit = icmp eq ptr %t, %task
  br i1 %hit, label %found, label %next
next:
  %i1 = add i32 %i, 1
  %more = icmp slt i32 %i1, 8
  br i1 %more, label %loop, label %none
found:
  ret i32 %i
none:
  ret i32 -1
}

; -URLSession:dataTask:didReceiveData: - append the chunk, count it, note the length
define internal void @hs_dlg_data(ptr %self, ptr %cmd, ptr %session, ptr %task, ptr %data) {
entry:
  %slot = call i32 @hs_slot_of(ptr %task)
  %bad = icmp slt i32 %slot, 0
  br i1 %bad, label %out, label %file
file:
  %fp = getelementptr [8 x ptr], ptr @H_file, i32 0, i32 %slot
  %f = load ptr, ptr %fp
  %nof = icmp eq ptr %f, null
  br i1 %nof, label %out, label %write
write:
  %sel_len = call ptr @sel_registerName(ptr @.h_length)
  %n = call i64 (ptr, ptr) @objc_msgSend(ptr %data, ptr %sel_len)
  %sel_by = call ptr @sel_registerName(ptr @.h_bytes)
  %b = call ptr (ptr, ptr) @objc_msgSend(ptr %data, ptr %sel_by)
  %w = call i64 @fwrite(ptr %b, i64 1, i64 %n, ptr %f)
  %short = icmp ne i64 %w, %n
  br i1 %short, label %failed, label %count
failed:
  %ep = getelementptr [8 x i32], ptr @H_werr, i32 0, i32 %slot
  store i32 1, ptr %ep
  %sel_c = call ptr @sel_registerName(ptr @.h_cancel)
  %rc = call ptr (ptr, ptr) @objc_msgSend(ptr %task, ptr %sel_c)
  br label %count
count:
  %rp = getelementptr [8 x i32], ptr @H_recv, i32 0, i32 %slot
  %r0 = load atomic i32, ptr %rp acquire, align 4
  %w32 = trunc i64 %w to i32
  %r1 = add i32 %r0, %w32
  store atomic i32 %r1, ptr %rp release, align 4
  %sel_x = call ptr @sel_registerName(ptr @.h_cbexp)
  %x = call i64 (ptr, ptr) @objc_msgSend(ptr %task, ptr %sel_x)
  %x32 = trunc i64 %x to i32
  %neg = icmp slt i64 %x, 0
  %xv = select i1 %neg, i32 -1, i32 %x32
  %xp = getelementptr [8 x i32], ptr @H_exp, i32 0, i32 %slot
  store atomic i32 %xv, ptr %xp release, align 4
  br label %out
out:
  ret void
}

; -URLSession:task:didCompleteWithError: - close the file, publish status and done
define internal void @hs_dlg_done(ptr %self, ptr %cmd, ptr %session, ptr %task, ptr %error) {
entry:
  %slot = call i32 @hs_slot_of(ptr %task)
  %bad = icmp slt i32 %slot, 0
  br i1 %bad, label %out, label %close
close:
  %fp = getelementptr [8 x ptr], ptr @H_file, i32 0, i32 %slot
  %f = load ptr, ptr %fp
  %nof = icmp eq ptr %f, null
  br i1 %nof, label %judge, label %doclose
doclose:
  %cr = call i32 @fclose(ptr %f)
  store ptr null, ptr %fp
  %cfail = icmp ne i32 %cr, 0
  br i1 %cfail, label %markw, label %judge
markw:
  %ep0 = getelementptr [8 x i32], ptr @H_werr, i32 0, i32 %slot
  store i32 1, ptr %ep0
  br label %judge
judge:
  %ep = getelementptr [8 x i32], ptr @H_werr, i32 0, i32 %slot
  %we = load i32, ptr %ep
  %werr = icmp ne i32 %we, 0
  %neterr = icmp ne ptr %error, null
  %failed = or i1 %werr, %neterr
  br i1 %failed, label %publish, label %resp
resp:
  %sel_r = call ptr @sel_registerName(ptr @.h_respg)
  %rs = call ptr (ptr, ptr) @objc_msgSend(ptr %task, ptr %sel_r)
  %nors = icmp eq ptr %rs, null
  br i1 %nors, label %publish, label %keep
keep:
  %sel_ret = call ptr @sel_registerName(ptr @.h_retain)
  %rr = call ptr (ptr, ptr) @objc_msgSend(ptr %rs, ptr %sel_ret)
  %respp = getelementptr [8 x ptr], ptr @H_resp, i32 0, i32 %slot
  store ptr %rs, ptr %respp
  ; a file:// URL answers with a plain NSURLResponse, which has no status code: one that
  ; completed without an error is reported as 200
  %sel_st = call ptr @sel_registerName(ptr @.h_status)
  %sel_rts = call ptr @sel_registerName(ptr @.h_rts)
  %ishttp = call i8 (ptr, ptr, ptr) @objc_msgSend(ptr %rs, ptr %sel_rts, ptr %sel_st)
  %nothttp = icmp eq i8 %ishttp, 0
  br i1 %nothttp, label %plain, label %httpst
plain:
  br label %setst
httpst:
  %st64 = call i64 (ptr, ptr) @objc_msgSend(ptr %rs, ptr %sel_st)
  %st0 = trunc i64 %st64 to i32
  br label %setst
setst:
  %st = phi i32 [ 200, %plain ], [ %st0, %httpst ]
  %stp = getelementptr [8 x i32], ptr @H_status, i32 0, i32 %slot
  store i32 %st, ptr %stp
  ; an empty body never reached didReceiveData: take the length from the response
  %xp = getelementptr [8 x i32], ptr @H_exp, i32 0, i32 %slot
  %x0 = load atomic i32, ptr %xp acquire, align 4
  %unk = icmp slt i32 %x0, 0
  br i1 %unk, label %fromresp, label %publish
fromresp:
  %sel_e = call ptr @sel_registerName(ptr @.h_ecl)
  %e64 = call i64 (ptr, ptr) @objc_msgSend(ptr %rs, ptr %sel_e)
  %e32 = trunc i64 %e64 to i32
  %eneg = icmp slt i64 %e64, 0
  %ev = select i1 %eneg, i32 -1, i32 %e32
  store atomic i32 %ev, ptr %xp release, align 4
  br label %publish
publish:
  %rp = getelementptr [8 x i32], ptr @H_recv, i32 0, i32 %slot
  %got = load atomic i32, ptr %rp acquire, align 4
  %blenp = getelementptr [8 x i32], ptr @H_blen, i32 0, i32 %slot
  store i32 %got, ptr %blenp
  %donep = getelementptr [8 x i32], ptr @H_done, i32 0, i32 %slot
  store atomic i32 1, ptr %donep release, align 4
  br label %out
out:
  ret void
}

; The one session every streaming request goes through, made on first use (hs_send runs on
; the game thread only). Its delegate is an instance of a class built here.
define internal ptr @hs_session() {
entry:
  %have = load ptr, ptr @H_sess
  %got = icmp ne ptr %have, null
  br i1 %got, label %ready, label %make
ready:
  ret ptr %have
make:
  %cls0 = call ptr @objc_getClass(ptr @.h_dlgcls)
  %exists = icmp ne ptr %cls0, null
  br i1 %exists, label %inst, label %build
build:
  %super = call ptr @objc_getClass(ptr @.h_nsobj)
  %nc = call ptr @objc_allocateClassPair(ptr %super, ptr @.h_dlgcls, i64 0)
  %sd = call ptr @sel_registerName(ptr @.h_seldat)
  %m1 = call i8 @class_addMethod(ptr %nc, ptr %sd, ptr @hs_dlg_data, ptr @.h_enc5)
  %sc = call ptr @sel_registerName(ptr @.h_seldon)
  %m2 = call i8 @class_addMethod(ptr %nc, ptr %sc, ptr @hs_dlg_done, ptr @.h_enc5)
  call void @objc_registerClassPair(ptr %nc)
  br label %inst
inst:
  %cls = phi ptr [ %cls0, %make ], [ %nc, %build ]
  %sel_a = call ptr @sel_registerName(ptr @.h_alloc)
  %d0 = call ptr (ptr, ptr) @objc_msgSend(ptr %cls, ptr %sel_a)
  %sel_i = call ptr @sel_registerName(ptr @.h_init)
  %dlg = call ptr (ptr, ptr) @objc_msgSend(ptr %d0, ptr %sel_i)
  %cfgcls = call ptr @objc_getClass(ptr @.h_cfgcl)
  %sel_dc = call ptr @sel_registerName(ptr @.h_defcfg)
  %cfg = call ptr (ptr, ptr) @objc_msgSend(ptr %cfgcls, ptr %sel_dc)
  %sesscls = call ptr @objc_getClass(ptr @.h_sesscl)
  %sel_sw = call ptr @sel_registerName(ptr @.h_swc)
  %sess = call ptr (ptr, ptr, ptr, ptr, ptr) @objc_msgSend(ptr %sesscls, ptr %sel_sw, ptr %cfg, ptr %dlg, ptr null)
  %none = icmp eq ptr %sess, null
  br i1 %none, label %fail, label %hold
hold:
  ; the session retains its delegate; it is kept for the life of the program
  %sel_ret = call ptr @sel_registerName(ptr @.h_retain)
  %rs = call ptr (ptr, ptr) @objc_msgSend(ptr %sess, ptr %sel_ret)
  store ptr %sess, ptr @H_sess
  ret ptr %sess
fail:
  ret ptr null
}

; Send `req` on `slot` as a streaming download into `path`. The file is created first; if
; it cannot be, or the task cannot be made, the request finishes at once with status 0.
define internal void @hs_stream_start(i32 %slot, ptr %req, ptr %path) {
entry:
  %pool = call ptr @objc_autoreleasePoolPush()
  %sp = getelementptr [8 x i32], ptr @H_strm, i32 0, i32 %slot
  store i32 1, ptr %sp
  %rp = getelementptr [8 x i32], ptr @H_recv, i32 0, i32 %slot
  store atomic i32 0, ptr %rp release, align 4
  %xp = getelementptr [8 x i32], ptr @H_exp, i32 0, i32 %slot
  store atomic i32 -1, ptr %xp release, align 4
  %ep = getelementptr [8 x i32], ptr @H_werr, i32 0, i32 %slot
  store i32 0, ptr %ep
  %sel_rel = call ptr @sel_registerName(ptr @.h_rel)
  %f = call ptr @fopen(ptr %path, ptr @.h_wb)
  %nof = icmp eq ptr %f, null
  br i1 %nof, label %finish, label %opened
opened:
  %fp = getelementptr [8 x ptr], ptr @H_file, i32 0, i32 %slot
  store ptr %f, ptr %fp
  ; the bytes on disk are the bytes the counter reports: ask for no transfer compression
  ; unless the caller chose an encoding
  %strcls = call ptr @objc_getClass(ptr @.h_nsstr)
  %sel_u = call ptr @sel_registerName(ptr @.h_utf8)
  %aen = call ptr (ptr, ptr, ptr) @objc_msgSend(ptr %strcls, ptr %sel_u, ptr @.h_aenc)
  %sel_vh = call ptr @sel_registerName(ptr @.h_vhdr)
  %cur = call ptr (ptr, ptr, ptr) @objc_msgSend(ptr %req, ptr %sel_vh, ptr %aen)
  %unset = icmp eq ptr %cur, null
  br i1 %unset, label %setenc, label %session
setenc:
  %idn = call ptr (ptr, ptr, ptr) @objc_msgSend(ptr %strcls, ptr %sel_u, ptr @.h_ident)
  %sel_sh = call ptr @sel_registerName(ptr @.h_shdr)
  %r0 = call ptr (ptr, ptr, ptr, ptr) @objc_msgSend(ptr %req, ptr %sel_sh, ptr %idn, ptr %aen)
  br label %session
session:
  %sess = call ptr @hs_session()
  %nosess = icmp eq ptr %sess, null
  br i1 %nosess, label %closefile, label %mktask
mktask:
  %sel_dt = call ptr @sel_registerName(ptr @.h_dtwr)
  %task = call ptr (ptr, ptr, ptr) @objc_msgSend(ptr %sess, ptr %sel_dt, ptr %req)
  %notask = icmp eq ptr %task, null
  br i1 %notask, label %closefile, label %run
run:
  %sel_ret = call ptr @sel_registerName(ptr @.h_retain)
  %rt = call ptr (ptr, ptr) @objc_msgSend(ptr %task, ptr %sel_ret)
  %tp = getelementptr [8 x ptr], ptr @H_task, i32 0, i32 %slot
  store ptr %task, ptr %tp
  %rr = call ptr (ptr, ptr) @objc_msgSend(ptr %req, ptr %sel_rel)
  %sel_go = call ptr @sel_registerName(ptr @.h_resume)
  %g = call ptr (ptr, ptr) @objc_msgSend(ptr %task, ptr %sel_go)
  call void @objc_autoreleasePoolPop(ptr %pool)
  ret void
closefile:
  %c = call i32 @fclose(ptr %f)
  store ptr null, ptr %fp
  br label %finish
finish:
  %rr2 = call ptr (ptr, ptr) @objc_msgSend(ptr %req, ptr %sel_rel)
  %donep = getelementptr [8 x i32], ptr @H_done, i32 0, i32 %slot
  store atomic i32 1, ptr %donep release, align 4
  call void @objc_autoreleasePoolPop(ptr %pool)
  ret void
}
