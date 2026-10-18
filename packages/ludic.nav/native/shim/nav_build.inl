// nav_build.inl - Recast's pipeline, shared by a whole mesh and a tile: rasterize the triangles,
// filter, mark what nothing stands in, erode, regions, contours, polygons, detail, Detour's data.
// c[] is the configuration: cell size, cell height, agent height, radius, max climb, max slope, and
// the detail mesh's sample spacing (at least 0.9 m, Recast's own limit; 0 grew without bound)

// cylinders (x, y, z, r, h each) no agent may stand in: trunks, posts, tents
static void nav_mark_cylinders(rcContext &ctx, rcCompactHeightfield &chf, const float *cyl, int nc) {
  for (int i = 0; i < nc; ++i) {
    float pos[3] = {cyl[i * 5], cyl[i * 5 + 1], cyl[i * 5 + 2]};
    rcMarkCylinderArea(&ctx, pos, cyl[i * 5 + 3], cyl[i * 5 + 4], RC_NULL_AREA, chf);
  }
}

// convex footprints no agent may stand in (a boulder): each is n, n points (x, z), ymin, ymax
static void nav_mark_footprints(rcContext &ctx, rcCompactHeightfield &chf, const float *f, int nf) {
  float pts[3 * 64];
  int i = 0;
  while (i < nf) {
    int n = (int)f[i];
    if (n < 3 || n > 64 || i + 1 + n * 2 + 2 > nf) return;
    float y0 = f[i + 1 + n * 2], y1 = f[i + 2 + n * 2];
    for (int k = 0; k < n; ++k) { pts[k * 3] = f[i + 1 + k * 2]; pts[k * 3 + 1] = y0; pts[k * 3 + 2] = f[i + 2 + k * 2]; }
    rcMarkConvexPolyArea(&ctx, pts, n, y0, y1, RC_NULL_AREA, chf);
    i += 3 + n * 2;
  }
}

static void nav_config(rcConfig &cfg, const float *c) {
  memset(&cfg, 0, sizeof(cfg));
  cfg.cs = c[0];
  cfg.ch = c[1];
  cfg.walkableSlopeAngle = c[5];
  cfg.walkableHeight = (int)ceilf(c[2] / cfg.ch);
  cfg.walkableClimb = (int)floorf(c[4] / cfg.ch);
  cfg.walkableRadius = (int)ceilf(c[3] / cfg.cs);
  cfg.maxEdgeLen = (int)(12.0f / cfg.cs);
  cfg.maxSimplificationError = 1.3f;
  cfg.minRegionArea = 8 * 8;
  cfg.mergeRegionArea = 20 * 20;
  cfg.maxVertsPerPoly = 6;
  cfg.detailSampleDist = c[6] > 0.9f ? c[6] : 0.9f;
  cfg.detailSampleMaxError = cfg.ch;
}

struct NavIn {
  const float *v; int nv; const int *t; int nt; const unsigned char *area;
  const float *cyl; int nc; const float *foot; int nf; const float *c;
};

