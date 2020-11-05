//
//  Biome.h
//  Genera
//
//  Created by Dylan Gattey on 11/4/20.
//

#ifndef Biome_h
#define Biome_h

#ifdef __METAL_VERSION__
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#define NSInteger metal::int32_t
#else
#import <Foundation/Foundation.h>
#endif

#include <simd/simd.h>

/// Defines a biome, consisting of a elevation and color that defines a particular biome
typedef struct Biome {
    
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
    
    /// Whether trees should appear on this biome
    bool hasTrees;
    
} Biome;

/// Represents a type of biome with associated color
typedef NS_ENUM(NSInteger, BiomeType) {
    BiomeTypeOcean = 1,
    BiomeTypeShallowWater,
    BiomeTypeShore,
    BiomeTypeScorched,
    BiomeTypeBare,
    BiomeTypeTundra,
    BiomeTypeSnow,
    BiomeTypeTemperateDesert,
    BiomeTypeShrubland,
    BiomeTypeTaiga,
    BiomeTypeGrassland,
    BiomeTypeTemperateDeciduousForest,
    BiomeTypeTemperateRainforest,
    BiomeTypeSubtropicalDesert,
    BiomeTypeTropicalSeasonalForest,
    BiomeTypeTropicalRainforest,
    BiomeTypeTotal,
};

#endif /* Biome_h */
