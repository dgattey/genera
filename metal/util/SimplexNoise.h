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

/// Fractal Brownian Motion input data for use in shaders
struct FBMData {
    
    /// Octaves of noise to use
    int octaves;
    
    /// Amount to multiply amplitude by every iteration
    float persistence;
    
    /// Frequency of the noise
    float scale;
    
};

/// Creates one value of simplex noise from a 2d point
float simplexNoise(simd_float2 v);

/// Implements fractal Brownian motion with multiple octaves, persistence, and scale
float fractalBrownianMotion(simd_float2 xy, struct FBMData data, float lowerBound, float upperBound);

#endif /* SimplexNoise_h */
