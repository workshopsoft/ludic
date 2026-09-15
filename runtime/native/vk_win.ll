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
  ; Streamline: when the renderer asked for it (lvk_sl_prefer) and sl.interposer.dll is found, the
  ; interposer IS the loader - it proxies every Vulkan command, and intercepts the few its DLSS and
  ; Reflex plugins need. Without it, vulkan-1.dll as always.
  %want = load i32, ptr @lvk_sl_want
  %try = icmp ne i32 %want, 0
  br i1 %try, label %sl, label %plain
sl:
  %sll = call ptr @LoadLibraryA(ptr @.lsl_dll)
  %slmiss = icmp eq ptr %sll, null
  br i1 %slmiss, label %plain, label %slok
slok:
  store i32 1, ptr @lvk_sl_on
  store ptr %sll, ptr @lvk_lib
  %sln = call i32 @lvk_bind()
  br label %ok
plain:
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

; ---- Streamline (NVIDIA DLSS, Reflex) -----------------------------------------------------------
; lvk_sl_prefer(1) before lvk_open makes the loader try sl.interposer.dll first; lvk_sl_active says
; whether it did. The sl* thunks resolve their exports from the opened library once and return -1
; (not sl::Result::eOk) when it has none - vulkan-1.dll, or no library at all.
@.lsl_dll = private unnamed_addr constant [18 x i8] c"sl.interposer.dll\00"
@lvk_sl_want = internal global i32 0
@lvk_sl_on = internal global i32 0
define void @lvk_sl_prefer(i32 %on) {
entry:
  store i32 %on, ptr @lvk_sl_want
  ret void
}
define i32 @lvk_sl_active() {
entry:
  %v = load i32, ptr @lvk_sl_on
  ret i32 %v
}
@.lsl_n_slInit = private unnamed_addr constant [7 x i8] c"slInit\00"
@lsl_p_slInit = internal global ptr null
define i32 @lsl_slInit(ptr %a0, i64 %a1) {
entry:
  %have = load ptr, ptr @lsl_p_slInit
  %known = icmp ne ptr %have, null
  br i1 %known, label %call, label %look
look:
  %found = call ptr @lvk_sym(ptr @.lsl_n_slInit)
  store ptr %found, ptr @lsl_p_slInit
  %none = icmp eq ptr %found, null
  br i1 %none, label %absent, label %call
call:
  %fp = load ptr, ptr @lsl_p_slInit
  %r = call i32 %fp(ptr %a0, i64 %a1)
  ret i32 %r
absent:
  ret i32 -1
}
@.lsl_n_slShutdown = private unnamed_addr constant [11 x i8] c"slShutdown\00"
@lsl_p_slShutdown = internal global ptr null
define i32 @lsl_slShutdown() {
entry:
  %have = load ptr, ptr @lsl_p_slShutdown
  %known = icmp ne ptr %have, null
  br i1 %known, label %call, label %look
look:
  %found = call ptr @lvk_sym(ptr @.lsl_n_slShutdown)
  store ptr %found, ptr @lsl_p_slShutdown
  %none = icmp eq ptr %found, null
  br i1 %none, label %absent, label %call
call:
  %fp = load ptr, ptr @lsl_p_slShutdown
  %r = call i32 %fp()
  ret i32 %r
absent:
  ret i32 -1
}
@.lsl_n_slIsFeatureSupported = private unnamed_addr constant [21 x i8] c"slIsFeatureSupported\00"
@lsl_p_slIsFeatureSupported = internal global ptr null
define i32 @lsl_slIsFeatureSupported(i32 %a0, ptr %a1) {
entry:
  %have = load ptr, ptr @lsl_p_slIsFeatureSupported
  %known = icmp ne ptr %have, null
  br i1 %known, label %call, label %look
look:
  %found = call ptr @lvk_sym(ptr @.lsl_n_slIsFeatureSupported)
  store ptr %found, ptr @lsl_p_slIsFeatureSupported
  %none = icmp eq ptr %found, null
  br i1 %none, label %absent, label %call
call:
  %fp = load ptr, ptr @lsl_p_slIsFeatureSupported
  %r = call i32 %fp(i32 %a0, ptr %a1)
  ret i32 %r
absent:
  ret i32 -1
}
@.lsl_n_slIsFeatureLoaded = private unnamed_addr constant [18 x i8] c"slIsFeatureLoaded\00"
@lsl_p_slIsFeatureLoaded = internal global ptr null
define i32 @lsl_slIsFeatureLoaded(i32 %a0, ptr %a1) {
entry:
  %have = load ptr, ptr @lsl_p_slIsFeatureLoaded
  %known = icmp ne ptr %have, null
  br i1 %known, label %call, label %look
look:
  %found = call ptr @lvk_sym(ptr @.lsl_n_slIsFeatureLoaded)
  store ptr %found, ptr @lsl_p_slIsFeatureLoaded
  %none = icmp eq ptr %found, null
  br i1 %none, label %absent, label %call
call:
  %fp = load ptr, ptr @lsl_p_slIsFeatureLoaded
  %r = call i32 %fp(i32 %a0, ptr %a1)
  ret i32 %r
absent:
  ret i32 -1
}
@.lsl_n_slGetFeatureRequirements = private unnamed_addr constant [25 x i8] c"slGetFeatureRequirements\00"
@lsl_p_slGetFeatureRequirements = internal global ptr null
define i32 @lsl_slGetFeatureRequirements(i32 %a0, ptr %a1) {
entry:
  %have = load ptr, ptr @lsl_p_slGetFeatureRequirements
  %known = icmp ne ptr %have, null
  br i1 %known, label %call, label %look
look:
  %found = call ptr @lvk_sym(ptr @.lsl_n_slGetFeatureRequirements)
  store ptr %found, ptr @lsl_p_slGetFeatureRequirements
  %none = icmp eq ptr %found, null
  br i1 %none, label %absent, label %call
call:
  %fp = load ptr, ptr @lsl_p_slGetFeatureRequirements
  %r = call i32 %fp(i32 %a0, ptr %a1)
  ret i32 %r
absent:
  ret i32 -1
}
@.lsl_n_slGetFeatureFunction = private unnamed_addr constant [21 x i8] c"slGetFeatureFunction\00"
@lsl_p_slGetFeatureFunction = internal global ptr null
define i32 @lsl_slGetFeatureFunction(i32 %a0, ptr %a1, ptr %a2) {
entry:
  %have = load ptr, ptr @lsl_p_slGetFeatureFunction
  %known = icmp ne ptr %have, null
  br i1 %known, label %call, label %look
look:
  %found = call ptr @lvk_sym(ptr @.lsl_n_slGetFeatureFunction)
  store ptr %found, ptr @lsl_p_slGetFeatureFunction
  %none = icmp eq ptr %found, null
  br i1 %none, label %absent, label %call
call:
  %fp = load ptr, ptr @lsl_p_slGetFeatureFunction
  %r = call i32 %fp(i32 %a0, ptr %a1, ptr %a2)
  ret i32 %r
absent:
  ret i32 -1
}
@.lsl_n_slGetNewFrameToken = private unnamed_addr constant [19 x i8] c"slGetNewFrameToken\00"
@lsl_p_slGetNewFrameToken = internal global ptr null
define i32 @lsl_slGetNewFrameToken(ptr %a0, ptr %a1) {
entry:
  %have = load ptr, ptr @lsl_p_slGetNewFrameToken
  %known = icmp ne ptr %have, null
  br i1 %known, label %call, label %look
look:
  %found = call ptr @lvk_sym(ptr @.lsl_n_slGetNewFrameToken)
  store ptr %found, ptr @lsl_p_slGetNewFrameToken
  %none = icmp eq ptr %found, null
  br i1 %none, label %absent, label %call
call:
  %fp = load ptr, ptr @lsl_p_slGetNewFrameToken
  %r = call i32 %fp(ptr %a0, ptr %a1)
  ret i32 %r
absent:
  ret i32 -1
}
@.lsl_n_slSetTagForFrame = private unnamed_addr constant [17 x i8] c"slSetTagForFrame\00"
@lsl_p_slSetTagForFrame = internal global ptr null
define i32 @lsl_slSetTagForFrame(ptr %a0, ptr %a1, ptr %a2, i32 %a3, ptr %a4) {
entry:
  %have = load ptr, ptr @lsl_p_slSetTagForFrame
  %known = icmp ne ptr %have, null
  br i1 %known, label %call, label %look
look:
  %found = call ptr @lvk_sym(ptr @.lsl_n_slSetTagForFrame)
  store ptr %found, ptr @lsl_p_slSetTagForFrame
  %none = icmp eq ptr %found, null
  br i1 %none, label %absent, label %call
call:
  %fp = load ptr, ptr @lsl_p_slSetTagForFrame
  %r = call i32 %fp(ptr %a0, ptr %a1, ptr %a2, i32 %a3, ptr %a4)
  ret i32 %r
absent:
  ret i32 -1
}
@.lsl_n_slSetConstants = private unnamed_addr constant [15 x i8] c"slSetConstants\00"
@lsl_p_slSetConstants = internal global ptr null
define i32 @lsl_slSetConstants(ptr %a0, ptr %a1, ptr %a2) {
entry:
  %have = load ptr, ptr @lsl_p_slSetConstants
  %known = icmp ne ptr %have, null
  br i1 %known, label %call, label %look
look:
  %found = call ptr @lvk_sym(ptr @.lsl_n_slSetConstants)
  store ptr %found, ptr @lsl_p_slSetConstants
  %none = icmp eq ptr %found, null
  br i1 %none, label %absent, label %call
call:
  %fp = load ptr, ptr @lsl_p_slSetConstants
  %r = call i32 %fp(ptr %a0, ptr %a1, ptr %a2)
  ret i32 %r
absent:
  ret i32 -1
}
@.lsl_n_slEvaluateFeature = private unnamed_addr constant [18 x i8] c"slEvaluateFeature\00"
@lsl_p_slEvaluateFeature = internal global ptr null
define i32 @lsl_slEvaluateFeature(i32 %a0, ptr %a1, ptr %a2, i32 %a3, ptr %a4) {
entry:
  %have = load ptr, ptr @lsl_p_slEvaluateFeature
  %known = icmp ne ptr %have, null
  br i1 %known, label %call, label %look
look:
  %found = call ptr @lvk_sym(ptr @.lsl_n_slEvaluateFeature)
  store ptr %found, ptr @lsl_p_slEvaluateFeature
  %none = icmp eq ptr %found, null
  br i1 %none, label %absent, label %call
call:
  %fp = load ptr, ptr @lsl_p_slEvaluateFeature
  %r = call i32 %fp(i32 %a0, ptr %a1, ptr %a2, i32 %a3, ptr %a4)
  ret i32 %r
absent:
  ret i32 -1
}
@.lsl_n_slFreeResources = private unnamed_addr constant [16 x i8] c"slFreeResources\00"
@lsl_p_slFreeResources = internal global ptr null
define i32 @lsl_slFreeResources(i32 %a0, ptr %a1) {
entry:
  %have = load ptr, ptr @lsl_p_slFreeResources
  %known = icmp ne ptr %have, null
  br i1 %known, label %call, label %look
look:
  %found = call ptr @lvk_sym(ptr @.lsl_n_slFreeResources)
  store ptr %found, ptr @lsl_p_slFreeResources
  %none = icmp eq ptr %found, null
  br i1 %none, label %absent, label %call
call:
  %fp = load ptr, ptr @lsl_p_slFreeResources
  %r = call i32 %fp(i32 %a0, ptr %a1)
  ret i32 %r
absent:
  ret i32 -1
}
; a feature's own functions (slDLSSSetOptions, slReflexSleep ...) come from slGetFeatureFunction
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

