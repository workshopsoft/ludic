// jph_queries.inl - what is there: a ray, the top a body could step onto, overlaps, a push out

// a ray from o along d (its length the reach) against the layers in mask; the body id or -1, and
// out[7] the fraction, the point and the normal
JPH_SHIM int jph_ray(void *w, float ox, float oy, float oz, float dx, float dy, float dz, int mask, float *out) {
  World *ww = static_cast<World *>(w);
  RRayCast ray{ RVec3(ox, oy, oz), Vec3(dx, dy, dz) };
  RayCastResult hit;
  MaskFilter f(mask);
  if (!ww->sys.GetNarrowPhaseQuery().CastRay(ray, hit, {}, f)) return -1;
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
  ww->sys.GetNarrowPhaseQuery().CastShape(cast, ShapeCastSettings(), RVec3::sZero(), hit, {}, f);
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
                                             CollideShapeSettings(), RVec3::sZero(), hits, {}, f);
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
// of what it overlaps in mask, into out[2]; returns how many things it overlapped
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
                                             cs, RVec3::sZero(), hits, {}, f);
  hits.Sort();
  float px = 0.0f, pz = 0.0f;
  for (const CollideShapeResult &h : hits.mHits) {
    Vec3 a = h.mPenetrationAxis;
    Vec3 flat(a.GetX(), 0.0f, a.GetZ());
    if (flat.LengthSq() < 1.0e-8f) continue;
    flat = flat.Normalized() * h.mPenetrationDepth;
    px -= flat.GetX();
    pz -= flat.GetZ();
  }
  out[0] = px;
  out[1] = pz;
  return int(hits.mHits.size());
}
