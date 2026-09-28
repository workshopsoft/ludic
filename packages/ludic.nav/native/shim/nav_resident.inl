// nav_resident.inl - a baked mesh whose tiles are resident by chunk (phase 23.5b): the file is
// indexed once (each tile's grid cell, where its bytes are, its ref), and a tile's bytes are read
// in when a player comes near and let go when all are far. The game reads the file (its reads are
// the pack's); the shim only parses what it is handed and keeps the index.

// a mesh with no tiles yet, from nav_save's 40-byte head; null for anything else
NAV_SHIM void *nav_index_open(const unsigned char *head) {
  int magic = 0, version = 0;
  memcpy(&magic, head, 4); memcpy(&version, head + 4, 4);
  if (magic != NAV_MAGIC || version != NAV_VERSION) return nullptr;
  dtNavMeshParams p;
  memset(&p, 0, sizeof(p));
  memcpy(p.orig, head + 12, 12); memcpy(&p.tileWidth, head + 24, 4); memcpy(&p.tileHeight, head + 28, 4);
  memcpy(&p.maxTiles, head + 32, 4); memcpy(&p.maxPolys, head + 36, 4);
  dtNavMesh *mesh = dtAllocNavMesh();
  if (!mesh || dtStatusFailed(mesh->init(&p))) { dtFreeNavMesh(mesh); return nullptr; }
  return nav_open(mesh);
}
// how many tiles the file said it holds (from the same head)
NAV_SHIM int nav_index_count_in(const unsigned char *head) {
  int count = 0;
  memcpy(&count, head + 8, 4);
  return count;
}

// one tile's record, read at `offset`: its ref and size, and the start of its data (its header's
// magic, version, x, y). Returns the data's size, so the caller can seek past it; -1 when not a tile
NAV_SHIM int nav_index_put(void *h, const unsigned char *rec, long long offset) {
  Nav *n = static_cast<Nav *>(h);
  NavTileRec t;
  memcpy(&t.ref, rec, 8); memcpy(&t.size, rec + 8, 4);
  int magic = 0;
  memcpy(&magic, rec + 12, 4); memcpy(&t.x, rec + 20, 4); memcpy(&t.y, rec + 24, 4);
  if (magic != DT_NAVMESH_MAGIC || t.size <= 0) return -1;
  t.offset = offset + 12;
  n->tiles.push_back(t);
  return t.size;
}
NAV_SHIM int nav_index_count(void *h) { return static_cast<int>(static_cast<Nav *>(h)->tiles.size()); }

// tile i's centre and whether it is in: out[0] x, out[1] z, out[2] 1 in / 0 out, out[3] its bytes
NAV_SHIM int nav_index_tile(void *h, int i, float *out) {
  Nav *n = static_cast<Nav *>(h);
  if (i < 0 || i >= (int)n->tiles.size()) return 0;
  const NavTileRec &t = n->tiles[i];
  const dtNavMeshParams *p = n->mesh->getParams();
  out[0] = p->orig[0] + (t.x + 0.5f) * p->tileWidth;
  out[1] = p->orig[2] + (t.y + 0.5f) * p->tileHeight;
  out[2] = t.in ? 1.0f : 0.0f;
  out[3] = (float)t.size;
  return 1;
}
// where tile i's bytes are in the file (the caller seeks there and reads nav_index_size of them)
NAV_SHIM long long nav_index_offset(void *h, int i) { return static_cast<Nav *>(h)->tiles[i].offset; }
NAV_SHIM int nav_index_size(void *h, int i) { return static_cast<Nav *>(h)->tiles[i].size; }

// tile i's bytes (staged by nav_stage, owned from here on) added to the mesh; 0 when refused
NAV_SHIM int nav_index_in(void *h, int i, unsigned char *data, int size) {
  Nav *n = static_cast<Nav *>(h);
  if (i < 0 || i >= (int)n->tiles.size() || n->tiles[i].in || !data) { free(data); return 0; }
  if (dtStatusFailed(n->mesh->addTile(data, size, DT_TILE_FREE_DATA, (dtTileRef)n->tiles[i].ref, nullptr))) { free(data); return 0; }
  n->tiles[i].in = true;
  return 1;
}
// tile i let go, its bytes with it
NAV_SHIM int nav_index_out(void *h, int i) {
  Nav *n = static_cast<Nav *>(h);
  if (i < 0 || i >= (int)n->tiles.size() || !n->tiles[i].in) return 0;
  n->mesh->removeTile((dtTileRef)n->tiles[i].ref, nullptr, nullptr);
  n->tiles[i].in = false;
  return 1;
}
