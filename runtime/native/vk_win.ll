; ============================================================================
; vk_win.ll — the Vulkan loader, for Windows, written in LLVM IR.
;
; vulkan-1.dll ships with every GPU driver on Windows 10 and 11, but it is not
; guaranteed, so it is opened AT RUN TIME and never linked: a program that asks for
; Vulkan on a machine without it gets 0 from vk_open and falls back to OpenGL
; rather than failing to start.
;
;   lvk_open() -> 1 | 0      open the loader and bind every command (vk_thunks.ll)
;   lvk_sym(name) -> ptr     one entry point by name, null when the loader lacks it
;   lvk_has(name) -> 1 | 0   whether a command is there (an extension's, say)
;
; The commands themselves, their struct layouts and constants are generated from
; the Vulkan registry by `ludic-dev vkgen` into vk_api.ludic and vk_thunks.ll.
; ============================================================================

declare ptr @LoadLibraryA(ptr)
declare ptr @GetProcAddress(ptr, ptr)
declare i32 @lvk_bind()

@.lvk_dll = private unnamed_addr constant [13 x i8] c"vulkan-1.dll\00"
@lvk_lib  = internal global ptr null

define i32 @lvk_open() {
entry:
  %have = load ptr, ptr @lvk_lib
  %open = icmp ne ptr %have, null
  br i1 %open, label %ok, label %load
load:
  %lib = call ptr @LoadLibraryA(ptr @.lvk_dll)
  %none = icmp eq ptr %lib, null
  br i1 %none, label %fail, label %bind
bind:
  store ptr %lib, ptr @lvk_lib
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
  %p = call ptr @GetProcAddress(ptr %lib, ptr %name)
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
