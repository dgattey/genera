//
//  GridShaders.metal
//  Genera
//
//  Created by Dylan Gattey on 10/28/20.
//

// Shades tiles in a grid, using a passed in color and vertex

#include <metal_stdlib>
#include <simd/simd.h>

// Including header shared between this Metal shader code and Swift/C code executing Metal API commands
#import "SharedShaderTypes.h"
#include "Util.h"

using namespace metal;

typedef struct {
    // The [[position]] attribute of this member indicates that this value
    // is the clip space position of the vertex when this structure is
    // returned from the vertex function.
    float4 position [[position]];
    
    // Since this member does not have a special attribute, the rasterizer
    // interpolates its value with the values of the other triangle vertices
    // and then passes the interpolated value to the fragment shader for each
    // fragment in the triangle.
    float4 color;
    
    // Sends a color position to the fragment function
    float2 colorPosition;

} ColoredVertex;

// This function creates color and position data for the vertices from viewport size
vertex ColoredVertex gridVertexShader(uint vertexID [[vertex_id]],
                                      constant float2 *positions [[buffer(ShaderIndexPositions)]],
                                      constant float4 *colors [[buffer(ShaderIndexColors)]],
                                      constant float4 *viewport [[buffer(ShaderIndexViewport)]]) {
    float2 pixelSpacePosition = positions[vertexID];
    float2 roundedPixelSpacePosition = round(pixelSpacePosition * 100) / 100;
    float2 viewportOrigin = float2((*viewport).x, (*viewport).y);
    float2 viewportSize = float2((*viewport).z, (*viewport).w);
    float x = (roundedPixelSpacePosition.x - viewportOrigin.x) / viewportSize.x;
    float y = (roundedPixelSpacePosition.y - viewportOrigin.y) / viewportSize.y;
    
    ColoredVertex out;
    out.position = vector_float4(x, y, 0.0, 1.0);
    out.color = colors[vertexID];
    out.colorPosition = positions[vertexID];
    return out;
}

// Use the defined color to set tile color - a bit of noise
fragment float4 gridFragmentShader(ColoredVertex in [[stage_in]]) {
    return in.color;
}

// Use the defined color to set tile color + a bit of rainbow :D
fragment float4 gridRainbowFragmentShader(ColoredVertex in [[stage_in]]) {
    float shadingR = simplexNoise(in.colorPosition * 0.0001);
    float shadingG = simplexNoise(in.colorPosition * 0.0001 + 1.0);
    float shadingB = simplexNoise(in.colorPosition * 0.0001 + 100.0);
    float r = .9 * in.color.r + shadingR * 0.1;
    float g = .9 * in.color.g + shadingG * 0.1;
    float b = .9 * in.color.b + shadingB * 0.1;
    return float4(r, g, b, 1.0);
}
