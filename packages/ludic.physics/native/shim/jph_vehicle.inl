// jph_vehicle.inl - a wheeled vehicle on a dynamic body: Jolt's VehicleConstraint with a WheeledVehicleController
// (Samples/Tests/Vehicle/VehicleConstraintTest.cpp is the model). The settings are built in calls (jph_vs_*) on a
// handle, then jph_vehicle_add makes the constraint on a body, adds it to the world and registers it as a step
// listener; the settings handle is freed there. Inputs go in between steps; wheels, engine and gear are read back.
// Floats cross, arrays of floats cross, the vehicle is a handle; jph_vehicle_free undoes jph_vehicle_add.

namespace {
struct VehicleBuild {
  VehicleConstraintSettings vs;
  WheeledVehicleControllerSettings *ctl = nullptr;   // owned by vs.mController once set
};

struct Vehicle {
  World *w = nullptr;
  BodyID body;
  Ref<VehicleConstraint> c;
  Ref<VehicleCollisionTester> tester;
  MaskFilter ground{ 3 };   // the wheels stand on the ground and the still things, not on what moves (another car, a box, a walker)
  float grip[16];       // a multiplier per wheel for the surface it stands on (the game's ground), 1 by default
  float steer[16];      // each wheel's own most steer as it was given (the Ackermann angles are worked out from it)
  float rear_z = 0.0f;  // where the wheels that do not steer are, along the body: the turn's centre is level with them
  float bar_k[16];      // each anti-roll bar's stiffness as given, N/m (Jolt's own is set from it every step: bars_in_newtons)
  bool kin = false;     // its body kinematic, moved by the game (jph_vehicle_kinematic): the constraint off and not a step listener
};

// Jolt's anti-roll bar is not in N/m. It works out an impulse, difference * stiffness * dt (N.s), and hands it to each wheel's soft
// suspension constraint as its velocity BIAS (m/s), so what the wheel gets is that number times the soft constraint's effective mass,
// 1 / (K + softness): a bar given in N/m acted 1 / (K + softness) times as stiff (some 85x on the van: its 7000 N/m bar held like
// 600 kN/m, ten times its springs). One wheel on a kerb then lifted its whole axle at once - 120 kN on the wheel that met a 14 cm kerb
// at 16 m/s, and the van flew 0.8 m. Before each step the bar's Jolt stiffness is the given one times (K + softness) of its wheels'
// suspensions (K: the body's inverse mass at the suspension's force point along up; softness = 1 / (dt (c + dt k))), so the wheels
// get exactly stiffness * difference: a bar in N/m, as the car's row means it.
static float soft_inv_mass(const VehicleConstraint &c, const WheelSettings *ws, float dt) {
  const Body *body = c.GetVehicleBody();
  const MotionProperties *mp = body->GetMotionProperties();
  Vec3 up = c.GetLocalUp();
  Vec3 fp = ws->mPosition + 0.5f * (ws->mSuspensionMinLength + ws->mSuspensionMaxLength) * ws->mSuspensionDirection - body->GetShape()->GetCenterOfMass();
  Vec3 rxn = fp.Cross(up);
  float inv_k = mp->GetInverseMass() + rxn.Dot(mp->GetLocalSpaceInverseInertia().Multiply3x3(rxn));
  float k = ws->mSuspensionSpring.mStiffness, d = ws->mSuspensionSpring.mDamping;
  if (ws->mSuspensionSpring.mMode != ESpringMode::StiffnessAndDamping) {
    float m = 1.0f / inv_k;
    if (ws->mSuspensionSpring.mMode == ESpringMode::FrequencyAndDamping) {
      float omega = 2.0f * JPH_PI * ws->mSuspensionSpring.mFrequency;
      k = m * omega * omega;
      d = 2.0f * m * ws->mSuspensionSpring.mDamping * omega;
    } else { k *= m; d *= m; }
  }
  float denom = dt * (d + dt * k);
  return inv_k + (denom > 0.0f ? 1.0f / denom : 0.0f);
}
static void bars_in_newtons(Vehicle *v, float dt) {
  if (dt <= 0.0f) return;
  VehicleAntiRollBars &bars = v->c->GetAntiRollBars();
  const Wheels &ws = v->c->GetWheels();
  for (uint i = 0; i < bars.size() && i < 16; i++) {
    VehicleAntiRollBar &r = bars[i];
    float f = 0.5f * (soft_inv_mass(*v->c, ws[r.mLeftWheel]->GetSettings(), dt) + soft_inv_mass(*v->c, ws[r.mRightWheel]->GetSettings(), dt));
    r.mStiffness = v->bar_k[i] * f;
  }
}

// Ackermann steering: wheels that steer turn about one centre level with the axle that does not, so the inner wheel turns more than
// the outer (with every wheel at the same angle they scrub against each other and the car turns wider than its lock). Jolt turns a
// wheel by right * its most steer, so each wheel's most is set for this input: the given angle is the one the middle of the axle
// would have, the wheel's own follows from its side. Straight ahead, the given angles
void ackermann(Vehicle *v, float right) {
  const Wheels &ws = v->c->GetWheels();
  for (uint i = 0; i < ws.size() && i < 16; i++) {
    WheelSettings *base = const_cast<WheelSettings *>(ws[i]->GetSettings());
    WheelSettingsWV *s = static_cast<WheelSettingsWV *>(base);
    float a = v->steer[i];
    float l = s->mPosition.GetZ() - v->rear_z;
    if (a == 0.0f || std::abs(right) < 1.0e-4f || std::abs(l) < 0.05f) { s->mMaxSteerAngle = a; continue; }
    float mid = std::abs(right * a);                    // the middle of the axle's angle, radians
    if (mid < 1.0e-4f) { s->mMaxSteerAngle = a; continue; }
    float r = std::abs(l) / std::tan(mid);              // the turn's radius at the axle's middle
    // turning right (the body's right is -x) the left wheel (x > 0) is outside; Jolt's wheel turns by -right * most
    float side = right * (a > 0.0f ? 1.0f : -1.0f) > 0.0f ? s->mPosition.GetX() : -s->mPosition.GetX();
    float own = std::atan(std::abs(l) / std::max(0.1f, r + side));
    s->mMaxSteerAngle = (a > 0.0f ? 1.0f : -1.0f) * own / std::abs(right);
  }
}

// Jolt's cylinder cast for a wheel (VehicleCollisionTesterCastCylinder, as it is written), with two changes. A mesh's back faces count:
// a road mesh wound the other way is still the road (Jolt's ray, which the ground's queries use, sees them; its shape cast did not, and
// the wheels fell through the road onto the ground under it while the body struck the road's edge). And where the cylinder meets an EDGE (a kerb's corner, a slab's step, the lip of a
// ramp) the contact's normal points back at the wheel, and Jolt lays the tyre's friction in the plane of that normal - the drive and the
// brakes then push the car up the face (a kerb at speed throws it in the air, a step stops it dead). Past 50 degrees from the
// vehicle's up a contact's normal is taken as the vehicle's up: the cast still finds how high the wheel stands (it climbs the step
// as a round wheel does), and the tyre's forces stay along the road. A slope up to 50 degrees keeps its own normal.
class WheelCast final : public VehicleCollisionTesterCastCylinder {
public:
  explicit WheelCast(ObjectLayer layer) : VehicleCollisionTesterCastCylinder(layer) {}
  bool Collide(PhysicsSystem &sys, const VehicleConstraint &vc, uint wheel, RVec3Arg origin, Vec3Arg dir, const BodyID &self,
               Body *&out_body, SubShapeID &out_sub, RVec3 &out_pos, Vec3 &out_normal, float &out_len) const override {
    const DefaultBroadPhaseLayerFilter bp_default = sys.GetDefaultBroadPhaseLayerFilter(mObjectLayer);
    const BroadPhaseLayerFilter &bp = mBroadPhaseLayerFilter != nullptr ? *mBroadPhaseLayerFilter : bp_default;
    const DefaultObjectLayerFilter ol_default = sys.GetDefaultLayerFilter(mObjectLayer);
    const ObjectLayerFilter &ol = mObjectLayerFilter != nullptr ? *mObjectLayerFilter : ol_default;
    const IgnoreSingleBodyFilter body_filter(self);
    const WheelSettings *ws = vc.GetWheel(wheel)->GetSettings();
    float max_len = ws->mSuspensionMaxLength;
    RMat44 start = vc.GetWheelWorldTransform(wheel, Vec3::sAxisY(), Vec3::sAxisX());
    start.SetTranslation(origin);
    float half_w = 0.5f * ws->mWidth;
    CylinderShape cylinder(half_w, ws->mRadius, std::min(half_w, ws->mRadius) * 0.1f);
    cylinder.SetEmbedded();
    RShapeCast cast(&cylinder, Vec3::sOne(), start, dir * max_len);
    ShapeCastSettings settings;
    settings.mUseShrunkenShapeAndConvexRadius = true;
    settings.mReturnDeepestPoint = true;
    // a road's mesh is met from whichever side it is wound (a ray finds its back faces too: the ground and the wheels agree)
    settings.mBackFaceModeTriangles = EBackFaceMode::CollideWithBackFaces;
    ClosestHitCollisionCollector<CastShapeCollector> hit;
    sys.GetNarrowPhaseQueryNoLock().CastShape(cast, settings, cast.mCenterOfMassStart.GetTranslation(), hit, bp, ol, body_filter);
    if (!hit.HadHit()) return false;
    BodyLockRead lock(sys.GetBodyLockInterfaceNoLock(), hit.mHit.mBodyID2);
    if (!lock.Succeeded() || lock.GetBody().IsSensor()) return false;
    out_body = const_cast<Body *>(&lock.GetBody());
    out_sub = hit.mHit.mSubShapeID2;
    out_pos = cast.mCenterOfMassStart.GetTranslation() + hit.mHit.mContactPointOn2;
    out_normal = -hit.mHit.mPenetrationAxis.Normalized();
    out_len = max_len * hit.mHit.mFraction;
    Vec3 up = vc.GetVehicleBody()->GetRotation() * vc.GetLocalUp();
    if (out_normal.Dot(up) < 0.6427876f) out_normal = up;
    return true;
  }
};

LinearCurve curve_of(const float *xy, int n) {
  LinearCurve c;
  c.Reserve(uint(n > 0 ? n : 2));
  if (xy == nullptr || n < 2) {
    c.AddPoint(0.0f, 0.0f);
    c.AddPoint(1.0f, 1.0f);
    return c;
  }
  for (int i = 0; i < n; i++) c.AddPoint(xy[i * 2], xy[i * 2 + 1]);
  return c;
}
} // namespace

