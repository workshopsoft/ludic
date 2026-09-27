// nav_query.inl - what a navmesh answers: the nearest point on it, a path as corner points, and
// whether a straight line stays on it. Points go out through out[] (x, y, z each).

static dtPolyRef nav_poly_at(Nav *n, const float *p, float *on) {
  dtPolyRef r = 0;
  if (dtStatusFailed(n->query->findNearestPoly(p, n->ext, &n->filter, &r, on))) return 0;
  return r;
}

// the nearest point on the mesh to (x, y, z) into out; 0 when none is within reach
NAV_SHIM int nav_nearest(void *h, float x, float y, float z, float *out) {
  float p[3] = {x, y, z};
  return nav_poly_at(static_cast<Nav *>(h), p, out) ? 1 : 0;
}

// a cost per kind of ground (area 1..62): the filter every query uses
NAV_SHIM void nav_area_cost(void *h, int area, float cost) {
  Nav *n = static_cast<Nav *>(h);
  if (area > 0 && area < DT_MAX_AREAS) n->filter.setAreaCost(area, cost);
}

// the corners of a path from one point to another, at most max of them, into out: the count, or
// -1 when either end is off the mesh. One that cannot reach the end stops as near it as the mesh
// allows, and nav_partial says so
NAV_SHIM int nav_path(void *h, float sx, float sy, float sz, float ex, float ey, float ez, float *out, int max) {
  Nav *n = static_cast<Nav *>(h);
  float s[3] = {sx, sy, sz}, e[3] = {ex, ey, ez}, so[3], eo[3];
  dtPolyRef a = nav_poly_at(n, s, so), b = nav_poly_at(n, e, eo);
  n->partial = 0;
  if (!a || !b) return -1;
  int np = 0;
  dtStatus st = n->query->findPath(a, b, so, eo, &n->filter, n->polys, &np, NAV_MAX_POLYS);
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
NAV_SHIM int nav_raycast(void *h, float sx, float sy, float sz, float ex, float ez) {
  Nav *n = static_cast<Nav *>(h);
  float s[3] = {sx, sy, sz}, so[3], e[3] = {ex, sy, ez}, t = 0, nrm[3];
  dtPolyRef a = nav_poly_at(n, s, so);
  if (!a) return -1;
  int np = 0;
  if (dtStatusFailed(n->query->raycast(a, so, e, &n->filter, &t, nrm, n->polys, &np, NAV_MAX_POLYS))) return -1;
  return t >= 1.0f ? 1 : 0;
}
