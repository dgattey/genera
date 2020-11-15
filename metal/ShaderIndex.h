// ShaderIndex.h
// Copyright (c) 2020 Dylan Gattey
// Created by Dylan Gattey on 11/4/20.

#ifndef ShaderIndex_h
#define ShaderIndex_h

#import "NSEnum.h"

/// An index for buffer indices when passing data to Metal from the app
typedef NS_ENUM(NSInteger, ShaderIndex) {

    /// Data for the vertices themselves
    ShaderIndexVertices = 0,
    
    /// Data for the viewport bounds to use in calculating normaliized positions
    ShaderIndexViewport = 1,
    
    /// Shader config data
    ShaderIndexConfigData = 2,
    
    /// Shader biome data
    ShaderIndexBiomeData = 3,
};

#endif /* ShaderIndex_h */