// a settings handle: up +y, forward +z (the body's own axes), no limit on pitch and roll unless asked
JPH_SHIM void *jph_vs_new(void) {
  VehicleBuild *b = new VehicleBuild();
  b->ctl = new WheeledVehicleControllerSettings();
  b->vs.mController = b->ctl;
  b->ctl->mDifferentials.clear();
  return b;
}

JPH_SHIM void jph_vs_free(void *vs) { delete static_cast<VehicleBuild *>(vs); }

// the most the body may pitch or roll (radians; pi: free) - Jolt keeps the vehicle's up inside that cone
JPH_SHIM void jph_vs_limit(void *vs, float max_pitch_roll) { static_cast<VehicleBuild *>(vs)->vs.mMaxPitchRollAngle = max_pitch_roll; }

// the engine: its most torque (N.m), idle and highest rpm, its inertia and damping, and n points (rpm / max_rpm, torque / max)
JPH_SHIM void jph_vs_engine(void *vs, float max_torque, float min_rpm, float max_rpm, float inertia, float damping, const float *curve, int n) {
  VehicleEngineSettings &e = static_cast<VehicleBuild *>(vs)->ctl->mEngine;
  e.mMaxTorque = max_torque;
  e.mMinRPM = min_rpm;
  e.mMaxRPM = max_rpm;
  e.mInertia = inertia;
  e.mAngularDamping = damping;
  e.mNormalizedTorque = curve_of(curve, n);
}

