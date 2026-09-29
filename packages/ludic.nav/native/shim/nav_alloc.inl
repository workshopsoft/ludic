// nav_alloc.inl - Recast's and Detour's allocations counted apart from the game's (plan 25), as
// ludic.physics counts Jolt's: libc's malloc underneath, each block carrying its size in a 16-byte
// header, so the tiles, queries and crowds are measured exactly. Registered when the library loads.
#include <atomic>

namespace {
constexpr size_t kNavHead = 16;
std::atomic<long long> g_nav_live{0}, g_nav_peak{0}, g_nav_allocs{0};

void *nav_heap_alloc(size_t n) {
  char *b = static_cast<char *>(std::malloc(n + kNavHead));
  if (!b) return nullptr;
  std::memcpy(b, &n, sizeof n);
  g_nav_allocs.fetch_add(1, std::memory_order_relaxed);
  long long now = g_nav_live.fetch_add((long long)n, std::memory_order_relaxed) + (long long)n;
  long long p = g_nav_peak.load(std::memory_order_relaxed);
  while (now > p && !g_nav_peak.compare_exchange_weak(p, now, std::memory_order_relaxed)) {}
  return b + kNavHead;
}
void nav_heap_free(void *p) {
  if (!p) return;
  char *b = static_cast<char *>(p) - kNavHead;
  size_t n;
  std::memcpy(&n, b, sizeof n);
  g_nav_live.fetch_sub((long long)n, std::memory_order_relaxed);
  std::free(b);
}
void *nav_dt_alloc(size_t n, dtAllocHint) { return nav_heap_alloc(n); }
void *nav_rc_alloc(size_t n, rcAllocHint) { return nav_heap_alloc(n); }

struct NavHeapRegister {
  NavHeapRegister() {
    dtAllocSetCustom(nav_dt_alloc, nav_heap_free);
    rcAllocSetCustom(nav_rc_alloc, nav_heap_free);
  }
} g_nav_heap_register;
}  // namespace

// bytes Recast and Detour hold now, the most they ever held, and how many blocks they asked for
NAV_SHIM long long nav_heap_bytes(void) { return g_nav_live.load(std::memory_order_relaxed); }
NAV_SHIM long long nav_heap_peak(void) { return g_nav_peak.load(std::memory_order_relaxed); }
NAV_SHIM long long nav_heap_allocs(void) { return g_nav_allocs.load(std::memory_order_relaxed); }
