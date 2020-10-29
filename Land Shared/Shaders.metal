//
//  Shaders.metal
//  Land Shared
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
    vector_float2 position;
    vector_float4 color;
} Vertex;

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

} RasterizerData;

// This function creates color and position data for the vertices from viewport size
vertex RasterizerData
vertexShader(uint vertexID [[vertex_id]],
             constant Vertex *vertices [[buffer(VertexAttributeVertices)]],
             constant vector_uint2 *viewportSizePointer [[buffer(VertexAttributeViewportSize)]])
{
    RasterizerData out;
    vector_float2 viewportSize = vector_float2(*viewportSizePointer);
    
    // Normalize by dividing by half viewport size (and these are SIMD types so
    // they can be divided all at once).
    float2 pixelSpacePosition = vertices[vertexID].position.xy;
    out.position = vector_float4(0.0, 0.0, 0.0, 1.0);
    out.position.xy = pixelSpacePosition / (viewportSize / 2.0);
    
    // Just set color to be whatever it was passed in as
    out.color = vertices[vertexID].color;
    
    return out;
}

// Just use interpolation between the colors already defined
fragment float4 fragmentShader(RasterizerData in [[stage_in]])
{
    return in.color;
}
