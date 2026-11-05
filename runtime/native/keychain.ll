; ============================================================================
; keychain.ll — the OS secret store behind Keychain.* (macOS, Security.framework).
;
; Linked into any program that uses Keychain.* (selfhost/main.ludic, tools/ludic-cli/build.ludic),
; with Security and CoreFoundation. keychain_win.ll is the same interface over the Windows
; Credential Manager, keychain_linux.ll over the Secret Service (libsecret).
;
; Each secret is a generic password item in the user's default (login) keychain, keyed by
; kSecAttrService + kSecAttrAccount - the item `security find-generic-password -s S -a A`
; shows.
;
;   lu_kc_set(service, account, key, secret) -> i32    0 stored, 2 failed
;   lu_kc_get(service, account, key) -> ptr            a malloc'd NUL-terminated copy, or null
;                                                      (lu_kc_status says 1 absent, 2 failed)
;   lu_kc_delete(service, account, key) -> i32         0 removed, 1 absent, 2 failed
;   lu_kc_status() -> i32                              the last call's 0 / 1 / 2
;   lu_kc_error() -> ptr                               the last failure's text ("" after a success)
;   lu_kc_available() -> i32                           1: the keychain is always there on macOS
;
; `key` is "service/account", which Windows names the credential by; it is unused here.
; ============================================================================

declare ptr @CFDictionaryCreateMutable(ptr, i64, ptr, ptr)
declare void @CFDictionarySetValue(ptr, ptr, ptr)
declare ptr @CFStringCreateWithCString(ptr, ptr, i32)
declare ptr @CFDataCreate(ptr, ptr, i64)
declare i64 @CFDataGetLength(ptr)
declare ptr @CFDataGetBytePtr(ptr)
declare i8 @CFStringGetCString(ptr, ptr, i64, i32)
declare void @CFRelease(ptr)
declare i32 @SecItemAdd(ptr, ptr)
declare i32 @SecItemUpdate(ptr, ptr)
declare i32 @SecItemCopyMatching(ptr, ptr)
declare i32 @SecItemDelete(ptr)
declare ptr @SecCopyErrorMessageString(i32, ptr)
declare i64 @strlen(ptr)
declare ptr @malloc(i64)
declare ptr @memcpy(ptr, ptr, i64)
declare i32 @snprintf(ptr, i64, ptr, ...)

@kCFTypeDictionaryKeyCallBacks = external global i8
@kCFTypeDictionaryValueCallBacks = external global i8
@kCFBooleanTrue = external global ptr
@kSecClass = external global ptr
@kSecClassGenericPassword = external global ptr
@kSecAttrService = external global ptr
@kSecAttrAccount = external global ptr
@kSecValueData = external global ptr
@kSecReturnData = external global ptr
@kSecMatchLimit = external global ptr
@kSecMatchLimitOne = external global ptr

@KC_status = internal global i32 0
@KC_msg    = internal global [512 x i8] zeroinitializer
@KC_fmt    = private constant [17 x i8] c"OSStatus %d (%s)\00"
@KC_bad    = private constant [42 x i8] c"the service or account is not valid UTF-8\00"
@KC_none   = private constant [14 x i8] c"no such error\00"

; kCFStringEncodingUTF8
define internal ptr @kc_str(ptr %s) {
entry:
  %r = call ptr @CFStringCreateWithCString(ptr null, ptr %s, i32 134217984)
  ret ptr %r
}

define internal ptr @kc_dict() {
entry:
  %d = call ptr @CFDictionaryCreateMutable(ptr null, i64 0, ptr @kCFTypeDictionaryKeyCallBacks, ptr @kCFTypeDictionaryValueCallBacks)
  ret ptr %d
}

define internal void @kc_put(ptr %d, ptr %kglobal, ptr %v) {
entry:
  %k = load ptr, ptr %kglobal
  call void @CFDictionarySetValue(ptr %d, ptr %k, ptr %v)
  ret void
}

; the query that names one item: generic password, service, account. null when either name is
; not valid UTF-8.
define internal ptr @kc_query(ptr %svc, ptr %acct) {
entry:
  %s = call ptr @kc_str(ptr %svc)
  %a = call ptr @kc_str(ptr %acct)
  %sn = icmp eq ptr %s, null
  %an = icmp eq ptr %a, null
  %bad = or i1 %sn, %an
  br i1 %bad, label %fail, label %ok
fail:
  br i1 %sn, label %f2, label %f1
f1:
  call void @CFRelease(ptr %s)
  br label %f2
f2:
  br i1 %an, label %f4, label %f3
f3:
  call void @CFRelease(ptr %a)
  br label %f4
f4:
  ret ptr null
ok:
  %d = call ptr @kc_dict()
  %cls = load ptr, ptr @kSecClassGenericPassword
  call void @kc_put(ptr %d, ptr @kSecClass, ptr %cls)
  call void @kc_put(ptr %d, ptr @kSecAttrService, ptr %s)
  call void @kc_put(ptr %d, ptr @kSecAttrAccount, ptr %a)
  call void @CFRelease(ptr %s)
  call void @CFRelease(ptr %a)
  ret ptr %d
}

define internal i32 @kc_ok(i32 %code) {
entry:
  store i32 %code, ptr @KC_status
  store i8 0, ptr @KC_msg
  ret i32 %code
}

