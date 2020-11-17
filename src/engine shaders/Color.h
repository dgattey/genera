// Color.h
// Copyright (c) 2020 Dylan Gattey

// Has all color functions defined (make sure the Color.metal file includes these impls)

#ifndef Color_h
#define Color_h

#import <simd/simd.h>

/// Overload with float3s. Mixes base with the amount of color specified, clamping to 0 and 1 or specifed defaults
float3 mixColors(float3 base, float3 color, float amount, float min = 0.0, float max = 1.0);

/// Overload with float3, and float for base. Mixes base with the amount of color specified, clamping to 0 and 1 or specifed defaults
float3 mixColors(float base, float3 color, float amount, float min = 0.0, float max = 1.0);

/// Overload with float3, and float for color. Mixes base with the amount of color specified, clamping to 0 and 1 or specifed defaults
float3 mixColors(float3 base, float color, float amount, float min = 0.0, float max = 1.0);

/// Mixes base with the amount of color specified, clamping to 0 and 1 or specifed defaults
float mixColors(float base, float color, float amount, float min = 0.0, float max = 1.0);

#endif /* Color_h */
