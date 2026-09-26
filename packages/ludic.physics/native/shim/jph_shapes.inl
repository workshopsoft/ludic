// jph_shapes.inl - shapes, each a handle the package keeps and frees; null when Jolt refused it

JPH_SHIM void *jph_shape_box(float hx, float hy, float hz) {
  return keep(BoxShapeSettings(Vec3(hx, hy, hz), 0.02f).Create());
}
JPH_SHIM void *jph_shape_sphere(float r) { return keep(SphereShapeSettings(r).Create()); }
JPH_SHIM void *jph_shape_capsule(float half_h, float r) { return keep(CapsuleShapeSettings(half_h, r).Create()); }
JPH_SHIM void *jph_shape_cylinder(float half_h, float r) {
  float cr = r < 0.05f ? r * 0.5f : 0.02f;
  return keep(CylinderShapeSettings(half_h, r, cr).Create());
}

// a dome r across and h tall standing on y = 0: the cap of a sphere whose centre is below
JPH_SHIM void *jph_shape_dome(float r, float h) {
  float big = (r * r + h * h) / (2.0f * h);
  RefConst<Shape> s = SphereShapeSettings(big).Create().Get();
  return keep(RotatedTranslatedShapeSettings(Vec3(0.0f, h - big, 0.0f), Quat::sIdentity(), s).Create());
}

// a shape moved and turned about y, inside its body
JPH_SHIM void *jph_shape_offset(void *s, float x, float y, float z, float yaw) {
  return keep(RotatedTranslatedShapeSettings(Vec3(x, y, z), yaw_q(yaw), static_cast<Shape *>(s)).Create());
}

// n x n heights (row z, column x) at ox, oz, cell metres apart; FLT_MAX is a hole
JPH_SHIM void *jph_shape_heightfield(const float *h, int n, float ox, float oz, float cell) {
  HeightFieldShapeSettings st(h, Vec3(ox, 0.0f, oz), Vec3(cell, 1.0f, cell), uint32(n));
  return keep(st.Create());
}

// a triangle mesh for a dock or a cabin: nv vertices (x, y, z) and nt triangles (i, j, k)
JPH_SHIM void *jph_shape_mesh(const float *v, int nv, const int *tri, int nt) {
  VertexList vs;
  vs.reserve(nv);
  for (int i = 0; i < nv; i++) vs.push_back(Float3(v[i * 3], v[i * 3 + 1], v[i * 3 + 2]));
  IndexedTriangleList ts;
  ts.reserve(nt);
  for (int i = 0; i < nt; i++) ts.push_back(IndexedTriangle(tri[i * 3], tri[i * 3 + 1], tri[i * 3 + 2]));
  return keep(MeshShapeSettings(vs, ts).Create());
}

JPH_SHIM void jph_shape_free(void *s) { if (s) static_cast<Shape *>(s)->Release(); }
