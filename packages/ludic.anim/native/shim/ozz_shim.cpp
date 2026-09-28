// ozz_shim.cpp - ludic.anim's door into ozz-animation (phase 19). It keeps the shim rules of
// packages/README.md: int, float and opaque handles cross; no struct by value, no callback into
// Ludic; errors are a null handle or a 0. A skeleton and a clip are built at load from the numbers
// the package already holds (a skin's parents and rest pose, a clip's flattened channels); what a
// frame needs is made once per actor (a context) and reused.
#include "ozz/animation/offline/raw_skeleton.h"
#include "ozz/animation/offline/skeleton_builder.h"
#include "ozz/animation/offline/raw_animation.h"
#include "ozz/animation/offline/animation_builder.h"
#include "ozz/animation/runtime/skeleton.h"
#include "ozz/animation/runtime/animation.h"
#include "ozz/animation/runtime/sampling_job.h"
#include "ozz/base/maths/soa_transform.h"
#include "ozz/base/maths/simd_math.h"
#include <cstdlib>
#include <string>
#include <vector>

#if defined(_WIN32)
#define OZZ_SHIM extern "C" __declspec(dllexport)
#else
#define OZZ_SHIM extern "C" __attribute__((visibility("default")))
#endif

namespace oa = ozz::animation;
namespace off = ozz::animation::offline;

// a skeleton, and the map between its joints (ozz orders them depth first) and the file's nodes
struct Skel {
  ozz::unique_ptr<oa::Skeleton> s;
  std::vector<int> node_of;   // per joint: the file's node
  std::vector<int> joint_of;  // per node: its joint, -1 for none
  std::vector<float> rest;    // per node: t3 r4 s3, what a joint no channel moves holds
};
struct Clip {
  ozz::unique_ptr<oa::Animation> a;
  float dur;
};
struct Ctx {
  const Skel *sk;
  oa::SamplingJob::Context ctx;
  std::vector<ozz::math::SoaTransform> locals;
};

static void add_children(off::RawSkeleton::Joint &j, int node, int n, const int *par, const float *rest) {
  j.name = std::to_string(node).c_str();
  const float *r = rest + node * 10;
  j.transform.translation = ozz::math::Float3(r[0], r[1], r[2]);
  j.transform.rotation = ozz::math::Quaternion(r[3], r[4], r[5], r[6]);
  j.transform.scale = ozz::math::Float3(r[7], r[8], r[9]);
  for (int c = 0; c < n; c++) {
    if (par[c] != node) continue;
    j.children.emplace_back();
    add_children(j.children.back(), c, n, par, rest);
  }
}

// n nodes, each's parent (-1 a root, -2 not in this skeleton) and rest pose (10 floats: translation, rotation x y z w, scale)
OZZ_SHIM void *ozz_skel_new(int n, const int *par, const float *rest) {
  if (n <= 0 || n > oa::Skeleton::kMaxJoints) return nullptr;
  off::RawSkeleton raw;
  for (int i = 0; i < n; i++) {
    if (par[i] != -1) continue;
    raw.roots.emplace_back();
    add_children(raw.roots.back(), i, n, par, rest);
  }
  if (!raw.Validate()) return nullptr;
  off::SkeletonBuilder build;
  Skel *sk = new Skel();
  sk->s = build(raw);
  if (!sk->s) { delete sk; return nullptr; }
  int nj = sk->s->num_joints();
  sk->node_of.assign(nj, -1);
  sk->joint_of.assign(n, -1);
  auto names = sk->s->joint_names();
  for (int j = 0; j < nj; j++) {
    int node = std::atoi(names[j]);
    sk->node_of[j] = node;
    sk->joint_of[node] = j;
  }
  sk->rest.assign(rest, rest + n * 10);
  return sk;
}
OZZ_SHIM void ozz_skel_free(void *p) { delete static_cast<Skel *>(p); }
OZZ_SHIM int ozz_skel_joints(void *p) { return p ? static_cast<Skel *>(p)->s->num_joints() : 0; }
OZZ_SHIM int ozz_skel_joint_of(void *p, int node) {
  Skel *sk = static_cast<Skel *>(p);
  if (!sk || node < 0 || node >= (int)sk->joint_of.size()) return -1;
  return sk->joint_of[node];
}

static float clampt(float t, float dur) { return t < 0.f ? 0.f : (t > dur ? dur : t); }

