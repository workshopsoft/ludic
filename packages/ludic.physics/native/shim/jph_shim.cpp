// jph_shim.cpp - ludic.physics' door into Jolt Physics (phase 16). It keeps the shim rules of
// packages/README.md: int, long, float and opaque handles cross; no struct by value, no callback
// into Ludic - contacts are recorded during the step and drained after it; errors are return
// codes. Jolt's job threads stay in here.
#include <Jolt/Jolt.h>
#include <Jolt/RegisterTypes.h>
#include <Jolt/Core/Factory.h>
#include <Jolt/Core/TempAllocator.h>
#include <Jolt/Core/JobSystemThreadPool.h>
#include <Jolt/Physics/PhysicsSettings.h>
#include <Jolt/Physics/PhysicsSystem.h>
#include <Jolt/Physics/Collision/Shape/BoxShape.h>
#include <Jolt/Physics/Collision/Shape/SphereShape.h>
#include <Jolt/Physics/Collision/Shape/CapsuleShape.h>
#include <Jolt/Physics/Collision/Shape/CylinderShape.h>
#include <Jolt/Physics/Collision/Shape/HeightFieldShape.h>
#include <Jolt/Physics/Collision/Shape/MeshShape.h>
#include <Jolt/Physics/Collision/Shape/RotatedTranslatedShape.h>
#include <Jolt/Physics/Collision/Shape/ConvexHullShape.h>
#include <Jolt/Physics/Collision/Shape/ScaledShape.h>
#include <Jolt/Physics/Collision/RayCast.h>
#include <Jolt/Physics/Collision/CastResult.h>
#include <Jolt/Physics/Collision/ShapeCast.h>
#include <Jolt/Physics/Collision/CollideShape.h>
#include <Jolt/Physics/Collision/CollisionCollectorImpl.h>
#include <Jolt/Physics/Body/BodyCreationSettings.h>
#include <Jolt/Physics/Character/CharacterVirtual.h>
#include <Jolt/Physics/Body/BodyFilter.h>
#include <mutex>
#include <thread>
#include <cfloat>
#include <vector>
#include <cmath>
#include <algorithm>

#if defined(_WIN32)
#define JPH_SHIM extern "C" __declspec(dllexport)
#else
#define JPH_SHIM extern "C" __attribute__((visibility("default")))
#endif

using namespace JPH;

// ---- layers: the ground, the still things on it, and what moves --------------------------
namespace {
const ObjectLayer L_GROUND = 0, L_STATIC = 1, L_MOVING = 2, L_COUNT = 3;
const BroadPhaseLayer BP_STILL(0), BP_MOVING(1);

class BPLayers final : public BroadPhaseLayerInterface {
public:
  uint GetNumBroadPhaseLayers() const override { return 2; }
  BroadPhaseLayer GetBroadPhaseLayer(ObjectLayer l) const override { return l == L_MOVING ? BP_MOVING : BP_STILL; }
#if defined(JPH_EXTERNAL_PROFILE) || defined(JPH_PROFILE_ENABLED)
  const char *GetBroadPhaseLayerName(BroadPhaseLayer l) const override { return l == BP_MOVING ? "moving" : "still"; }
#endif
};
class ObjVsBP final : public ObjectVsBroadPhaseLayerFilter {
public:
  bool ShouldCollide(ObjectLayer l, BroadPhaseLayer bp) const override { return l == L_MOVING || bp == BP_MOVING; }
};
class ObjPairs final : public ObjectLayerPairFilter {
public:
  bool ShouldCollide(ObjectLayer a, ObjectLayer b) const override { return a == L_MOVING || b == L_MOVING; }
};
// a query's layers as a bit mask (1 ground, 2 static, 4 moving)
class MaskFilter final : public ObjectLayerFilter {
public:
  explicit MaskFilter(int m) : mask(m) {}
  bool ShouldCollide(ObjectLayer l) const override { return (mask >> l) & 1; }
  int mask;
};

// ---- contacts: recorded on Jolt's threads, drained on the game's -------------------------
const int C_CAP = 512;
struct Contact { uint32 a, b; float x, y, z, speed; };

class Contacts final : public ContactListener {
public:
  void OnContactAdded(const Body &b1, const Body &b2, const ContactManifold &m, ContactSettings &) override {
    Vec3 n = m.mWorldSpaceNormal;
    float speed = (b2.GetLinearVelocity() - b1.GetLinearVelocity()).Dot(n);
    RVec3 p = m.GetWorldSpaceContactPointOn1(0);
    std::lock_guard<std::mutex> g(lock);
    if (count >= C_CAP) { lost++; return; }
    items[count++] = { b1.GetID().GetIndexAndSequenceNumber(), b2.GetID().GetIndexAndSequenceNumber(),
                       float(p.GetX()), float(p.GetY()), float(p.GetZ()), std::abs(speed) };
  }
  std::mutex lock;
  Contact items[C_CAP];
  int count = 0;
  int lost = 0;
};

struct World {
  // pairs and contacts are for what MOVES: a valley of sixty thousand still trunks makes none
  // between them, so they are sized for the moving things, not the body count; the temporary memory
  // falls back to the heap rather than aborting a step. All four are the package's (phys_open)
  World(int max_bodies, int threads, int max_pairs, int max_contacts, int temp_kb)
      : temp(size_t(temp_kb) * 1024), jobs(cMaxPhysicsJobs, cMaxPhysicsBarriers, threads) {
    sys.Init(max_bodies, 0, max_pairs, max_contacts, bpl, ovb, olp);
    sys.SetContactListener(&contacts);
  }
  TempAllocatorImplWithMallocFallback temp;
  JobSystemThreadPool jobs;
  BPLayers bpl;
  ObjVsBP ovb;
  ObjPairs olp;
  PhysicsSystem sys;
  Contacts contacts;
};

bool g_ready = false;
BodyID bid(int id) { return BodyID(uint32(id)); }
Quat yaw_q(float yaw) { return Quat::sRotation(Vec3::sAxisY(), yaw); }
void *keep(const ShapeSettings::ShapeResult &r) {
  if (r.HasError()) return nullptr;
  Shape *s = const_cast<Shape *>(r.Get().GetPtr());
  s->AddRef();
  return s;
}
} // namespace

#include "jph_alloc.inl"

// Jolt's allocator (counted, jph_alloc.inl), factory and types, once per process; 0 when ready
JPH_SHIM int jph_init(void) {
  if (g_ready) return 0;
  heap_register();
  Factory::sInstance = new Factory();
  RegisterTypes();
  g_ready = true;
  return 0;
}

#include "jph_world.inl"
#include "jph_shapes.inl"
#include "jph_bodies.inl"
#include "jph_queries.inl"
#include "jph_character.inl"