// the gearbox: n forward ratios, the reverse's (positive; stored negative as Jolt has it), auto (1) or manual (0), the
// time a change takes, the clutch's release and strength, and the rpm it changes up and down at
JPH_SHIM void jph_vs_gears(void *vs, const float *ratios, int n, float reverse, int automatic, float switch_time, float clutch_release,
                           float up_rpm, float down_rpm, float clutch_strength) {
  VehicleTransmissionSettings &t = static_cast<VehicleBuild *>(vs)->ctl->mTransmission;
  t.mMode = automatic != 0 ? ETransmissionMode::Auto : ETransmissionMode::Manual;
  t.mGearRatios.clear();
  for (int i = 0; i < n; i++) t.mGearRatios.push_back(ratios[i]);
  if (t.mGearRatios.empty()) t.mGearRatios.push_back(1.0f);
  t.mReverseGearRatios.clear();
  t.mReverseGearRatios.push_back(-std::abs(reverse));
  t.mSwitchTime = switch_time;
  t.mClutchReleaseTime = clutch_release;
  t.mSwitchLatency = switch_time;
  t.mShiftUpRPM = up_rpm;
  t.mShiftDownRPM = down_rpm;
  t.mClutchStrength = clutch_strength;
}

// a wheel at (x, y, z) in the body's space (the suspension's top), its radius and width, the suspension from min to max length
// down -y, its spring (mode 0: frequency in Hz and damping ratio; 1: stiffness N/m and damping N.s/m), the most it steers (radians),
// its brake and handbrake torques (N.m), its inertia and spin damping (dw/dt = -c w), and its friction curves: nlon points (slip ratio, friction) and nlat
// points (slip angle in degrees, friction). Returns the wheel's index
JPH_SHIM int jph_vs_wheel(void *vs, float x, float y, float z, float radius, float width, float min_len, float max_len, int spring_mode,
                          float k, float damping, float max_steer, float brake, float hand, float inertia, float spin_damping,
                          const float *lon, int nlon, const float *lat, int nlat) {
  VehicleBuild *b = static_cast<VehicleBuild *>(vs);
  WheelSettingsWV *w = new WheelSettingsWV();
  w->mPosition = Vec3(x, y, z);
  w->mSuspensionDirection = Vec3(0.0f, -1.0f, 0.0f);
  w->mSteeringAxis = Vec3(0.0f, 1.0f, 0.0f);
  w->mWheelUp = Vec3(0.0f, 1.0f, 0.0f);
  w->mWheelForward = Vec3(0.0f, 0.0f, 1.0f);
  w->mSuspensionMinLength = min_len;
  w->mSuspensionMaxLength = max_len > min_len ? max_len : min_len + 0.01f;
  w->mSuspensionSpring = SpringSettings(spring_mode == 1 ? ESpringMode::StiffnessAndDamping : ESpringMode::FrequencyAndDamping, k, damping);
  w->mRadius = radius;
  w->mWidth = width;
  w->mMaxSteerAngle = max_steer;
  w->mMaxBrakeTorque = brake;
  w->mMaxHandBrakeTorque = hand;
  w->mInertia = inertia;
  w->mAngularDamping = spin_damping;
  w->mLongitudinalFriction = curve_of(lon, nlon);
  w->mLateralFriction = curve_of(lat, nlat);
  b->vs.mWheels.push_back(w);
  return int(b->vs.mWheels.size()) - 1;
}

