//
//  TerrainShaders.metal
//  Genera
//
//  Created by Dylan Gattey on 10/28/20.
//

// File for shading terrain

#include <metal_stdlib>
#include <simd/simd.h>
#import "../SharedTypes.h"
#import "../util/Color.h"
#import "../util/SimplexNoise.h"

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

constant const Biome ocean = (Biome) {
    .color = { 0.2188037932, 0.210770309, 0.3924256861 },
    .minElevation = 0.,
    .maxElevation = .07,
    .maxMoisture = INFINITY,
    .blendRange = .02,
};

constant const Biome shallowWater = (Biome) {
    .color = { 0.3497013152, 0.329328239, 0.4814990759 },
    .minElevation = .05,
    .maxElevation = .10,
    .maxMoisture = INFINITY,
    .blendRange = .02,
};

constant const Biome shore = (Biome) {
    .color = { 0.6381754875, 0.5679113269, 0.4531891346 },
    .minElevation = .12,
    .maxElevation = .22,
    .maxMoisture = .97,
    .blendRange = .02,
};

constant const Biome scorched = (Biome) {
    .color = { 0.3333011568, 0.3333538771, 0.3332896829 },
    .minElevation = .8,
    .maxElevation = INFINITY,
    .maxMoisture = .1,
    .blendRange = .02,
};

constant const Biome bare = (Biome) {
    .color = { 0.5332846642, 0.5333645344, 0.5332672 },
    .minElevation = .8,
    .maxElevation = INFINITY,
    .maxMoisture = .2,
    .blendRange = .02,
};

constant const Biome tundra = (Biome) {
    .color = { 0.7315357924, 0.7387986779, 0.6590853333 },
    .minElevation = .8,
    .maxElevation = INFINITY,
    .maxMoisture = .5,
    .blendRange = .02,
};

constant const Biome snow = (Biome) {
    .color = { 0.8708811402, 0.8700690866, 0.9006112814 },
    .minElevation = .8,
    .maxElevation = INFINITY,
    .maxMoisture = .1,
    .blendRange = .02,
};

constant const Biome temperateDesert1 = (Biome) {
    .color = { 0.7777122855, 0.8286150098, 0.5814029574 },
    .minElevation = .6,
    .maxElevation = .8,
    .maxMoisture = .33,
    .blendRange = .02,
};

constant const Biome shrubland = (Biome) {
    .color = { 0.5155887008, 0.6048905253, 0.4522334337 },
    .minElevation = .6,
    .maxElevation = .8,
    .maxMoisture = .66,
    .blendRange = .02,
};

constant const Biome taiga = (Biome) {
    .color = { 0.5767214894, 0.6726787686, 0.4422698319 },
    .minElevation = .6,
    .maxElevation = .8,
    .maxMoisture = INFINITY,
    .blendRange = .02,
};

constant const Biome temperateDesert2 = (Biome) {
    .color = { 0.7777122855, 0.8286150098, 0.5814029574 },
    .minElevation = .3,
    .maxElevation = .6,
    .maxMoisture = .16,
    .blendRange = .02,
};

constant const Biome grassland1 = (Biome) {
    .color = { 0.4925258756, 0.6802223325, 0.2770718932 },
    .minElevation = .3,
    .maxElevation = .6,
    .maxMoisture = .5,
    .blendRange = .02,
};

constant const Biome temperateDeciduousForest = (Biome) {
    .color = { 0.3480811715, 0.5857154727, 0.3204561472 },
    .minElevation = .3,
    .maxElevation = .6,
    .maxMoisture = .83,
    .blendRange = .02,
};

constant const Biome temperateRainforest = (Biome) {
    .color = { 0.1177579537, 0.544154644, 0.3114391267 },
    .minElevation = .3,
    .maxElevation = .6,
    .maxMoisture = INFINITY,
    .blendRange = .02,
};

constant const Biome subtropicalDesert = (Biome) {
    .color = { 0.8410642147, 0.7242162228, 0.5193104148 },
    .minElevation = .4,
    .maxElevation = .4,
    .maxMoisture = .4,
    .blendRange = .02,
};

constant const Biome grassland2 = (Biome) {
    .color = { 0.4925258756, 0.6802223325, 0.2770718932 },
    .minElevation = .22,
    .maxElevation = .3,
    .maxMoisture = .33,
    .blendRange = .02,
};

constant const Biome tropicalSeasonalForest = (Biome) {
    .color = { 0.2234450281, 0.6123558879, 0.2096185088 },
    .minElevation = .22,
    .maxElevation = .3,
    .maxMoisture = .66,
    .blendRange = .02,
};

constant const Biome tropicalRainforest = (Biome) {
    .color = { 0, 0.476154685, 0.32167539 },
    .minElevation = .22,
    .maxElevation = .3,
    .maxMoisture = INFINITY,
    .blendRange = .02,
};

/// Collects all biomes
constant const Biome allBiomes[] = {
    ocean,
    shallowWater,
    shore,
    scorched,
    bare,
    tundra,
    snow,
    temperateDesert1,
    shrubland,
    taiga,
    temperateDesert2,
    grassland1,
    temperateDeciduousForest,
    temperateRainforest,
    subtropicalDesert,
    grassland2,
    tropicalSeasonalForest,
    tropicalRainforest,
};

/// Total number of biomes we're using
constant const int biomeCount = sizeof(allBiomes);

/// Returns a color, mixing the base color with elevation a bit by a constant amount
float4 color(Biome biome, float elevation, float elevationWeight = 0) {
    float colorR = mixColors(biome.color.r, elevation, elevationWeight);
    float colorG = mixColors(biome.color.g, elevation, elevationWeight);
    float colorB = mixColors(biome.color.b, elevation, elevationWeight);
    return float4(colorR, colorG, colorB, 1.0);
}

/// TODO: @dgattey use this again!
/// Provides a color by blending two biome's colors in relation to a given elevation. Returns values in relation to the upper biome
/// i.e. if a solid color, it's the upper biome's color.
float4 blend(Biome upperBiome, Biome lowerBiome, float elevation) {
    float4 a = color(upperBiome, elevation);
    float4 b = color(lowerBiome, elevation);
    float percentOfThreshold = (upperBiome.minElevation - elevation + upperBiome.blendRange)/upperBiome.blendRange - 0.5 * upperBiome.blendRange;
    return mix(a, b, max(min(percentOfThreshold, 1.0), 0.0));
}

// Generates noise within 0, 1, then turns that into blended biomes
fragment float4 terrainFragmentShader(FragmentVertex in [[stage_in]]) {
    float2 pos = float2(in.colorPosition.xy);
    float elevation = fractalBrownianMotion(pos, 14, 0.71, 0.0001, 0, 1);
    float moisture = fractalBrownianMotion(pos, 6, 0.31, 0.001, 0, 1);
    
    // Makes some valleys & high peaks instead of being super spiky
//    float elevation = max(0.0, min(1.0, pow(noise, 1.8) + 0.2));
    
    // Search for the biome matching this moisture + heightmap
    Biome biome;
    ulong index = 0;
    while (index + 1 < biomeCount) {
        // TODO: @dgattey use this again
//        upperBiome = allBiomes[index];
//        lowerBiome = allBiomes[index + 1];
//        if (elevation > upperBiome.elevation) {
//            index = biomeCount;
//        }
        
        biome = allBiomes[index];
        if (elevation >= biome.minElevation && elevation < biome.maxElevation && moisture < biome.maxMoisture) {
            index = biomeCount;
        }
        
        index++;
    }
    
    // We didn't blend anything so return the base color
    return color(biome, elevation);
}
