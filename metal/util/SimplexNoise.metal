//
//  SimplexNoise.metal
//  Genera
//
//  Created by Dylan Gattey on 11/2/20.
//

// Has all simplex noise functions defined (make sure the SimplexNoise.h file includes these defs)

#include <metal_stdlib>
#include <simd/simd.h>
#include "SimplexNoise.h"

using namespace metal;

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
float simplexNoise(float2 v) {
    
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

/// Implements fractal Brownian motion with multiple octaves, persistence, and scale
float fractalBrownianMotion(float2 xy, int octaves, float persistence, float scale, float lowerBound, float upperBound) {
    float maxAmp = 0;
    float amp = 1;
    float freq = scale;
    float noise = 0;
    for(int i = 0; i < octaves; ++i)
    {
        noise += simplexNoise(xy * freq) * amp;
        freq *= 2;
        maxAmp += amp;
        amp *= persistence;
    }
    noise /= maxAmp;
    return noise * (upperBound - lowerBound) / 2 + (upperBound + lowerBound) / 2;
}
