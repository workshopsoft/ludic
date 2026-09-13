; ============================================================================
; http_win.ll — the Windows HTTP transport, written in LLVM IR.
;
; http.ll's contract over WinHTTP (winhttp.dll). ludicc links it with winhttp
; when a Windows program uses Http.*. TLS is the system's, with certificate
; verification: an https:// URL just works, as on macOS.
;
; The shape is http.ll's. A request is built on the game thread as a plain record
; (method, URL, header lines, body); hs_send hands one slot to a worker thread,
; which runs the whole blocking exchange and publishes the status, a malloc'd
; NUL-terminated copy of the body, and the WinHTTP request handle, kept open so
; header queries can be answered later. The done flag is written last, atomically,
; so what the poller reads is what the worker finished writing.
;
;   hs_req_new(method, url) -> req       hs_req_header(req, name, val)
;   hs_req_body(req, bytes, len)         hs_send(slot, req)
;   hs_done(slot) -> bool                hs_status(slot) -> int
;   hs_body(slot) -> ptr                 hs_blen(slot) -> int
;   hs_header(slot, name) -> cstr        hs_free(slot)
;
; WinHTTP speaks UTF-16; every string crosses in UTF-8 and is converted at the call.
; A request record: method 0, url 8, header lines 16 ("Name: value\r\n"...), body 24,
; body length 32.
; ============================================================================

declare ptr @malloc(i64)
declare ptr @realloc(ptr, i64)
declare void @free(ptr)
declare i64 @strlen(ptr)
declare void @llvm.memset.p0.i64(ptr, i8, i64, i1)
declare void @llvm.memcpy.p0.p0.i64(ptr, ptr, i64, i1)
declare i32 @MultiByteToWideChar(i32, i32, ptr, i32, ptr, i32)
declare i32 @WideCharToMultiByte(i32, i32, ptr, i32, ptr, i32, ptr, ptr)
declare ptr @CreateThread(ptr, i64, ptr, ptr, i32, ptr)
declare i32 @CloseHandle(ptr)
declare ptr @WinHttpOpen(ptr, i32, ptr, ptr, i32)
declare i32 @WinHttpCrackUrl(ptr, i32, i32, ptr)
declare ptr @WinHttpConnect(ptr, ptr, i16, i32)
declare ptr @WinHttpOpenRequest(ptr, ptr, ptr, ptr, ptr, ptr, i32)
declare i32 @WinHttpAddRequestHeaders(ptr, ptr, i32, i32)
declare i32 @WinHttpSendRequest(ptr, ptr, i32, ptr, i32, i32, i64)
declare i32 @WinHttpReceiveResponse(ptr, ptr)
declare i32 @WinHttpQueryHeaders(ptr, i32, ptr, ptr, ptr, ptr)
declare i32 @WinHttpQueryDataAvailable(ptr, ptr)
declare i32 @WinHttpReadData(ptr, ptr, i32, ptr)
declare i32 @WinHttpCloseHandle(ptr)

@.h_agent = private unnamed_addr constant [6 x i16] [i16 76, i16 117, i16 100, i16 105, i16 99, i16 0]   ; L"Ludic"
@.h_empty = private unnamed_addr constant [1 x i8] c"\00"
@.h_colon = private unnamed_addr constant [3 x i8] c": \00"
@.h_crlf  = private unnamed_addr constant [3 x i8] c"\0D\0A\00"

; HTTP_SLOTS = 8
@H_req    = internal global [8 x ptr] zeroinitializer
@H_sess   = internal global [8 x ptr] zeroinitializer
@H_conn   = internal global [8 x ptr] zeroinitializer
@H_hreq   = internal global [8 x ptr] zeroinitializer
@H_body   = internal global [8 x ptr] zeroinitializer
@H_blen   = internal global [8 x i32] zeroinitializer
@H_status = internal global [8 x i32] zeroinitializer
@H_done   = internal global [8 x i32] zeroinitializer
@H_hdr    = internal global [8 x ptr] zeroinitializer

; ---- strings -----------------------------------------------------------------

