// vk_compute.slang — the first Slang shader Ludic runs: a compute pass that writes a
// picture into a storage buffer the CPU reads back. RGBA8 packed into one uint per
// pixel, so the result needs no image, no staging copy and no format conversion.
//   slangc vk_compute.slang -target spirv -profile spirv_1_5 -entry main -stage compute -o vk_compute.spv

[[vk::binding(0, 0)]] RWStructuredBuffer<uint> pixels;

struct Params
{
    float time;
    uint width;
    uint height;
};
[[vk::push_constant]] ConstantBuffer<Params> params;

uint pack(float3 c)
{
    uint3 b = uint3(saturate(c) * 255.0 + 0.5);
    return b.r | (b.g << 8) | (b.b << 16) | (255u << 24);
}

[shader("compute")]
[numthreads(16, 16, 1)]
void main(uint3 id : SV_DispatchThreadID)
{
    if (id.x >= params.width || id.y >= params.height)
        return;
    float2 uv = (float2(id.xy) + 0.5) / float2(params.width, params.height);
    // a sky over a ridge line, so a wrong row order or a swapped channel is obvious
    float ridge = 0.55 + 0.08 * sin(uv.x * 9.0 + params.time) + 0.04 * sin(uv.x * 23.0);
    float3 sky = lerp(float3(0.95, 0.72, 0.45), float3(0.20, 0.35, 0.65), uv.y / ridge);
    float3 ground = lerp(float3(0.18, 0.28, 0.14), float3(0.08, 0.12, 0.07), (uv.y - ridge) / (1.0 - ridge));
    float3 c = uv.y < ridge ? sky : ground;
    pixels[id.y * params.width + id.x] = pack(c);
}
