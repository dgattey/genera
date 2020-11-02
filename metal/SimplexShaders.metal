//
//  SimplexShaders.metal
//  Genera
//
//  Created by Dylan Gattey on 10/28/20.
//

// File for Metal kernel and shader functions

#include <metal_stdlib>
#include <simd/simd.h>

// Including header shared between this Metal shader code and Swift/C code executing Metal API commands
#import "SimpleShaderTypes.h"

using namespace metal;

typedef float2 u_resolution;
typedef float2 u_mouse;
typedef float u_time;

float3 mod289(float3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
float2 mod289(float2 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
float3 permute(float3 x) { return mod289(((x*34.0)+1.0)*x); }

//
// Description : GLSL 2D simplex noise function
//      Author : Ian McEwan, Ashima Arts
//  Maintainer : ijm
//     Lastmod : 20110822 (ijm)
//     License :
//  Copyright (C) 2011 Ashima Arts. All rights reserved.
//  Distributed under the MIT License. See LICENSE file.
//  https://github.com/ashima/webgl-noise
//
float snoise(float2 v) {
    
    // Precompute values for skewed triangular grid
    const float4 C = float4(0.211324865405187,
                                          // (3.0-sqrt(3.0))/6.0
                                          0.366025403784439,
                                          // 0.5*(sqrt(3.0)-1.0)
                                          -0.577350269189626,
                                          // -1.0 + 2.0 * C.x
                                          0.024390243902439);
                                          // 1.0 / 41.0
    
    // First corner (x0)
    float2 i  = floor(v + dot(v, C.yy));
    float2 x0 = v - i + dot(i, C.xx);
    
    // Other two corners (x1, x2)
    float2 i1 = float2(0.0);
    i1 = (x0.x > x0.y)? float2(1.0, 0.0):float2(0.0, 1.0);
    float2 x1 = x0.xy + C.xx - i1;
    float2 x2 = x0.xy + C.zz;
    
    // Do some permutations to avoid
    // truncation effects in permutation
    i = mod289(i);
    float3 p = permute(
                     permute( i.y + float3(0.0, i1.y, 1.0))
                     + i.x + float3(0.0, i1.x, 1.0 ));
    
    float3 m = max(0.5 - float3(
                            dot(x0,x0),
                            dot(x1,x1),
                            dot(x2,x2)
                            ), 0.0);
    
    m = m*m ;
    m = m*m ;
    
    // Gradients:
    //  41 pts uniformly over a line, mapped onto a diamond
    //  The ring size 17*17 = 289 is close to a multiple
    //      of 41 (41*7 = 287)
    
    float3 x = 2.0 * fract(p * C.www) - 1.0;
    float3 h = abs(x) - 0.5;
    float3 ox = floor(x + 0.5);
    float3 a0 = x - ox;
    
    // Normalise gradients implicitly by scaling m
    // Approximation of: m *= inversesqrt(a0*a0 + h*h);
    m *= 1.79284291400159 - 0.85373472095314 * (a0*a0+h*h);
    
    // Compute final noise value at P
    float3 g = float3(0.0);
    g.x  = a0.x  * x0.x  + h.x  * x0.y;
    g.yz = a0.yz * float2(x1.x,x2.x) + h.yz * float2(x1.y,x2.y);
    return 130.0 * dot(m, g);
}

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
    float4 color [[flat]];
    
} ColoredVertex;

// This function creates color and position data for the vertices from viewport size
vertex ColoredVertex simplexVertexShader(uint vertexID [[vertex_id]],
                                        constant float2 *positions [[buffer(SimpleShaderIndexPositions)]],
                                        constant float4 *colors [[buffer(SimpleShaderIndexColors)]],
                                        constant float4 *viewport [[buffer(SimpleShaderIndexViewport)]])
{
    float2 pixelSpacePosition = positions[vertexID];
    float2 roundedPixelSpacePosition = round(pixelSpacePosition * 100) / 100;
    float2 viewportOrigin = float2((*viewport).x, (*viewport).y);
    float2 viewportSize = float2((*viewport).z, (*viewport).w);
    float x = (roundedPixelSpacePosition.x - viewportOrigin.x) / viewportSize.x;
    float y = (roundedPixelSpacePosition.y - viewportOrigin.y) / viewportSize.y;
    
    ColoredVertex out;
    out.position = float4(x, y, 0.0, 1.0);
    
    float2 pos = float2(pixelSpacePosition * 0.00008 * 7.168);
    float DF = 1.288;
    
    // Add a random position
    float a = .0;
    float2 vel = float2(0.070,0.140);
    DF += snoise(pos+vel)*-0.710+0.290;
    
    // Add a random position
    a = snoise(pos*float2(cos(0.958),sin(0.300))*-0.044)*0.029;
    vel = float2(cos(a),sin(a));
    DF += snoise(pos+vel)*-0.046+0.378;
    
    float3 color = smoothstep(0.260,0.094,fract(DF));
    
    out.color = float4(1.0 - color, 1.0);
    return out;
}

// Use the defined color to set tile color
fragment float4 simplexFragmentShader(ColoredVertex in [[stage_in]])
{
    return in.color;
}