// a clip from ludic.anim's flattened channels (clip.ludic): a channel's keys are
// times[coff .. coff + ckeys], its values 4 (rotation, path 0) or 3 (translation, path 1) from
// cvoff; translations only when `positions`. A joint no channel moves holds its rest pose.
OZZ_SHIM void *ozz_clip_new(void *skp, float dur, int nch, const int *cnode, const int *cpath, const int *ckeys,
                            const int *coff, const int *cvoff, const float *times, const float *vals, int positions) {
  Skel *sk = static_cast<Skel *>(skp);
  if (!sk) return nullptr;
  off::RawAnimation raw;
  raw.duration = dur > 0.0001f ? dur : 0.0001f;
  int nj = sk->s->num_joints();
  raw.tracks.resize(nj);
  for (int ch = 0; ch < nch; ch++) {
    int node = cnode[ch];
    if (node < 0 || node >= (int)sk->joint_of.size() || sk->joint_of[node] < 0) continue;
    auto &tr = raw.tracks[sk->joint_of[node]];
    const float *v = vals + cvoff[ch];
    for (int k = 0; k < ckeys[ch]; k++) {
      float t = clampt(times[coff[ch] + k], raw.duration);
      if (k > 0 && t <= times[coff[ch] + k - 1] && t < raw.duration) continue;
      if (cpath[ch] == 0) {
        const float *q = v + k * 4;
        tr.rotations.push_back({t, ozz::math::Quaternion(q[0], q[1], q[2], q[3])});
      } else if (positions) {
        const float *p = v + k * 3;
        tr.translations.push_back({t, ozz::math::Float3(p[0], p[1], p[2])});
      }
    }
  }
  for (int j = 0; j < nj; j++) {
    auto &tr = raw.tracks[j];
    const float *r = &sk->rest[sk->node_of[j] * 10];
    if (tr.translations.empty()) tr.translations.push_back({0.f, ozz::math::Float3(r[0], r[1], r[2])});
    if (tr.rotations.empty()) tr.rotations.push_back({0.f, ozz::math::Quaternion(r[3], r[4], r[5], r[6])});
    if (tr.scales.empty()) tr.scales.push_back({0.f, ozz::math::Float3(r[7], r[8], r[9])});
  }
  if (!raw.Validate()) return nullptr;
  off::AnimationBuilder build;
  Clip *c = new Clip();
  c->a = build(raw);
  if (!c->a) { delete c; return nullptr; }
  c->dur = raw.duration;
  return c;
}
OZZ_SHIM void ozz_clip_free(void *p) { delete static_cast<Clip *>(p); }
OZZ_SHIM int ozz_clip_bytes(void *p) { return p ? (int)static_cast<Clip *>(p)->a->size() : 0; }

// what one actor samples with, made once
OZZ_SHIM void *ozz_ctx_new(void *skp) {
  Skel *sk = static_cast<Skel *>(skp);
  if (!sk) return nullptr;
  Ctx *c = new Ctx();
  c->sk = sk;
  c->ctx.Resize(sk->s->num_joints());
  c->locals.resize(sk->s->num_soa_joints());
  return c;
}
OZZ_SHIM void ozz_ctx_free(void *p) { delete static_cast<Ctx *>(p); }

// clip at t seconds (wrapped on its duration), each joint's local rotation (4 per node) and
// translation (3 per node) written at its FILE node, into the caller's buffers of n nodes
OZZ_SHIM int ozz_sample(void *cp, void *clp, float t, float *rot, float *pos, int n) {
  Ctx *c = static_cast<Ctx *>(cp);
  Clip *cl = static_cast<Clip *>(clp);
  if (!c || !cl) return 0;
  float tt = t;
  if (cl->dur > 0.f) { tt = std::fmod(t, cl->dur); if (tt < 0.f) tt += cl->dur; }
  oa::SamplingJob job;
  job.animation = cl->a.get();
  job.context = &c->ctx;
  job.ratio = tt / cl->dur;
  job.output = ozz::make_span(c->locals);
  if (!job.Run()) return 0;
  const Skel *sk = c->sk;
  int nj = sk->s->num_joints();
  float lane[4][10];
  for (int s = 0; s * 4 < nj; s++) {
    const ozz::math::SoaTransform &x = c->locals[s];
    ozz::math::SimdFloat4 comp[7] = {x.translation.x, x.translation.y, x.translation.z,
                                     x.rotation.x, x.rotation.y, x.rotation.z, x.rotation.w};
    for (int k = 0; k < 7; k++) {
      float v[4];
      ozz::math::StorePtrU(comp[k], v);
      for (int l = 0; l < 4; l++) lane[l][k] = v[l];
    }
    for (int l = 0; l < 4 && s * 4 + l < nj; l++) {
      int node = sk->node_of[s * 4 + l];
      if (node < 0 || node >= n) continue;
      for (int k = 0; k < 3; k++) pos[node * 3 + k] = lane[l][k];
      for (int k = 0; k < 4; k++) rot[node * 4 + k] = lane[l][3 + k];
    }
  }
  return 1;
}
