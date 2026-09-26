/* nativeecho - the shape every shim in packages/ has (packages/README.md, "Native libraries"):
   int, long, float and opaque handles cross; no struct by value, no callback into Ludic. What a
   library would report through a callback is recorded here and drained after the call returns. */
#include <stdint.h>

#if defined(_WIN32)
#define NE_API __declspec(dllexport)
#else
#define NE_API __attribute__((visibility("default")))
#endif

#define NE_CAP 64

static int ne_kinds[NE_CAP];
static float ne_values[NE_CAP];
static int ne_count = 0;
static int ne_lost = 0;

/* the sum of n floats the package owns */
NE_API float ne_sum(const float *xs, int n) {
  float s = 0.0f;
  for (int i = 0; i < n; i++) s += xs[i];
  return s;
}

/* what a callback would have reported: kept until drained, counted as lost past the cap */
NE_API int ne_record(int kind, float value) {
  if (ne_count >= NE_CAP) { ne_lost++; return -1; }
  ne_kinds[ne_count] = kind;
  ne_values[ne_count] = value;
  ne_count++;
  return 0;
}

/* a library's work that "calls back" once per element over a threshold */
NE_API int ne_scan(const float *xs, int n, float over) {
  int hits = 0;
  for (int i = 0; i < n; i++) {
    if (xs[i] > over) { ne_record(i, xs[i]); hits++; }
  }
  return hits;
}

/* copy up to cap pending records into two slices the package owns; returns how many */
NE_API int ne_drain(int *kinds, float *values, int cap) {
  int n = ne_count < cap ? ne_count : cap;
  for (int i = 0; i < n; i++) { kinds[i] = ne_kinds[i]; values[i] = ne_values[i]; }
  for (int i = n; i < ne_count; i++) {
    ne_kinds[i - n] = ne_kinds[i];
    ne_values[i - n] = ne_values[i];
  }
  ne_count -= n;
  return n;
}

NE_API int ne_lost_count(void) { return ne_lost; }

/* a 64-bit value round trip: handles and counts wider than 32 bits cross as long */
NE_API int64_t ne_twice(int64_t x) { return x * 2; }
