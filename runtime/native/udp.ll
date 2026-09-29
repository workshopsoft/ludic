; ============================================================================
; udp.ll — UDP datagrams behind Udp.* (macOS / POSIX, BSD sockets).
;
; Linked into any program that uses Udp.* (selfhost/main.ludic, tools/ludic-cli/build.ludic).
; udp_win.ll is the same interface over Winsock.
;
;   lu_udp_open(port) -> int            a non-blocking IPv4 socket bound to 0.0.0.0:port
;                                       (0 picks one); a handle 1..16, or 0 on failure
;   lu_udp_port(h) -> int               the port it is bound to
;   lu_udp_send(h, ip, port, buf, len)  one datagram; bytes sent, or -1
;   lu_udp_recv(h, buf, cap, ipport)    one waiting datagram into buf: its length, or 0 when
;                                       none is waiting; the sender's ip and port go to
;                                       ipport[0] and ipport[1] (two i32s)
;   lu_udp_close(h)
;   lu_udp_resolve(name) -> int         the first IPv4 address of a host name, or 0
;   lu_udp_local_ip() -> int            the address this machine reaches the internet from
;                                       (no packet is sent), or 0
;
; An address is a host-order i32: a.b.c.d is (a << 24) | (b << 16) | (c << 8) | d.
; The handle table keeps the file descriptors, so a handle is the same small number on both
; platforms (a Winsock SOCKET is 64 bits wide).
; ============================================================================

declare i32 @socket(i32, i32, i32)
declare i32 @bind(i32, ptr, i32)
declare i32 @connect(i32, ptr, i32)
declare i32 @getsockname(i32, ptr, ptr)
declare i32 @fcntl(i32, i32, ...)
declare i64 @sendto(i32, ptr, i64, i32, ptr, i32)
declare i64 @recvfrom(i32, ptr, i64, i32, ptr, ptr)
declare i32 @close(i32)
declare i32 @getaddrinfo(ptr, ptr, ptr, ptr)
declare void @freeaddrinfo(ptr)
declare i32 @llvm.bswap.i32(i32)
declare i16 @llvm.bswap.i16(i16)

@LU_fd = internal global [16 x i32] zeroinitializer     ; fd + 1 per handle, 0 = free

; sockaddr_in (BSD): len, family, port (network order), addr (network order), 8 zero
define internal void @lu_addr(ptr %sa, i32 %ip, i32 %port) {
entry:
  store i64 0, ptr %sa
  %z8 = getelementptr i8, ptr %sa, i64 8
  store i64 0, ptr %z8
  store i8 16, ptr %sa
  %fam = getelementptr i8, ptr %sa, i64 1
  store i8 2, ptr %fam
  %p16 = trunc i32 %port to i16
  %pn = call i16 @llvm.bswap.i16(i16 %p16)
  %pp = getelementptr i8, ptr %sa, i64 2
  store i16 %pn, ptr %pp
  %in = call i32 @llvm.bswap.i32(i32 %ip)
  %ap = getelementptr i8, ptr %sa, i64 4
  store i32 %in, ptr %ap
  ret void
}

define internal i32 @lu_fd_of(i32 %h) {
entry:
  %lo = icmp slt i32 %h, 1
  %hi = icmp sgt i32 %h, 16
  %bad = or i1 %lo, %hi
  br i1 %bad, label %none, label %look
look:
  %i = sub i32 %h, 1
  %slot = getelementptr [16 x i32], ptr @LU_fd, i32 0, i32 %i
  %v = load i32, ptr %slot
  %fd = sub i32 %v, 1
  ret i32 %fd
none:
  ret i32 -1
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
  %sa = alloca [16 x i8]
  %fd = call i32 @socket(i32 2, i32 2, i32 17)
  %bad = icmp slt i32 %fd, 0
  br i1 %bad, label %fail, label %bindit
bindit:
  call void @lu_addr(ptr %sa, i32 %ip, i32 %port)
  %b = call i32 @bind(i32 %fd, ptr %sa, i32 16)
  %bb = icmp ne i32 %b, 0
  br i1 %bb, label %closefail, label %nonblock
nonblock:
  %fl = call i32 (i32, i32, ...) @fcntl(i32 %fd, i32 3, i32 0)
  %nb = or i32 %fl, 4
  %s = call i32 (i32, i32, ...) @fcntl(i32 %fd, i32 4, i32 %nb)
  br label %find
find:
  %i = phi i32 [ 0, %nonblock ], [ %inext, %next ]
  %done = icmp sge i32 %i, 16
  br i1 %done, label %closefail, label %check
check:
  %slot = getelementptr [16 x i32], ptr @LU_fd, i32 0, i32 %i
  %v = load i32, ptr %slot
  %free = icmp eq i32 %v, 0
  br i1 %free, label %take, label %next
next:
  %inext = add i32 %i, 1
  br label %find
take:
  %fd1 = add i32 %fd, 1
  store i32 %fd1, ptr %slot
  %h = add i32 %i, 1
  ret i32 %h
closefail:
  %c = call i32 @close(i32 %fd)
  br label %fail
fail:
  ret i32 0
}