// the pipeline over cfg's box; the tile's Detour data into data / size. 0 polygons is not an error
static bool nav_pipeline(rcConfig &cfg, const NavIn &in, int tx, int tz, unsigned char **data, int *size, int *polys) {
  rcContext ctx(false);
  std::vector<unsigned char> areas(in.area, in.area + in.nt);
  rcClearUnwalkableTriangles(&ctx, cfg.walkableSlopeAngle, in.v, in.nv, in.t, in.nt, areas.data());
  rcHeightfield *hf = rcAllocHeightfield();
  rcCompactHeightfield *chf = rcAllocCompactHeightfield();
  rcContourSet *cs = rcAllocContourSet();
  rcPolyMesh *pm = rcAllocPolyMesh();
  rcPolyMeshDetail *dm = rcAllocPolyMeshDetail();
  bool ok = hf && chf && cs && pm && dm &&
            rcCreateHeightfield(&ctx, *hf, cfg.width, cfg.height, cfg.bmin, cfg.bmax, cfg.cs, cfg.ch) &&
            rcRasterizeTriangles(&ctx, in.v, in.nv, in.t, areas.data(), in.nt, *hf, cfg.walkableClimb);
  if (ok) {
    rcFilterLowHangingWalkableObstacles(&ctx, cfg.walkableClimb, *hf);
    rcFilterLedgeSpans(&ctx, cfg.walkableHeight, cfg.walkableClimb, *hf);
    rcFilterWalkableLowHeightSpans(&ctx, cfg.walkableHeight, *hf);
    ok = rcBuildCompactHeightfield(&ctx, cfg.walkableHeight, cfg.walkableClimb, *hf, *chf);
  }
  if (ok) {
    nav_mark_cylinders(ctx, *chf, in.cyl, in.nc);
    nav_mark_footprints(ctx, *chf, in.foot, in.nf);
    // monotone partitioning: no distance field (watershed's cost), the fastest; paths are string-pulled, so long thin polygons do not show
    ok = rcErodeWalkableArea(&ctx, cfg.walkableRadius, *chf) &&
         rcBuildRegionsMonotone(&ctx, *chf, cfg.borderSize, cfg.minRegionArea, cfg.mergeRegionArea) &&
         rcBuildContours(&ctx, *chf, cfg.maxSimplificationError, cfg.maxEdgeLen, *cs) &&
         rcBuildPolyMesh(&ctx, *cs, cfg.maxVertsPerPoly, *pm) &&
         rcBuildPolyMeshDetail(&ctx, *pm, *chf, cfg.detailSampleDist, cfg.detailSampleMaxError, *dm);
  }
  *polys = ok ? pm->npolys : 0;
  if (ok && pm->npolys > 0) {
    for (int i = 0; i < pm->npolys; ++i) pm->flags[i] = pm->areas[i] ? 1 : 0;
    dtNavMeshCreateParams p;
    memset(&p, 0, sizeof(p));
    p.verts = pm->verts; p.vertCount = pm->nverts; p.polys = pm->polys; p.polyAreas = pm->areas;
    p.polyFlags = pm->flags; p.polyCount = pm->npolys; p.nvp = pm->nvp;
    p.detailMeshes = dm->meshes; p.detailVerts = dm->verts; p.detailVertsCount = dm->nverts;
    p.detailTris = dm->tris; p.detailTriCount = dm->ntris;
    p.walkableHeight = in.c[2]; p.walkableRadius = in.c[3]; p.walkableClimb = in.c[4];
    p.tileX = tx; p.tileY = tz;
    rcVcopy(p.bmin, pm->bmin); rcVcopy(p.bmax, pm->bmax);
    p.cs = cfg.cs; p.ch = cfg.ch; p.buildBvTree = true;
    ok = dtCreateNavMeshData(&p, data, size);
  }
  rcFreeHeightField(hf); rcFreeCompactHeightfield(chf); rcFreeContourSet(cs); rcFreePolyMesh(pm); rcFreePolyMeshDetail(dm);
  return ok;
}

// one mesh over all the triangles given: v nv points (x, y, z); t nt triangles; area a byte each,
// 0 not walkable and 1..62 a kind of ground; the slope clears what is too steep whatever its area
NAV_SHIM void *nav_build(const float *v, int nv, const int *t, int nt, const unsigned char *area,
                         const float *cyl, int nc, const float *foot, int nf, const float *c) {
  rcConfig cfg;
  nav_config(cfg, c);
  rcCalcBounds(v, nv, cfg.bmin, cfg.bmax);
  rcCalcGridSize(cfg.bmin, cfg.bmax, cfg.cs, &cfg.width, &cfg.height);
  NavIn in = {v, nv, t, nt, area, cyl, nc, foot, nf, c};
  unsigned char *data = nullptr;
  int size = 0, polys = 0;
  if (!nav_pipeline(cfg, in, 0, 0, &data, &size, &polys) || polys == 0) return nullptr;
  return nav_from(data, size);
}

NAV_SHIM void nav_free(void *h) {
  Nav *n = static_cast<Nav *>(h);
  if (!n) return;
  dtFreeNavMeshQuery(n->query);
  dtFreeNavMesh(n->mesh);
  delete n;
}

// every polygon in every tile
NAV_SHIM int nav_polys(void *h) {
  const dtNavMesh *m = static_cast<Nav *>(h)->mesh;
  int total = 0;
  for (int i = 0; i < m->getMaxTiles(); ++i) {
    const dtMeshTile *t = m->getTile(i);
    if (t && t->header) total += t->header->polyCount;
  }
  return total;
}
