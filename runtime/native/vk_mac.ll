; ============================================================================
; vk_mac.ll — the Vulkan loader, for macOS, written in LLVM IR.
;
; macOS has no Vulkan of its own: the LunarG loader and MoltenVK (Vulkan over
; Metal) come with the Vulkan SDK or with a game that bundles them. So the loader
; is looked for at run time - beside the executable, in the usual library
; directories, then MoltenVK on its own (a bundle's Contents/Frameworks), then under
; $VULKAN_SDK - and a Mac without any gets 0 from vk_open. The contract is vk_win.ll's:
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
@.lvk_fmtm = private unnamed_addr constant [25 x i8] c"%s/lib/libMoltenVK.dylib\00"
@.lvk_m0 = private unnamed_addr constant [49 x i8] c"@executable_path/../Frameworks/libMoltenVK.dylib\00"
@.lvk_mr = private unnamed_addr constant [25 x i8] c"@rpath/libMoltenVK.dylib\00"
@.lvk_m1 = private unnamed_addr constant [35 x i8] c"@executable_path/libMoltenVK.dylib\00"
@.lvk_m2 = private unnamed_addr constant [18 x i8] c"libMoltenVK.dylib\00"
@lvk_lib  = internal global ptr null

; RTLD_NOW (2) | RTLD_LOCAL (4)
define internal ptr @lvk_try(ptr %path) {
entry:
  %h = call ptr @dlopen(ptr %path, i32 6)
  ret ptr %h
}

; The candidates in order. MoltenVK itself first - it exports every vk* entry point, it is what a bundle
; ships in Contents/Frameworks and what ludic.render3d carries (lib/macos-arm64), and the program is
; linked against it, so dlopen hands back the copy already loaded. A Vulkan loader (the SDK's, found
; in /usr/local/lib) loads its OWN MoltenVK as an ICD: two in one process, each keeping its pools,
; and the program drew through the SDK's. The loader comes first only when layers are asked for
; (VK_INSTANCE_LAYERS, VK_LOADER_LAYERS_ENABLE, R3D_VK_LOADER), and is then pinned to ours (lvk_pin_icd).
@lvk_direct = internal constant [8 x ptr] [ptr @.lvk_m0, ptr @.lvk_mr, ptr @.lvk_m1, ptr @.lvk_m2, ptr @.lvk_c0, ptr @.lvk_c1, ptr @.lvk_c2, ptr @.lvk_c3]
@lvk_layered = internal constant [8 x ptr] [ptr @.lvk_c0, ptr @.lvk_c1, ptr @.lvk_c2, ptr @.lvk_c3, ptr @.lvk_m0, ptr @.lvk_mr, ptr @.lvk_m1, ptr @.lvk_m2]

declare i32 @dladdr(ptr, ptr)
declare i32 @setenv(ptr, ptr, i32)
declare i32 @unsetenv(ptr)
declare ptr @strrchr(ptr, i32)
declare i32 @access(ptr, i32)
@.lvk_e1 = private unnamed_addr constant [19 x i8] c"VK_INSTANCE_LAYERS\00"
@.lvk_e2 = private unnamed_addr constant [24 x i8] c"VK_LOADER_LAYERS_ENABLE\00"
@.lvk_e3 = private unnamed_addr constant [14 x i8] c"R3D_VK_LOADER\00"
@.lvk_df = private unnamed_addr constant [16 x i8] c"VK_DRIVER_FILES\00"
@.lvk_if = private unnamed_addr constant [17 x i8] c"VK_ICD_FILENAMES\00"
@.lvk_any = private unnamed_addr constant [18 x i8] c"R3D_VK_ANY_DRIVER\00"
@.lvk_gipa = private unnamed_addr constant [22 x i8] c"vkGetInstanceProcAddr\00"
@.lvk_icd = private unnamed_addr constant [23 x i8] c"%.*s/MoltenVK_icd.json\00"

; 1 when a layer is asked for: the loader is what stacks one
define internal i32 @lvk_want_loader() {
entry:
  %a = call ptr @getenv(ptr @.lvk_e1)
  %b = call ptr @getenv(ptr @.lvk_e2)
  %c = call ptr @getenv(ptr @.lvk_e3)
  %ha = icmp ne ptr %a, null
  %hb = icmp ne ptr %b, null
  %hc = icmp ne ptr %c, null
  %ab = or i1 %ha, %hb
  %abc = or i1 %ab, %hc
  %r = zext i1 %abc to i32
  ret i32 %r
}

; The loader told to use our MoltenVK and no other: VK_DRIVER_FILES set to the ICD json beside the
; libMoltenVK.dylib the program is linked against (found through dladdr), over whatever the shell had -
; the SDK's setup-env.sh exports both VK_DRIVER_FILES and VK_ICD_FILENAMES at its own MoltenVK, and a
; validation run must see the driver the game uses - and VK_ICD_FILENAMES cleared. R3D_VK_ANY_DRIVER=1
; leaves the shell's choice alone; nothing is set where there is no json (a bundle ships none).
define internal void @lvk_pin_icd() {
entry:
  %any = call ptr @getenv(ptr @.lvk_any)
  %keep = icmp ne ptr %any, null
  br i1 %keep, label %out, label %find
find:
  %h = call ptr @dlopen(ptr @.lvk_mr, i32 6)
  %noh = icmp eq ptr %h, null
  br i1 %noh, label %out, label %sym
sym:
  %f = call ptr @dlsym(ptr %h, ptr @.lvk_gipa)
  %nof = icmp eq ptr %f, null
  br i1 %nof, label %out, label %where
where:
  %info = alloca [4 x ptr]
  %got = call i32 @dladdr(ptr %f, ptr %info)
  %nogot = icmp eq i32 %got, 0
  br i1 %nogot, label %out, label %dir
dir:
  %fname = load ptr, ptr %info
  %slash = call ptr @strrchr(ptr %fname, i32 47)
  %noslash = icmp eq ptr %slash, null
  br i1 %noslash, label %out, label %json
json:
  %pa = ptrtoint ptr %fname to i64
  %pb = ptrtoint ptr %slash to i64
  %len64 = sub i64 %pb, %pa
  %len = trunc i64 %len64 to i32
  %buf = alloca [1024 x i8]
  %w = call i32 (ptr, i64, ptr, ...) @snprintf(ptr %buf, i64 1024, ptr @.lvk_icd, i32 %len, ptr %fname)
  %acc = call i32 @access(ptr %buf, i32 0)
  %there = icmp eq i32 %acc, 0
  br i1 %there, label %pin, label %out
pin:
  %s = call i32 @setenv(ptr @.lvk_df, ptr %buf, i32 1)
  %u = call i32 @unsetenv(ptr @.lvk_if)
  br label %out
out:
  ret void
}

define i32 @lvk_open() {
entry:
  %have = load ptr, ptr @lvk_lib
  %open = icmp ne ptr %have, null
  br i1 %open, label %ok, label %pick
pick:
  %wl = call i32 @lvk_want_loader()
  %layered = icmp ne i32 %wl, 0
  br i1 %layered, label %pinned, label %start
pinned:
  call void @lvk_pin_icd()
  br label %start
start:
  %paths = select i1 %layered, ptr @lvk_layered, ptr @lvk_direct
  br label %loop
loop:
  %i = phi i32 [ 0, %start ], [ %i1, %next ]
  %slot = getelementptr [8 x ptr], ptr %paths, i32 0, i32 %i
  %path = load ptr, ptr %slot
  %h = call ptr @lvk_try(ptr %path)
  %miss = icmp eq ptr %h, null
  br i1 %miss, label %next, label %got
next:
  %i1 = add i32 %i, 1
  %more = icmp slt i32 %i1, 8
  br i1 %more, label %loop, label %sdk
got:
  store ptr %h, ptr @lvk_lib
  br label %bind
sdk:
  %sdkp = call ptr @getenv(ptr @.lvk_env)
  %nosdk = icmp eq ptr %sdkp, null
  br i1 %nosdk, label %fail, label %s1
s1:
  %buf = alloca [1024 x i8]
  %w = call i32 (ptr, i64, ptr, ...) @snprintf(ptr %buf, i64 1024, ptr @.lvk_fmt, ptr %sdkp)
  %h4 = call ptr @lvk_try(ptr %buf)
  %n4 = icmp eq ptr %h4, null
  br i1 %n4, label %s2, label %got4
s2:
  %w2 = call i32 (ptr, i64, ptr, ...) @snprintf(ptr %buf, i64 1024, ptr @.lvk_fmtm, ptr %sdkp)
  %h5 = call ptr @lvk_try(ptr %buf)
  %n5 = icmp eq ptr %h5, null
  br i1 %n5, label %fail, label %got5
got4:
  store ptr %h4, ptr @lvk_lib
  br label %bind
got5:
  store ptr %h5, ptr @lvk_lib
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

; ---- the frame's autorelease pool --------------------------------------------------------------
; MoltenVK and CAMetalLayer autorelease objects on every frame (the drawable, each render pass's
; descriptor), and a program that pumps its own events never drains a pool: without this they are
; kept for the life of the process - 160 MB/s of small allocations in a windowed valley.
; lvk_frame_pool() pops the pool the last frame pushed and pushes the next one.
declare ptr @objc_autoreleasePoolPush()
declare void @objc_autoreleasePoolPop(ptr)
@lvk_pool = internal global ptr null

define void @lvk_frame_pool() {
entry:
  %old = load ptr, ptr @lvk_pool
  %have = icmp ne ptr %old, null
  br i1 %have, label %pop, label %push
pop:
  call void @objc_autoreleasePoolPop(ptr %old)
  br label %push
push:
  %p = call ptr @objc_autoreleasePoolPush()
  store ptr %p, ptr @lvk_pool
  ret void
}

; ---- the heap in use --------------------------------------------------------------------------
; malloc's live bytes across the default zones, for a test that proves a path allocates nothing in
; its steady state (render3d's examples/rendering/steady.ludic). malloc_statistics_t is four
; words: blocks_in_use (u32, padded), size_in_use, max_size_in_use, size_allocated.
declare void @malloc_zone_statistics(ptr, ptr)
define i64 @lvk_heap_bytes() {
entry:
  %st = alloca [4 x i64], align 8
  call void @malloc_zone_statistics(ptr null, ptr %st)
  %p = getelementptr [4 x i64], ptr %st, i32 0, i32 1
  %n = load i64, ptr %p
  ret i64 %n
}

; VkAllocationCallbacks (memory plan 25.1c): render3d hands @lvk_ac to every Vulkan create and
; destroy when R3D_ALLOC_VK=1, so MoltenVK's own host allocations are counted - live bytes, the peak,
; allocations made and bytes per VkSystemAllocationScope - for the fence to read (lvk_ac_*).
; Metal's own allocations are never seen here. libc underneath, never the fence's allocator. Each
; block carries a 16-byte header before it: scope (i32), the offset to malloc's block (i32), size
; (i64); the offset is the alignment asked, at least 16, so the block keeps it. The counters are
; atomics: MoltenVK allocates from its completion handlers' threads too.
@lvk_ac_live = global i64 0
@lvk_ac_peak_v = global i64 0
@lvk_ac_n = global i64 0
@lvk_ac_scope = global [5 x i64] zeroinitializer
@lvk_ac = global [6 x ptr] [ptr null, ptr @lvk_ac_alloc, ptr @lvk_ac_realloc, ptr @lvk_ac_free, ptr null, ptr null]
declare i32 @posix_memalign(ptr, i64, i64)
declare void @free(ptr)
declare ptr @memcpy(ptr, ptr, i64)

define internal void @lvk_ac_count(i32 %scope, i64 %d, i64 %n) {
entry:
  %old = atomicrmw add ptr @lvk_ac_live, i64 %d seq_cst
  %new = add i64 %old, %d
  %pk = atomicrmw max ptr @lvk_ac_peak_v, i64 %new seq_cst
  %nn = atomicrmw add ptr @lvk_ac_n, i64 %n seq_cst
  %lo = icmp slt i32 %scope, 0
  %hi = icmp sgt i32 %scope, 4
  %bad = or i1 %lo, %hi
  %sc = select i1 %bad, i32 1, i32 %scope
  %sp = getelementptr [5 x i64], ptr @lvk_ac_scope, i32 0, i32 %sc
  %sv = atomicrmw add ptr %sp, i64 %d seq_cst
  ret void
}
define internal ptr @lvk_ac_alloc(ptr %ud, i64 %size, i64 %align, i32 %scope) {
entry:
  %z = icmp eq i64 %size, 0
  br i1 %z, label %none, label %go
none:
  ret ptr null
go:
  %small = icmp ult i64 %align, 16
  %a = select i1 %small, i64 16, i64 %align
  %tot = add i64 %size, %a
  %slot = alloca ptr, align 8
  %r = call i32 @posix_memalign(ptr %slot, i64 %a, i64 %tot)
  %ok = icmp eq i32 %r, 0
  br i1 %ok, label %have, label %none
have:
  %base = load ptr, ptr %slot
  %p = getelementptr i8, ptr %base, i64 %a
  %h = getelementptr i8, ptr %p, i64 -16
  store i32 %scope, ptr %h
  %ha = getelementptr i8, ptr %h, i64 4
  %a32 = trunc i64 %a to i32
  store i32 %a32, ptr %ha
  %hs = getelementptr i8, ptr %h, i64 8
  store i64 %size, ptr %hs
  call void @lvk_ac_count(i32 %scope, i64 %size, i64 1)
  ret ptr %p
}
define internal void @lvk_ac_free(ptr %ud, ptr %p) {
entry:
  %z = icmp eq ptr %p, null
  br i1 %z, label %done, label %go
done:
  ret void
go:
  %h = getelementptr i8, ptr %p, i64 -16
  %scope = load i32, ptr %h
  %ha = getelementptr i8, ptr %h, i64 4
  %a32 = load i32, ptr %ha
  %hs = getelementptr i8, ptr %h, i64 8
  %size = load i64, ptr %hs
  %neg = sub i64 0, %size
  call void @lvk_ac_count(i32 %scope, i64 %neg, i64 0)
  %a = zext i32 %a32 to i64
  %na = sub i64 0, %a
  %base = getelementptr i8, ptr %p, i64 %na
  call void @free(ptr %base)
  ret void
}
; a new block at the asked alignment, the old one's bytes copied, the old one freed: realloc itself
; only keeps 16
define internal ptr @lvk_ac_realloc(ptr %ud, ptr %old, i64 %size, i64 %align, i32 %scope) {
entry:
  %nold = icmp eq ptr %old, null
  br i1 %nold, label %fresh, label %chk
fresh:
  %f = call ptr @lvk_ac_alloc(ptr %ud, i64 %size, i64 %align, i32 %scope)
  ret ptr %f
chk:
  %z = icmp eq i64 %size, 0
  br i1 %z, label %drop, label %move
drop:
  call void @lvk_ac_free(ptr %ud, ptr %old)
  ret ptr null
move:
  %nb = call ptr @lvk_ac_alloc(ptr %ud, i64 %size, i64 %align, i32 %scope)
  %nz = icmp eq ptr %nb, null
  br i1 %nz, label %fail, label %copy
fail:
  ret ptr null
copy:
  %hs = getelementptr i8, ptr %old, i64 -8
  %osz = load i64, ptr %hs
  %less = icmp ult i64 %osz, %size
  %n = select i1 %less, i64 %osz, i64 %size
  %cp = call ptr @memcpy(ptr %nb, ptr %old, i64 %n)
  call void @lvk_ac_free(ptr %ud, ptr %old)
  ret ptr %nb
}
define ptr @lvk_ac_ptr() {
entry:
  ret ptr @lvk_ac
}
define i64 @lvk_ac_bytes() {
entry:
  %v = load atomic i64, ptr @lvk_ac_live seq_cst, align 8
  ret i64 %v
}
define i64 @lvk_ac_peak() {
entry:
  %v = load atomic i64, ptr @lvk_ac_peak_v seq_cst, align 8
  ret i64 %v
}
define i64 @lvk_ac_allocs() {
entry:
  %v = load atomic i64, ptr @lvk_ac_n seq_cst, align 8
  ret i64 %v
}
define i64 @lvk_ac_scope_bytes(i32 %scope) {
entry:
  %lo = icmp slt i32 %scope, 0
  %hi = icmp sgt i32 %scope, 4
  %bad = or i1 %lo, %hi
  br i1 %bad, label %none, label %read
none:
  ret i64 0
read:
  %sp = getelementptr [5 x i64], ptr @lvk_ac_scope, i32 0, i32 %scope
  %v = load atomic i64, ptr %sp seq_cst, align 8
  ret i64 %v
}

; ---- MetalFX temporal upscaling (render3d's mfx.ludic) ---------------------------------------
; The renderer is Vulkan over MoltenVK; VK_EXT_metal_objects hands back the MTLDevice, the
; MTLCommandQueue and each image's MTLTexture, and these few calls drive MTLFXTemporalScaler
; (macOS 13) through the Objective-C runtime's C ABI, as cocoa.ll drives AppKit. MetalFX is opened
; at run time (dlopen), so a Mac without it starts and draws as before: lmfx_open answers 0.
; Floats arrive as float bits in an i32, as every Ludic extern passes them.
declare ptr @objc_getClass(ptr)
declare ptr @sel_registerName(ptr)
declare ptr @objc_msgSend(ptr, ptr, ...)

@.mfx_lib = private unnamed_addr constant [53 x i8] c"/System/Library/Frameworks/MetalFX.framework/MetalFX\00"
@.mfx_cls = private unnamed_addr constant [30 x i8] c"MTLFXTemporalScalerDescriptor\00"
@.mfx_s_alloc = private unnamed_addr constant [6 x i8] c"alloc\00"
@.mfx_s_init = private unnamed_addr constant [5 x i8] c"init\00"
@.mfx_s_release = private unnamed_addr constant [8 x i8] c"release\00"
@.mfx_s_supports = private unnamed_addr constant [16 x i8] c"supportsDevice:\00"
@.mfx_s_maxscale = private unnamed_addr constant [40 x i8] c"supportedInputContentMaxScaleForDevice:\00"
@.mfx_s_cfmt = private unnamed_addr constant [23 x i8] c"setColorTextureFormat:\00"
@.mfx_s_dfmt = private unnamed_addr constant [23 x i8] c"setDepthTextureFormat:\00"
@.mfx_s_mfmt = private unnamed_addr constant [24 x i8] c"setMotionTextureFormat:\00"
@.mfx_s_ofmt = private unnamed_addr constant [24 x i8] c"setOutputTextureFormat:\00"
@.mfx_s_iw = private unnamed_addr constant [15 x i8] c"setInputWidth:\00"
@.mfx_s_ih = private unnamed_addr constant [16 x i8] c"setInputHeight:\00"
@.mfx_s_ow = private unnamed_addr constant [16 x i8] c"setOutputWidth:\00"
@.mfx_s_oh = private unnamed_addr constant [17 x i8] c"setOutputHeight:\00"
@.mfx_s_autoexp = private unnamed_addr constant [24 x i8] c"setAutoExposureEnabled:\00"
@.mfx_s_new = private unnamed_addr constant [29 x i8] c"newTemporalScalerWithDevice:\00"
@.mfx_s_color = private unnamed_addr constant [17 x i8] c"setColorTexture:\00"
@.mfx_s_depth = private unnamed_addr constant [17 x i8] c"setDepthTexture:\00"
@.mfx_s_motion = private unnamed_addr constant [18 x i8] c"setMotionTexture:\00"
@.mfx_s_output = private unnamed_addr constant [18 x i8] c"setOutputTexture:\00"
@.mfx_s_jx = private unnamed_addr constant [18 x i8] c"setJitterOffsetX:\00"
@.mfx_s_jy = private unnamed_addr constant [18 x i8] c"setJitterOffsetY:\00"
@.mfx_s_mx = private unnamed_addr constant [23 x i8] c"setMotionVectorScaleX:\00"
@.mfx_s_my = private unnamed_addr constant [23 x i8] c"setMotionVectorScaleY:\00"
@.mfx_s_reset = private unnamed_addr constant [10 x i8] c"setReset:\00"
@.mfx_s_rev = private unnamed_addr constant [18 x i8] c"setDepthReversed:\00"
@.mfx_s_preexp = private unnamed_addr constant [16 x i8] c"setPreExposure:\00"
@.mfx_s_cb = private unnamed_addr constant [14 x i8] c"commandBuffer\00"
@.mfx_s_encode = private unnamed_addr constant [23 x i8] c"encodeToCommandBuffer:\00"
@.mfx_s_commit = private unnamed_addr constant [7 x i8] c"commit\00"
@.mfx_s_cusage = private unnamed_addr constant [18 x i8] c"colorTextureUsage\00"
@.mfx_s_dusage = private unnamed_addr constant [18 x i8] c"depthTextureUsage\00"
@.mfx_s_musage = private unnamed_addr constant [19 x i8] c"motionTextureUsage\00"
@.mfx_s_ousage = private unnamed_addr constant [19 x i8] c"outputTextureUsage\00"
@.mfx_s_usage = private unnamed_addr constant [6 x i8] c"usage\00"
@.mfx_s_smode = private unnamed_addr constant [12 x i8] c"storageMode\00"
@.mfx_s_retain = private unnamed_addr constant [7 x i8] c"retain\00"
@.mfx_s_status = private unnamed_addr constant [7 x i8] c"status\00"
@.mfx_s_gstart = private unnamed_addr constant [13 x i8] c"GPUStartTime\00"
@.mfx_s_gend = private unnamed_addr constant [11 x i8] c"GPUEndTime\00"
@lmfx_class = internal global ptr null
; the scaler's last committed command buffer (autoreleased, this frame only) and the ones kept for their GPU time
@lmfx_last = internal global ptr null
@lmfx_slots = internal global [8 x ptr] zeroinitializer

; 1 when MetalFX's temporal scaler is there to use
define i32 @lmfx_open() {
entry:
  %have = load ptr, ptr @lmfx_class
  %ok0 = icmp ne ptr %have, null
  br i1 %ok0, label %yes, label %load
load:
  %h = call ptr @dlopen(ptr @.mfx_lib, i32 6)
  %hok = icmp ne ptr %h, null
  br i1 %hok, label %find, label %no
find:
  %c = call ptr @objc_getClass(ptr @.mfx_cls)
  store ptr %c, ptr @lmfx_class
  %cok = icmp ne ptr %c, null
  br i1 %cok, label %yes, label %no
yes:
  ret i32 1
no:
  ret i32 0
}

define i32 @lmfx_supports(ptr %dev) {
entry:
  %c = load ptr, ptr @lmfx_class
  %s = call ptr @sel_registerName(ptr @.mfx_s_supports)
  %r = call i8 (ptr, ptr, ptr) @objc_msgSend(ptr %c, ptr %s, ptr %dev)
  %r32 = zext i8 %r to i32
  ret i32 %r32
}

; the largest output / input scale the device takes, float bits (macOS 14)
define i32 @lmfx_max_scale(ptr %dev) {
entry:
  %c = load ptr, ptr @lmfx_class
  %s = call ptr @sel_registerName(ptr @.mfx_s_maxscale)
  %r = call float (ptr, ptr, ptr) @objc_msgSend(ptr %c, ptr %s, ptr %dev)
  %b = bitcast float %r to i32
  ret i32 %b
}

define internal void @lmfx_set_u(ptr %o, ptr %name, i32 %v) {
entry:
  %s = call ptr @sel_registerName(ptr %name)
  %v64 = zext i32 %v to i64
  call void (ptr, ptr, i64) @objc_msgSend(ptr %o, ptr %s, i64 %v64)
  ret void
}
define internal void @lmfx_set_f(ptr %o, ptr %name, i32 %bits) {
entry:
  %s = call ptr @sel_registerName(ptr %name)
  %f = bitcast i32 %bits to float
  call void (ptr, ptr, float) @objc_msgSend(ptr %o, ptr %s, float %f)
  ret void
}
define internal void @lmfx_set_b(ptr %o, ptr %name, i32 %v) {
entry:
  %s = call ptr @sel_registerName(ptr %name)
  %b = trunc i32 %v to i8
  call void (ptr, ptr, i8) @objc_msgSend(ptr %o, ptr %s, i8 %b)
  ret void
}
define internal void @lmfx_set_p(ptr %o, ptr %name, ptr %v) {
entry:
  %s = call ptr @sel_registerName(ptr %name)
  call void (ptr, ptr, ptr) @objc_msgSend(ptr %o, ptr %s, ptr %v)
  ret void
}

; a scaler from input w x h to output w x h with these MTLPixelFormats, or null
define ptr @lmfx_new(ptr %dev, i32 %iw, i32 %ih, i32 %ow, i32 %oh, i32 %cfmt, i32 %dfmt, i32 %mfmt, i32 %ofmt, i32 %autoexp) {
entry:
  %c = load ptr, ptr @lmfx_class
  %sa = call ptr @sel_registerName(ptr @.mfx_s_alloc)
  %a = call ptr (ptr, ptr) @objc_msgSend(ptr %c, ptr %sa)
  %si = call ptr @sel_registerName(ptr @.mfx_s_init)
  %d = call ptr (ptr, ptr) @objc_msgSend(ptr %a, ptr %si)
  call void @lmfx_set_u(ptr %d, ptr @.mfx_s_cfmt, i32 %cfmt)
  call void @lmfx_set_u(ptr %d, ptr @.mfx_s_dfmt, i32 %dfmt)
  call void @lmfx_set_u(ptr %d, ptr @.mfx_s_mfmt, i32 %mfmt)
  call void @lmfx_set_u(ptr %d, ptr @.mfx_s_ofmt, i32 %ofmt)
  call void @lmfx_set_u(ptr %d, ptr @.mfx_s_iw, i32 %iw)
  call void @lmfx_set_u(ptr %d, ptr @.mfx_s_ih, i32 %ih)
  call void @lmfx_set_u(ptr %d, ptr @.mfx_s_ow, i32 %ow)
  call void @lmfx_set_u(ptr %d, ptr @.mfx_s_oh, i32 %oh)
  call void @lmfx_set_b(ptr %d, ptr @.mfx_s_autoexp, i32 %autoexp)
  %sn = call ptr @sel_registerName(ptr @.mfx_s_new)
  %sc = call ptr (ptr, ptr, ptr) @objc_msgSend(ptr %d, ptr %sn, ptr %dev)
  call void @lmfx_release(ptr %d)
  ret ptr %sc
}

define void @lmfx_release(ptr %o) {
entry:
  %ok = icmp ne ptr %o, null
  br i1 %ok, label %rel, label %done
rel:
  %s = call ptr @sel_registerName(ptr @.mfx_s_release)
  call void (ptr, ptr) @objc_msgSend(ptr %o, ptr %s)
  br label %done
done:
  ret void
}

; what the scaler wants of its textures (0 colour, 1 depth, 2 motion, 3 output), MTLTextureUsage
define i32 @lmfx_usage(ptr %sc, i32 %which) {
entry:
  switch i32 %which, label %out [ i32 0, label %col
                                  i32 1, label %dep
                                  i32 2, label %mot ]
col:
  br label %ask
dep:
  br label %ask
mot:
  br label %ask
out:
  br label %ask
ask:
  %name = phi ptr [ @.mfx_s_cusage, %col ], [ @.mfx_s_dusage, %dep ], [ @.mfx_s_musage, %mot ], [ @.mfx_s_ousage, %out ]
  %s = call ptr @sel_registerName(ptr %name)
  %u = call i64 (ptr, ptr) @objc_msgSend(ptr %sc, ptr %s)
  %u32 = trunc i64 %u to i32
  ret i32 %u32
}
; a texture's MTLTextureUsage (which = 0) or MTLStorageMode (1)
define i32 @lmfx_tex_info(ptr %t, i32 %which) {
entry:
  %is_mode = icmp eq i32 %which, 1
  %name = select i1 %is_mode, ptr @.mfx_s_smode, ptr @.mfx_s_usage
  %s = call ptr @sel_registerName(ptr %name)
  %u = call i64 (ptr, ptr) @objc_msgSend(ptr %t, ptr %s)
  %u32 = trunc i64 %u to i32
  ret i32 %u32
}

; one frame: the textures, jitter (pixels), motion scale and reset, encoded into a command buffer of
; the renderer's own queue and committed - after the Vulkan work before it, before the work after it
define i32 @lmfx_encode(ptr %sc, ptr %queue, ptr %color, ptr %depth, ptr %motion, ptr %output, i32 %jx, i32 %jy, i32 %mx, i32 %my, i32 %reset, i32 %reversed) {
entry:
  call void @lmfx_set_p(ptr %sc, ptr @.mfx_s_color, ptr %color)
  call void @lmfx_set_p(ptr %sc, ptr @.mfx_s_depth, ptr %depth)
  call void @lmfx_set_p(ptr %sc, ptr @.mfx_s_motion, ptr %motion)
  call void @lmfx_set_p(ptr %sc, ptr @.mfx_s_output, ptr %output)
  call void @lmfx_set_f(ptr %sc, ptr @.mfx_s_jx, i32 %jx)
  call void @lmfx_set_f(ptr %sc, ptr @.mfx_s_jy, i32 %jy)
  call void @lmfx_set_f(ptr %sc, ptr @.mfx_s_mx, i32 %mx)
  call void @lmfx_set_f(ptr %sc, ptr @.mfx_s_my, i32 %my)
  call void @lmfx_set_b(ptr %sc, ptr @.mfx_s_reset, i32 %reset)
  call void @lmfx_set_b(ptr %sc, ptr @.mfx_s_rev, i32 %reversed)
  %scb = call ptr @sel_registerName(ptr @.mfx_s_cb)
  %cb = call ptr (ptr, ptr) @objc_msgSend(ptr %queue, ptr %scb)
  %ok = icmp ne ptr %cb, null
  br i1 %ok, label %go, label %fail
go:
  %se = call ptr @sel_registerName(ptr @.mfx_s_encode)
  call void (ptr, ptr, ptr) @objc_msgSend(ptr %sc, ptr %se, ptr %cb)
  %sm = call ptr @sel_registerName(ptr @.mfx_s_commit)
  call void (ptr, ptr) @objc_msgSend(ptr %cb, ptr %sm)
  store ptr %cb, ptr @lmfx_last
  ret i32 1
fail:
  ret i32 0
}

; The scaler's own GPU time. Its command buffer runs on MoltenVK's queue between two Vulkan submits, so a Vulkan timestamp pair
; around it also counts the queue's wait for the second submit; Metal's own clock does not: MTLCommandBuffer GPUStartTime /
; GPUEndTime (Apple, "MTLCommandBuffer.GPUStartTime": the host time in seconds the GPU started and finished the buffer, valid
; once it has completed). lmfx_hold keeps the buffer just committed in slot i (retained; what the slot held is let go);
; lmfx_slot_ns reads it once it is MTLCommandBufferStatusCompleted (4): its nanoseconds, the buffer let go; -1 while it runs;
; -2 for an empty slot or one that failed (MTLCommandBufferStatusError, 5).
define void @lmfx_hold(i32 %i) {
entry:
  %ok = icmp ult i32 %i, 8
  br i1 %ok, label %go, label %done
go:
  %p = getelementptr [8 x ptr], ptr @lmfx_slots, i32 0, i32 %i
  %old = load ptr, ptr %p
  call void @lmfx_release(ptr %old)
  %cb = load ptr, ptr @lmfx_last
  store ptr null, ptr @lmfx_last
  store ptr null, ptr %p
  %has = icmp ne ptr %cb, null
  br i1 %has, label %keep, label %done
keep:
  %sr = call ptr @sel_registerName(ptr @.mfx_s_retain)
  %r = call ptr (ptr, ptr) @objc_msgSend(ptr %cb, ptr %sr)
  store ptr %cb, ptr %p
  br label %done
done:
  ret void
}
define i64 @lmfx_slot_ns(i32 %i) {
entry:
  %ok = icmp ult i32 %i, 8
  br i1 %ok, label %look, label %empty
look:
  %p = getelementptr [8 x ptr], ptr @lmfx_slots, i32 0, i32 %i
  %cb = load ptr, ptr %p
  %has = icmp ne ptr %cb, null
  br i1 %has, label %stat, label %empty
stat:
  %ss = call ptr @sel_registerName(ptr @.mfx_s_status)
  %st = call i64 (ptr, ptr) @objc_msgSend(ptr %cb, ptr %ss)
  %fin = icmp eq i64 %st, 4
  br i1 %fin, label %time, label %notyet
notyet:
  %bad = icmp sgt i64 %st, 4
  br i1 %bad, label %drop, label %wait
wait:
  ret i64 -1
drop:
  call void @lmfx_release(ptr %cb)
  store ptr null, ptr %p
  ret i64 -2
time:
  %s0 = call ptr @sel_registerName(ptr @.mfx_s_gstart)
  %t0 = call double (ptr, ptr) @objc_msgSend(ptr %cb, ptr %s0)
  %s1 = call ptr @sel_registerName(ptr @.mfx_s_gend)
  %t1 = call double (ptr, ptr) @objc_msgSend(ptr %cb, ptr %s1)
  call void @lmfx_release(ptr %cb)
  store ptr null, ptr %p
  %d = fsub double %t1, %t0
  %ns = fmul double %d, 1.000000e+09
  %n = fptosi double %ns to i64
  ret i64 %n
empty:
  ret i64 -2
}
