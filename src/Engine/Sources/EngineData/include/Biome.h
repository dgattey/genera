// Biome.h
// Copyright (c) 2020 Dylan Gattey

#ifndef Biome_h
#define Biome_h

#import <simd/simd.h>
#import "BiomeType.h"

/// Defines a biome, consisting of a elevation and color that defines a particular biome
struct Biome {
    
    /// The type of biome we're representing
    BiomeType type;
    
    /// The color defining the core of this biome
    vector_float3 color;
    
    /// The elevation (0-1) above which this biome sits
    float minElevation;
    
    /// The elevation (0-1) below which this biome sits
    float maxElevation;
    
    /// The amount of moisture (0-1) this biome gets at max (more than this is another biome)
    float maxMoisture;
    
    /// Biomes blend within this elevation range around the elevation (i.e. a biome defined at
    /// elevation 0.6 will range from 0.6-blendRange/2 to 0.6+blendRange/2).
    float blendRange;
    
};

#endif /* Biome_h */
