//
//  Shaders.metal
//  Genera
//
//  Created by Dylan Gattey on 10/28/20.
//

// File for Metal kernel and shader functions

#include <metal_stdlib>
#include <simd/simd.h>

// Including header shared between this Metal shader code and Swift/C code executing Metal API commands
#import "ShaderTypes.h"

using namespace metal;

typedef struct
{
    // The [[position]] attribute of this member indicates that this value
    // is the clip space position of the vertex when this structure is
    // returned from the vertex function.
    float4 position [[position]];
    
    // Since this member does not have a special attribute, the rasterizer
    // interpolates its value with the values of the other triangle vertices
    // and then passes the interpolated value to the fragment shader for each
    // fragment in the triangle.
    float4 color;

} ColoredVertex;

// This function creates color and position data for the vertices from viewport size
vertex ColoredVertex vertexShader(uint vertexID [[vertex_id]],
                                  constant float2 *positions [[buffer(VertexAttributePositions)]],
                                  constant float4 *colors [[buffer(VertexAttributeColors)]],
                                  constant float2 *viewportSize [[buffer(VertexAttributeViewportSize)]])
{
    ColoredVertex out;
    float2 pixelSpacePosition = positions[vertexID];
    // Normalize by dividing by half viewport size
    float x = pixelSpacePosition.x / (*viewportSize).x;
    float y = pixelSpacePosition.y / (*viewportSize).y;
    out.position = vector_float4(x, y, 0.0, 1.0);
    out.color = colors[vertexID];
    return out;
}

// Use the defined color to interpolate
fragment float4 fragmentShader(ColoredVertex in [[stage_in]])
{
    return in.color;
}
