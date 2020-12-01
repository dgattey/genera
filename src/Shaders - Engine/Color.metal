// Color.metal
// Copyright (c) 2020 Dylan Gattey

// Has all color functions defined (make sure the Color.h file includes these defs)

#import <metal_stdlib>
#import <simd/simd.h>
#import "Color.h"

using namespace metal;

/// Overload with float3s. Mixes base with the amount of color specified, clamping to 0 and 1 or specifed defaults
float3 mixColors(float3 base, float3 color, float amount, float min, float max) {
    return float3(mixColors(base, color, amount, min, max));
}

/// Overload with float3, and float for base. Mixes base with the amount of color specified, clamping to 0 and 1 or specifed defaults
float3 mixColors(float base, float3 color, float amount, float min, float max) {
    return float3(mixColors(float3(base), color, amount, min, max));
}

/// Overload with float3, and float for color. Mixes base with the amount of color specified, clamping to 0 and 1 or specifed defaults
float3 mixColors(float3 base, float color, float amount, float min, float max) {
    return float3(mixColors(color, float3(base), amount, min, max));
}

/// Mixes base with the amount of color specified, clamping to 0 and 1 or specifed defaults
float mixColors(float base, float color, float amount, float min, float max) {
    float mixed = base + color * amount;
    float returned = metal::max(min, metal::min(max, mixed));
    return returned;
}
