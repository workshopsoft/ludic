// vk_triangle.slang — the first thing Ludic draws through Vulkan's graphics pipeline: three
// corners with no vertex buffer and a colour each, the rasteriser blending between them.
// The corner comes from SV_VulkanVertexID (gl_VertexIndex as it is): Slang compiles SV_VertexID
// to gl_VertexIndex - gl_BaseVertex, which needs the draw-parameters capability.
//   slangc vk_triangle.slang -target spirv -profile spirv_1_5 -entry vsMain -stage vertex -o vk_triangle_vs.spv
//   slangc vk_triangle.slang -target spirv -profile spirv_1_5 -entry fsMain -stage fragment -o vk_triangle_fs.spv

struct VOut
{
    float4 pos : SV_Position;
    float3 col : COLOR;
};

[shader("vertex")]
VOut vsMain(uint id : SV_VulkanVertexID)
{
    // Vulkan's clip space has y pointing down, so the apex is at -y
    static const float2 corners[3] = { float2(0.0, -0.6), float2(0.6, 0.6), float2(-0.6, 0.6) };
    static const float3 colours[3] = { float3(1.0, 0.25, 0.1), float3(0.1, 1.0, 0.3), float3(0.2, 0.35, 1.0) };
    VOut o;
    o.pos = float4(corners[id], 0.0, 1.0);
    o.col = colours[id];
    return o;
}

[shader("fragment")]
float4 fsMain(VOut i) : SV_Target
{
    return float4(i.col, 1.0);
}
