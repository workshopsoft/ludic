// nav_shim.cpp - ludic.nav's door into Recast & Detour (phase 17). The shim rules of
// packages/README.md: int, float and opaque handles cross; no struct by value, no callback into
// Ludic; what a query finds is written into a buffer the package owns; errors are return codes.
#include <Recast.h>
#include <DetourNavMesh.h>
#include <DetourNavMeshBuilder.h>
#include <DetourNavMeshQuery.h>
#include <DetourCommon.h>
#include <cstring>
#include <cstdlib>
#include <cmath>
#include <vector>

#if defined(_WIN32)
#define NAV_SHIM extern "C" __declspec(dllexport)
#else
#define NAV_SHIM extern "C" __attribute__((visibility("default")))
#endif

namespace {
const int NAV_MAX_POLYS = 512;     // polygons a path may cross; a longer one is cut there
const int NAV_MAX_NODES = 4096;    // the search's open list
const int NAV_FILTERS = 8;         // costs per kind of ground: one set per kind of walker's taste

// a navmesh and the one query that walks it, with the scratch a path needs
struct Nav {
  dtNavMesh *mesh = nullptr;
  dtNavMeshQuery *query = nullptr;
  dtQueryFilter filters[NAV_FILTERS];
  float ext[3] = {2.0f, 4.0f, 2.0f};   // how far to look for the mesh around a point
  dtPolyRef polys[NAV_MAX_POLYS];
  int partial = 0;                     // the last path stopped short of its end
};

// a navmesh with its query, from params (a set of tiles) or from one tile's data
Nav *nav_open(dtNavMesh *mesh) {
  Nav *n = new Nav();
  n->mesh = mesh;
  n->query = dtAllocNavMeshQuery();
  if (!n->query || dtStatusFailed(n->query->init(n->mesh, NAV_MAX_NODES))) { dtFreeNavMeshQuery(n->query); dtFreeNavMesh(n->mesh); delete n; return nullptr; }
  for (int f = 0; f < NAV_FILTERS; ++f) {
    n->filters[f].setIncludeFlags(0xffff);
    n->filters[f].setExcludeFlags(0);
  }
  return n;
}
Nav *nav_from(unsigned char *data, int size) {
  dtNavMesh *mesh = dtAllocNavMesh();
  if (!mesh || dtStatusFailed(mesh->init(data, size, DT_TILE_FREE_DATA))) { dtFree(data); dtFreeNavMesh(mesh); return nullptr; }
  return nav_open(mesh);
}
// filter f, the first when f is out of range
const dtQueryFilter *nav_filter(Nav *n, int f) { return &n->filters[f >= 0 && f < NAV_FILTERS ? f : 0]; }
}  // namespace

#include "nav_build.inl"
#include "nav_tiles.inl"
#include "nav_query.inl"
