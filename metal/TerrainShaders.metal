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
    float2 roundedPixelSpacePosition = round(position * 100) / 100;
    float2 viewportOrigin = float2((*viewport).x, (*viewport).y);
    float2 viewportSize = float2((*viewport).z, (*viewport).w);
    float x = (roundedPixelSpacePosition.x - viewportOrigin.x) / viewportSize.x;
    float y = (roundedPixelSpacePosition.y - viewportOrigin.y) / viewportSize.y;
    
    FragmentVertex out;
    out.position = float4(x, y, 0.0, 1.0);
    out.colorPosition = position;
    return out;
}

// Use some blended fractal brownian motion to generate a modulated color
fragment float4 terrainFragmentShader(FragmentVertex in [[stage_in]]) {
    float2 pos = float2(in.colorPosition.xy * 0.001);
    float3 color = float3(fractalBrownianMotion(pos), fractalBrownianMotion(pos - 2.0), fractalBrownianMotion(pos + 0.1));
    
    return float4(color, 1.0);
}
