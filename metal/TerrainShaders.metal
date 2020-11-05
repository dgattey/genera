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
    .height = .82,
    .blendRange = .04,
};
constant const Biome mountainside = (Biome){
    .color = { .2, .24, .1 },
    .height = .73,
    .blendRange = .08,
};
constant const Biome plains = (Biome){
    .color = { .16, .48, .16 },
    .height = .62,
    .blendRange = .04,
};
constant const Biome shore = (Biome){
    .color = { .82, .85, .2 },
    .height = .6,
    .blendRange = .02,
};
constant const Biome shallowWater = (Biome){
    .color = { .1, .15, .38 },
    .height = .41,
    .blendRange = .35,
};
constant const Biome deepWater = (Biome){
    .color = { .08, .12, .27 },
    .height = 0,
    .blendRange = 0.,
};

/// Collects all biomes, high to low
constant const Biome allBiomes[] = { peak, mountainside, plains, shore, shallowWater, deepWater };

/// Total number of biomes we're using
constant const int biomeCount = sizeof(allBiomes);

/// Returns a color, mixing the base color with height a bit by a constant amount
float4 color(Biome biome, float height, float heightWeight = 0) {
    float colorR = clampedMix(biome.color.r, height, heightWeight);
    float colorG = clampedMix(biome.color.g, height, heightWeight);
    float colorB = clampedMix(biome.color.b, height, heightWeight);
    return float4(colorR, colorG, colorB, 1.0);
}

/// Provides a color by blending two biome's colors in relation to a given height. Returns values in relation to the upper biome
/// i.e. if a solid color, it's the upper biome's color.
float4 blend(Biome upperBiome, Biome lowerBiome, float height) {
    float4 a = color(upperBiome, height);
    float4 b = color(lowerBiome, height);
    float percentOfThreshold = (upperBiome.height - height + upperBiome.blendRange)/upperBiome.blendRange - 0.5 * upperBiome.blendRange;
    return mix(a, b, max(min(percentOfThreshold, 1.0), 0.0));
}

// Generates noise within 0, 1, then turns that into blended biomes
fragment float4 terrainFragmentShader(FragmentVertex in [[stage_in]]) {
    float2 pos = float2(in.colorPosition.xy);
    float height = fractalBrownianMotion(pos, 14, 0.71, 0.0001, 0, 1);
    
    // The biomes for the boundaries
    Biome upperBiome;
    Biome lowerBiome;
    
    // Search for the biome matching this
    ulong index = 0;
    while (index + 1 < biomeCount) {
        upperBiome = allBiomes[index];
        lowerBiome = allBiomes[index + 1];
        if (height > upperBiome.height) {
            index = biomeCount;
        }
        index++;
    }
    
    // We didn't blend anything so return the base color
    return blend(upperBiome, lowerBiome, height);
}
