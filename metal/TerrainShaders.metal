//
//  TerrainShaders.metal
//  Genera
//
//  Created by Dylan Gattey on 10/28/20.
//

// File for shading terrain

#include <metal_stdlib>
#include <simd/simd.h>

// Including header shared between this Metal shader code and Swift/C code executing Metal API commands + Utils
#import "SharedTypes.h"
#import "Util.h"

using namespace metal;

typedef struct {
    // The [[position]] attribute of this member indicates that this value
    // is the clip space position of the vertex when this structure is
    // returned from the vertex function.
    float4 position [[position]];
    
    // Need the non-transformed position for noise generation
    float2 colorPosition;
    
} FragmentVertex;

// This function creates color and position data for the vertices from viewport size
vertex FragmentVertex terrainVertexShader(uint vertexID [[vertex_id]],
                                          const device TerrainVertex *vertexArray [[buffer(ShaderIndexVertices)]],
                                          constant float4 *viewport [[buffer(ShaderIndexViewport)]]) {
    float2 position = vertexArray[vertexID].position;
    
    // Calculate with viewport applied
    float2 viewportOrigin = float2((*viewport).x, (*viewport).y);
    float2 viewportSize = float2((*viewport).z, (*viewport).w);
    float x = (position.x - viewportOrigin.x) / viewportSize.x;
    float y = (position.y - viewportOrigin.y) / viewportSize.y;
    
    FragmentVertex out;
    out.position = float4(x, y, 0.0, 1.0);
    out.colorPosition = position;
    return out;
}

// Overloaded with float3s. Mixes base with the amount of color specified, clamping to 0 and 1 or specifed defaults
float3 clampedMix(float3 base, float3 color, float amount, float min = 0.0, float max = 1.0) {
    return float3(clampedMix(base, color, amount, min, max));
}

// Overloaded with float3, and float for base. Mixes base with the amount of color specified, clamping to 0 and 1 or specifed defaults
float3 clampedMix(float base, float3 color, float amount, float min = 0.0, float max = 1.0) {
    return float3(clampedMix(float3(base), color, amount, min, max));
}

// Overloaded with float3, and float for color. Mixes base with the amount of color specified, clamping to 0 and 1 or specifed defaults
float3 clampedMix(float3 base, float color, float amount, float min = 0.0, float max = 1.0) {
    return float3(clampedMix(color, float3(base), amount, min, max));
}

// Mixes base with the amount of color specified, clamping to 0 and 1 or specifed defaults
float clampedMix(float base, float color, float amount, float min = 0.0, float max = 1.0) {
    float mixed = base + color * amount;
    float returned = metal::max(min, metal::min(max, mixed));
    return returned;
}

// Use some blended fractal brownian motion to generate a modulated color
fragment float4 terrainFragmentShader(FragmentVertex in [[stage_in]]) {
    float2 pos = float2(in.colorPosition.xy) * 0.0001;
    float3 color = float3(fractalBrownianMotion(pos), fractalBrownianMotion(pos - 20.0), fractalBrownianMotion(pos + 0.791));
    
    if (color.r > 0.8 && color.g > 0.6) {
        // "Sandy" color
        return float4(clampedMix(0.7, color.r, 0.4), clampedMix(0.7, color.g, 0.4), color.b, 1.0);
    } else if (color.r > 0.8 || color.g > 0.8) {
        // "Ice" color
        float3 mixed = clampedMix(0.97, color.b, 0.3);
        return float4(mixed, 1.0);
    } else if (color.b > 0.5) {
        // "Water" color
        float mixed = clampedMix(0.4, color.b, 0.3, 0.5, 0.8);
        return float4(0.2, 0.3, mixed, 1.0);
    }
    return float4(color, 1.0);
}