// a differential between two wheels (-1: none on that side): its ratio (the final drive), the left / right split, the limited
// slip ratio (0 or less: open) and the share of the engine's torque it takes
JPH_SHIM void jph_vs_diff(void *vs, int left, int right, float ratio, float split, float limited_slip, float torque_share) {
  VehicleDifferentialSettings d;
  d.mLeftWheel = left;
  d.mRightWheel = right;
  d.mDifferentialRatio = ratio;
  d.mLeftRightSplit = split;
  d.mLimitedSlipRatio = limited_slip > 1.0f ? limited_slip : FLT_MAX;
  d.mEngineTorqueRatio = torque_share;
  static_cast<VehicleBuild *>(vs)->ctl->mDifferentials.push_back(d);
}

// the limited slip between the differentials (0 or less: open)
JPH_SHIM void jph_vs_diff_lsd(void *vs, float ratio) { static_cast<VehicleBuild *>(vs)->ctl->mDifferentialLimitedSlipRatio = ratio > 1.0f ? ratio : FLT_MAX; }

// an anti-roll bar between two wheels, N/m
JPH_SHIM void jph_vs_bar(void *vs, int left, int right, float stiffness) {
  VehicleAntiRollBar a;
  a.mLeftWheel = left;
  a.mRightWheel = right;
  a.mStiffness = stiffness;
  static_cast<VehicleBuild *>(vs)->vs.mAntiRollBars.push_back(a);
}

