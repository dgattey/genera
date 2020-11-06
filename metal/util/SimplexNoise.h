//
//  SimplexNoise.h
//  Genera
//
//  Created by Dylan Gattey on 11/3/20.
//

// Has all simplex noise functions defined (make sure the SimplexNoise.metal file includes these impls)

#ifndef SimplexNoise_h
#define SimplexNoise_h

/// Creates one value of simplex noise from a 2d point
float simplexNoise(float2 v);

/// Implements fractal Brownian motion with multiple octaves, persistence, and scale
float fractalBrownianMotion(float2 xy, int octaves, float persistence, float scale, float lowerBound, float upperBound);

#endif /* SimplexNoise_h */