; a failure with a fixed message
define internal i32 @kc_failtext(ptr %m) {
entry:
  store i32 2, ptr @KC_status
  %n = call i64 @strlen(ptr %m)
  %n1 = add i64 %n, 1
  call ptr @memcpy(ptr @KC_msg, ptr %m, i64 %n1)
  ret i32 2
}

; a failure with an OSStatus: "OSStatus -25308 (User interaction is not allowed.)"
define internal i32 @kc_fail(i32 %st) {
entry:
  store i32 2, ptr @KC_status
  %why = alloca [400 x i8], align 1
  store i8 0, ptr %why
  %cf = call ptr @SecCopyErrorMessageString(i32 %st, ptr null)
  %none = icmp eq ptr %cf, null
  br i1 %none, label %plain, label %text
text:
  %got = call i8 @CFStringGetCString(ptr %cf, ptr %why, i64 400, i32 134217984)
  call void @CFRelease(ptr %cf)
  %g = icmp ne i8 %got, 0
  br i1 %g, label %fmt, label %plain
plain:
  call ptr @memcpy(ptr %why, ptr @KC_none, i64 14)
  br label %fmt
fmt:
  call i32 (ptr, i64, ptr, ...) @snprintf(ptr @KC_msg, i64 512, ptr @KC_fmt, i32 %st, ptr %why)
  ret i32 2
}

define i32 @lu_kc_set(ptr %svc, ptr %acct, ptr %key, ptr %secret) {
entry:
  %q = call ptr @kc_query(ptr %svc, ptr %acct)
  %qn = icmp eq ptr %q, null
  br i1 %qn, label %bad, label %go
bad:
  %b = call i32 @kc_failtext(ptr @KC_bad)
  ret i32 2
go:
  %n = call i64 @strlen(ptr %secret)
  %data = call ptr @CFDataCreate(ptr null, ptr %secret, i64 %n)
  ; replace the item's data when it is there, add it when it is not
  %upd = call ptr @kc_dict()
  call void @kc_put(ptr %upd, ptr @kSecValueData, ptr %data)
  %st = call i32 @SecItemUpdate(ptr %q, ptr %upd)
  call void @CFRelease(ptr %upd)
  %absent = icmp eq i32 %st, -25300                       ; errSecItemNotFound
  br i1 %absent, label %add, label %done
add:
  call void @kc_put(ptr %q, ptr @kSecValueData, ptr %data)
  %st2 = call i32 @SecItemAdd(ptr %q, ptr null)
  br label %done
done:
  %r = phi i32 [ %st, %go ], [ %st2, %add ]
  call void @CFRelease(ptr %data)
  call void @CFRelease(ptr %q)
  %okk = icmp eq i32 %r, 0
  br i1 %okk, label %yes, label %no
yes:
  %y = call i32 @kc_ok(i32 0)
  ret i32 0
no:
  %f = call i32 @kc_fail(i32 %r)
  ret i32 2
}

define ptr @lu_kc_get(ptr %svc, ptr %acct, ptr %key) {
entry:
  %res = alloca ptr, align 8
  store ptr null, ptr %res
  %q = call ptr @kc_query(ptr %svc, ptr %acct)
  %qn = icmp eq ptr %q, null
  br i1 %qn, label %bad, label %go
bad:
  %b = call i32 @kc_failtext(ptr @KC_bad)
  ret ptr null
go:
  %t = load ptr, ptr @kCFBooleanTrue
  call void @kc_put(ptr %q, ptr @kSecReturnData, ptr %t)
  %one = load ptr, ptr @kSecMatchLimitOne
  call void @kc_put(ptr %q, ptr @kSecMatchLimit, ptr %one)
  %st = call i32 @SecItemCopyMatching(ptr %q, ptr %res)
  call void @CFRelease(ptr %q)
  %absent = icmp eq i32 %st, -25300
  br i1 %absent, label %none, label %check
none:
  %z = call i32 @kc_ok(i32 1)
  ret ptr null
check:
  %okk = icmp eq i32 %st, 0
  br i1 %okk, label %copy, label %fail
fail:
  %f = call i32 @kc_fail(i32 %st)
  ret ptr null
copy:
  %d = load ptr, ptr %res
  %n = call i64 @CFDataGetLength(ptr %d)
  %p = call ptr @CFDataGetBytePtr(ptr %d)
  %n1 = add i64 %n, 1
  %out = call ptr @malloc(i64 %n1)
  call ptr @memcpy(ptr %out, ptr %p, i64 %n)
  %endp = getelementptr i8, ptr %out, i64 %n
  store i8 0, ptr %endp
  call void @CFRelease(ptr %d)
  %y = call i32 @kc_ok(i32 0)
  ret ptr %out
}

define i32 @lu_kc_delete(ptr %svc, ptr %acct, ptr %key) {
entry:
  %q = call ptr @kc_query(ptr %svc, ptr %acct)
  %qn = icmp eq ptr %q, null
  br i1 %qn, label %bad, label %go
bad:
  %b = call i32 @kc_failtext(ptr @KC_bad)
  ret i32 2
go:
  %st = call i32 @SecItemDelete(ptr %q)
  call void @CFRelease(ptr %q)
  %absent = icmp eq i32 %st, -25300
  br i1 %absent, label %none, label %check
none:
  %z = call i32 @kc_ok(i32 1)
  ret i32 1
check:
  %okk = icmp eq i32 %st, 0
  br i1 %okk, label %yes, label %fail
yes:
  %y = call i32 @kc_ok(i32 0)
  ret i32 0
fail:
  %f = call i32 @kc_fail(i32 %st)
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
