// nav_shim.cpp - ludic.nav's door into Recast & Detour (phase 17). The shim rules of
// packages/README.md: int, float and opaque handles cross; no struct by value, no callback into
// Ludic; what a query finds is written into a buffer the package owns; errors are return codes.
#include <Recast.h>
#include <DetourNavMesh.h>
#include <DetourNavMeshBuilder.h>
#include <DetourNavMeshQuery.h>
#include <DetourCommon.h>
#include <cstring>
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

// a navmesh and the one query that walks it, with the scratch a path needs
struct Nav {
  dtNavMesh *mesh = nullptr;
  dtNavMeshQuery *query = nullptr;
  dtQueryFilter filter;
  float ext[3] = {2.0f, 4.0f, 2.0f};   // how far to look for the mesh around a point
  dtPolyRef polys[NAV_MAX_POLYS];
  unsigned char *data = nullptr;       // the tile as built or loaded (the mesh frees it)
  int size = 0;
  int partial = 0;                     // the last path stopped short of its end
};

Nav *nav_from(unsigned char *data, int size) {
  Nav *n = new Nav();
  n->mesh = dtAllocNavMesh();
  if (!n->mesh || dtStatusFailed(n->mesh->init(data, size, DT_TILE_FREE_DATA))) { dtFree(data); dtFreeNavMesh(n->mesh); delete n; return nullptr; }
  n->data = data;
  n->size = size;
  n->query = dtAllocNavMeshQuery();
  if (!n->query || dtStatusFailed(n->query->init(n->mesh, NAV_MAX_NODES))) { dtFreeNavMeshQuery(n->query); dtFreeNavMesh(n->mesh); delete n; return nullptr; }
  n->filter.setIncludeFlags(0xffff);
  n->filter.setExcludeFlags(0);
  return n;
}
}  // namespace

#include "nav_build.inl"
#include "nav_query.inl"
