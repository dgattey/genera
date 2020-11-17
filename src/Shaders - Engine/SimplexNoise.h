// SimplexNoise.h
// Copyright (c) 2020 Dylan Gattey

// Has all simplex noise functions defined (make sure the SimplexNoise.metal file includes these impls)

#ifndef SimplexNoise_h
#define SimplexNoise_h

#import <simd/simd.h>
#import "FBMData.h"

/// Creates one value of simplex noise from a 2d point
float simplexNoise(vector_float2 v);

/// Implements fractal Brownian motion with multiple octaves, persistence, scale, frequency, and compression, with a seed in [0..<4096]
float fractalBrownianMotion(vector_float2 xy, struct FBMData data);

#endif /* SimplexNoise_h */
