// nav_build.inl - a navmesh from triangles: Recast's solo pipeline (rasterize, filter, erode,
// regions, contours, polygons, detail) and one Detour tile. c[] is the configuration:
// cell size, cell height, agent height, agent radius, max climb, max slope (degrees).

// cylinders (x, y, z, r, h each) no agent may stand in: trunks, posts, tents
static void nav_mark_cylinders(rcContext &ctx, rcCompactHeightfield &chf, const float *cyl, int nc) {
  for (int i = 0; i < nc; ++i) {
    float pos[3] = {cyl[i * 5], cyl[i * 5 + 1], cyl[i * 5 + 2]};
    rcMarkCylinderArea(&ctx, pos, cyl[i * 5 + 3], cyl[i * 5 + 4], RC_NULL_AREA, chf);
  }
}

// v: nv points (x, y, z); t: nt triangles; area: one per triangle, 0 not walkable, 1..62 a kind of
// ground (its cost is the filter's); the slope clears what is too steep whatever its area
NAV_SHIM void *nav_build(const float *v, int nv, const int *t, int nt, const unsigned char *area,
                         const float *cyl, int nc, const float *c) {
  rcContext ctx(false);
  rcConfig cfg;
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
  cfg.detailSampleDist = cfg.cs * 6.0f;
  cfg.detailSampleMaxError = cfg.ch;
  rcCalcBounds(v, nv, cfg.bmin, cfg.bmax);
  rcCalcGridSize(cfg.bmin, cfg.bmax, cfg.cs, &cfg.width, &cfg.height);

  std::vector<unsigned char> areas(area, area + nt);
  rcClearUnwalkableTriangles(&ctx, cfg.walkableSlopeAngle, v, nv, t, nt, areas.data());
  rcHeightfield *hf = rcAllocHeightfield();
  rcCompactHeightfield *chf = rcAllocCompactHeightfield();
  rcContourSet *cs = rcAllocContourSet();
  rcPolyMesh *pm = rcAllocPolyMesh();
  rcPolyMeshDetail *dm = rcAllocPolyMeshDetail();
  bool ok = hf && chf && cs && pm && dm &&
            rcCreateHeightfield(&ctx, *hf, cfg.width, cfg.height, cfg.bmin, cfg.bmax, cfg.cs, cfg.ch) &&
            rcRasterizeTriangles(&ctx, v, nv, t, areas.data(), nt, *hf, cfg.walkableClimb);
  if (ok) {
    rcFilterLowHangingWalkableObstacles(&ctx, cfg.walkableClimb, *hf);
    rcFilterLedgeSpans(&ctx, cfg.walkableHeight, cfg.walkableClimb, *hf);
    rcFilterWalkableLowHeightSpans(&ctx, cfg.walkableHeight, *hf);
    ok = rcBuildCompactHeightfield(&ctx, cfg.walkableHeight, cfg.walkableClimb, *hf, *chf);
  }
  if (ok) {
    nav_mark_cylinders(ctx, *chf, cyl, nc);
    ok = rcErodeWalkableArea(&ctx, cfg.walkableRadius, *chf) && rcBuildDistanceField(&ctx, *chf) &&
         rcBuildRegions(&ctx, *chf, 0, cfg.minRegionArea, cfg.mergeRegionArea) &&
         rcBuildContours(&ctx, *chf, cfg.maxSimplificationError, cfg.maxEdgeLen, *cs) &&
         rcBuildPolyMesh(&ctx, *cs, cfg.maxVertsPerPoly, *pm) &&
         rcBuildPolyMeshDetail(&ctx, *pm, *chf, cfg.detailSampleDist, cfg.detailSampleMaxError, *dm);
  }
  unsigned char *data = nullptr;
  int size = 0;
  if (ok) {
    for (int i = 0; i < pm->npolys; ++i) pm->flags[i] = pm->areas[i] ? 1 : 0;
    dtNavMeshCreateParams p;
    memset(&p, 0, sizeof(p));
    p.verts = pm->verts; p.vertCount = pm->nverts; p.polys = pm->polys; p.polyAreas = pm->areas;
    p.polyFlags = pm->flags; p.polyCount = pm->npolys; p.nvp = pm->nvp;
    p.detailMeshes = dm->meshes; p.detailVerts = dm->verts; p.detailVertsCount = dm->nverts;
    p.detailTris = dm->tris; p.detailTriCount = dm->ntris;
    p.walkableHeight = c[2]; p.walkableRadius = c[3]; p.walkableClimb = c[4];
    rcVcopy(p.bmin, pm->bmin); rcVcopy(p.bmax, pm->bmax);
    p.cs = cfg.cs; p.ch = cfg.ch; p.buildBvTree = true;
    ok = dtCreateNavMeshData(&p, &data, &size);
  }
  rcFreeHeightField(hf); rcFreeCompactHeightfield(chf); rcFreeContourSet(cs); rcFreePolyMesh(pm); rcFreePolyMeshDetail(dm);
  if (!ok) return nullptr;
  return nav_from(data, size);
}

// the tile's bytes, to write to a file: first the size (buf null), then the copy
NAV_SHIM int nav_save(void *h, unsigned char *buf, int cap) {
  Nav *n = static_cast<Nav *>(h);
  if (!buf) return n->size;
  if (cap < n->size) return -1;
  memcpy(buf, n->data, n->size);
  return n->size;
}

// a navmesh from bytes nav_save wrote
NAV_SHIM void *nav_load(const unsigned char *buf, int size) {
  unsigned char *data = static_cast<unsigned char *>(dtAlloc(size, DT_ALLOC_PERM));
  if (!data) return nullptr;
  memcpy(data, buf, size);
  return nav_from(data, size);
}

NAV_SHIM void nav_free(void *h) {
  Nav *n = static_cast<Nav *>(h);
  if (!n) return;
  dtFreeNavMeshQuery(n->query);
  dtFreeNavMesh(n->mesh);
  delete n;
}

NAV_SHIM int nav_polys(void *h) {
  const dtMeshTile *t = static_cast<const dtNavMesh *>(static_cast<Nav *>(h)->mesh)->getTile(0);
  return t && t->header ? t->header->polyCount : 0;
}