// the vehicle on dynamic body `id`: the constraint made from the settings (which are freed here, used or not), its wheels cast as
// cylinders against the ground and the still things (a wheel does not climb another car: the bodies meet), added to the world and stepped with it. Null when there is no such
// dynamic body or no wheel
JPH_SHIM void *jph_vehicle_add(void *w, int id, void *vs) {
  World *ww = static_cast<World *>(w);
  VehicleBuild *b = static_cast<VehicleBuild *>(vs);
  if (b == nullptr) return nullptr;
  if (b->vs.mWheels.empty() || b->vs.mWheels.size() > 16) { delete b; return nullptr; }
  Vehicle *v = nullptr;
  {
    BodyLockWrite lock(ww->sys.GetBodyLockInterface(), bid(id));
    if (!lock.Succeeded() || !lock.GetBody().IsDynamic()) { delete b; return nullptr; }
    Body &body = lock.GetBody();
    v = new Vehicle();
    v->w = ww;
    v->body = body.GetID();
    v->c = new VehicleConstraint(body, b->vs);
    v->tester = new WheelCast(body.GetObjectLayer());
    v->tester->SetObjectLayerFilter(&v->ground);
    v->c->SetVehicleCollisionTester(v->tester);
    // a vehicle asleep (its body and every body under its wheels at rest) does not cast its wheels again: nothing it stands on moves
    // while nothing wakes it, and Jolt's simplified test keeps the last contacts (a body under a wheel taken away is let go). Jolt's
    // default casts every wheel every step even asleep: about 5 us a vehicle a step, a car park of parked cars a frame's budget
    v->c->SetNumStepsBetweenCollisionTestInactive(0);
    for (int i = 0; i < 16; i++) { v->grip[i] = 1.0f; v->steer[i] = 0.0f; }
    float rz = 0.0f;
    int nr = 0;
    for (uint i = 0; i < b->vs.mWheels.size(); i++) {
      const WheelSettingsWV *s = static_cast<const WheelSettingsWV *>(b->vs.mWheels[i].GetPtr());
      v->steer[i] = s->mMaxSteerAngle;
      if (s->mMaxSteerAngle == 0.0f) { rz += s->mPosition.GetZ(); nr++; }
    }
    v->rear_z = nr > 0 ? rz / float(nr) : 0.0f;
    // the tyre's own friction times the ground's grip under that wheel (the game's surface), not Jolt's mean with the body's; and the
    // friction circle Jolt leaves out: a wheel that spins or is locked (its slip ratio past the grip's peak) has little left across it,
    // so a pulled handbrake lets the rear come round and a wheel that grips again takes the car back
    float *grip = v->grip;
    VehicleConstraint *vc = v->c.GetPtr();
    v->c->SetCombineFriction([grip, vc](uint wheel, float &lon, float &lat, const Body &, const SubShapeID &) {
      float k = wheel < 16 ? grip[wheel] : 1.0f;
      lon *= k;
      lat *= k;
      const WheelWV *w = static_cast<const WheelWV *>(vc->GetWheels()[wheel]);
      float s = std::max(0.0f, std::abs(w->mLongitudinalSlip) - 0.1f) / 0.2f;
      lat *= std::max(0.25f, 1.0f / std::sqrt(1.0f + s * s));
    });
  }
  delete b;
  {
    VehicleAntiRollBars &bars = v->c->GetAntiRollBars();
    for (uint i = 0; i < bars.size() && i < 16; i++) v->bar_k[i] = bars[i].mStiffness;
    Vehicle *vv = v;
    v->c->SetPostCollideCallback([vv](VehicleConstraint &, const PhysicsStepListenerContext &ctx) { bars_in_newtons(vv, ctx.mDeltaTime); });
  }
  ww->sys.AddConstraint(v->c);
  ww->sys.AddStepListener(v->c);
  return v;
}

// out of the world and freed: before the body is removed
JPH_SHIM void jph_vehicle_free(void *vh) {
  Vehicle *v = static_cast<Vehicle *>(vh);
  if (v == nullptr) return;
  if (!v->kin) v->w->sys.RemoveStepListener(v->c);
  v->w->sys.RemoveConstraint(v->c);
  delete v;
}

