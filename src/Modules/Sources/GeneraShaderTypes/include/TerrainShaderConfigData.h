// TerrainShaderConfigData.h
// Copyright (c) 2020 Dylan Gattey

#ifndef TerrainShaderConfigData_h
#define TerrainShaderConfigData_h

// This file is imported both from Metal and Swift, so we need dual imports for the two different search contexts
#ifdef __METAL_VERSION__
#import "FBMData.h"
#else
@import DataStructures;
#endif

/// Shader config data to pass in the form of a uniform to all shaders
struct TerrainShaderConfigData {
    
    /// The number of biomes we'll pass in the biomes array
    int numBiomes;
    
    /// How much elevation influences color of any biome (0-1)
    float elevationColorWeight;
    
    /// How much moisture influences color of any biome (0-1)
    float moistureColorWeight;
    
    /// Multiplied by the color position to change the scale of anything
    float globalScalar;
    
    /// The sea level offset from zero for elevation change
    float seaLevelOffset;
    
    /// How spiky the elevation should be (higher values create higher peaks/flatter valleys)
    float elevationDistribution;
    
    /// The offset from 0 the moisture level should have
    float aridness;
    
    /// How spiky/distributed the moisture should be (higher values create more extremes)
    float moistureDistribution;
    
    /// The elevation data for FBM generation
    const struct FBMData elevationGenerator;
    
    /// The moisture data for FBM generation
    const struct FBMData moistureGenerator;

};

#endif /* TerrainShaderConfigData_h */
