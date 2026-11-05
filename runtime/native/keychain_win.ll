; ============================================================================
; keychain_win.ll — the OS secret store behind Keychain.* (Windows, Credential Manager).
;
; The same interface as keychain.ll (macOS), over advapi32's CredWriteW / CredReadW /
; CredDeleteW. Linked with -ladvapi32 into any program that uses Keychain.*.
;
; Each secret is a CRED_TYPE_GENERIC credential named "service/account" (the `key` the Ludic
; layer passes), with UserName = account, persisted for this user on this machine
; (CRED_PERSIST_LOCAL_MACHINE) - what Control Panel > Credential Manager > Windows Credentials
; lists, and the naming other tools (keytar, git-credential-manager style) use. The secret's
; UTF-8 bytes are the blob, so it reads back byte for byte; Windows caps a blob at 2560 bytes.
;
;   lu_kc_set(service, account, key, secret) -> i32    0 stored, 2 failed
;   lu_kc_get(service, account, key) -> ptr            a malloc'd NUL-terminated copy, or null
;   lu_kc_delete(service, account, key) -> i32         0 removed, 1 absent, 2 failed
;   lu_kc_status() -> i32                              the last call's 0 ok / 1 absent / 2 failed
;   lu_kc_error() -> ptr                               the last failure's text ("" after a success)
;   lu_kc_available() -> i32                           1
;
; CREDENTIALW on x64 (80 bytes):
;   0 Flags u32 | 4 Type u32 | 8 TargetName | 16 Comment | 24 LastWritten (FILETIME)
;   32 CredentialBlobSize u32 | 40 CredentialBlob | 48 Persist u32 | 52 AttributeCount u32
;   56 Attributes | 64 TargetAlias | 72 UserName
; ============================================================================

declare i32 @CredWriteW(ptr, i32)
declare i32 @CredReadW(ptr, i32, i32, ptr)
declare i32 @CredDeleteW(ptr, i32, i32)
declare void @CredFree(ptr)
declare i32 @GetLastError()
declare i32 @MultiByteToWideChar(i32, i32, ptr, i32, ptr, i32)
declare i32 @FormatMessageA(i32, ptr, i32, i32, ptr, i32, ptr)
declare ptr @malloc(i64)
declare void @free(ptr)
declare i64 @strlen(ptr)
declare ptr @memcpy(ptr, ptr, i64)
declare ptr @memset(ptr, i32, i64)

@KC_status = internal global i32 0
@KC_msg    = internal global [512 x i8] zeroinitializer
@KC_bad    = private constant [42 x i8] c"the service or account is not valid UTF-8\00"
@KC_err    = private constant [15 x i8] c"Windows error \00"

; UTF-8 -> a malloc'd UTF-16 string (CP_UTF8, MB_ERR_INVALID_CHARS), or null when invalid
define internal ptr @kc_wide(ptr %s) {
entry:
  %n = call i32 @MultiByteToWideChar(i32 65001, i32 8, ptr %s, i32 -1, ptr null, i32 0)
  %bad = icmp sle i32 %n, 0
  br i1 %bad, label %no, label %yes
no:
  ret ptr null
yes:
  %n64 = sext i32 %n to i64
  %bytes = mul i64 %n64, 2
  %w = call ptr @malloc(i64 %bytes)
  %r = call i32 @MultiByteToWideChar(i32 65001, i32 8, ptr %s, i32 -1, ptr %w, i32 %n)
  ret ptr %w
}

define internal i32 @kc_ok(i32 %code) {
entry:
  store i32 %code, ptr @KC_status
  store i8 0, ptr @KC_msg
  ret i32 %code
}

define internal i32 @kc_failtext(ptr %m) {
entry:
  store i32 2, ptr @KC_status
  %n = call i64 @strlen(ptr %m)
  %n1 = add i64 %n, 1
  call ptr @memcpy(ptr @KC_msg, ptr %m, i64 %n1)
  ret i32 2
}

