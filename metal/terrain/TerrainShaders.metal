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

/// Returns a color, mixing the base color with noise a bit by a given amount
float4 color(Biome biome, float noise, float weight) {
    float colorR = mixColors(biome.color.r, noise, weight);
    float colorG = mixColors(biome.color.g, noise, weight);
    float colorB = mixColors(biome.color.b, noise, weight);
    return float4(colorR, colorG, colorB, 1.0);
}

/// TODO: @dgattey use this again!
/// Provides a color by blending two biome's colors in relation to a given elevation. Returns values in relation to the upper biome
/// i.e. if a solid color, it's the upper biome's color.
float4 blend(Biome upperBiome, Biome lowerBiome, float elevation, float moisture, constant TerrainShaderConfigData *configData) {
    float4 elevationColorA = color(upperBiome, elevation, (*configData).elevationColorWeight);
    float4 elevationColorB = color(lowerBiome, elevation, (*configData).elevationColorWeight);
    float4 moistureColorA = color(upperBiome, moisture, (*configData).moistureColorWeight);
    float4 moistureColorB = color(lowerBiome, moisture, (*configData).moistureColorWeight);
    float percentOfElevationThreshold = (upperBiome.minElevation - elevation + upperBiome.blendRange)/upperBiome.blendRange - 0.5 * upperBiome.blendRange;
    /// TODO: @dgattey is this right at all?
    float percentOfMoistureThreshold = (upperBiome.maxMoisture - moisture + upperBiome.blendRange)/upperBiome.blendRange - 0.5 * upperBiome.blendRange;
    return mix(elevationColorA, elevationColorB, max(min(percentOfElevationThreshold, 1.0), 0.0));
}

// Generates noise within 0, 1, then turns that into blended biomes
fragment float4 terrainFragmentShader(FragmentVertex in [[stage_in]],
                                      constant TerrainShaderConfigData *configData [[buffer(ShaderIndexConfigData)]],
                                      constant Biome *allBiomes [[buffer(ShaderIndexBiomeData)]]) {
    float2 pos = float2(in.colorPosition.xy) * (*configData).globalScalar;
    float elevation = fractalBrownianMotion(pos, (*configData).elevationGenerator);
    float moisture = fractalBrownianMotion(pos, (*configData).moistureGenerator);
    
    // Makes some valleys & high peaks instead of being super spiky
    elevation = max(0.0, min(1.0, pow(elevation - (*configData).seaLevelOffset, (*configData).elevationDistribution)));
    
    // Fits moisture levels to a curve
    moisture = max(0.0, min(1.0, pow(moisture - (*configData).aridness, (*configData).moistureDistribution)));
    
    // Search for the biome matching this moisture + elevation
    Biome biome;
    int index = 0;
    while (index + 1 < (*configData).numBiomes) {
        biome = allBiomes[index];
        if (elevation >= biome.minElevation && elevation < biome.maxElevation && moisture < biome.maxMoisture) {
            index = (*configData).numBiomes;
        }
        index++;
    }
    
    // Simple color
    return float4(biome.color, 1);
}
