// GridShaderTypes.h
// Copyright (c) 2020 Dylan Gattey

#ifndef GridShaderTypes_h
#define GridShaderTypes_h

#import <simd/simd.h>

/// A struct of data for one vertex to pass to the grid shaders
struct GridVertex {
    
    /// The position of this vertex in 2D space
    vector_float2 position;
    
    /// The color of this vertex in RGBA space
    vector_float4 color;
};

#endif /* GridShaderTypes_h */