define internal ptr @h_dup(ptr %s) {
entry:
  %n = call i64 @strlen(ptr %s)
  %n1 = add i64 %n, 1
  %m = call ptr @malloc(i64 %n1)
  call void @llvm.memcpy.p0.p0.i64(ptr %m, ptr %s, i64 %n1, i1 false)
  ret ptr %m
}

; a fresh NUL-terminated UTF-16 copy of a UTF-8 string (CP_UTF8 = 65001)
define internal ptr @h_wide(ptr %s) {
entry:
  %n = call i32 @MultiByteToWideChar(i32 65001, i32 0, ptr %s, i32 -1, ptr null, i32 0)
  %bad = icmp sle i32 %n, 0
  br i1 %bad, label %empty, label %conv
empty:
  %e = call ptr @malloc(i64 2)
  store i16 0, ptr %e
  ret ptr %e
conv:
  %n64 = sext i32 %n to i64
  %bytes = mul i64 %n64, 2
  %w = call ptr @malloc(i64 %bytes)
  %r = call i32 @MultiByteToWideChar(i32 65001, i32 0, ptr %s, i32 -1, ptr %w, i32 %n)
  ret ptr %w
}

; `a` (or nothing, when null) followed by `b`, in a buffer that replaces `a`
define internal ptr @h_append(ptr %a, ptr %b) {
entry:
  %none = icmp eq ptr %a, null
  br i1 %none, label %zero, label %len
zero:
  br label %grow
len:
  %la0 = call i64 @strlen(ptr %a)
  br label %grow
grow:
  %la = phi i64 [ 0, %zero ], [ %la0, %len ]
  %lb = call i64 @strlen(ptr %b)
  %sum = add i64 %la, %lb
  %cap = add i64 %sum, 1
  %m = call ptr @realloc(ptr %a, i64 %cap)
  %dst = getelementptr i8, ptr %m, i64 %la
  %lb1 = add i64 %lb, 1
  call void @llvm.memcpy.p0.p0.i64(ptr %dst, ptr %b, i64 %lb1, i1 false)
  ret ptr %m
}

define internal void @h_free_if(ptr %p) {
entry:
  %none = icmp eq ptr %p, null
  br i1 %none, label %out, label %go
go:
  call void @free(ptr %p)
  br label %out
out:
  ret void
}

define internal void @h_close_if(ptr %h) {
entry:
  %none = icmp eq ptr %h, null
  br i1 %none, label %out, label %go
go:
  %r = call i32 @WinHttpCloseHandle(ptr %h)
  br label %out
out:
  ret void
}

; ---- request construction -------------------------------------------------------

define ptr @hs_req_new(ptr %method, ptr %url) {
entry:
  %nou = icmp eq ptr %url, null
  br i1 %nou, label %fail, label %mk
mk:
  %rec = call ptr @malloc(i64 40)
  call void @llvm.memset.p0.i64(ptr %rec, i8 0, i64 40, i1 false)
  %m = call ptr @h_dup(ptr %method)
  store ptr %m, ptr %rec
  %u = call ptr @h_dup(ptr %url)
  %up = getelementptr i8, ptr %rec, i64 8
  store ptr %u, ptr %up
  ret ptr %rec
fail:
  ret ptr null
}

define void @hs_req_header(ptr %req, ptr %name, ptr %val) {
entry:
  %nil = icmp eq ptr %req, null
  br i1 %nil, label %out, label %go
go:
  %hp = getelementptr i8, ptr %req, i64 16
  %h0 = load ptr, ptr %hp
  %h1 = call ptr @h_append(ptr %h0, ptr %name)
  %h2 = call ptr @h_append(ptr %h1, ptr @.h_colon)
  %h3 = call ptr @h_append(ptr %h2, ptr %val)
  %h4 = call ptr @h_append(ptr %h3, ptr @.h_crlf)
  store ptr %h4, ptr %hp
  br label %out
out:
  ret void
}

