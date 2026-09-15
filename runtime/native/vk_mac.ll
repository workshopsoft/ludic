; ============================================================================
; vk_mac.ll — the Vulkan loader, for macOS, written in LLVM IR.
;
; macOS has no Vulkan of its own: the LunarG loader and MoltenVK (Vulkan over
; Metal) come with the Vulkan SDK or with a game that bundles them. So the loader
; is looked for at run time - beside the executable, in the usual library
; directories, then under $VULKAN_SDK - and a Mac without it gets 0 from vk_open
; and stays on OpenGL. The contract is vk_win.ll's:
;
;   lvk_open() -> 1 | 0      lvk_sym(name) -> ptr      lvk_has(name) -> 1 | 0
;
; MoltenVK is a portability driver: an instance must ask for
; VK_KHR_portability_enumeration (and the ENUMERATE_PORTABILITY flag) to see it.
; ============================================================================

declare ptr @dlopen(ptr, i32)
declare ptr @dlsym(ptr, ptr)
declare ptr @getenv(ptr)
declare i32 @snprintf(ptr, i64, ptr, ...)
declare i32 @lvk_bind()

@.lvk_c0 = private unnamed_addr constant [18 x i8] c"libvulkan.1.dylib\00"
@.lvk_c1 = private unnamed_addr constant [35 x i8] c"@executable_path/libvulkan.1.dylib\00"
@.lvk_c2 = private unnamed_addr constant [33 x i8] c"/usr/local/lib/libvulkan.1.dylib\00"
@.lvk_c3 = private unnamed_addr constant [36 x i8] c"/opt/homebrew/lib/libvulkan.1.dylib\00"
@.lvk_env = private unnamed_addr constant [11 x i8] c"VULKAN_SDK\00"
@.lvk_fmt = private unnamed_addr constant [25 x i8] c"%s/lib/libvulkan.1.dylib\00"
@lvk_lib  = internal global ptr null

; RTLD_NOW (2) | RTLD_LOCAL (4)
define internal ptr @lvk_try(ptr %path) {
entry:
  %h = call ptr @dlopen(ptr %path, i32 6)
  ret ptr %h
}

define i32 @lvk_open() {
entry:
  %have = load ptr, ptr @lvk_lib
  %open = icmp ne ptr %have, null
  br i1 %open, label %ok, label %t0
t0:
  %h0 = call ptr @lvk_try(ptr @.lvk_c0)
  %n0 = icmp eq ptr %h0, null
  br i1 %n0, label %t1, label %got0
got0:
  store ptr %h0, ptr @lvk_lib
  br label %bind
t1:
  %h1 = call ptr @lvk_try(ptr @.lvk_c1)
  %n1 = icmp eq ptr %h1, null
  br i1 %n1, label %t2, label %got1
got1:
  store ptr %h1, ptr @lvk_lib
  br label %bind
t2:
  %h2 = call ptr @lvk_try(ptr @.lvk_c2)
  %n2 = icmp eq ptr %h2, null
  br i1 %n2, label %t3, label %got2
got2:
  store ptr %h2, ptr @lvk_lib
  br label %bind
t3:
  %h3 = call ptr @lvk_try(ptr @.lvk_c3)
  %n3 = icmp eq ptr %h3, null
  br i1 %n3, label %t4, label %got3
got3:
  store ptr %h3, ptr @lvk_lib
  br label %bind
t4:
  %sdk = call ptr @getenv(ptr @.lvk_env)
  %nosdk = icmp eq ptr %sdk, null
  br i1 %nosdk, label %fail, label %t4b
t4b:
  %buf = alloca [1024 x i8]
  %w = call i32 (ptr, i64, ptr, ...) @snprintf(ptr %buf, i64 1024, ptr @.lvk_fmt, ptr %sdk)
  %h4 = call ptr @lvk_try(ptr %buf)
  %n4 = icmp eq ptr %h4, null
  br i1 %n4, label %fail, label %got4
got4:
  store ptr %h4, ptr @lvk_lib
  br label %bind
bind:
  %n = call i32 @lvk_bind()
  br label %ok
ok:
  ret i32 1
fail:
  ret i32 0
}

define ptr @lvk_sym(ptr %name) {
entry:
  %lib = load ptr, ptr @lvk_lib
  %none = icmp eq ptr %lib, null
  br i1 %none, label %no, label %look
look:
  %p = call ptr @dlsym(ptr %lib, ptr %name)
  ret ptr %p
no:
  ret ptr null
}

define i32 @lvk_has(ptr %name) {
entry:
  %p = call ptr @lvk_sym(ptr %name)
  %there = icmp ne ptr %p, null
  %r = zext i1 %there to i32
  ret i32 %r
}

; ---- Streamline: Windows only. The same symbols, so a program that calls them links everywhere. ----
define void @lvk_sl_prefer(i32 %on) {
entry:
  ret void
}
define i32 @lvk_sl_active() {
entry:
  ret i32 0
}
define i32 @lsl_slInit(ptr %a0, i64 %a1) {
entry:
  ret i32 -1
}
define i32 @lsl_slShutdown() {
entry:
  ret i32 -1
}
define i32 @lsl_slIsFeatureSupported(i32 %a0, ptr %a1) {
entry:
  ret i32 -1
}
define i32 @lsl_slIsFeatureLoaded(i32 %a0, ptr %a1) {
entry:
  ret i32 -1
}
define i32 @lsl_slGetFeatureRequirements(i32 %a0, ptr %a1) {
entry:
  ret i32 -1
}
define i32 @lsl_slGetFeatureFunction(i32 %a0, ptr %a1, ptr %a2) {
entry:
  ret i32 -1
}
define i32 @lsl_slGetNewFrameToken(ptr %a0, ptr %a1) {
entry:
  ret i32 -1
}
define i32 @lsl_slSetTagForFrame(ptr %a0, ptr %a1, ptr %a2, i32 %a3, ptr %a4) {
entry:
  ret i32 -1
}
define i32 @lsl_slSetConstants(ptr %a0, ptr %a1, ptr %a2) {
entry:
  ret i32 -1
}
define i32 @lsl_slEvaluateFeature(i32 %a0, ptr %a1, ptr %a2, i32 %a3, ptr %a4) {
entry:
  ret i32 -1
}
define i32 @lsl_slFreeResources(i32 %a0, ptr %a1) {
entry:
  ret i32 -1
}
define i32 @lsl_call_p(ptr %fn, ptr %a0) {
entry:
  %r = call i32 %fn(ptr %a0)
  ret i32 %r
}
define i32 @lsl_call_pp(ptr %fn, ptr %a0, ptr %a1) {
entry:
  %r = call i32 %fn(ptr %a0, ptr %a1)
  ret i32 %r
}
define i32 @lsl_call_ppp(ptr %fn, ptr %a0, ptr %a1, ptr %a2) {
entry:
  %r = call i32 %fn(ptr %a0, ptr %a1, ptr %a2)
  ret i32 %r
}
define i32 @lsl_call_ip(ptr %fn, i32 %a0, ptr %a1) {
entry:
  %r = call i32 %fn(i32 %a0, ptr %a1)
  ret i32 %r
}
