; ============================================================================
; runtime/web/wasm.ll — the web platform layer, written in LLVM IR.
;
; This is to the browser what runtime/native/cocoa.ll is to macOS: the one
; per-platform file, hand-written in the same IR ludicc emits, assembled by the
; same toolchain and handed to the same linker. No C is compiled here either.
;
; It exists because wasm32-unknown-unknown has no libc. The Ludic runtime
; (runtime/native/*.ludic) stands on a floor of ~15 platform calls — malloc,
; memcpy, fopen, getchar — and on a native target those are the OS's. On the
; web there is no OS underneath, so this file *is* the floor:
;
;   * the allocator is implemented here, over wasm linear memory;
;   * memcpy/memset/strlen are implemented here;
;   * everything genuinely external — files, stdin, stdout, the clock, and the
;     five win_* window functions — is a wasm import, resolved by
;     runtime/web/platform.js.
;
; Nothing above this file changes for the web. core.ludic, image.ludic,
; truetype.ludic and ui.ludic compile to wasm unmodified.
; ============================================================================

target triple = "wasm32-unknown-unknown"

declare i32 @llvm.wasm.memory.size.i32(i32)
declare i32 @llvm.wasm.memory.grow.i32(i32, i32)
declare void @llvm.memcpy.p0.p0.i32(ptr, ptr, i32, i1)
declare void @llvm.memmove.p0.p0.i32(ptr, ptr, i32, i1)
declare void @llvm.memset.p0.i32(ptr, i8, i32, i1)

; wasm-ld places this symbol immediately after the static data segments; its
; *address* is where our heap may begin.
@__heap_base = external global i8

; ---------------------------------------------------------------------------
; The allocator.
;
; A first-fit free list over linear memory, growing the wasm memory with
; memory.grow when it runs out. Every block carries an 8-byte header
; [i32 payload_size][i32 next_free] and the pointer handed out is header+8, so
; free() is O(1) and malloc() reuses blocks of a size it has seen before —
; which is the shape of the load the PNG decoder actually makes (a dozen tiles
; of identical dimensions, each decode allocating and releasing the same three
; buffers). Blocks are split when the fit is loose; adjacent free blocks are
; not coalesced, which costs some fragmentation and buys a lot of simplicity.
; ---------------------------------------------------------------------------

@ludic_brk  = internal global i32 0        ; bump pointer; 0 until first use
@ludic_free = internal global i32 0        ; head of the free list, 0 = empty

define ptr @malloc(i32 %n0) {
entry:
  %small = icmp slt i32 %n0, 1
  %n1    = select i1 %small, i32 1, i32 %n0
  %pad   = add i32 %n1, 7
  %n     = and i32 %pad, -8                ; 8-byte aligned payloads
  %head  = load i32, ptr @ludic_free
  br label %scan

scan:                                       ; walk the free list, first fit
  %cur  = phi i32 [ %head, %entry ], [ %nxt, %scan.next ]
  %prev = phi i32 [ 0,     %entry ], [ %cur, %scan.next ]
  %end  = icmp eq i32 %cur, 0
  br i1 %end, label %bump, label %check

check:
  %cp   = inttoptr i32 %cur to ptr
  %sz   = load i32, ptr %cp
  %nxtp = getelementptr i8, ptr %cp, i32 4
  %nxt  = load i32, ptr %nxtp
  %fits = icmp sge i32 %sz, %n
  br i1 %fits, label %take, label %scan.next

scan.next:
  br label %scan

take:                                       ; unlink %cur from the free list
  %first = icmp eq i32 %prev, 0
  br i1 %first, label %unlink.head, label %unlink.mid
unlink.head:
  store i32 %nxt, ptr @ludic_free
  br label %split
unlink.mid:
  %pp  = inttoptr i32 %prev to ptr
  %pnp = getelementptr i8, ptr %pp, i32 4
  store i32 %nxt, ptr %pnp
  br label %split

split:                                      ; give the tail back if it is worth it
  %floor = add i32 %n, 40
  %loose = icmp sge i32 %sz, %floor
  br i1 %loose, label %do.split, label %take.done
do.split:
  store i32 %n, ptr %cp
  %tail    = sub i32 %sz, %n
  %tailsz  = sub i32 %tail, 8
  %tailat0 = add i32 %cur, 8
  %tailat  = add i32 %tailat0, %n
  %tp      = inttoptr i32 %tailat to ptr
  store i32 %tailsz, ptr %tp
  %tnp = getelementptr i8, ptr %tp, i32 4
  %fh  = load i32, ptr @ludic_free
  store i32 %fh, ptr %tnp
  store i32 %tailat, ptr @ludic_free
  br label %take.done
take.done:
  %reuse = getelementptr i8, ptr %cp, i32 8
  ret ptr %reuse

bump:                                       ; nothing reusable: take fresh memory
  %b0  = load i32, ptr @ludic_brk
  %new = icmp eq i32 %b0, 0
  br i1 %new, label %brk.init, label %brk.have
brk.init:
  %hb  = ptrtoint ptr @__heap_base to i32
  %hb7 = add i32 %hb, 7
  %hba = and i32 %hb7, -8
  br label %brk.have
brk.have:
  %brk   = phi i32 [ %b0, %bump ], [ %hba, %brk.init ]
  %hdr   = add i32 %brk, 8
  %need  = add i32 %hdr, %n
  %pages = call i32 @llvm.wasm.memory.size.i32(i32 0)
  %have  = shl i32 %pages, 16
  %short = icmp ugt i32 %need, %have
  br i1 %short, label %grow, label %carve
grow:
  %deficit = sub i32 %need, %have
  %round   = add i32 %deficit, 65535
  %want    = lshr i32 %round, 16
  %got     = call i32 @llvm.wasm.memory.grow.i32(i32 0, i32 %want)
  %oom     = icmp eq i32 %got, -1
  br i1 %oom, label %fail, label %carve
fail:
  ret ptr null
carve:
  %hp = inttoptr i32 %brk to ptr
  store i32 %n, ptr %hp
  store i32 %need, ptr @ludic_brk
  %up = inttoptr i32 %hdr to ptr
  ret ptr %up
}

define void @free(ptr %p) {
entry:
  %nil = icmp eq ptr %p, null
  br i1 %nil, label %out, label %push
push:
  %pi = ptrtoint ptr %p to i32
  %hi = sub i32 %pi, 8
  %hp = inttoptr i32 %hi to ptr
  %np = getelementptr i8, ptr %hp, i32 4
  %fh = load i32, ptr @ludic_free
  store i32 %fh, ptr %np
  store i32 %hi, ptr @ludic_free
  br label %out
out:
  ret void
}

; calloc and realloc are here because LLVM *invents* calls to them. It
; recognises the allocator by name, so an -O2 pass rewrites the
; mem_alloc()+mem_set(0) that core.ludic's rt_init does into a single calloc.
; The platform layer therefore has to be a complete enough libc for whatever the
; optimiser lowers to, not just for what ludicc emits.
define ptr @calloc(i32 %count, i32 %size) {
entry:
  %n   = mul i32 %count, %size
  %p   = call ptr @malloc(i32 %n)
  %nil = icmp eq ptr %p, null
  br i1 %nil, label %out, label %zero
zero:
  call void @llvm.memset.p0.i32(ptr %p, i8 0, i32 %n, i1 false)
  br label %out
out:
  ret ptr %p
}

; the block header carries its own size, so realloc can grow in place
define ptr @realloc(ptr %p, i32 %n) {
entry:
  %nil = icmp eq ptr %p, null
  br i1 %nil, label %fresh, label %known
fresh:
  %f = call ptr @malloc(i32 %n)
  ret ptr %f
known:
  %pi  = ptrtoint ptr %p to i32
  %hi  = sub i32 %pi, 8
  %hp  = inttoptr i32 %hi to ptr
  %old = load i32, ptr %hp
  %big = icmp sge i32 %old, %n
  br i1 %big, label %keep, label %move
keep:
  ret ptr %p
move:
  %new = call ptr @malloc(i32 %n)
  %bad = icmp eq ptr %new, null
  br i1 %bad, label %fail, label %shift
fail:
  ret ptr null
shift:
  call void @llvm.memcpy.p0.p0.i32(ptr %new, ptr %p, i32 %old, i1 false)
  call void @free(ptr %p)
  ret ptr %new
}

; ---------------------------------------------------------------------------
; Bulk memory and strings.
;
; size_t is 32-bit on wasm32, which is the signature ludicc emits for this
; target and the one LLVM canonicalises these names to. They use the wasm
; bulk-memory instructions (memory.copy / memory.fill) rather than a byte loop.
; ---------------------------------------------------------------------------

define ptr @memcpy(ptr %d, ptr %s, i32 %n) {
  call void @llvm.memcpy.p0.p0.i32(ptr %d, ptr %s, i32 %n, i1 false)
  ret ptr %d
}

define ptr @memset(ptr %d, i32 %c, i32 %n) {
  %b = trunc i32 %c to i8
  call void @llvm.memset.p0.i32(ptr %d, i8 %b, i32 %n, i1 false)
  ret ptr %d
}

define ptr @memmove(ptr %d, ptr %s, i32 %n) {
  call void @llvm.memmove.p0.p0.i32(ptr %d, ptr %s, i32 %n, i1 false)
  ret ptr %d
}

define i32 @memcmp(ptr %a, ptr %b, i32 %n) {
entry:
  br label %loop
loop:
  %i    = phi i32 [ 0, %entry ], [ %i1, %step ]
  %done = icmp uge i32 %i, %n
  br i1 %done, label %same, label %test
test:
  %ap = getelementptr i8, ptr %a, i32 %i
  %bp = getelementptr i8, ptr %b, i32 %i
  %av = load i8, ptr %ap
  %bv = load i8, ptr %bp
  %eq = icmp eq i8 %av, %bv
  br i1 %eq, label %step, label %differ
step:
  %i1 = add i32 %i, 1
  br label %loop
differ:
  %az = zext i8 %av to i32
  %bz = zext i8 %bv to i32
  %r  = sub i32 %az, %bz
  ret i32 %r
same:
  ret i32 0
}

; LLVM emits bcmp for comparisons whose result is only tested against zero.
define i32 @bcmp(ptr %a, ptr %b, i32 %n) {
  %r = call i32 @memcmp(ptr %a, ptr %b, i32 %n)
  ret i32 %r
}

define i32 @strlen(ptr %s) {
entry:
  br label %loop
loop:
  %i  = phi i32 [ 0, %entry ], [ %i1, %step ]
  %cp = getelementptr i8, ptr %s, i32 %i
  %c  = load i8, ptr %cp
  %z  = icmp eq i8 %c, 0
  br i1 %z, label %out, label %step
step:
  %i1 = add i32 %i, 1
  br label %loop
out:
  ret i32 %i
}

; ---------------------------------------------------------------------------
; Everything genuinely outside the module.
;
; These are wasm imports: platform.js supplies them, exactly as Cocoa supplies
; objc_msgSend to cocoa.ll. Files are served from a preloaded read-only image of
; the game's assets; the save file is backed by localStorage.
; ---------------------------------------------------------------------------

declare i32  @web_fopen(ptr, ptr)          ; -> handle, 0 on failure
declare i32  @web_fread(i32, ptr, i32)
declare i32  @web_fwrite(i32, ptr, i32)
declare void @web_fclose(i32)
declare i32  @web_fseek(i32, i32, i32)
declare i32  @web_ftell(i32)
declare i32  @web_time()
declare void @web_exit(i32)

; A file handle is an opaque `ptr` to the Ludic runtime, and a small integer to
; JS. Handle 0 doubles as libc's NULL, so `file_open` failure checks work
; unchanged.
define ptr @fopen(ptr %path, ptr %mode) {
  %h = call i32 @web_fopen(ptr %path, ptr %mode)
  %p = inttoptr i32 %h to ptr
  ret ptr %p
}

define i32 @fread(ptr %buf, i32 %size, i32 %count, ptr %f) {
  %bytes = mul i32 %size, %count
  %h     = ptrtoint ptr %f to i32
  %got   = call i32 @web_fread(i32 %h, ptr %buf, i32 %bytes)
  ret i32 %got
}

define i32 @fwrite(ptr %buf, i32 %size, i32 %count, ptr %f) {
  %bytes = mul i32 %size, %count
  %h     = ptrtoint ptr %f to i32
  %put   = call i32 @web_fwrite(i32 %h, ptr %buf, i32 %bytes)
  ret i32 %put
}

define i32 @fclose(ptr %f) {
  %h = ptrtoint ptr %f to i32
  call void @web_fclose(i32 %h)
  ret i32 0
}

define i32 @fseek(ptr %f, i32 %off, i32 %whence) {
  %h = ptrtoint ptr %f to i32
  %r = call i32 @web_fseek(i32 %h, i32 %off, i32 %whence)
  ret i32 %r
}

define i32 @ftell(ptr %f) {
  %h = ptrtoint ptr %f to i32
  %r = call i32 @web_ftell(i32 %h)
  ret i32 %r
}

define i64 @time(ptr %slot) {
  %s = call i32 @web_time()
  %r = sext i32 %s to i64
  ret i64 %r
}

define void @exit(i32 %code) noreturn {
  call void @web_exit(i32 %code)
  unreachable
}

; stdin/stdout. A windowed web build never reads stdin — rt_poll() goes through
; win_poll() — but the intrinsic still has to resolve, and the headless path
; (used by the test suite under Node) genuinely uses both.
declare i32  @web_getchar()
declare void @web_putchar(i32)

define i32 @getchar() {
  %c = call i32 @web_getchar()
  ret i32 %c
}

define i32 @putchar(i32 %c) {
  call void @web_putchar(i32 %c)
  ret i32 %c
}

; `print_str` is the one intrinsic ludicc lowers differently for the web: on a
; native target it goes through variadic printf("%s"), which wasm's strict
; signature checking makes awkward, so the web backend emits a direct call to
; @web_print_str instead. It is a pure import — platform.js defines it — and so
; needs no adapter here.