; the body is copied, as NSData copies it on macOS: the caller may free its buffer
define void @hs_req_body(ptr %req, ptr %bytes, i32 %len) {
entry:
  %nil = icmp eq ptr %req, null
  br i1 %nil, label %out, label %go
go:
  %bp = getelementptr i8, ptr %req, i64 24
  %old = load ptr, ptr %bp
  call void @h_free_if(ptr %old)
  %l64 = sext i32 %len to i64
  %cap = add i64 %l64, 1
  %b = call ptr @malloc(i64 %cap)
  call void @llvm.memcpy.p0.p0.i64(ptr %b, ptr %bytes, i64 %l64, i1 false)
  store ptr %b, ptr %bp
  %lp = getelementptr i8, ptr %req, i64 32
  store i32 %len, ptr %lp
  br label %out
out:
  ret void
}

; ---- the worker --------------------------------------------------------------------

; One whole exchange for one slot, on its own thread. arg is the slot index.
define internal i32 @h_worker(ptr %arg) {
entry:
  %uc = alloca [104 x i8], align 8          ; URL_COMPONENTS
  %num = alloca i32, align 4
  %numlen = alloca i32, align 4
  %avail = alloca i32, align 4
  %got = alloca i32, align 4
  %wurlp = alloca ptr, align 8
  %hostp = alloca ptr, align 8
  %verbp = alloca ptr, align 8
  %whdrp = alloca ptr, align 8
  %bufp = alloca ptr, align 8
  %lenp = alloca i64, align 8
  %capp = alloca i64, align 8
  store ptr null, ptr %wurlp
  store ptr null, ptr %hostp
  store ptr null, ptr %verbp
  store ptr null, ptr %whdrp
  %slot64 = ptrtoint ptr %arg to i64
  %slot = trunc i64 %slot64 to i32
  %reqp = getelementptr [8 x ptr], ptr @H_req, i32 0, i32 %slot
  %req = load ptr, ptr %reqp
  %murlp = getelementptr i8, ptr %req, i64 8
  %murl = load ptr, ptr %murlp
  %wurl = call ptr @h_wide(ptr %murl)
  store ptr %wurl, ptr %wurlp
  ; WINHTTP_ACCESS_TYPE_AUTOMATIC_PROXY: the system's proxy settings, as NSURLConnection uses
  %sess = call ptr @WinHttpOpen(ptr @.h_agent, i32 4, ptr null, ptr null, i32 0)
  %sessp = getelementptr [8 x ptr], ptr @H_sess, i32 0, i32 %slot
  store ptr %sess, ptr %sessp
  %nosess = icmp eq ptr %sess, null
  br i1 %nosess, label %done, label %crack
crack:
  ; a non-zero length asks WinHTTP for a pointer into the URL instead of a copy
  call void @llvm.memset.p0.i64(ptr %uc, i8 0, i64 104, i1 false)
  store i32 104, ptr %uc
  %sl = getelementptr i8, ptr %uc, i64 16
  store i32 -1, ptr %sl
  %hl = getelementptr i8, ptr %uc, i64 32
  store i32 -1, ptr %hl
  %pl = getelementptr i8, ptr %uc, i64 80
  store i32 -1, ptr %pl
  %xl = getelementptr i8, ptr %uc, i64 96
  store i32 -1, ptr %xl
  %ok = call i32 @WinHttpCrackUrl(ptr %wurl, i32 0, i32 0, ptr %uc)
  %noparse = icmp eq i32 %ok, 0
  br i1 %noparse, label %done, label %connect
connect:
  %hsp = getelementptr i8, ptr %uc, i64 24
  %hs = load ptr, ptr %hsp
  %hlen = load i32, ptr %hl
  %hlen64 = zext i32 %hlen to i64
  %hbytes = mul i64 %hlen64, 2
  %hcap = add i64 %hbytes, 2
  %host = call ptr @malloc(i64 %hcap)
  call void @llvm.memcpy.p0.p0.i64(ptr %host, ptr %hs, i64 %hbytes, i1 false)
  %hend = getelementptr i8, ptr %host, i64 %hbytes
  store i16 0, ptr %hend
  store ptr %host, ptr %hostp
  %portp = getelementptr i8, ptr %uc, i64 36
  %port = load i16, ptr %portp
  %conn = call ptr @WinHttpConnect(ptr %sess, ptr %host, i16 %port, i32 0)
  %connp = getelementptr [8 x ptr], ptr @H_conn, i32 0, i32 %slot
  store ptr %conn, ptr %connp
  %noconn = icmp eq ptr %conn, null
  br i1 %noconn, label %done, label %open
open:
  ; the path runs on to the end of the URL, so it carries the query with it
  %pathp = getelementptr i8, ptr %uc, i64 72
  %path = load ptr, ptr %pathp
  %schp = getelementptr i8, ptr %uc, i64 20
  %sch = load i32, ptr %schp
  %https = icmp eq i32 %sch, 2                       ; INTERNET_SCHEME_HTTPS
  %flags = select i1 %https, i32 8388608, i32 0       ; WINHTTP_FLAG_SECURE
  %mp = load ptr, ptr %req
  %verb = call ptr @h_wide(ptr %mp)
  store ptr %verb, ptr %verbp
  %hreq = call ptr @WinHttpOpenRequest(ptr %conn, ptr %verb, ptr %path, ptr null, ptr null, ptr null, i32 %flags)
  %hreqp = getelementptr [8 x ptr], ptr @H_hreq, i32 0, i32 %slot
  store ptr %hreq, ptr %hreqp
  %noreq = icmp eq ptr %hreq, null
  br i1 %noreq, label %done, label %headers
headers:
  %hdrsp = getelementptr i8, ptr %req, i64 16
  %hdrs = load ptr, ptr %hdrsp
  %nohdrs = icmp eq ptr %hdrs, null
  br i1 %nohdrs, label %send, label %addh
addh:
  %wh = call ptr @h_wide(ptr %hdrs)
  store ptr %wh, ptr %whdrp
  ; WINHTTP_ADDREQ_FLAG_ADD | WINHTTP_ADDREQ_FLAG_REPLACE: a header set twice is the last value, as setValue:forHTTPHeaderField:
  %ah = call i32 @WinHttpAddRequestHeaders(ptr %hreq, ptr %wh, i32 -1, i32 -1610612736)
  br label %send
send:
  %bodyp = getelementptr i8, ptr %req, i64 24
  %body = load ptr, ptr %bodyp
  %blp = getelementptr i8, ptr %req, i64 32
  %bl = load i32, ptr %blp
  %sent = call i32 @WinHttpSendRequest(ptr %hreq, ptr null, i32 0, ptr %body, i32 %bl, i32 %bl, i64 0)
  %nosend = icmp eq i32 %sent, 0
  br i1 %nosend, label %done, label %receive
receive:
  %rr = call i32 @WinHttpReceiveResponse(ptr %hreq, ptr null)
  %norecv = icmp eq i32 %rr, 0
  br i1 %norecv, label %done, label %status
status:
  ; WINHTTP_QUERY_STATUS_CODE | WINHTTP_QUERY_FLAG_NUMBER
  store i32 0, ptr %num
  store i32 4, ptr %numlen
  %qs = call i32 @WinHttpQueryHeaders(ptr %hreq, i32 536870931, ptr null, ptr %num, ptr %numlen, ptr null)
  %st = load i32, ptr %num
  %stp = getelementptr [8 x i32], ptr @H_status, i32 0, i32 %slot
  store i32 %st, ptr %stp
  %b0 = call ptr @malloc(i64 4097)
  store ptr %b0, ptr %bufp
  store i64 0, ptr %lenp
  store i64 4096, ptr %capp
  br label %more
more:
  store i32 0, ptr %avail
  %qa = call i32 @WinHttpQueryDataAvailable(ptr %hreq, ptr %avail)
  %av = load i32, ptr %avail
  %qfail = icmp eq i32 %qa, 0
  %nothing = icmp eq i32 %av, 0
  %stop = or i1 %qfail, %nothing
  br i1 %stop, label %finish, label %room
room:
  %len = load i64, ptr %lenp
  %cap = load i64, ptr %capp
  %av64 = zext i32 %av to i64
  %need = add i64 %len, %av64
  %small = icmp ugt i64 %need, %cap
  br i1 %small, label %enlarge, label %read
enlarge:
  %ncap = mul i64 %need, 2
  store i64 %ncap, ptr %capp
  %ob = load ptr, ptr %bufp
  %ncap1 = add i64 %ncap, 1
  %nb = call ptr @realloc(ptr %ob, i64 %ncap1)
  store ptr %nb, ptr %bufp
  br label %read
read:
  %buf = load ptr, ptr %bufp
  %len2 = load i64, ptr %lenp
  %dst = getelementptr i8, ptr %buf, i64 %len2
  store i32 0, ptr %got
  %rd = call i32 @WinHttpReadData(ptr %hreq, ptr %dst, i32 %av, ptr %got)
  %g = load i32, ptr %got
  %g64 = zext i32 %g to i64
  %len3 = add i64 %len2, %g64
  store i64 %len3, ptr %lenp
  %rfail = icmp eq i32 %rd, 0
  %none = icmp eq i32 %g, 0
  %end = or i1 %rfail, %none
  br i1 %end, label %finish, label %more
finish:
  %fb = load ptr, ptr %bufp
  %fl = load i64, ptr %lenp
  %term = getelementptr i8, ptr %fb, i64 %fl
  store i8 0, ptr %term
  %bodyslot = getelementptr [8 x ptr], ptr @H_body, i32 0, i32 %slot
  store ptr %fb, ptr %bodyslot
  %fl32 = trunc i64 %fl to i32
  %blenslot = getelementptr [8 x i32], ptr @H_blen, i32 0, i32 %slot
  store i32 %fl32, ptr %blenslot
  br label %done
done:
  %f1 = load ptr, ptr %wurlp
  call void @h_free_if(ptr %f1)
  %f2 = load ptr, ptr %hostp
  call void @h_free_if(ptr %f2)
  %f3 = load ptr, ptr %verbp
  call void @h_free_if(ptr %f3)
  %f4 = load ptr, ptr %whdrp
  call void @h_free_if(ptr %f4)
  %donep = getelementptr [8 x i32], ptr @H_done, i32 0, i32 %slot
  store atomic i32 1, ptr %donep release, align 4
  ret i32 0
}

