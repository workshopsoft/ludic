; ============================================================================
; keychain_linux.ll — the OS secret store behind Keychain.* (Linux, the Secret Service).
;
; The same interface as keychain.ll (macOS), over libsecret: GNOME Keyring, KWallet (5.97+)
; or any other org.freedesktop.secrets provider on the session bus. libsecret is opened at
; run time (dlopen "libsecret-1.so.0"), never linked, so a program that uses Keychain.*
; still starts on a machine without it - Keychain.available() is then false and every call
; fails with a message saying why.
;
; Each secret is stored under the schema "org.freedesktop.Secret.Generic" with the string
; attributes `service` and `account` - the layout keytar and `secret-tool` use, so
;   secret-tool lookup service S account A
; reads it back. The label is the `key` the Ludic layer passes ("service/account").
;
;   lu_kc_set(service, account, key, secret) -> i32    0 stored, 2 failed
;   lu_kc_get(service, account, key) -> ptr            a malloc'd NUL-terminated copy, or null
;   lu_kc_delete(service, account, key) -> i32         0 removed, 1 absent, 2 failed
;   lu_kc_status() -> i32                              the last call's 0 ok / 1 absent / 2 failed
;   lu_kc_error() -> ptr                               the last failure's text ("" after a success)
;   lu_kc_available() -> i32                           1 when libsecret loads and a Secret
;                                                      Service answers on the session bus
;
; SecretSchema (x86_64 / aarch64): name ptr | flags i32 | 32 x { name ptr, type i32 } |
; reserved i32 | 7 x ptr. SECRET_SCHEMA_NONE = 0, SECRET_SCHEMA_ATTRIBUTE_STRING = 0.
; GError: domain u32 | code i32 | message ptr (at 8).
; ============================================================================

declare ptr @dlopen(ptr, i32)
declare ptr @dlsym(ptr, ptr)
declare ptr @malloc(i64)
declare i64 @strlen(ptr)
declare ptr @memcpy(ptr, ptr, i64)

%SecretSchema = type { ptr, i32, [32 x { ptr, i32 }], i32, ptr, ptr, ptr, ptr, ptr, ptr, ptr }

@KC_s_name    = private constant [31 x i8] c"org.freedesktop.Secret.Generic\00"
@KC_s_service = private constant [8 x i8] c"service\00"
@KC_s_account = private constant [8 x i8] c"account\00"
@KC_s_probe   = private constant [21 x i8] c"ludic.keychain.probe\00"

@KC_schema = internal global %SecretSchema {
  ptr @KC_s_name, i32 0,
  [32 x { ptr, i32 }] [
    { ptr, i32 } { ptr @KC_s_service, i32 0 }, { ptr, i32 } { ptr @KC_s_account, i32 0 },
    { ptr, i32 } zeroinitializer, { ptr, i32 } zeroinitializer, { ptr, i32 } zeroinitializer,
    { ptr, i32 } zeroinitializer, { ptr, i32 } zeroinitializer, { ptr, i32 } zeroinitializer,
    { ptr, i32 } zeroinitializer, { ptr, i32 } zeroinitializer, { ptr, i32 } zeroinitializer,
    { ptr, i32 } zeroinitializer, { ptr, i32 } zeroinitializer, { ptr, i32 } zeroinitializer,
    { ptr, i32 } zeroinitializer, { ptr, i32 } zeroinitializer, { ptr, i32 } zeroinitializer,
    { ptr, i32 } zeroinitializer, { ptr, i32 } zeroinitializer, { ptr, i32 } zeroinitializer,
    { ptr, i32 } zeroinitializer, { ptr, i32 } zeroinitializer, { ptr, i32 } zeroinitializer,
    { ptr, i32 } zeroinitializer, { ptr, i32 } zeroinitializer, { ptr, i32 } zeroinitializer,
    { ptr, i32 } zeroinitializer, { ptr, i32 } zeroinitializer, { ptr, i32 } zeroinitializer,
    { ptr, i32 } zeroinitializer, { ptr, i32 } zeroinitializer, { ptr, i32 } zeroinitializer ],
  i32 0, ptr null, ptr null, ptr null, ptr null, ptr null, ptr null, ptr null }

@KC_lib0      = private constant [17 x i8] c"libsecret-1.so.0\00"
@KC_lib1      = private constant [15 x i8] c"libsecret-1.so\00"
@KC_f_store   = private constant [27 x i8] c"secret_password_store_sync\00"
@KC_f_lookup  = private constant [28 x i8] c"secret_password_lookup_sync\00"
@KC_f_clear   = private constant [27 x i8] c"secret_password_clear_sync\00"
@KC_f_free    = private constant [21 x i8] c"secret_password_free\00"
@KC_f_gerr    = private constant [13 x i8] c"g_error_free\00"
@KC_nolib     = private constant [76 x i8] c"libsecret is not installed (libsecret-1.so.0; the package is libsecret-1-0)\00"
@KC_unknown   = private constant [34 x i8] c"the Secret Service gave no reason\00"

