// TerrainShaderTypes.h
// Copyright (c) 2020 Dylan Gattey

#ifndef TerrainShaderTypes_h
#define TerrainShaderTypes_h

#import <simd/simd.h>

/// A struct of data for one vertex to pass to the terrain shaders
struct TerrainVertex {
    
    /// The position of this vertex in 2D space
    vector_float2 position;
};

#endif /* TerrainShaderTypes_h */