; Start the request on `slot` running on a worker thread of its own.
define void @hs_send(i32 %slot, ptr %req) {
entry:
  %donep = getelementptr [8 x i32], ptr @H_done, i32 0, i32 %slot
  store atomic i32 0, ptr %donep release, align 4
  %stp = getelementptr [8 x i32], ptr @H_status, i32 0, i32 %slot
  store i32 0, ptr %stp
  %bodyp = getelementptr [8 x ptr], ptr @H_body, i32 0, i32 %slot
  store ptr null, ptr %bodyp
  %blenp = getelementptr [8 x i32], ptr @H_blen, i32 0, i32 %slot
  store i32 0, ptr %blenp
  %reqp = getelementptr [8 x ptr], ptr @H_req, i32 0, i32 %slot
  store ptr %req, ptr %reqp
  %nil = icmp eq ptr %req, null
  br i1 %nil, label %nothing, label %start
nothing:
  ; a request that could not be built finishes at once, with status 0, as a failed one does
  store atomic i32 1, ptr %donep release, align 4
  ret void
start:
  %arg = inttoptr i32 %slot to ptr
  %t = call ptr @CreateThread(ptr null, i64 0, ptr @h_worker, ptr %arg, i32 0, ptr null)
  %not = icmp eq ptr %t, null
  br i1 %not, label %nothing, label %detach
detach:
  %c = call i32 @CloseHandle(ptr %t)
  ret void
}

