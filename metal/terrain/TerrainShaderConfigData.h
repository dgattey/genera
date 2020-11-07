//
//  TerrainShaderConfigData.h
//  Genera
//
//  Created by Dylan Gattey on 11/5/20.
//

#ifndef TerrainShaderConfigData_h
#define TerrainShaderConfigData_h

#import "../util/SimplexNoise.h"

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
    
    /// The elevation data for FBM generation
    const struct FBMData elevationGenerator;
    
    /// The moisture data for FBM generation
    const struct FBMData moistureGenerator;

};

#endif /* TerrainShaderConfigData_h */