// The vehicle's body made kinematic (on) or dynamic again (off): a car the game moves to a pose each frame (a traffic car near the
// player, driven by the traffic, not by its tyres) needs no wheel casts, no suspension, no gravity and no contacts with the ground and
// the still things (Jolt makes no pair of two bodies neither of which is dynamic), only its own against what is dynamic (a car rammed
// into it, a thrown body). Kinematic, the constraint is disabled and taken off the step listeners (VehicleConstraint::OnStep casts the
// wheels whatever its body's motion), its velocities zeroed; dynamic, both back, the body awake. As CARLA's hybrid physics turns a
// vehicle's simulation off away from the hero (and Chaos vehicles go to sleep: ChaosVehicleMovementComponent), here near the player
// too until something hits it. 1 when the state changed.
JPH_SHIM int jph_vehicle_kinematic(void *vh, int on) {
  Vehicle *v = static_cast<Vehicle *>(vh);
  if (v == nullptr) return 0;
  bool want = on != 0;
  if (v->kin == want) return 0;
  BodyInterface &bi = v->w->sys.GetBodyInterface();
  if (want) {
    v->w->sys.RemoveStepListener(v->c);
    v->c->SetEnabled(false);
    bi.SetMotionType(v->body, EMotionType::Kinematic, EActivation::Activate);
    bi.SetLinearAndAngularVelocity(v->body, Vec3::sZero(), Vec3::sZero());
  } else {
    bi.SetMotionType(v->body, EMotionType::Dynamic, EActivation::Activate);
    v->c->SetEnabled(true);
    v->w->sys.AddStepListener(v->c);
  }
  v->kin = want;
  return 1;
}


// the driver: forward -1..1 (negative: reverse), right -1..1, brake and handbrake 0..1. A body asleep is woken by a pedal or the wheel
JPH_SHIM void jph_vehicle_input(void *vh, float forward, float right, float brake, float hand) {
  Vehicle *v = static_cast<Vehicle *>(vh);
  WheeledVehicleController *ctl = static_cast<WheeledVehicleController *>(v->c->GetController());
  ackermann(v, right);
  ctl->SetDriverInput(forward, right, brake, hand);
  if (forward != 0.0f || right != 0.0f || brake != 0.0f)
    v->w->sys.GetBodyInterface().ActivateBody(v->body);
}

// the engine's most torque now (nitrous, a hurt engine): N.m
JPH_SHIM void jph_vehicle_torque(void *vh, float max_torque) {
  Vehicle *v = static_cast<Vehicle *>(vh);
  static_cast<WheeledVehicleController *>(v->c->GetController())->GetEngine().mMaxTorque = max_torque;
}

// the ground's grip under wheel i (a multiplier on the tyre's friction curves)
JPH_SHIM void jph_vehicle_grip(void *vh, int i, float k) {
  Vehicle *v = static_cast<Vehicle *>(vh);
  if (i >= 0 && i < 16) v->grip[i] = k;
}

// the engine and gearbox into out[4]: rpm, gear (negative reverse, 0 neutral), 1 while a gear changes, the clutch's friction
JPH_SHIM void jph_vehicle_read(void *vh, float *out) {
  Vehicle *v = static_cast<Vehicle *>(vh);
  const WheeledVehicleController *ctl = static_cast<const WheeledVehicleController *>(v->c->GetController());
  out[0] = ctl->GetEngine().GetCurrentRPM();
  out[1] = float(ctl->GetTransmission().GetCurrentGear());
  out[2] = ctl->GetTransmission().IsSwitchingGear() ? 1.0f : 0.0f;
  out[3] = ctl->GetTransmission().GetClutchFriction();
}

