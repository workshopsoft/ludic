// jph_ragdoll.inl - a ragdoll: Jolt's RagdollSettings (a Skeleton, a capsule a part, a SwingTwistConstraint to each part's parent) built
// in calls from the game's bones, then any number of Ragdolls of it in a world (Samples/Utils/RagdollLoader.cpp's sCreate is the model).
// A part's body stands at its joint, turned as the joint is: its transform IS the joint's, as Jolt's own ragdolls keep it, so the game reads
// the bodies back as bones. Floats cross in arrays; a definition and a ragdoll are handles.

namespace {
const int RAG_PART_FLOATS = 26;

struct RagDef {
  Ref<RagdollSettings> s;
  Array<Mat44> bind;      // each part's joint in the definition's pose: which parts touch there (they never collide)
  int n = 0;
  int added = 0;
  bool made = false;
};

struct Rag {
  World *w = nullptr;
  Ref<Ragdoll> r;
};

Vec3 v3_at(const float *f, int i) { return Vec3(f[i], f[i + 1], f[i + 2]); }
} // namespace

// a definition of n parts, added in order with jph_rag_def_part (a parent before its children)
JPH_SHIM void *jph_rag_def_new(int n) {
  if (jph_init() != 0 || n < 1 || n > 64) return nullptr;
  RagDef *d = new RagDef();
  d->s = new RagdollSettings();
  d->s->mSkeleton = new Skeleton();
  d->s->mParts.resize(n);
  d->bind.resize(n, Mat44::sIdentity());
  d->n = n;
  return d;
}

JPH_SHIM void jph_rag_def_free(void *d) { delete static_cast<RagDef *>(d); }

// part i (the next one), its parent (-1 for the root, part 0 only), and f[26]:
//   0..2 the joint, 3..6 its rotation (x, y, z, w), in the definition's pose (world space)
//   7..9, 10..12 the capsule's two ends in the joint's own space; 13 its radius; 14 the part's mass (kg)
//   15..17 the twist axis, 18..20 the plane axis (world space, at the joint; the plane axis is where the part swings most)
//   21 the bend: the constraint's middle turned this far (radians) from the definition's pose toward the plane axis (a knee, an elbow)
//   22, 23 the twist's least and most; 24 the swing toward the normal axis, 25 toward the plane axis (half cones, radians)
// 0 when added; -1 out of order, a parent that is not before it, or a shape Jolt refused
JPH_SHIM int jph_rag_def_part(void *dp, int i, int parent, const float *f) {
  RagDef *d = static_cast<RagDef *>(dp);
  if (d == nullptr || d->made || i != d->added || i >= d->n) return -1;
  if ((i == 0) != (parent < 0) || parent >= i) return -1;
  d->s->mSkeleton->AddJoint(String("p") + ConvertToString(i), parent);
  RagdollSettings::Part &p = d->s->mParts[i];
  Vec3 a = v3_at(f, 7), b = v3_at(f, 10);
  float r = std::max(0.01f, f[13]);
  Vec3 ab = b - a;
  float len = ab.Length();
  Quat axis = len > 1.0e-4f ? Quat::sFromTo(Vec3::sAxisY(), ab / len) : Quat::sIdentity();
  Ref<Shape> cap = new CapsuleShape(std::max(0.005f, 0.5f * len), r);
  RotatedTranslatedShapeSettings rt(0.5f * (a + b), axis, cap);
  ShapeSettings::ShapeResult res = rt.Create();
  if (res.HasError()) return -1;
  RVec3 at(f[0], f[1], f[2]);
  Quat q = Quat(f[3], f[4], f[5], f[6]).Normalized();
  p.SetShape(res.Get());
  p.mPosition = at;
  p.mRotation = q;
  p.mMotionType = EMotionType::Dynamic;
  p.mObjectLayer = L_MOVING;
  p.mFriction = 0.8f;
  p.mRestitution = 0.05f;
  p.mLinearDamping = 0.1f;
  p.mAngularDamping = 0.6f;
  p.mMotionQuality = EMotionQuality::LinearCast;   // a thrown limb is 6 cm across and moves 30 cm a step: the road's mesh has no thickness
  if (f[14] > 0.0f) {
    p.mOverrideMassProperties = EOverrideMassProperties::CalculateInertia;
    p.mMassPropertiesOverride.mMass = f[14];
  }
  d->bind[i] = Mat44::sRotationTranslation(q, Vec3(at));
  if (parent >= 0) {
    Vec3 twist = v3_at(f, 15).NormalizedOr(Vec3::sAxisY());
    Vec3 plane = v3_at(f, 18);
    plane = (plane - plane.Dot(twist) * twist).NormalizedOr(twist.GetNormalizedPerpendicular());
    float bend = f[21];
    Vec3 twist1 = twist * std::cos(bend) + plane * std::sin(bend);
    Vec3 plane1 = plane * std::cos(bend) - twist * std::sin(bend);
    SwingTwistConstraintSettings *c = new SwingTwistConstraintSettings();
    c->mPosition1 = c->mPosition2 = at;
    c->mTwistAxis1 = twist1;
    c->mPlaneAxis1 = plane1;
    c->mTwistAxis2 = twist;
    c->mPlaneAxis2 = plane;
    c->mTwistMinAngle = f[22];
    c->mTwistMaxAngle = f[23];
    c->mNormalHalfConeAngle = f[24];
    c->mPlaneHalfConeAngle = f[25];
    p.mToParent = c;
  }
  d->added++;
  return 0;
}