; a command-buffer command with three counts, through a pointer (vkCmdDrawMeshTasksEXT: the Streamline
; interposer exports no such command, so it is looked up per device with vkGetDeviceProcAddr)
define void @lsl_call_piii(ptr %fn, ptr %a0, i32 %a1, i32 %a2, i32 %a3) {
entry:
  call void %fn(ptr %a0, i32 %a1, i32 %a2, i32 %a3)
  ret void
}

; ---- acceleration structures: commands the Streamline interposer does not export --------------------
; vkCreateAccelerationStructureKHR(device, info, allocator, out) -> VkResult
define i32 @lsl_call_pppp(ptr %fn, ptr %a0, ptr %a1, ptr %a2, ptr %a3) {
entry:
  %r = call i32 %fn(ptr %a0, ptr %a1, ptr %a2, ptr %a3)
  ret i32 %r
}
; vkDestroyAccelerationStructureKHR(device, handle, allocator)
define void @lsl_call_plp(ptr %fn, ptr %a0, i64 %a1, ptr %a2) {
entry:
  call void %fn(ptr %a0, i64 %a1, ptr %a2)
  ret void
}
; vkGetAccelerationStructureBuildSizesKHR(device, buildType, info, maxPrimitiveCounts, sizes)
define void @lsl_call_pippp(ptr %fn, ptr %a0, i32 %a1, ptr %a2, ptr %a3, ptr %a4) {
entry:
  call void %fn(ptr %a0, i32 %a1, ptr %a2, ptr %a3, ptr %a4)
  ret void
}
; vkCmdBuildAccelerationStructuresKHR(commandBuffer, infoCount, infos, buildRangeInfos)
define void @lsl_call_pipp(ptr %fn, ptr %a0, i32 %a1, ptr %a2, ptr %a3) {
entry:
  call void %fn(ptr %a0, i32 %a1, ptr %a2, ptr %a3)
  ret void
}
; vkGetAccelerationStructureDeviceAddressKHR(device, info) -> VkDeviceAddress
define i64 @lsl_call_pp_l(ptr %fn, ptr %a0, ptr %a1) {
entry:
  %r = call i64 %fn(ptr %a0, ptr %a1)
  ret i64 %r
}
