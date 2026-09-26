// jph_world.inl - a physics world: made, stepped, emptied of its contacts, freed

// a world for up to max_bodies; threads 0 means the machine's cores less one, at most four
JPH_SHIM void *jph_world_new(int max_bodies, int threads) {
  if (jph_init() != 0) return nullptr;
  if (threads <= 0) {
    int hw = int(std::thread::hardware_concurrency()) - 1;
    threads = hw < 1 ? 1 : (hw > 4 ? 4 : hw);
  }
  World *w = new World(max_bodies, threads);
  w->sys.SetGravity(Vec3(0.0f, -9.81f, 0.0f));
  return w;
}

JPH_SHIM void jph_world_free(void *w) { delete static_cast<World *>(w); }

JPH_SHIM void jph_world_gravity(void *w, float y) { static_cast<World *>(w)->sys.SetGravity(Vec3(0.0f, y, 0.0f)); }

// one step of dt seconds in `sub` collision steps; 0 when Jolt reports nothing wrong
JPH_SHIM int jph_world_step(void *w, float dt, int sub) {
  World *ww = static_cast<World *>(w);
  EPhysicsUpdateError e = ww->sys.Update(dt, sub < 1 ? 1 : sub, &ww->temp, &ww->jobs);
  return e == EPhysicsUpdateError::None ? 0 : -int(e);
}

// after adding many still bodies at once, before the first query
JPH_SHIM void jph_world_optimize(void *w) { static_cast<World *>(w)->sys.OptimizeBroadPhase(); }

JPH_SHIM int jph_world_bodies(void *w) { return int(static_cast<World *>(w)->sys.GetNumBodies()); }

// up to cap contacts into ids (a, b pairs) and vals (x, y, z, speed); returns how many
JPH_SHIM int jph_contacts_drain(void *w, int *ids, float *vals, int cap) {
  Contacts &c = static_cast<World *>(w)->contacts;
  std::lock_guard<std::mutex> g(c.lock);
  int n = c.count < cap ? c.count : cap;
  for (int i = 0; i < n; i++) {
    ids[i * 2] = int(c.items[i].a);
    ids[i * 2 + 1] = int(c.items[i].b);
    vals[i * 4] = c.items[i].x;
    vals[i * 4 + 1] = c.items[i].y;
    vals[i * 4 + 2] = c.items[i].z;
    vals[i * 4 + 3] = c.items[i].speed;
  }
  for (int i = n; i < c.count; i++) c.items[i - n] = c.items[i];
  c.count -= n;
  return n;
}

JPH_SHIM int jph_contacts_lost(void *w) { return static_cast<World *>(w)->contacts.lost; }
