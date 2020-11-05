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
    
    /// The elevation above which this biome sits
    float elevation;
    
    /// Biomes blend within this elevation range around the elevation (i.e. a biome defined at
    /// elevation 0.6 will range from 0.6-blendRange/2 to 0.6+blendRange/2).
    float blendRange;
    
} Biome;

#endif /* Biome_h */