; a failure with a Win32 error code: the system's own text for it (trailing CR/LF and period
; trimmed), or "Windows error <n>" when it has none
define internal i32 @kc_fail(i32 %err) {
entry:
  store i32 2, ptr @KC_status
  ; FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS
  %n = call i32 @FormatMessageA(i32 4608, ptr null, i32 %err, i32 0, ptr @KC_msg, i32 511, ptr null)
  %none = icmp eq i32 %n, 0
  br i1 %none, label %num, label %trim
trim:
  %i = phi i32 [ %n, %entry ], [ %im, %cut ]
  %some = icmp sgt i32 %i, 0
  br i1 %some, label %look, label %done
look:
  %im = sub i32 %i, 1
  %p = getelementptr i8, ptr @KC_msg, i32 %im
  %c = load i8, ptr %p
  %cr = icmp eq i8 %c, 13
  %lf = icmp eq i8 %c, 10
  %dot = icmp eq i8 %c, 46
  %sp = icmp eq i8 %c, 32
  %a = or i1 %cr, %lf
  %b = or i1 %dot, %sp
  %ws = or i1 %a, %b
  br i1 %ws, label %cut, label %done
cut:
  store i8 0, ptr %p
  br label %trim
done:
  ret i32 2
num:
  call ptr @memcpy(ptr @KC_msg, ptr @KC_err, i64 14)
  ; the code's decimal digits, written backwards into a scratch buffer then copied
  %tmp = alloca [12 x i8], align 1
  br label %dig
dig:
  %v = phi i32 [ %err, %num ], [ %q, %dig ]
  %k = phi i32 [ 0, %num ], [ %k1, %dig ]
  %q = udiv i32 %v, 10
  %r = urem i32 %v, 10
  %r8 = trunc i32 %r to i8
  %ch = add i8 %r8, 48
  %tp = getelementptr i8, ptr %tmp, i32 %k
  store i8 %ch, ptr %tp
  %k1 = add i32 %k, 1
  %more = icmp ne i32 %q, 0
  br i1 %more, label %dig, label %out
out:
  br label %rev
rev:
  %j = phi i32 [ 0, %out ], [ %j1, %rev ]
  %src = sub i32 %k1, %j
  %src1 = sub i32 %src, 1
  %sp2 = getelementptr i8, ptr %tmp, i32 %src1
  %d = load i8, ptr %sp2
  %dst = add i32 %j, 14
  %dp = getelementptr i8, ptr @KC_msg, i32 %dst
  store i8 %d, ptr %dp
  %j1 = add i32 %j, 1
  %again = icmp ult i32 %j1, %k1
  br i1 %again, label %rev, label %term
term:
  %e = add i32 %k1, 14
  %ep = getelementptr i8, ptr @KC_msg, i32 %e
  store i8 0, ptr %ep
  ret i32 2
}

define i32 @lu_kc_set(ptr %svc, ptr %acct, ptr %key, ptr %secret) {
entry:
  %cred = alloca [80 x i8], align 8
  %wt = call ptr @kc_wide(ptr %key)
  %wu = call ptr @kc_wide(ptr %acct)
  %tn = icmp eq ptr %wt, null
  %un = icmp eq ptr %wu, null
  %bad = or i1 %tn, %un
  br i1 %bad, label %badtext, label %go
badtext:
  call void @free(ptr %wt)
  call void @free(ptr %wu)
  %b = call i32 @kc_failtext(ptr @KC_bad)
  ret i32 2
go:
  call ptr @memset(ptr %cred, i32 0, i64 80)
  %typ = getelementptr i8, ptr %cred, i64 4
  store i32 1, ptr %typ                                   ; CRED_TYPE_GENERIC
  %tgt = getelementptr i8, ptr %cred, i64 8
  store ptr %wt, ptr %tgt
  %n = call i64 @strlen(ptr %secret)
  %n32 = trunc i64 %n to i32
  %bsz = getelementptr i8, ptr %cred, i64 32
  store i32 %n32, ptr %bsz
  %blob = getelementptr i8, ptr %cred, i64 40
  store ptr %secret, ptr %blob
  %per = getelementptr i8, ptr %cred, i64 48
  store i32 2, ptr %per                                   ; CRED_PERSIST_LOCAL_MACHINE
  %usr = getelementptr i8, ptr %cred, i64 72
  store ptr %wu, ptr %usr
  %ok = call i32 @CredWriteW(ptr %cred, i32 0)
  %err = call i32 @GetLastError()
  call void @free(ptr %wt)
  call void @free(ptr %wu)
  %good = icmp ne i32 %ok, 0
  br i1 %good, label %yes, label %no
yes:
  %y = call i32 @kc_ok(i32 0)
  ret i32 0
no:
  %f = call i32 @kc_fail(i32 %err)
  ret i32 2
}