; ---- result accessors ---------------------------------------------------------------

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

; A response header value as a C string, or "" if absent / no response yet. The string
; lives until the slot's next header query or hs_free.
define ptr @hs_header(i32 %slot, ptr %name) {
entry:
  %lenp = alloca i32, align 4
  %hp = getelementptr [8 x ptr], ptr @H_hreq, i32 0, i32 %slot
  %h = load ptr, ptr %hp
  %noh = icmp eq ptr %h, null
  br i1 %noh, label %empty, label %size
size:
  %wn = call ptr @h_wide(ptr %name)
  ; WINHTTP_QUERY_CUSTOM with no buffer answers the size needed, in bytes
  store i32 0, ptr %lenp
  %q0 = call i32 @WinHttpQueryHeaders(ptr %h, i32 65535, ptr %wn, ptr null, ptr %lenp, ptr null)
  %need = load i32, ptr %lenp
  %absent = icmp sle i32 %need, 0
  br i1 %absent, label %nothere, label %fetch
nothere:
  call void @free(ptr %wn)
  br label %empty
fetch:
  %n64 = zext i32 %need to i64
  %cap = add i64 %n64, 2
  %wb = call ptr @malloc(i64 %cap)
  %q1 = call i32 @WinHttpQueryHeaders(ptr %h, i32 65535, ptr %wn, ptr %wb, ptr %lenp, ptr null)
  call void @free(ptr %wn)
  %got = load i32, ptr %lenp
  %g64 = zext i32 %got to i64
  %endp = getelementptr i8, ptr %wb, i64 %g64
  store i16 0, ptr %endp
  %failq = icmp eq i32 %q1, 0
  br i1 %failq, label %freewb, label %utf8
freewb:
  call void @free(ptr %wb)
  br label %empty
utf8:
  %n8 = call i32 @WideCharToMultiByte(i32 65001, i32 0, ptr %wb, i32 -1, ptr null, i32 0, ptr null, ptr null)
  %n8z = icmp sle i32 %n8, 0
  br i1 %n8z, label %freewb, label %conv
conv:
  %n864 = sext i32 %n8 to i64
  %out = call ptr @malloc(i64 %n864)
  %c = call i32 @WideCharToMultiByte(i32 65001, i32 0, ptr %wb, i32 -1, ptr %out, i32 %n8, ptr null, ptr null)
  call void @free(ptr %wb)
  %oldp = getelementptr [8 x ptr], ptr @H_hdr, i32 0, i32 %slot
  %old = load ptr, ptr %oldp
  call void @h_free_if(ptr %old)
  store ptr %out, ptr %oldp
  ret ptr %out
empty:
  ret ptr @.h_empty
}

