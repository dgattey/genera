//
//  Util.h
//  Genera
//
//  Created by Dylan Gattey on 11/3/20.
//

// Has all util functions defined (make sure the Util.metal file includes these impls)

#ifndef Util_h
#define Util_h

/// Creates one value of simplex noise from a 2d point
float simplexNoise(float2 v);

/// Implements fractal Brownian motion with multiple octaves, persistence, and scale
float fractalBrownianMotion(float2 xy, int octaves, float persistence, float scale, float lowerBound, float upperBound);

/// Overload with float3s. Mixes base with the amount of color specified, clamping to 0 and 1 or specifed defaults
float3 clampedMix(float3 base, float3 color, float amount, float min = 0.0, float max = 1.0);

/// Overload with float3, and float for base. Mixes base with the amount of color specified, clamping to 0 and 1 or specifed defaults
float3 clampedMix(float base, float3 color, float amount, float min = 0.0, float max = 1.0);

/// Overload with float3, and float for color. Mixes base with the amount of color specified, clamping to 0 and 1 or specifed defaults
float3 clampedMix(float3 base, float color, float amount, float min = 0.0, float max = 1.0);

/// Mixes base with the amount of color specified, clamping to 0 and 1 or specifed defaults
float clampedMix(float base, float color, float amount, float min = 0.0, float max = 1.0);

#endif /* Util_h */
