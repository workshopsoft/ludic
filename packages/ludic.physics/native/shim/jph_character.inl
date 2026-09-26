// jph_character.inl - a walking body: Jolt's CharacterVirtual, stepped by the game, with an inner
// rigid body on the moving layer so dynamic things are shoved and a ray can find it. Its feet are
// its origin. The game says how fast it wants to go across and whether it jumps; Jolt does the
// rest - gravity, landing, stairs, slopes, sticking to the ground going down.

struct Walker {
  CharacterVirtual *c;
  float step_up;
  float stick;
};

// r wide, h tall, feet at (x, y, z); a slope steeper than max_slope degrees is not ground
JPH_SHIM void *jph_char_new(void *w, float r, float h, float x, float y, float z, float max_slope, float mass) {
  World *ww = static_cast<World *>(w);
  float half = (h - 2.0f * r) * 0.5f;
  if (half < 0.01f) half = 0.01f;
  RefConst<Shape> cap = CapsuleShapeSettings(half, r).Create().Get();
  RefConst<Shape> sh = RotatedTranslatedShapeSettings(Vec3(0.0f, half + r, 0.0f), Quat::sIdentity(), cap).Create().Get();
  CharacterVirtualSettings st;
  st.mShape = sh;
  st.mInnerBodyShape = sh;
  st.mInnerBodyLayer = L_MOVING;
  st.mMaxSlopeAngle = DegreesToRadians(max_slope);
  st.mMass = mass;
  st.mMaxStrength = mass * 9.81f * 2.0f;
  st.mSupportingVolume = Plane(Vec3::sAxisY(), -r);
  Walker *wk = new Walker{ new CharacterVirtual(&st, RVec3(x, y, z), Quat::sIdentity(), 0, &ww->sys), 0.55f, 0.5f };
  return wk;
}

JPH_SHIM void jph_char_free(void *k) {
  Walker *wk = static_cast<Walker *>(k);
  delete wk->c;
  delete wk;
}

// how high a step it takes without a jump, how far it follows the ground down, and the steepest
// slope in degrees that is still ground
JPH_SHIM void jph_char_limits(void *k, float step_up, float stick, float max_slope) {
  Walker *wk = static_cast<Walker *>(k);
  wk->step_up = step_up;
  wk->stick = stick;
  wk->c->SetMaxSlopeAngle(DegreesToRadians(max_slope));
}

// what the step comes to: TOO STEEP (1) only when GROUND too steep for it faces against the way it
// wanted to go (a cliff, a rise the boots cannot take) - a still thing's edge is a step or a wall;
// steep ground merely under the feet, as when stepping off an edge, is UNSUPPORTED (2)
static int jph_char_says(World *ww, CharacterVirtual *c, float vx, float vz) {
  int state = int(c->GetGroundState());
  if (state == int(CharacterBase::EGroundState::InAir)) return state;
  Vec3 want(vx, 0.0f, vz);
  for (const CharacterContact &ct : c->GetActiveContacts()) {
    if (!ct.mHadCollision || ct.mWasDiscarded || ct.mBodyB.IsInvalid()) continue;
    if (ww->sys.GetBodyInterface().GetObjectLayer(ct.mBodyB) != L_GROUND) continue;
    Vec3 n = ct.mSurfaceNormal;
    bool slope = n.GetY() > 0.05f && c->IsSlopeTooSteep(n);
    if (slope && Vec3(n.GetX(), 0.0f, n.GetZ()).Dot(want) < -1.0e-4f) return int(CharacterBase::EGroundState::OnSteepGround);
  }
  if (state == int(CharacterBase::EGroundState::OnSteepGround)) return int(CharacterBase::EGroundState::NotSupported);
  return state;
}

// one step of dt: (vx, vz) the speed it wants across; jump > 0 leaves the ground at that speed up
JPH_SHIM int jph_char_step(void *w, void *k, float dt, float vx, float vz, float jump) {
  World *ww = static_cast<World *>(w);
  Walker *wk = static_cast<Walker *>(k);
  CharacterVirtual *c = wk->c;
  Vec3 g = ww->sys.GetGravity();
  bool ground = c->GetGroundState() == CharacterBase::EGroundState::OnGround;
  float vy = c->GetLinearVelocity().GetY() + g.GetY() * dt;
  Vec3 v(vx, vy, vz);
  if (ground) v = Vec3(vx, 0.0f, vz) + c->GetGroundVelocity();
  // whether a jump may leave is the game's rule; here it only leaves
  if (jump > 0.0f) v.SetY(jump);
  c->SetLinearVelocity(v);
  CharacterVirtual::ExtendedUpdateSettings u;
  u.mWalkStairsStepUp = Vec3(0.0f, wk->step_up, 0.0f);
  u.mStickToFloorStepDown = Vec3(0.0f, jump > 0.0f ? 0.0f : -wk->stick, 0.0f);
  IgnoreSingleBodyFilter self(c->GetInnerBodyID());
  c->ExtendedUpdate(dt, g, u, ww->sys.GetDefaultBroadPhaseLayerFilter(L_MOVING), ww->sys.GetDefaultLayerFilter(L_MOVING),
                    self, {}, ww->temp);
  return jph_char_says(ww, c, vx, vz);
}

// position, velocity, the ground state (0 on ground, 1 too steep, 2 touching but unsupported,
// 3 in the air), the ground normal's y, and the inner body's id - into out[9]
JPH_SHIM void jph_char_read(void *k, float *out) {
  CharacterVirtual *c = static_cast<Walker *>(k)->c;
  RVec3 p = c->GetPosition();
  Vec3 v = c->GetLinearVelocity();
  float vals[9] = { float(p.GetX()), float(p.GetY()), float(p.GetZ()), v.GetX(), v.GetY(), v.GetZ(),
                    float(int(c->GetGroundState())), c->GetGroundNormal().GetY(),
                    float(int(c->GetInnerBodyID().GetIndexAndSequenceNumber())) };
  for (int i = 0; i < 9; i++) out[i] = vals[i];
}

// put it somewhere, standing still (a teleport, a map swap, getting off a boat)
JPH_SHIM void jph_char_place(void *w, void *k, float x, float y, float z) {
  World *ww = static_cast<World *>(w);
  CharacterVirtual *c = static_cast<Walker *>(k)->c;
  c->SetPosition(RVec3(x, y, z));
  c->SetLinearVelocity(Vec3::sZero());
  IgnoreSingleBodyFilter self(c->GetInnerBodyID());
  c->RefreshContacts(ww->sys.GetDefaultBroadPhaseLayerFilter(L_MOVING), ww->sys.GetDefaultLayerFilter(L_MOVING), self, {}, ww->temp);
}