// every part given: the inertia steadied, the parts that touch in the definition's pose (and each part and its parent) kept from colliding,
// the root's constraints first. 0 when made
JPH_SHIM int jph_rag_def_make(void *dp) {
  RagDef *d = static_cast<RagDef *>(dp);
  if (d == nullptr || d->made || d->added != d->n) return -1;
  d->s->GetSkeleton()->CalculateParentJointIndices();
  d->s->Stabilize();
  d->s->DisableParentChildCollisions(d->bind.data(), 0.02f);
  d->s->CalculateBodyIndexToConstraintIndex();
  d->s->CalculateConstraintIndexToBodyIdxPair();
  d->s->CalculateConstraintPriorities();
  d->made = true;
  return 0;
}

JPH_SHIM int jph_rag_def_parts(void *dp) { return dp == nullptr ? 0 : static_cast<RagDef *>(dp)->n; }

// a ragdoll of the definition in the world, every part where pose[7 * i ..] puts it (x, y, z, then the rotation x, y, z, w) and moving at
// vel[3 * i ..]; `group` keeps its own parts apart (a number no other live ragdoll has). Null when the world has no room for its bodies
JPH_SHIM void *jph_rag_new(void *w, void *dp, int group, const float *pose, const float *vel) {
  World *ww = static_cast<World *>(w);
  RagDef *d = static_cast<RagDef *>(dp);
  if (ww == nullptr || d == nullptr || !d->made) return nullptr;
  Ref<Ragdoll> r = d->s->CreateRagdoll(CollisionGroup::GroupID(group), 0, &ww->sys);
  if (r == nullptr) return nullptr;
  BodyInterface &bi = ww->sys.GetBodyInterface();
  for (int i = 0; i < d->n; i++) {
    BodyID id = r->GetBodyID(i);
    const float *p = pose + 7 * i;
    bi.SetPositionAndRotation(id, RVec3(p[0], p[1], p[2]), Quat(p[3], p[4], p[5], p[6]).Normalized(), EActivation::DontActivate);
    bi.SetLinearVelocity(id, v3_at(vel, 3 * i));
  }
  r->AddToPhysicsSystem(EActivation::Activate);
  Rag *g = new Rag();
  g->w = ww;
  g->r = r;
  return g;
}

JPH_SHIM void jph_rag_free(void *gp) {
  Rag *g = static_cast<Rag *>(gp);
  if (g == nullptr) return;
  g->r->RemoveFromPhysicsSystem();
  delete g;   // the Ragdoll goes with its last reference, and its bodies with it
}

JPH_SHIM int jph_rag_parts(void *gp) { return gp == nullptr ? 0 : int(static_cast<Rag *>(gp)->r->GetBodyCount()); }

JPH_SHIM int jph_rag_body(void *gp, int i) {
  Rag *g = static_cast<Rag *>(gp);
  if (g == nullptr || i < 0 || i >= int(g->r->GetBodyCount())) return -1;
  return int(g->r->GetBodyID(i).GetIndexAndSequenceNumber());
}

// a push on part i at the world point (px, py, pz)
JPH_SHIM void jph_rag_impulse(void *gp, int i, float ix, float iy, float iz, float px, float py, float pz) {
  Rag *g = static_cast<Rag *>(gp);
  if (g == nullptr || i < 0 || i >= int(g->r->GetBodyCount())) return;
  g->w->sys.GetBodyInterface().AddImpulse(g->r->GetBodyID(i), Vec3(ix, iy, iz), RVec3(px, py, pz));
}

// every part's place and rotation into out[7 * parts]; 1 while any part is awake, 0 when all sleep
JPH_SHIM int jph_rag_read(void *gp, float *out) {
  Rag *g = static_cast<Rag *>(gp);
  if (g == nullptr) return 0;
  BodyInterface &bi = g->w->sys.GetBodyInterface();
  bool awake = false;
  for (int i = 0; i < int(g->r->GetBodyCount()); i++) {
    BodyID id = g->r->GetBodyID(i);
    RVec3 p; Quat q;
    bi.GetPositionAndRotation(id, p, q);
    float *o = out + 7 * i;
    o[0] = float(p.GetX()); o[1] = float(p.GetY()); o[2] = float(p.GetZ());
    o[3] = q.GetX(); o[4] = q.GetY(); o[5] = q.GetZ(); o[6] = q.GetW();
    awake = awake || bi.IsActive(id);
  }
  return awake ? 1 : 0;
}

// a body made a sensor (on 1) or solid again: a sensor's contacts are recorded and nothing is pushed by it, and no query finds it
JPH_SHIM int jph_body_sensor(void *w, int id, int on) {
  BodyInterface &bi = static_cast<World *>(w)->sys.GetBodyInterface();
  if (!bi.IsAdded(bid(id))) return -1;
  bi.SetIsSensor(bid(id), on != 0);
  return bi.IsSensor(bid(id)) ? 1 : 0;
}
