// jph_queries.inl - what is there: a ray, the top a body could step onto, overlaps, a push out

// a ray from o along d (its length the reach) against the layers in mask; the body id or -1, and
// out[7] the fraction, the point and the normal
JPH_SHIM int jph_ray(void *w, float ox, float oy, float oz, float dx, float dy, float dz, int mask, float *out) {
  World *ww = static_cast<World *>(w);
  RRayCast ray{ RVec3(ox, oy, oz), Vec3(dx, dy, dz) };
  RayCastResult hit;
  MaskFilter f(mask);
  if (!ww->sys.GetNarrowPhaseQuery().CastRay(ray, hit, {}, f, g_no_sensors)) return -1;
  RVec3 p = ray.GetPointOnRay(hit.mFraction);
  Vec3 n = Vec3::sAxisY();
  BodyLockRead lock(ww->sys.GetBodyLockInterface(), hit.mBodyID);
  if (lock.Succeeded()) n = lock.GetBody().GetWorldSpaceSurfaceNormal(hit.mSubShapeID2, p);
  float vals[7] = { hit.mFraction, float(p.GetX()), float(p.GetY()), float(p.GetZ()), n.GetX(), n.GetY(), n.GetZ() };
  for (int i = 0; i < 7; i++) out[i] = vals[i];
  return int(hit.mBodyID.GetIndexAndSequenceNumber());
}

// a ball of radius r let down from (x, from_y, z) at most `depth`: the height of what it lands
// on, or -FLT_MAX when it lands on nothing in mask
JPH_SHIM float jph_top_at(void *w, float x, float z, float r, float from_y, float depth, int mask) {
  World *ww = static_cast<World *>(w);
  SphereShape ball(r);
  ball.SetEmbedded();
  RShapeCast cast = RShapeCast::sFromWorldTransform(&ball, Vec3::sOne(), RMat44::sTranslation(RVec3(x, from_y, z)),
                                                    Vec3(0.0f, -depth, 0.0f));
  ClosestHitCollisionCollector<CastShapeCollector> hit;
  MaskFilter f(mask);
  ww->sys.GetNarrowPhaseQuery().CastShape(cast, ShapeCastSettings(), RVec3::sZero(), hit, {}, f, g_no_sensors);
  if (!hit.HadHit()) return -FLT_MAX;
  return float(hit.mHit.mContactPointOn2.GetY());
}

// the bodies (in mask) a ball at (x, y, z) touches, up to cap into ids; returns how many
JPH_SHIM int jph_overlap(void *w, float x, float y, float z, float r, int mask, int *ids, int cap) {
  World *ww = static_cast<World *>(w);
  SphereShape ball(r);
  ball.SetEmbedded();
  AllHitCollisionCollector<CollideShapeCollector> hits;
  MaskFilter f(mask);
  ww->sys.GetNarrowPhaseQuery().CollideShape(&ball, Vec3::sOne(), RMat44::sTranslation(RVec3(x, y, z)),
                                             CollideShapeSettings(), RVec3::sZero(), hits, {}, f, g_no_sensors);
  hits.Sort();
  int n = 0;
  for (const CollideShapeResult &h : hits.mHits) {
    int id = int(h.mBodyID2.GetIndexAndSequenceNumber());
    bool seen = false;
    for (int i = 0; i < n; i++) seen = seen || ids[i] == id;
    if (!seen && n < cap) ids[n++] = id;
  }
  return n;
}