define ptr @lu_kc_get(ptr %svc, ptr %acct, ptr %key) {
entry:
  %pc = alloca ptr, align 8
  store ptr null, ptr %pc
  %wt = call ptr @kc_wide(ptr %key)
  %tn = icmp eq ptr %wt, null
  br i1 %tn, label %badtext, label %go
badtext:
  %b = call i32 @kc_failtext(ptr @KC_bad)
  ret ptr null
go:
  %ok = call i32 @CredReadW(ptr %wt, i32 1, i32 0, ptr %pc)
  %err = call i32 @GetLastError()
  call void @free(ptr %wt)
  %good = icmp ne i32 %ok, 0
  br i1 %good, label %copy, label %miss
miss:
  %absent = icmp eq i32 %err, 1168                        ; ERROR_NOT_FOUND
  br i1 %absent, label %none, label %fail
none:
  %z = call i32 @kc_ok(i32 1)
  ret ptr null
fail:
  %f = call i32 @kc_fail(i32 %err)
  ret ptr null
copy:
  %c = load ptr, ptr %pc
  %bsz = getelementptr i8, ptr %c, i64 32
  %n32 = load i32, ptr %bsz
  %n = zext i32 %n32 to i64
  %bp = getelementptr i8, ptr %c, i64 40
  %blob = load ptr, ptr %bp
  %n1 = add i64 %n, 1
  %out = call ptr @malloc(i64 %n1)
  call ptr @memcpy(ptr %out, ptr %blob, i64 %n)
  %endp = getelementptr i8, ptr %out, i64 %n
  store i8 0, ptr %endp
  call void @CredFree(ptr %c)
  %y = call i32 @kc_ok(i32 0)
  ret ptr %out
}

define i32 @lu_kc_delete(ptr %svc, ptr %acct, ptr %key) {
entry:
  %wt = call ptr @kc_wide(ptr %key)
  %tn = icmp eq ptr %wt, null
  br i1 %tn, label %badtext, label %go
badtext:
  %b = call i32 @kc_failtext(ptr @KC_bad)
  ret i32 2
go:
  %ok = call i32 @CredDeleteW(ptr %wt, i32 1, i32 0)
  %err = call i32 @GetLastError()
  call void @free(ptr %wt)
  %good = icmp ne i32 %ok, 0
  br i1 %good, label %yes, label %miss
yes:
  %y = call i32 @kc_ok(i32 0)
  ret i32 0
miss:
  %absent = icmp eq i32 %err, 1168
  br i1 %absent, label %none, label %fail
none:
  %z = call i32 @kc_ok(i32 1)
  ret i32 1
fail:
  %f = call i32 @kc_fail(i32 %err)
  ret i32 2
}

define i32 @lu_kc_status() {
entry:
  %s = load i32, ptr @KC_status
  ret i32 %s
}

define ptr @lu_kc_error() {
entry:
  ret ptr @KC_msg
}

define i32 @lu_kc_available() {
entry:
  ret i32 1
}
