; ============================================================================
; udp_win.ll — UDP datagrams behind Udp.* (Windows, Winsock 2).
;
; The interface of udp.ll over ws2_32: WSAStartup on first use, a SOCKET per handle (64 bits,
; kept in the table), ioctlsocket(FIONBIO) for non-blocking reads, and the Windows
; sockaddr_in (a 16-bit family, no length byte). See udp.ll for the interface.
; ============================================================================

declare i32 @WSAStartup(i16, ptr)
declare i64 @socket(i32, i32, i32)
declare i32 @bind(i64, ptr, i32)
declare i32 @connect(i64, ptr, i32)
declare i32 @getsockname(i64, ptr, ptr)
declare i32 @ioctlsocket(i64, i32, ptr)
declare i32 @sendto(i64, ptr, i32, i32, ptr, i32)
declare i32 @recvfrom(i64, ptr, i32, i32, ptr, ptr)
declare i32 @closesocket(i64)
declare i32 @getaddrinfo(ptr, ptr, ptr, ptr)
declare void @freeaddrinfo(ptr)
declare i32 @llvm.bswap.i32(i32)
declare i16 @llvm.bswap.i16(i16)
declare void @llvm.memset.p0.i64(ptr, i8, i64, i1)

@LU_sock = internal global [16 x i64] zeroinitializer   ; SOCKET + 1 per handle, 0 = free
@LU_wsa = internal global i32 0
@LU_wsadata = internal global [512 x i8] zeroinitializer

define internal void @lu_start() {
entry:
  %s = load i32, ptr @LU_wsa
  %ok = icmp ne i32 %s, 0
  br i1 %ok, label %done, label %go
go:
  %r = call i32 @WSAStartup(i16 514, ptr @LU_wsadata)
  store i32 1, ptr @LU_wsa
  br label %done
done:
  ret void
}

; sockaddr_in (Winsock): family (u16), port (network order), addr (network order), 8 zero
define internal void @lu_addr(ptr %sa, i32 %ip, i32 %port) {
entry:
  store i64 0, ptr %sa
  %z8 = getelementptr i8, ptr %sa, i64 8
  store i64 0, ptr %z8
  store i16 2, ptr %sa
  %p16 = trunc i32 %port to i16
  %pn = call i16 @llvm.bswap.i16(i16 %p16)
  %pp = getelementptr i8, ptr %sa, i64 2
  store i16 %pn, ptr %pp
  %in = call i32 @llvm.bswap.i32(i32 %ip)
  %ap = getelementptr i8, ptr %sa, i64 4
  store i32 %in, ptr %ap
  ret void
}

define internal i64 @lu_sock_of(i32 %h) {
entry:
  %lo = icmp slt i32 %h, 1
  %hi = icmp sgt i32 %h, 16
  %bad = or i1 %lo, %hi
  br i1 %bad, label %none, label %look
look:
  %i = sub i32 %h, 1
  %slot = getelementptr [16 x i64], ptr @LU_sock, i32 0, i32 %i
  %v = load i64, ptr %slot
  %s = sub i64 %v, 1
  ret i64 %s
none:
  ret i64 -1
}

