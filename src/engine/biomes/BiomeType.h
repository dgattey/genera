// BiomeType.h
// Copyright (c) 2020 Dylan Gattey

#ifndef BiomeType_h
#define BiomeType_h

#import "NSEnum+Metal.h"

/// Represents a type of biome for use in color generation
typedef NS_ENUM(NSInteger, BiomeType) {
    BiomeTypeOcean = 0,
    BiomeTypeShallowWater = 1,
    BiomeTypeShore = 2,
    BiomeTypeScorched = 3,
    BiomeTypeBare = 4,
    BiomeTypeTundra = 5,
    BiomeTypeSnow = 6,
    BiomeTypeTemperateDesert = 7,
    BiomeTypeShrubland = 8,
    BiomeTypeTaiga = 9,
    BiomeTypeGrassland = 10,
    BiomeTypeTemperateDeciduousForest = 11,
    BiomeTypeTemperateRainforest = 12,
    BiomeTypeSubtropicalDesert = 13,
    BiomeTypeTropicalSeasonalForest = 14,
    BiomeTypeTropicalRainforest = 15,
    BiomeTypeTotal,
};

#endif /* BiomeType_h */
