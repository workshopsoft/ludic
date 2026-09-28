// nav_tiles.inl - a map as square tiles: a tiled mesh, one tile built from the triangles under it
// and a border round it, and every tile written and read back as one set of bytes

// an empty mesh of tiles `tile` metres across, the first at (ox, oz)
NAV_SHIM void *nav_tiled(float ox, float oz, float tile, int max_tiles, int max_polys) {
  dtNavMeshParams p;
  memset(&p, 0, sizeof(p));
  p.orig[0] = ox; p.orig[1] = 0.0f; p.orig[2] = oz;
  p.tileWidth = tile; p.tileHeight = tile;
  p.maxTiles = max_tiles; p.maxPolys = max_polys;
  dtNavMesh *mesh = dtAllocNavMesh();
  if (!mesh || dtStatusFailed(mesh->init(&p))) { dtFreeNavMesh(mesh); return nullptr; }
  return nav_open(mesh);
}

// tile (tx, tz) built from triangles that cover it and a border of the walker's radius and three
// cells round it, replacing whatever was there; its polygons, 0 for none, -1 when it failed
NAV_SHIM int nav_tile_build(void *h, int tx, int tz, const float *v, int nv, const int *t, int nt,
                            const unsigned char *area, const float *cyl, int nc, const float *foot, int nf, const float *c) {
  Nav *n = static_cast<Nav *>(h);
  const dtNavMeshParams *mp = n->mesh->getParams();
  rcConfig cfg;
  nav_config(cfg, c);
  cfg.tileSize = (int)(mp->tileWidth / cfg.cs + 0.5f);
  // a tile a cell short of its width leaves a seam its neighbour's polygons never meet
  if (fabsf(cfg.tileSize * cfg.cs - mp->tileWidth) > 0.001f) return -1;
  cfg.borderSize = cfg.walkableRadius + 3;
  cfg.width = cfg.height = cfg.tileSize + cfg.borderSize * 2;
  float lo[3], hi[3];
  rcCalcBounds(v, nv, lo, hi);
  cfg.bmin[0] = mp->orig[0] + tx * mp->tileWidth - cfg.borderSize * cfg.cs;
  cfg.bmin[2] = mp->orig[2] + tz * mp->tileHeight - cfg.borderSize * cfg.cs;
  cfg.bmax[0] = mp->orig[0] + (tx + 1) * mp->tileWidth + cfg.borderSize * cfg.cs;
  cfg.bmax[2] = mp->orig[2] + (tz + 1) * mp->tileHeight + cfg.borderSize * cfg.cs;
  cfg.bmin[1] = lo[1] - 1.0f;
  cfg.bmax[1] = hi[1] + c[2] + 1.0f;
  NavIn in = {v, nv, t, nt, area, cyl, nc, foot, nf, c};
  unsigned char *data = nullptr;
  int size = 0, polys = 0;
  n->mesh->removeTile(n->mesh->getTileRefAt(tx, tz, 0), nullptr, nullptr);
  if (!nav_pipeline(cfg, in, tx, tz, &data, &size, &polys)) return -1;
  if (polys == 0) return 0;
  if (dtStatusFailed(n->mesh->addTile(data, size, DT_TILE_FREE_DATA, 0, nullptr))) { dtFree(data); return -1; }
  return polys;
}

// the set's bytes: "NAVT", a version, the mesh's params, then each tile's ref, size and data.
// First call with buf null for the size, then with a buffer that big
static const int NAV_MAGIC = 'N' << 24 | 'A' << 16 | 'V' << 8 | 'T';
static const int NAV_VERSION = 1;
static void nav_put(unsigned char *buf, int &at, const void *p, int n) {
  if (buf) memcpy(buf + at, p, n);
  at += n;
}
NAV_SHIM int nav_save(void *h, unsigned char *buf, int cap) {
  const dtNavMesh *m = static_cast<Nav *>(h)->mesh;
  const dtNavMeshParams *p = m->getParams();
  int at = 0, count = 0;
  for (int i = 0; i < m->getMaxTiles(); ++i) {
    const dtMeshTile *t = m->getTile(i);
    if (t && t->header && t->dataSize) count++;
  }
  nav_put(buf, at, &NAV_MAGIC, 4); nav_put(buf, at, &NAV_VERSION, 4); nav_put(buf, at, &count, 4);
  nav_put(buf, at, p->orig, 12); nav_put(buf, at, &p->tileWidth, 4); nav_put(buf, at, &p->tileHeight, 4);
  nav_put(buf, at, &p->maxTiles, 4); nav_put(buf, at, &p->maxPolys, 4);
  for (int i = 0; i < m->getMaxTiles(); ++i) {
    const dtMeshTile *t = m->getTile(i);
    if (!t || !t->header || !t->dataSize) continue;
    unsigned long long ref = (unsigned long long)m->getTileRef(t);
    if (buf && at + 12 + t->dataSize > cap) return -1;
    nav_put(buf, at, &ref, 8); nav_put(buf, at, &t->dataSize, 4); nav_put(buf, at, t->data, t->dataSize);
  }
  return at;
}

// a mesh from bytes nav_save wrote; null for anything else
NAV_SHIM void *nav_load(const unsigned char *buf, int size) {
  int at = 0, magic = 0, version = 0, count = 0;
  if (size < 40) return nullptr;
  memcpy(&magic, buf, 4); memcpy(&version, buf + 4, 4); memcpy(&count, buf + 8, 4);
  if (magic != NAV_MAGIC || version != NAV_VERSION) return nullptr;
  dtNavMeshParams p;
  memset(&p, 0, sizeof(p));
  memcpy(p.orig, buf + 12, 12); memcpy(&p.tileWidth, buf + 24, 4); memcpy(&p.tileHeight, buf + 28, 4);
  memcpy(&p.maxTiles, buf + 32, 4); memcpy(&p.maxPolys, buf + 36, 4);
  at = 40;
  dtNavMesh *mesh = dtAllocNavMesh();
  if (!mesh || dtStatusFailed(mesh->init(&p))) { dtFreeNavMesh(mesh); return nullptr; }
  for (int i = 0; i < count; ++i) {
    unsigned long long ref = 0;
    int n = 0;
    if (at + 12 > size) break;
    memcpy(&ref, buf + at, 8); memcpy(&n, buf + at + 8, 4);
    at += 12;
    if (n <= 0 || at + n > size) break;
    unsigned char *data = static_cast<unsigned char *>(dtAlloc(n, DT_ALLOC_PERM));
    memcpy(data, buf + at, n);
    at += n;
    if (dtStatusFailed(mesh->addTile(data, n, DT_TILE_FREE_DATA, (dtTileRef)ref, nullptr))) dtFree(data);
  }
  return nav_open(mesh);
}

// a file read straight into the shim's own memory rather than a Ludic slice (which is never given
// back): nav_stage hands out the room, nav_load_staged parses it and frees it, whatever the outcome
NAV_SHIM void nav_unstage(unsigned char *buf) { free(buf); }
NAV_SHIM unsigned char *nav_stage(int size) { return size > 0 ? static_cast<unsigned char *>(malloc(size)) : nullptr; }
NAV_SHIM void *nav_load_staged(unsigned char *buf, int size) {
  void *h = buf ? nav_load(buf, size) : nullptr;
  free(buf);
  return h;
}