define i32 @lu_udp_port(i32 %h) {
entry:
  %sa = alloca [16 x i8]
  %len = alloca i32
  store i32 16, ptr %len
  %fd = call i32 @lu_fd_of(i32 %h)
  %bad = icmp slt i32 %fd, 0
  br i1 %bad, label %none, label %ask
ask:
  %r = call i32 @getsockname(i32 %fd, ptr %sa, ptr %len)
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
  %fd = call i32 @lu_fd_of(i32 %h)
  %bad = icmp slt i32 %fd, 0
  br i1 %bad, label %none, label %go
go:
  call void @lu_addr(ptr %sa, i32 %ip, i32 %port)
  %n64 = sext i32 %n to i64
  %r = call i64 @sendto(i32 %fd, ptr %buf, i64 %n64, i32 0, ptr %sa, i32 16)
  %r32 = trunc i64 %r to i32
  ret i32 %r32
none:
  ret i32 -1
}

define i32 @lu_udp_recv(i32 %h, ptr %buf, i32 %cap, ptr %ipport) {
entry:
  %sa = alloca [16 x i8]
  %len = alloca i32
  store i32 16, ptr %len
  %fd = call i32 @lu_fd_of(i32 %h)
  %bad = icmp slt i32 %fd, 0
  br i1 %bad, label %none, label %go
go:
  %c64 = sext i32 %cap to i64
  %r = call i64 @recvfrom(i32 %fd, ptr %buf, i64 %c64, i32 0, ptr %sa, ptr %len)
  %got = icmp sgt i64 %r, 0
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
  %r32 = trunc i64 %r to i32
  ret i32 %r32
none:
  ret i32 0
}

define void @lu_udp_close(i32 %h) {
entry:
  %fd = call i32 @lu_fd_of(i32 %h)
  %bad = icmp slt i32 %fd, 0
  br i1 %bad, label %done, label %go
go:
  %c = call i32 @close(i32 %fd)
  %i = sub i32 %h, 1
  %slot = getelementptr [16 x i32], ptr @LU_fd, i32 0, i32 %i
  store i32 0, ptr %slot
  br label %done
done:
  ret void
}

; addrinfo (macOS): flags, family, socktype, protocol (i32 each), addrlen (u32), then
; canonname, addr, next (pointers at 24, 32, 40)
define i32 @lu_udp_resolve(ptr %name) {
entry:
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
declare void @llvm.memset.p0.i64(ptr, i8, i64, i1)

; connect a scratch socket toward a public address (UDP: no packet leaves) and read back
; the local address the system picked for that route
define i32 @lu_udp_local_ip() {
entry:
  %sa = alloca [16 x i8]
  %len = alloca i32
  store i32 16, ptr %len
  %fd = call i32 @socket(i32 2, i32 2, i32 17)
  %bad = icmp slt i32 %fd, 0
  br i1 %bad, label %none, label %go
go:
  ; 8.8.8.8:53
  call void @lu_addr(ptr %sa, i32 134744072, i32 53)
  %c = call i32 @connect(i32 %fd, ptr %sa, i32 16)
  %cb = icmp ne i32 %c, 0
  br i1 %cb, label %closenone, label %ask
ask:
  store i32 16, ptr %len
  %r = call i32 @getsockname(i32 %fd, ptr %sa, ptr %len)
  %ap = getelementptr i8, ptr %sa, i64 4
  %an = load i32, ptr %ap
  %ah = call i32 @llvm.bswap.i32(i32 %an)
  %x = call i32 @close(i32 %fd)
  ret i32 %ah
closenone:
  %y = call i32 @close(i32 %fd)
  br label %none
none:
  ret i32 0
}
