// jph_alloc.inl - Jolt's allocations counted apart from the game's (plan 25): libc's malloc underneath,
// each block carrying its size in a 16-byte header, so live bytes, the peak and the count are exact.
// The fence reads them (extern_weak) to judge Jolt by its plateau, not per frame.
#include <atomic>
#include <cstdlib>
#include <cstring>

namespace {
constexpr size_t kHead = 16;
std::atomic<int64_t> g_live{0}, g_peak{0}, g_allocs{0};

void heap_add(int64_t n) {
  int64_t now = g_live.fetch_add(n, std::memory_order_relaxed) + n;
  int64_t p = g_peak.load(std::memory_order_relaxed);
  while (now > p && !g_peak.compare_exchange_weak(p, now, std::memory_order_relaxed)) {}
}
void *heap_alloc(size_t n) {
  char *b = static_cast<char *>(std::malloc(n + kHead));
  if (!b) return nullptr;
  std::memcpy(b, &n, sizeof n);
  g_allocs.fetch_add(1, std::memory_order_relaxed);
  heap_add(int64_t(n));
  return b + kHead;
}
void heap_free(void *p) {
  if (!p) return;
  char *b = static_cast<char *>(p) - kHead;
  size_t n;
  std::memcpy(&n, b, sizeof n);
  heap_add(-int64_t(n));
  std::free(b);
}
void *heap_realloc(void *p, size_t, size_t n) {
  if (!p) return heap_alloc(n);
  char *b = static_cast<char *>(p) - kHead;
  size_t old;
  std::memcpy(&old, b, sizeof old);
  char *q = static_cast<char *>(std::realloc(b, n + kHead));
  if (!q) return nullptr;
  std::memcpy(q, &n, sizeof n);
  heap_add(int64_t(n) - int64_t(old));
  return q + kHead;
}
// aligned: over-asked, the counted block's pointer kept in the word before the aligned one
void *heap_aligned(size_t n, size_t align) {
  if (align < sizeof(void *)) align = sizeof(void *);
  char *raw = static_cast<char *>(heap_alloc(n + align + sizeof(void *)));
  if (!raw) return nullptr;
  uintptr_t at = (reinterpret_cast<uintptr_t>(raw) + sizeof(void *) + align - 1) & ~(uintptr_t(align) - 1);
  reinterpret_cast<void **>(at)[-1] = raw;
  return reinterpret_cast<void *>(at);
}
void heap_aligned_free(void *p) {
  if (p) heap_free(static_cast<void **>(p)[-1]);
}
void heap_register() {
  JPH::Allocate = heap_alloc;
  JPH::Reallocate = heap_realloc;
  JPH::Free = heap_free;
  JPH::AlignedAllocate = heap_aligned;
  JPH::AlignedFree = heap_aligned_free;
}
} // namespace

// bytes Jolt holds now, the most it ever held, and how many blocks it has asked for
JPH_SHIM int64_t jph_heap_bytes(void) { return g_live.load(std::memory_order_relaxed); }
JPH_SHIM int64_t jph_heap_peak(void) { return g_peak.load(std::memory_order_relaxed); }
JPH_SHIM int64_t jph_heap_allocs(void) { return g_allocs.load(std::memory_order_relaxed); }