@KC_tried  = internal global i32 0
@KC_store  = internal global ptr null
@KC_lookup = internal global ptr null
@KC_clear  = internal global ptr null
@KC_free   = internal global ptr null
@KC_gerr   = internal global ptr null

@KC_status = internal global i32 0
@KC_msg    = internal global [512 x i8] zeroinitializer

; open libsecret once; 1 when every entry point it needs was found
define internal i32 @kc_load() {
entry:
  %t = load i32, ptr @KC_tried
  %done = icmp ne i32 %t, 0
  br i1 %done, label %have, label %open
open:
  store i32 1, ptr @KC_tried
  %h0 = call ptr @dlopen(ptr @KC_lib0, i32 2)             ; RTLD_NOW
  %n0 = icmp eq ptr %h0, null
  br i1 %n0, label %try1, label %got
try1:
  %h1 = call ptr @dlopen(ptr @KC_lib1, i32 2)
  br label %got
got:
  %h = phi ptr [ %h0, %open ], [ %h1, %try1 ]
  %nh = icmp eq ptr %h, null
  br i1 %nh, label %have, label %syms
syms:
  %fs = call ptr @dlsym(ptr %h, ptr @KC_f_store)
  %fl = call ptr @dlsym(ptr %h, ptr @KC_f_lookup)
  %fc = call ptr @dlsym(ptr %h, ptr @KC_f_clear)
  %ff = call ptr @dlsym(ptr %h, ptr @KC_f_free)
  %fg = call ptr @dlsym(ptr %h, ptr @KC_f_gerr)
  %a = icmp ne ptr %fs, null
  %b = icmp ne ptr %fl, null
  %c = icmp ne ptr %fc, null
  %d = icmp ne ptr %ff, null
  %e = icmp ne ptr %fg, null
  %ab = and i1 %a, %b
  %cd = and i1 %c, %d
  %abcd = and i1 %ab, %cd
  %all = and i1 %abcd, %e
  br i1 %all, label %keep, label %have
keep:
  store ptr %fs, ptr @KC_store
  store ptr %fl, ptr @KC_lookup
  store ptr %fc, ptr @KC_clear
  store ptr %ff, ptr @KC_free
  store ptr %fg, ptr @KC_gerr
  br label %have
have:
  %s = load ptr, ptr @KC_store
  %ok = icmp ne ptr %s, null
  %r = zext i1 %ok to i32
  ret i32 %r
}

define internal i32 @kc_ok(i32 %code) {
entry:
  store i32 %code, ptr @KC_status
  store i8 0, ptr @KC_msg
  ret i32 %code
}

; copy at most 511 bytes of a message into KC_msg
define internal i32 @kc_failtext(ptr %m) {
entry:
  store i32 2, ptr @KC_status
  %n = call i64 @strlen(ptr %m)
  %big = icmp ugt i64 %n, 511
  %c = select i1 %big, i64 511, i64 %n
  call ptr @memcpy(ptr @KC_msg, ptr %m, i64 %c)
  %ep = getelementptr i8, ptr @KC_msg, i64 %c
  store i8 0, ptr %ep
  ret i32 2
}

; a GError: keep its message, free it. Returns 1 when there was one.
define internal i32 @kc_gerror(ptr %errp) {
entry:
  %e = load ptr, ptr %errp
  %none = icmp eq ptr %e, null
  br i1 %none, label %no, label %yes
no:
  ret i32 0
yes:
  %mp = getelementptr i8, ptr %e, i64 8
  %m = load ptr, ptr %mp
  %nm = icmp eq ptr %m, null
  %why = select i1 %nm, ptr @KC_unknown, ptr %m
  %f = call i32 @kc_failtext(ptr %why)
  %gf = load ptr, ptr @KC_gerr
  call void %gf(ptr %e)
  store ptr null, ptr %errp
  ret i32 1
}

define i32 @lu_kc_set(ptr %svc, ptr %acct, ptr %key, ptr %secret) {
entry:
  %errp = alloca ptr, align 8
  store ptr null, ptr %errp
  %l = call i32 @kc_load()
  %nol = icmp eq i32 %l, 0
  br i1 %nol, label %nolib, label %go
nolib:
  %x = call i32 @kc_failtext(ptr @KC_nolib)
  ret i32 2
go:
  %fs = load ptr, ptr @KC_store
  ; secret_password_store_sync(schema, collection, label, password, cancellable, error, ...)
  %ok = call i32 (ptr, ptr, ptr, ptr, ptr, ptr, ...) %fs(ptr @KC_schema, ptr null, ptr %key, ptr %secret, ptr null, ptr %errp, ptr @KC_s_service, ptr %svc, ptr @KC_s_account, ptr %acct, ptr null)
  %ge = call i32 @kc_gerror(ptr %errp)
  %had = icmp ne i32 %ge, 0
  br i1 %had, label %fail, label %chk
chk:
  %good = icmp ne i32 %ok, 0
  br i1 %good, label %yes, label %quiet
quiet:
  %q = call i32 @kc_failtext(ptr @KC_unknown)
  ret i32 2
yes:
  %y = call i32 @kc_ok(i32 0)
  ret i32 0
fail:
  ret i32 2
}

