//
//  SimplexNoise.h
//  Genera
//
//  Created by Dylan Gattey on 11/3/20.
//

// Has all simplex noise functions defined (make sure the SimplexNoise.metal file includes these impls)

#ifndef SimplexNoise_h
#define SimplexNoise_h

#include <simd/simd.h>
#import "../NSEnum.h"

/// Fractal Brownian Motion input data for use in shaders (will always output 0-1 range
/// but changing `compression` will change how closely those values are distributed within
/// that range.
struct FBMData {
    
    /// Octaves of noise to use
    int octaves;
    
    /// Amount to multiply amplitude by every iteration
    float persistence;
    
    /// Frequency of the noise at the beginning
    float scale;
    
    /// How closely the values are distributed around 0-1
    float compression;
    
    /// A seed to use in generating random offset
    uint seed;
};

/// Creates one value of simplex noise from a 2d point
float simplexNoise(simd_float2 v);

/// Implements fractal Brownian motion with multiple octaves, persistence, scale, frequency, and compression, with a seed in [0..<4096]
float fractalBrownianMotion(simd_float2 xy, struct FBMData data);

#endif /* SimplexNoise_h */
