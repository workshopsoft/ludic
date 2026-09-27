// nav_crowd.inl - DetourCrowd over a navmesh: many walkers steered along their paths at once, each
// kept clear of the others. The mechanic decides where and how fast; the crowd only moves them.

struct Crowd {
  dtCrowd *crowd = nullptr;
  Nav *nav = nullptr;
  long long ns = 0;    // time spent stepping it, for the measure (18.8)
};

// a crowd of at most max walkers, none wider than max_radius, with the mesh's tastes as its filters
NAV_SHIM void *nav_crowd_new(void *h, int max, float max_radius) {
  Nav *n = static_cast<Nav *>(h);
  Crowd *c = new Crowd();
  c->nav = n;
  c->crowd = dtAllocCrowd();
  if (!c->crowd || !c->crowd->init(max, max_radius, n->mesh)) { dtFreeCrowd(c->crowd); delete c; return nullptr; }
  for (int f = 0; f < NAV_FILTERS && f < DT_CROWD_MAX_QUERY_FILTER_TYPE; ++f) *c->crowd->getEditableFilter(f) = n->filters[f];
  return c;
}
NAV_SHIM void nav_crowd_free(void *p) {
  Crowd *c = static_cast<Crowd *>(p);
  if (!c) return;
  dtFreeCrowd(c->crowd);
  delete c;
}

// a walker at (x, y, z): its index, or -1 when the crowd is full or the point is off the mesh;
// separation is how hard it keeps its distance (a herd animal more than a loner)
NAV_SHIM int nav_crowd_add(void *p, float x, float y, float z, float radius, float height, float speed, int filter, float separation) {
  Crowd *c = static_cast<Crowd *>(p);
  dtCrowdAgentParams ap;
  memset(&ap, 0, sizeof(ap));
  ap.radius = radius;
  ap.height = height;
  ap.maxSpeed = speed;
  ap.maxAcceleration = speed * 4.0f;
  ap.collisionQueryRange = radius * 12.0f;
  ap.pathOptimizationRange = radius * 30.0f;
  ap.separationWeight = separation;
  ap.updateFlags = DT_CROWD_ANTICIPATE_TURNS | DT_CROWD_OBSTACLE_AVOIDANCE | DT_CROWD_SEPARATION | DT_CROWD_OPTIMIZE_TOPO | DT_CROWD_OPTIMIZE_VIS;
  ap.obstacleAvoidanceType = 3;
  ap.queryFilterType = (unsigned char)(filter >= 0 && filter < NAV_FILTERS ? filter : 0);
  float pos[3] = {x, y, z}, near[3];
  dtPolyRef ref = 0;
  c->nav->query->findNearestPoly(pos, c->nav->ext, c->crowd->getFilter(ap.queryFilterType), &ref, near);
  if (!ref) return -1;
  return c->crowd->addAgent(near, &ap);
}
// a walker the crowd avoids but does not steer (a player): placed by nav_crowd_place each frame
NAV_SHIM int nav_crowd_add_fixed(void *p, float x, float y, float z, float radius, float height) {
  Crowd *c = static_cast<Crowd *>(p);
  dtCrowdAgentParams ap;
  memset(&ap, 0, sizeof(ap));
  ap.radius = radius;
  ap.height = height;
  ap.maxSpeed = 20.0f;
  ap.maxAcceleration = 1000.0f;
  ap.collisionQueryRange = radius * 12.0f;
  ap.pathOptimizationRange = radius * 30.0f;
  ap.separationWeight = 0.0f;
  ap.updateFlags = 0;
  float pos[3] = {x, y, z}, near[3];
  dtPolyRef ref = 0;
  c->nav->query->findNearestPoly(pos, c->nav->ext, c->crowd->getFilter(0), &ref, near);
  if (!ref) return -1;
  return c->crowd->addAgent(near, &ap);
}
// walker i put at (x, y, z) going (vx, vz), snapped to the mesh; 0 when it is off it (left where it was)
NAV_SHIM int nav_crowd_place(void *p, int i, float x, float y, float z, float vx, float vz) {
  Crowd *c = static_cast<Crowd *>(p);
  dtCrowdAgent *a = c->crowd->getEditableAgent(i);
  if (!a || !a->active) return 0;
  float pos[3] = {x, y, z}, near[3];
  dtPolyRef ref = 0;
  c->nav->query->findNearestPoly(pos, c->nav->ext, c->crowd->getFilter(0), &ref, near);
  if (!ref) return 0;
  a->corridor.reset(ref, near);
  dtVcopy(a->npos, near);
  float v[3] = {vx, 0.0f, vz};
  dtVcopy(a->vel, v);
  dtVcopy(a->dvel, v);
  dtVcopy(a->nvel, v);
  a->desiredSpeed = dtVlen(v);
  return 1;
}
NAV_SHIM void nav_crowd_remove(void *p, int i) { static_cast<Crowd *>(p)->crowd->removeAgent(i); }

// send walker i toward (x, y, z), snapped to the mesh; 0 when the point is off it
NAV_SHIM int nav_crowd_target(void *p, int i, float x, float y, float z) {
  Crowd *c = static_cast<Crowd *>(p);
  const dtCrowdAgent *a = c->crowd->getAgent(i);
  if (!a || !a->active) return 0;
  float e[3] = {x, y, z}, near[3];
  dtPolyRef ref = 0;
  c->nav->query->findNearestPoly(e, c->nav->ext, c->crowd->getFilter(a->params.queryFilterType), &ref, near);
  if (!ref) return 0;
  return c->crowd->requestMoveTarget(i, ref, near) ? 1 : 0;
}
// a new top speed, as a walker goes from a walk to a run; 0 stands it still (a new target moves it again)
NAV_SHIM void nav_crowd_speed(void *p, int i, float speed) {
  Crowd *c = static_cast<Crowd *>(p);
  const dtCrowdAgent *a = c->crowd->getAgent(i);
  if (!a || !a->active) return;
  if (speed < 0.01f) { c->crowd->resetMoveTarget(i); return; }   // standing: no target, not no acceleration
  dtCrowdAgentParams ap = a->params;
  ap.maxSpeed = speed;
  ap.maxAcceleration = speed * 4.0f;
  c->crowd->updateAgentParameters(i, &ap);
}

NAV_SHIM void nav_crowd_update(void *p, float dt) {
  Crowd *c = static_cast<Crowd *>(p);
  long long t0 = nav_now_ns();
  c->crowd->update(dt, nullptr);
  c->ns += nav_now_ns() - t0;
}

// walker i's position and velocity into out[0..5]; 0 when there is no such walker
NAV_SHIM int nav_crowd_read(void *p, int i, float *out) {
  const dtCrowdAgent *a = static_cast<Crowd *>(p)->crowd->getAgent(i);
  if (!a || !a->active) return 0;
  dtVcopy(out, a->npos);
  dtVcopy(out + 3, a->vel);
  return 1;
}
NAV_SHIM int nav_crowd_us(void *p) { return static_cast<int>(static_cast<Crowd *>(p)->ns / 1000); }
