//
//  BiomeType.h
//  Genera
//
//  Created by Dylan Gattey on 11/5/20.
//

#ifndef BiomeType_h
#define BiomeType_h

#include "../NSEnum.h"

/// Represents a type of biome for use in color generation
typedef NS_ENUM(NSInteger, BiomeType) {
    BiomeTypeOcean = 0,
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

#endif /* BiomeType_h */
