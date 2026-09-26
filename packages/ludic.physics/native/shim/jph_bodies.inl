// jph_bodies.inl - bodies by id: added, removed, moved, pushed, read back

// motion 0 still, 1 kinematic, 2 dynamic; layer 0 ground, 1 static, 2 moving; mass 0 = from shape
JPH_SHIM int jph_body_add(void *w, void *shape, float x, float y, float z, float yaw, int motion, int layer,
                          float mass, float friction, float bounce) {
  World *ww = static_cast<World *>(w);
  EMotionType mt = motion == 2 ? EMotionType::Dynamic : (motion == 1 ? EMotionType::Kinematic : EMotionType::Static);
  BodyCreationSettings st(static_cast<Shape *>(shape), RVec3(x, y, z), yaw_q(yaw), mt, ObjectLayer(layer));
  st.mFriction = friction;
  st.mRestitution = bounce;
  if (mt == EMotionType::Dynamic && mass > 0.0f) {
    st.mOverrideMassProperties = EOverrideMassProperties::CalculateInertia;
    st.mMassPropertiesOverride.mMass = mass;
  }
  EActivation act = mt == EMotionType::Static ? EActivation::DontActivate : EActivation::Activate;
  BodyID id = ww->sys.GetBodyInterface().CreateAndAddBody(st, act);
  if (id.IsInvalid()) return -1;
  return int(id.GetIndexAndSequenceNumber());
}

JPH_SHIM void jph_body_remove(void *w, int id) {
  BodyInterface &bi = static_cast<World *>(w)->sys.GetBodyInterface();
  bi.RemoveBody(bid(id));
  bi.DestroyBody(bid(id));
}

// position, rotation (x, y, z, w) and velocity into out[10]
JPH_SHIM int jph_body_read(void *w, int id, float *out) {
  BodyInterface &bi = static_cast<World *>(w)->sys.GetBodyInterface();
  if (!bi.IsAdded(bid(id))) return -1;
  RVec3 p; Quat q;
  bi.GetPositionAndRotation(bid(id), p, q);
  Vec3 v = bi.GetLinearVelocity(bid(id));
  float vals[10] = { float(p.GetX()), float(p.GetY()), float(p.GetZ()), q.GetX(), q.GetY(), q.GetZ(), q.GetW(),
                     v.GetX(), v.GetY(), v.GetZ() };
  for (int i = 0; i < 10; i++) out[i] = vals[i];
  return 0;
}

JPH_SHIM void jph_body_place(void *w, int id, float x, float y, float z, float yaw) {
  static_cast<World *>(w)->sys.GetBodyInterface().SetPositionAndRotation(bid(id), RVec3(x, y, z), yaw_q(yaw), EActivation::Activate);
}
JPH_SHIM void jph_body_impulse(void *w, int id, float x, float y, float z) {
  static_cast<World *>(w)->sys.GetBodyInterface().AddImpulse(bid(id), Vec3(x, y, z));
}
JPH_SHIM void jph_body_velocity(void *w, int id, float x, float y, float z) {
  static_cast<World *>(w)->sys.GetBodyInterface().SetLinearVelocity(bid(id), Vec3(x, y, z));
}
// a kinematic body driven to where it should be after dt, pushing what it meets
JPH_SHIM void jph_body_target(void *w, int id, float x, float y, float z, float yaw, float dt) {
  static_cast<World *>(w)->sys.GetBodyInterface().MoveKinematic(bid(id), RVec3(x, y, z), yaw_q(yaw), dt);
}
JPH_SHIM int jph_body_awake(void *w, int id) { return static_cast<World *>(w)->sys.GetBodyInterface().IsActive(bid(id)) ? 1 : 0; }

// water under a body: the surface's height and normal, how buoyant, the drags and the current
JPH_SHIM int jph_body_buoyancy(void *w, int id, float sy, float nx, float ny, float nz, float buoy, float lin, float ang,
                               float cx, float cz, float dt) {
  World *ww = static_cast<World *>(w);
  BodyInterface &bi = ww->sys.GetBodyInterface();
  RVec3 p = bi.GetPosition(bid(id));
  bool in = bi.ApplyBuoyancyImpulse(bid(id), RVec3(p.GetX(), sy, p.GetZ()), Vec3(nx, ny, nz), buoy, lin, ang,
                                     Vec3(cx, 0.0f, cz), ww->sys.GetGravity(), dt);
  return in ? 1 : 0;
}

// a push kept up over the next step (an oar's stroke, a paddle), and a twist
JPH_SHIM void jph_body_force(void *w, int id, float x, float y, float z) {
  static_cast<World *>(w)->sys.GetBodyInterface().AddForce(bid(id), Vec3(x, y, z));
}
JPH_SHIM void jph_body_torque(void *w, int id, float x, float y, float z) {
  static_cast<World *>(w)->sys.GetBodyInterface().AddTorque(bid(id), Vec3(x, y, z));
}
JPH_SHIM void jph_body_angular_impulse(void *w, int id, float x, float y, float z) {
  static_cast<World *>(w)->sys.GetBodyInterface().AddAngularImpulse(bid(id), Vec3(x, y, z));
}
// how fast it turns (x, y, z), into out[3]
JPH_SHIM void jph_body_spin(void *w, int id, float *out) {
  Vec3 a = static_cast<World *>(w)->sys.GetBodyInterface().GetAngularVelocity(bid(id));
  out[0] = a.GetX(); out[1] = a.GetY(); out[2] = a.GetZ();
}
// where a body is going, set whole: a guest's copy of the host's body, moved to what the host said
JPH_SHIM void jph_body_set_pose(void *w, int id, float x, float y, float z, float qx, float qy, float qz, float qw,
                                float vx, float vy, float vz) {
  BodyInterface &bi = static_cast<World *>(w)->sys.GetBodyInterface();
  bi.SetPositionAndRotation(bid(id), RVec3(x, y, z), Quat(qx, qy, qz, qw).Normalized(), EActivation::Activate);
  bi.SetLinearVelocity(bid(id), Vec3(vx, vy, vz));
}