// wheel i into out[20]: contact (0/1), suspension length, steer angle (radians, Jolt's sign: positive left), rotation angle,
// angular velocity (rad/s), longitudinal slip, lateral slip (radians), the contact point (3) and normal (3), the wheel's world
// position (3) and rotation (x, y, z, w), the suspension's lambda (N.s over the step). -1 for a wheel it does not have
JPH_SHIM int jph_vehicle_wheel(void *vh, int i, float *out) {
  Vehicle *v = static_cast<Vehicle *>(vh);
  const Wheels &ws = v->c->GetWheels();
  if (i < 0 || i >= int(ws.size())) return -1;
  const WheelWV *w = static_cast<const WheelWV *>(ws[i]);
  bool on = w->HasContact();
  RMat44 t = v->c->GetWheelWorldTransform(uint(i), Vec3::sAxisX(), Vec3::sAxisY());
  RVec3 p = t.GetTranslation();
  Quat q = t.GetQuaternion();
  out[0] = on ? 1.0f : 0.0f;
  out[1] = w->GetSuspensionLength();
  out[2] = w->GetSteerAngle();
  out[3] = w->GetRotationAngle();
  out[4] = w->GetAngularVelocity();
  out[5] = w->mLongitudinalSlip;
  out[6] = w->mLateralSlip;
  RVec3 cp = on ? w->GetContactPosition() : p;
  Vec3 cn = on ? w->GetContactNormal() : Vec3::sAxisY();
  out[7] = float(cp.GetX()); out[8] = float(cp.GetY()); out[9] = float(cp.GetZ());
  out[10] = cn.GetX(); out[11] = cn.GetY(); out[12] = cn.GetZ();
  out[13] = float(p.GetX()); out[14] = float(p.GetY()); out[15] = float(p.GetZ());
  out[16] = q.GetX(); out[17] = q.GetY(); out[18] = q.GetZ(); out[19] = q.GetW();
  return 0;
}

// how many wheels it has
JPH_SHIM int jph_vehicle_wheels(void *vh) { return int(static_cast<Vehicle *>(vh)->c->GetWheels().size()); }

// a shape whose centre of mass is moved to (x, y, z) in its own space (a car's, low between its wheels); the inertia follows
JPH_SHIM void *jph_shape_com(void *s, float x, float y, float z) {
  Shape *sh = static_cast<Shape *>(s);
  Vec3 off = Vec3(x, y, z) - sh->GetCenterOfMass();
  return keep(OffsetCenterOfMassShapeSettings(off, sh).Create());
}

// the wheels, gearbox and engine matched to the body's motion: each wheel rolling at the body's forward speed, the forward gear the
// gearbox would be in at that speed (the lowest under its change-up rpm) with the clutch in, the engine at the rpm that gives. A
// vehicle made under a body already moving (a car handed over at speed) then drives on instead of starting in first with its wheels still
JPH_SHIM void jph_vehicle_sync(void *vh) {
  Vehicle *v = static_cast<Vehicle *>(vh);
  BodyInterface &bi = v->w->sys.GetBodyInterface();
  Vec3 lv = bi.GetRotation(v->body).Conjugated() * bi.GetLinearVelocity(v->body);
  float fwd = lv.GetZ();
  Wheels &ws = v->c->GetWheels();
  for (Wheel *w : ws) w->SetAngularVelocity(fwd / w->GetSettings()->mRadius);
  WheeledVehicleController *ctl = static_cast<WheeledVehicleController *>(v->c->GetController());
  VehicleTransmission &t = ctl->GetTransmission();
  const Array<VehicleDifferentialSettings> &ds = ctl->GetDifferentials();
  if (std::abs(fwd) < 1.0f || ds.empty() || t.mGearRatios.empty()) return;
  int wi = ds[0].mLeftWheel >= 0 ? ds[0].mLeftWheel : ds[0].mRightWheel;
  if (wi < 0 || wi >= int(ws.size())) return;
  float wheel_rpm = std::abs(fwd) / ws[wi]->GetSettings()->mRadius * 60.0f / (2.0f * JPH_PI) * ds[0].mDifferentialRatio;
  int gear = int(t.mGearRatios.size());
  float ratio = fwd > 0.0f ? t.mGearRatios.back() : std::abs(t.mReverseGearRatios[0]);
  if (fwd > 0.0f) {
    for (int g = 0; g < int(t.mGearRatios.size()); g++)
      if (wheel_rpm * t.mGearRatios[g] <= t.mShiftUpRPM) { gear = g + 1; ratio = t.mGearRatios[g]; break; }
  } else gear = -1;
  t.Set(gear, 1.0f);
  ctl->GetEngine().SetCurrentRPM(wheel_rpm * ratio);
}
