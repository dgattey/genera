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
fragment float4 terrainFragmentShader(FragmentVertex in [[stage_in]],
                                      constant TerrainShaderConfigData *configData [[buffer(ShaderIndexConfigData)]],
                                      constant Biome *allBiomes [[buffer(ShaderIndexBiomeData)]]) {
    float2 pos = float2(in.colorPosition.xy);
    float elevation = fractalBrownianMotion(pos, (*configData).elevationGenerator, 0, 1);
    float moisture = fractalBrownianMotion(pos, (*configData).moistureGenerator, 0, 1);
    
    // Makes some valleys & high peaks instead of being super spiky
//    float elevation = max(0.0, min(1.0, pow(noise, 1.8) + 0.2));
    
    // Search for the biome matching this moisture + heightmap
    Biome biome;
    int index = 0;
    while (index + 1 < (*configData).numBiomes) {
        // TODO: @dgattey use this again
//        upperBiome = allBiomes[index];
//        lowerBiome = allBiomes[index + 1];
//        if (elevation > upperBiome.elevation) {
//            index = biomeCount;
//        }
        
        biome = allBiomes[index];
        if (elevation >= biome.minElevation && elevation < biome.maxElevation && moisture < biome.maxMoisture) {
            index = (*configData).numBiomes;
        }
        
        index++;
    }
    
    // We didn't blend anything so return the base color
    return color(biome, elevation);
}
