// GridShaders.metal
// Copyright (c) 2020 Dylan Gattey

// Shades tiles in a grid, using a passed in color and vertex

#import <metal_stdlib>
#import <simd/simd.h>
#import "ViewportData.h" // map renderer (engine), shaders
#import "GridShaderTypes.h" // Move into folder with this file
#import "SimplexNoise.h" // here, and all shaders (sharing between here and SimplexNoise is difficult)
#import "ShaderIndex.h" // map renderer (engine), shaders

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

} FragmentVertex;

// This function creates color and position data for the vertices from viewport size
vertex FragmentVertex gridVertexShader(uint vertexID [[vertex_id]],
                                       const device GridVertex *vertexArray [[buffer(ShaderIndexVertices)]],
                                       const device ViewportData *viewport [[buffer(ShaderIndexViewport)]]) {
    float2 position = vertexArray[vertexID].position;
    
    // Calculate with viewport applied
    float2 roundedPixelSpacePosition = round(position * 100) / 100;
    float x = (roundedPixelSpacePosition.x - (*viewport).origin.x) / (*viewport).size.x / (*viewport).scaleFactor.x;
    float y = (roundedPixelSpacePosition.y - (*viewport).origin.y) / (*viewport).size.y / (*viewport).scaleFactor.y;
    
    FragmentVertex out;
    out.position = vector_float4(x, y, 0.0, 1.0);
    out.color = vertexArray[vertexID].color;
    out.colorPosition = position;
    return out;
}

// Use the defined color to set tile color (flat)
fragment float4 gridFragmentShader(FragmentVertex in [[stage_in]]) {
    return in.color;
}

// Use the defined color to set tile color + a bit of rainbow :D
fragment float4 gridRainbowFragmentShader(FragmentVertex in [[stage_in]]) {
    float shadingR = simplexNoise(in.colorPosition * 0.00007);
    float shadingG = simplexNoise(in.colorPosition * 0.00006 + 1.0);
    float shadingB = simplexNoise(in.colorPosition * 0.00005 + 100.0);
    float r = .9 * in.color.r + shadingR * 0.1;
    float g = .9 * in.color.g + shadingG * 0.1;
    float b = .9 * in.color.b + shadingB * 0.1;
    return float4(r, g, b, 1.0);
}