define ptr @lu_kc_get(ptr %svc, ptr %acct, ptr %key) {
entry:
  %errp = alloca ptr, align 8
  store ptr null, ptr %errp
  %l = call i32 @kc_load()
  %nol = icmp eq i32 %l, 0
  br i1 %nol, label %nolib, label %go
nolib:
  %x = call i32 @kc_failtext(ptr @KC_nolib)
  ret ptr null
go:
  %fl = load ptr, ptr @KC_lookup
  ; secret_password_lookup_sync(schema, cancellable, error, ...)
  %pw = call ptr (ptr, ptr, ptr, ...) %fl(ptr @KC_schema, ptr null, ptr %errp, ptr @KC_s_service, ptr %svc, ptr @KC_s_account, ptr %acct, ptr null)
  %ge = call i32 @kc_gerror(ptr %errp)
  %had = icmp ne i32 %ge, 0
  br i1 %had, label %fail, label %chk
fail:
  ret ptr null
chk:
  %none = icmp eq ptr %pw, null
  br i1 %none, label %absent, label %copy
absent:
  %z = call i32 @kc_ok(i32 1)
  ret ptr null
copy:
  %n = call i64 @strlen(ptr %pw)
  %n1 = add i64 %n, 1
  %out = call ptr @malloc(i64 %n1)
  call ptr @memcpy(ptr %out, ptr %pw, i64 %n1)
  %ff = load ptr, ptr @KC_free
  call void %ff(ptr %pw)                                  ; wipes the secret, then frees it
  %y = call i32 @kc_ok(i32 0)
  ret ptr %out
}

define i32 @lu_kc_delete(ptr %svc, ptr %acct, ptr %key) {
entry:
  %errp = alloca ptr, align 8
  store ptr null, ptr %errp
  %l = call i32 @kc_load()
  %nol = icmp eq i32 %l, 0
  br i1 %nol, label %nolib, label %go
nolib:
  %x = call i32 @kc_failtext(ptr @KC_nolib)
  ret i32 2
go:
  %fc = load ptr, ptr @KC_clear
  ; secret_password_clear_sync(schema, cancellable, error, ...): TRUE when something was removed
  %ok = call i32 (ptr, ptr, ptr, ...) %fc(ptr @KC_schema, ptr null, ptr %errp, ptr @KC_s_service, ptr %svc, ptr @KC_s_account, ptr %acct, ptr null)
  %ge = call i32 @kc_gerror(ptr %errp)
  %had = icmp ne i32 %ge, 0
  br i1 %had, label %fail, label %chk
fail:
  ret i32 2
chk:
  %good = icmp ne i32 %ok, 0
  br i1 %good, label %yes, label %absent
yes:
  %y = call i32 @kc_ok(i32 0)
  ret i32 0
absent:
  %z = call i32 @kc_ok(i32 1)
  ret i32 1
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

; libsecret loads, and a lookup of an item that is never there comes back without an error -
; which needs a Secret Service on the session bus (or one D-Bus can start)
define i32 @lu_kc_available() {
entry:
  %errp = alloca ptr, align 8
  store ptr null, ptr %errp
  %l = call i32 @kc_load()
  %nol = icmp eq i32 %l, 0
  br i1 %nol, label %nolib, label %go
nolib:
  %x = call i32 @kc_failtext(ptr @KC_nolib)
  ret i32 0
go:
  %fl = load ptr, ptr @KC_lookup
  %pw = call ptr (ptr, ptr, ptr, ...) %fl(ptr @KC_schema, ptr null, ptr %errp, ptr @KC_s_service, ptr @KC_s_probe, ptr @KC_s_account, ptr @KC_s_probe, ptr null)
  %ge = call i32 @kc_gerror(ptr %errp)
  %had = icmp ne i32 %ge, 0
  br i1 %had, label %no, label %yes
no:
  ret i32 0
yes:
  %some = icmp ne ptr %pw, null
  br i1 %some, label %drop, label %fine
drop:
  %ff = load ptr, ptr @KC_free
  call void %ff(ptr %pw)
  br label %fine
fine:
  %y = call i32 @kc_ok(i32 0)
  ret i32 1
}