; Free a slot's owned resources: the body copy, the last header string, the three
; WinHTTP handles, and the request record.
define void @hs_free(i32 %slot) {
entry:
  %bp = getelementptr [8 x ptr], ptr @H_body, i32 0, i32 %slot
  %b = load ptr, ptr %bp
  call void @h_free_if(ptr %b)
  store ptr null, ptr %bp
  %hdp = getelementptr [8 x ptr], ptr @H_hdr, i32 0, i32 %slot
  %hd = load ptr, ptr %hdp
  call void @h_free_if(ptr %hd)
  store ptr null, ptr %hdp
  %rqp = getelementptr [8 x ptr], ptr @H_hreq, i32 0, i32 %slot
  %rq = load ptr, ptr %rqp
  call void @h_close_if(ptr %rq)
  store ptr null, ptr %rqp
  %cnp = getelementptr [8 x ptr], ptr @H_conn, i32 0, i32 %slot
  %cn = load ptr, ptr %cnp
  call void @h_close_if(ptr %cn)
  store ptr null, ptr %cnp
  %ssp = getelementptr [8 x ptr], ptr @H_sess, i32 0, i32 %slot
  %ss = load ptr, ptr %ssp
  call void @h_close_if(ptr %ss)
  store ptr null, ptr %ssp
  %recp = getelementptr [8 x ptr], ptr @H_req, i32 0, i32 %slot
  %rec = load ptr, ptr %recp
  %norec = icmp eq ptr %rec, null
  br i1 %norec, label %out, label %freerec
freerec:
  %m = load ptr, ptr %rec
  call void @h_free_if(ptr %m)
  %up = getelementptr i8, ptr %rec, i64 8
  %u = load ptr, ptr %up
  call void @h_free_if(ptr %u)
  %hp = getelementptr i8, ptr %rec, i64 16
  %h = load ptr, ptr %hp
  call void @h_free_if(ptr %h)
  %bdp = getelementptr i8, ptr %rec, i64 24
  %bd = load ptr, ptr %bdp
  call void @h_free_if(ptr %bd)
  call void @free(ptr %rec)
  store ptr null, ptr %recp
  br label %out
out:
  ret void
}
