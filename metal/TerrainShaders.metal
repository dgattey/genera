//
//  TerrainShaders.metal
//  Genera
//
//  Created by Dylan Gattey on 10/28/20.
//

// File for shading terrain

#include <metal_stdlib>
#include <simd/simd.h>
#import "SharedTypes.h"
#import "Util.h"

using namespace metal;

/// A vertex for use in the fragment shader
typedef struct {
    /// The clip space position of the vertex from the vertex shader.
    float4 position [[position]];
    
    /// The non-transformed position of this tile for noise generation.
    float2 colorPosition;
    
} FragmentVertex;

// This function creates color position and clip space postion data for the vertices from viewport size
vertex FragmentVertex terrainVertexShader(uint vertexID [[vertex_id]],
                                          const device TerrainVertex *vertexArray [[buffer(ShaderIndexVertices)]],
                                          constant float4 *viewport [[buffer(ShaderIndexViewport)]]) {
    float2 position = vertexArray[vertexID].position;
    
    // Calculate with viewport applied (translate into 0-2) range
    float2 viewportOrigin = float2((*viewport).x, (*viewport).y);
    float2 viewportSize = float2((*viewport).z, (*viewport).w);
    float x = (position.x - viewportOrigin.x) / viewportSize.x;
    float y = (position.y - viewportOrigin.y) / viewportSize.y;
    
    FragmentVertex out;
    out.position = float4(x, y, 0.0, 1.0);
    out.colorPosition = position;
    return out;
}

constant const Biome peak = (Biome){
    .color = { .95, .95, .94 },
    .elevation = .9,
    .blendRange = .04,
};
constant const Biome highDesert = (Biome){
    .color = { .65, .7, .5 },
    .elevation = .84,
    .blendRange = .06,
};
constant const Biome mountainside = (Biome){
    .color = { .35, .38, .1 },
    .elevation = .73,
    .blendRange = .08,
};
constant const Biome jungle = (Biome){
    .color = { .12, .28, .16 },
    .elevation = .5,
    .blendRange = .11,
};
constant const Biome plains = (Biome){
    .color = { .16, .48, .16 },
    .elevation = .36,
    .blendRange = .04,
};
constant const Biome shore = (Biome){
    .color = { .82, .85, .2 },
    .elevation = .34,
    .blendRange = .02,
};
constant const Biome shallowWater = (Biome){
    .color = { .1, .15, .38 },
    .elevation = .3,
    .blendRange = .35,
};
constant const Biome deepWater = (Biome){
    .color = { .08, .12, .27 },
    .elevation = 0,
    .blendRange = 0.,
};

/// Collects all biomes, high to low
constant const Biome allBiomes[] = { peak, highDesert, mountainside, jungle, plains, shore, shallowWater, deepWater };

/// Total number of biomes we're using
constant const int biomeCount = sizeof(allBiomes);

/// Returns a color, mixing the base color with elevation a bit by a constant amount
float4 color(Biome biome, float elevation, float elevationWeight = 0) {
    float colorR = clampedMix(biome.color.r, elevation, elevationWeight);
    float colorG = clampedMix(biome.color.g, elevation, elevationWeight);
    float colorB = clampedMix(biome.color.b, elevation, elevationWeight);
    return float4(colorR, colorG, colorB, 1.0);
}

/// Provides a color by blending two biome's colors in relation to a given elevation. Returns values in relation to the upper biome
/// i.e. if a solid color, it's the upper biome's color.
float4 blend(Biome upperBiome, Biome lowerBiome, float elevation) {
    float4 a = color(upperBiome, elevation);
    float4 b = color(lowerBiome, elevation);
    float percentOfThreshold = (upperBiome.elevation - elevation + upperBiome.blendRange)/upperBiome.blendRange - 0.5 * upperBiome.blendRange;
    return mix(a, b, max(min(percentOfThreshold, 1.0), 0.0));
}

// Generates noise within 0, 1, then turns that into blended biomes
fragment float4 terrainFragmentShader(FragmentVertex in [[stage_in]]) {
    float2 pos = float2(in.colorPosition.xy);
    float noise = fractalBrownianMotion(pos, 14, 0.71, 0.0001, 0, 1);
    
    // Makes some valleys & high peaks instead of being super spiky
    float elevation = pow(noise, 1.8) + 0.2;
    
    // The biomes for the boundaries
    Biome upperBiome;
    Biome lowerBiome;
    
    // Search for the biome matching this
    ulong index = 0;
    while (index + 1 < biomeCount) {
        upperBiome = allBiomes[index];
        lowerBiome = allBiomes[index + 1];
        if (elevation > upperBiome.elevation) {
            index = biomeCount;
        }
        index++;
    }
    
    // We didn't blend anything so return the base color
    return blend(upperBiome, lowerBiome, elevation);
}
