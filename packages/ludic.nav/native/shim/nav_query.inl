// nav_query.inl - what a navmesh answers: the nearest point on it, a path as corner points, and
// whether a straight line stays on it. Points go out through out[] (x, y, z each).

static dtPolyRef nav_poly_at(Nav *n, const float *p, float *on) {
  dtPolyRef r = 0;
  if (dtStatusFailed(n->query->findNearestPoly(p, n->ext, nav_filter(n, 0), &r, on))) return 0;
  return r;
}

// the nearest point on the mesh to (x, y, z) into out; 0 when none is within reach
NAV_SHIM int nav_nearest(void *h, float x, float y, float z, float *out) {
  float p[3] = {x, y, z};
  return nav_poly_at(static_cast<Nav *>(h), p, out) ? 1 : 0;
}

// filter f's cost for a kind of ground (area 1..62); a query names the filter it walks by
NAV_SHIM void nav_area_cost(void *h, int f, int area, float cost) {
  Nav *n = static_cast<Nav *>(h);
  if (f >= 0 && f < NAV_FILTERS && area > 0 && area < DT_MAX_AREAS) n->filters[f].setAreaCost(area, cost);
}

// the corners of a path from one point to another, at most max of them, into out: the count, or
// -1 when either end is off the mesh. One that cannot reach the end stops as near it as the mesh
// allows, and nav_partial says so
NAV_SHIM int nav_path(void *h, int f, float sx, float sy, float sz, float ex, float ey, float ez, float *out, int max) {
  Nav *n = static_cast<Nav *>(h);
  float s[3] = {sx, sy, sz}, e[3] = {ex, ey, ez}, so[3], eo[3];
  dtPolyRef a = nav_poly_at(n, s, so), b = nav_poly_at(n, e, eo);
  n->partial = 0;
  if (!a || !b) return -1;
  int np = 0;
  dtStatus st = n->query->findPath(a, b, so, eo, nav_filter(n, f), n->polys, &np, NAV_MAX_POLYS);
  if (dtStatusFailed(st) || np == 0) return -1;
  if (dtStatusDetail(st, DT_PARTIAL_RESULT) || n->polys[np - 1] != b) n->partial = 1;
  float end[3];
  dtVcopy(end, eo);
  if (n->polys[np - 1] != b) n->query->closestPointOnPoly(n->polys[np - 1], eo, end, nullptr);
  int count = 0;
  if (dtStatusFailed(n->query->findStraightPath(so, end, n->polys, np, out, nullptr, nullptr, &count, max, 0))) return -1;
  return count;
}
NAV_SHIM int nav_partial(void *h) { return static_cast<Nav *>(h)->partial; }

// does the straight line from one point to another stay on the mesh? 1 yes, 0 no, -1 off it
NAV_SHIM int nav_raycast(void *h, int f, float sx, float sy, float sz, float ex, float ez) {
  Nav *n = static_cast<Nav *>(h);
  float s[3] = {sx, sy, sz}, so[3], e[3] = {ex, sy, ez}, t = 0, nrm[3];
  dtPolyRef a = nav_poly_at(n, s, so);
  if (!a) return -1;
  int np = 0;
  if (dtStatusFailed(n->query->raycast(a, so, e, nav_filter(n, f), &t, nrm, n->polys, &np, NAV_MAX_POLYS))) return -1;
  return t >= 1.0f ? 1 : 0;
}

// a point about r from (x, y, z) that a walker there can reach, into out; 0 when there is none.
// Detour asks a function for its dice: this one is seeded by the caller, so the same seed from the
// package's Rng gives the same point on every machine
static unsigned int nav_rs = 1;
static float nav_frand() {
  nav_rs = nav_rs * 1664525u + 1013904223u;
  return (float)(nav_rs >> 8) * (1.0f / 16777216.0f);
}
NAV_SHIM int nav_random_near(void *h, int f, float x, float y, float z, float r, int seed, float *out) {
  Nav *n = static_cast<Nav *>(h);
  float p[3] = {x, y, z}, on[3];
  dtPolyRef start = nav_poly_at(n, p, on);
  if (!start) return 0;
  nav_rs = (unsigned int)seed * 2654435761u + 1u;
  dtPolyRef ref = 0;
  if (dtStatusFailed(n->query->findRandomPointAroundCircle(start, on, r, nav_filter(n, f), nav_frand, &ref, out))) return 0;
  return ref ? 1 : 0;
}