; open: every interface (a party's port, reached from the LAN and beyond)
define i32 @lu_udp_open(i32 %port) {
entry:
  %h = call i32 @lu_udp_open_at(i32 0, i32 %port)
  ret i32 %h
}

; open_local: 127.0.0.1 only - a port for this machine's own tools, never reachable from the LAN
define i32 @lu_udp_open_local(i32 %port) {
entry:
  %h = call i32 @lu_udp_open_at(i32 2130706433, i32 %port)
  ret i32 %h
}

; bound to one address (host order: 0 any, 0x7f000001 loopback), non-blocking, in a free slot
define internal i32 @lu_udp_open_at(i32 %ip, i32 %port) {
entry:
  call void @lu_start()
  %sa = alloca [16 x i8]
  %arg = alloca i32
  %s = call i64 @socket(i32 2, i32 2, i32 17)
  %bad = icmp eq i64 %s, -1
  br i1 %bad, label %fail, label %bindit
bindit:
  call void @lu_addr(ptr %sa, i32 %ip, i32 %port)
  %b = call i32 @bind(i64 %s, ptr %sa, i32 16)
  %bb = icmp ne i32 %b, 0
  br i1 %bb, label %closefail, label %nonblock
nonblock:
  store i32 1, ptr %arg
  ; FIONBIO = 0x8004667E
  %nb = call i32 @ioctlsocket(i64 %s, i32 -2147195266, ptr %arg)
  br label %find
find:
  %i = phi i32 [ 0, %nonblock ], [ %inext, %next ]
  %done = icmp sge i32 %i, 16
  br i1 %done, label %closefail, label %check
check:
  %slot = getelementptr [16 x i64], ptr @LU_sock, i32 0, i32 %i
  %v = load i64, ptr %slot
  %free = icmp eq i64 %v, 0
  br i1 %free, label %take, label %next
next:
  %inext = add i32 %i, 1
  br label %find
take:
  %s1 = add i64 %s, 1
  store i64 %s1, ptr %slot
  %h = add i32 %i, 1
  ret i32 %h
closefail:
  %c = call i32 @closesocket(i64 %s)
  br label %fail
fail:
  ret i32 0
}

define i32 @lu_udp_port(i32 %h) {
entry:
  %sa = alloca [16 x i8]
  %len = alloca i32
  store i32 16, ptr %len
  %s = call i64 @lu_sock_of(i32 %h)
  %bad = icmp eq i64 %s, -1
  br i1 %bad, label %none, label %ask
ask:
  %r = call i32 @getsockname(i64 %s, ptr %sa, ptr %len)
  %rb = icmp ne i32 %r, 0
  br i1 %rb, label %none, label %read
read:
  %pp = getelementptr i8, ptr %sa, i64 2
  %pn = load i16, ptr %pp
  %ph = call i16 @llvm.bswap.i16(i16 %pn)
  %p = zext i16 %ph to i32
  ret i32 %p
none:
  ret i32 0
}

define i32 @lu_udp_send(i32 %h, i32 %ip, i32 %port, ptr %buf, i32 %n) {
entry:
  %sa = alloca [16 x i8]
  %s = call i64 @lu_sock_of(i32 %h)
  %bad = icmp eq i64 %s, -1
  br i1 %bad, label %none, label %go
go:
  call void @lu_addr(ptr %sa, i32 %ip, i32 %port)
  %r = call i32 @sendto(i64 %s, ptr %buf, i32 %n, i32 0, ptr %sa, i32 16)
  ret i32 %r
none:
  ret i32 -1
}

define i32 @lu_udp_recv(i32 %h, ptr %buf, i32 %cap, ptr %ipport) {
entry:
  %sa = alloca [16 x i8]
  %len = alloca i32
  store i32 16, ptr %len
  %s = call i64 @lu_sock_of(i32 %h)
  %bad = icmp eq i64 %s, -1
  br i1 %bad, label %none, label %go
go:
  %r = call i32 @recvfrom(i64 %s, ptr %buf, i32 %cap, i32 0, ptr %sa, ptr %len)
  %got = icmp sgt i32 %r, 0
  br i1 %got, label %from, label %none
from:
  %ap = getelementptr i8, ptr %sa, i64 4
  %an = load i32, ptr %ap
  %ah = call i32 @llvm.bswap.i32(i32 %an)
  store i32 %ah, ptr %ipport
  %pp = getelementptr i8, ptr %sa, i64 2
  %pn = load i16, ptr %pp
  %ph = call i16 @llvm.bswap.i16(i16 %pn)
  %p = zext i16 %ph to i32
  %o = getelementptr i8, ptr %ipport, i64 4
  store i32 %p, ptr %o
  ret i32 %r
none:
  ret i32 0
}

define void @lu_udp_close(i32 %h) {
entry:
  %s = call i64 @lu_sock_of(i32 %h)
  %bad = icmp eq i64 %s, -1
  br i1 %bad, label %done, label %go
go:
  %c = call i32 @closesocket(i64 %s)
  %i = sub i32 %h, 1
  %slot = getelementptr [16 x i64], ptr @LU_sock, i32 0, i32 %i
  store i64 0, ptr %slot
  br label %done
done:
  ret void
}

; addrinfo (Winsock): flags, family, socktype, protocol (i32 each), addrlen (size_t at 16),
; then canonname, addr, next (pointers at 24, 32, 40)
define i32 @lu_udp_resolve(ptr %name) {
entry:
  call void @lu_start()
  %hints = alloca [48 x i8]
  %res = alloca ptr
  store ptr null, ptr %res
  call void @llvm.memset.p0.i64(ptr %hints, i8 0, i64 48, i1 false)
  %fam = getelementptr i8, ptr %hints, i64 4
  store i32 2, ptr %fam
  %st = getelementptr i8, ptr %hints, i64 8
  store i32 2, ptr %st
  %r = call i32 @getaddrinfo(ptr %name, ptr null, ptr %hints, ptr %res)
  %rb = icmp ne i32 %r, 0
  br i1 %rb, label %none, label %read
read:
  %ai = load ptr, ptr %res
  %isnull = icmp eq ptr %ai, null
  br i1 %isnull, label %none, label %addr
addr:
  %sap = getelementptr i8, ptr %ai, i64 32
  %sa = load ptr, ptr %sap
  %ap = getelementptr i8, ptr %sa, i64 4
  %an = load i32, ptr %ap
  %ah = call i32 @llvm.bswap.i32(i32 %an)
  call void @freeaddrinfo(ptr %ai)
  ret i32 %ah
none:
  ret i32 0
}

define i32 @lu_udp_local_ip() {
entry:
  call void @lu_start()
  %sa = alloca [16 x i8]
  %len = alloca i32
  %s = call i64 @socket(i32 2, i32 2, i32 17)
  %bad = icmp eq i64 %s, -1
  br i1 %bad, label %none, label %go
go:
  call void @lu_addr(ptr %sa, i32 134744072, i32 53)
  %c = call i32 @connect(i64 %s, ptr %sa, i32 16)
  %cb = icmp ne i32 %c, 0
  br i1 %cb, label %closenone, label %ask
ask:
  store i32 16, ptr %len
  %r = call i32 @getsockname(i64 %s, ptr %sa, ptr %len)
  %ap = getelementptr i8, ptr %sa, i64 4
  %an = load i32, ptr %ap
  %ah = call i32 @llvm.bswap.i32(i32 %an)
  %x = call i32 @closesocket(i64 %s)
  ret i32 %ah
closenone:
  %y = call i32 @closesocket(i64 %s)
  br label %none
none:
  ret i32 0
}