// an upright body r wide, from y0 to y1, at (x, z): how far to move it in x and z to stand clear
// of what it overlaps in mask, into out[2]; returns how many things were in the way
JPH_SHIM int jph_push(void *w, float x, float z, float r, float y0, float y1, int mask, float *out) {
  World *ww = static_cast<World *>(w);
  float half = (y1 - y0) * 0.5f;
  CylinderShape body(half, r, 0.0f);
  body.SetEmbedded();
  AllHitCollisionCollector<CollideShapeCollector> hits;
  MaskFilter f(mask);
  CollideShapeSettings cs;
  cs.mBackFaceMode = EBackFaceMode::CollideWithBackFaces;
  ww->sys.GetNarrowPhaseQuery().CollideShape(&body, Vec3::sOne(), RMat44::sTranslation(RVec3(x, y0 + half, z)),
                                             cs, RVec3::sZero(), hits, {}, f, g_no_sensors);
  hits.Sort();
  // a thing wholly below the feet (stood on) or above the head is not in the way; anything else
  // pushes out sideways - along Jolt's own axis when the contact is side-on, else straight away
  // from the thing's middle, by as much as the two overlap across (exact for an upright post)
  float px = 0.0f, pz = 0.0f;
  int n = 0;
  for (const CollideShapeResult &h : hits.mHits) {
    BodyLockRead lock(ww->sys.GetBodyLockInterface(), h.mBodyID2);
    if (!lock.Succeeded()) continue;
    AABox bb = lock.GetBody().GetWorldSpaceBounds();
    if (float(bb.mMax.GetY()) <= y0 + 1.0e-3f || float(bb.mMin.GetY()) >= y1 - 1.0e-3f) continue;
    Vec3 a = h.mPenetrationAxis.NormalizedOr(Vec3::sAxisY());
    Vec3 flat(a.GetX(), 0.0f, a.GetZ());
    float dx, dz;
    if (flat.Length() >= 0.5f && h.mPenetrationDepth > 1.0e-4f) {
      flat = flat.Normalized() * h.mPenetrationDepth;
      dx = -flat.GetX();
      dz = -flat.GetZ();
    } else {
      Vec3 c = bb.GetCenter();
      float ex = x - float(c.GetX()), ez = z - float(c.GetZ());
      float d = std::sqrt(ex * ex + ez * ez);
      float half = std::max(float(bb.GetExtent().GetX()), float(bb.GetExtent().GetZ()));
      float push = half + r - d;
      if (push <= 1.0e-4f) continue;
      float ux = 1.0f, uz = 0.0f;
      if (d > 1.0e-6f) { ux = ex / d; uz = ez / d; }
      dx = ux * push;
      dz = uz * push;
    }
    px += dx;
    pz += dz;
    n++;
  }
  out[0] = px;
  out[1] = pz;
  return n;
}

// the highest top under an upright body r wide at (x, z) that a foot at `feet` could stand on or
// step up to: a thing whose top is above feet + reach is a wall and is left out, whatever else is
// there. Each candidate's surface is found by letting a ball r across down onto it alone.
// -FLT_MAX when there is nothing.
JPH_SHIM float jph_step_top(void *w, float x, float z, float r, float feet, float reach, int mask) {
  World *ww = static_cast<World *>(w);
  float limit = feet + reach;
  float y0 = feet - 1.0f, y1 = limit + 0.05f;
  float half = (y1 - y0) * 0.5f;
  CylinderShape column(half, r, 0.0f);
  column.SetEmbedded();
  AllHitCollisionCollector<CollideShapeCollector> hits;
  MaskFilter f(mask);
  ww->sys.GetNarrowPhaseQuery().CollideShape(&column, Vec3::sOne(), RMat44::sTranslation(RVec3(x, y0 + half, z)),
                                             CollideShapeSettings(), RVec3::sZero(), hits, {}, f, g_no_sensors);
  hits.Sort();
  float best = -FLT_MAX;
  SphereShape ball(r);
  ball.SetEmbedded();
  float from = limit + r + 0.01f;
  RShapeCast cast = RShapeCast::sFromWorldTransform(&ball, Vec3::sOne(), RMat44::sTranslation(RVec3(x, from, z)),
                                                    Vec3(0.0f, y0 - from, 0.0f));
  for (const CollideShapeResult &h : hits.mHits) {
    BodyLockRead lock(ww->sys.GetBodyLockInterface(), h.mBodyID2);
    if (!lock.Succeeded()) continue;
    const Body &b = lock.GetBody();
    float top = float(b.GetWorldSpaceBounds().mMax.GetY());
    if (top > limit + 1.0e-4f) continue;
    ClosestHitCollisionCollector<CastShapeCollector> c;
    b.GetTransformedShape().CastShape(cast, ShapeCastSettings(), RVec3::sZero(), c);
    float y = c.HadHit() ? float(c.mHit.mContactPointOn2.GetY()) : top;
    if (y > top) y = top;
    if (y > best) best = y;
  }
  return best;
}

// a ray from o along d against ONE body's shape (what a round meets on a car: its drawn hull, whatever else is round it); out[7] as
// jph_ray. 1 when it hits, 0 when it misses, -1 when there is no such body
JPH_SHIM int jph_ray_body(void *w, int id, float ox, float oy, float oz, float dx, float dy, float dz, float *out) {
  World *ww = static_cast<World *>(w);
  BodyLockRead lock(ww->sys.GetBodyLockInterface(), bid(id));
  if (!lock.Succeeded()) return -1;
  const Body &b = lock.GetBody();
  RRayCast ray{ RVec3(ox, oy, oz), Vec3(dx, dy, dz) };
  RayCastResult hit;
  if (!b.GetTransformedShape().CastRay(ray, hit)) return 0;
  RVec3 p = ray.GetPointOnRay(hit.mFraction);
  Vec3 n = b.GetWorldSpaceSurfaceNormal(hit.mSubShapeID2, p);
  float vals[7] = { hit.mFraction, float(p.GetX()), float(p.GetY()), float(p.GetZ()), n.GetX(), n.GetY(), n.GetZ() };
  for (int i = 0; i < 7; i++) out[i] = vals[i];
  return 1;
}
