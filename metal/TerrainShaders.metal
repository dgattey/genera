//
//  TerrainShaders.metal
//  Genera
//
//  Created by Dylan Gattey on 10/28/20.
//

// File for shading terrain

#include <metal_stdlib>
#include <simd/simd.h>

// Including header shared between this Metal shader code and Swift/C code executing Metal API commands + Utils
#import "SharedTypes.h"
#import "Util.h"

using namespace metal;

typedef struct {
    // The [[position]] attribute of this member indicates that this value
    // is the clip space position of the vertex when this structure is
    // returned from the vertex function.
    float4 position [[position]];
    
    // Need the non-transformed position for noise generation
    float2 colorPosition;
    
} FragmentVertex;

// This function creates color and position data for the vertices from viewport size
vertex FragmentVertex terrainVertexShader(uint vertexID [[vertex_id]],
                                          const device TerrainVertex *vertexArray [[buffer(ShaderIndexVertices)]],
                                          constant float4 *viewport [[buffer(ShaderIndexViewport)]]) {
    float2 position = vertexArray[vertexID].position;
    
    // Calculate with viewport applied
    float2 viewportOrigin = float2((*viewport).x, (*viewport).y);
    float2 viewportSize = float2((*viewport).z, (*viewport).w);
    float x = (position.x - viewportOrigin.x) / viewportSize.x;
    float y = (position.y - viewportOrigin.y) / viewportSize.y;
    
    FragmentVertex out;
    out.position = float4(x, y, 0.0, 1.0);
    out.colorPosition = position;
    return out;
}

// Overloaded with float3s. Mixes base with the amount of color specified, clamping to 0 and 1 or specifed defaults
float3 clampedMix(float3 base, float3 color, float amount, float min = 0.0, float max = 1.0) {
    return float3(clampedMix(base, color, amount, min, max));
}

// Overloaded with float3, and float for base. Mixes base with the amount of color specified, clamping to 0 and 1 or specifed defaults
float3 clampedMix(float base, float3 color, float amount, float min = 0.0, float max = 1.0) {
    return float3(clampedMix(float3(base), color, amount, min, max));
}

// Overloaded with float3, and float for color. Mixes base with the amount of color specified, clamping to 0 and 1 or specifed defaults
float3 clampedMix(float3 base, float color, float amount, float min = 0.0, float max = 1.0) {
    return float3(clampedMix(color, float3(base), amount, min, max));
}

// Mixes base with the amount of color specified, clamping to 0 and 1 or specifed defaults
float clampedMix(float base, float color, float amount, float min = 0.0, float max = 1.0) {
    float mixed = base + color * amount;
    float returned = metal::max(min, metal::min(max, mixed));
    return returned;
}

constant float3 ice = float3(.95, .95, .94);
constant float iceH = .92;
constant float3 mtn = float3(.3, .34, .2);
constant float mtnH = .76;
constant float3 grass = float3(.1, .55, .14);
constant float grassH = .4;
constant float3 sand = float3(.7, .7, .1);
constant float sandH = .35;
constant float3 water = float3(.1, .1, .42);
constant float waterH = .22;
constant float3 deepwater = float3(.1, .1, .3);
constant float blendThreshold = .08;
constant float variationAmount = .1;

float4 color(float3 base, float3 vars) {
    float colorR = clampedMix(base.r, vars.r, variationAmount);
    float colorG = clampedMix(base.g, vars.g, variationAmount);
    float colorB = clampedMix(base.b, vars.b, variationAmount);
    return float4(colorR, colorG, colorB, 1.0);
}

float4 blendColors(float3 color1, float3 color2, float threshold, float height, float3 vars, float blendSize = blendThreshold) {
    float4 a = color(color1, vars);
    float4 b = color(color2, vars);
    float percentOfThreshold = (threshold - height + blendSize)/blendSize - 0.5 * blendSize;
    return mix(a, b, max(min(percentOfThreshold, 1.0), 0.0));
}

float3 variations(float2 xy, float height) {
    float2 varPos = xy * .0001;
    float amtHeight = 0.78;
    float var1 = mix(fractalBrownianMotion(varPos + 17.4), height, amtHeight);
    float var2 = mix(fractalBrownianMotion(varPos + 71.), height, amtHeight);
    float var3 = mix(fractalBrownianMotion(varPos + 27.2), height, amtHeight);
    return float3(var1, var2, var3);
}

// Use some blended fractal brownian motion to generate a modulated color
fragment float4 terrainFragmentShader(FragmentVertex in [[stage_in]]) {
    float2 pos = float2(in.colorPosition.xy) * 0.0001;
    float height = fractalBrownianMotion(pos);
    float3 vars = variations(in.colorPosition, height);
    
    if (height > iceH) {
        return blendColors(ice, mtn, iceH, height, vars);
    } else if (height > mtnH) {
        return blendColors(mtn, grass, mtnH, height, vars);
    } else if (height > grassH) {
        return blendColors(grass, sand, grassH, height, vars);
    } else if (height > sandH) {
        return blendColors(sand, water, sandH, height, vars, blendThreshold * 0.4);
    } else if (height > waterH) {
        return blendColors(water, deepwater, waterH, height, vars);
    } else {
        return color(deepwater, vars);
    }
}
