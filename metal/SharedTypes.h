//
//  SharedTypes.h
//  Genera
//
//  Created by Dylan Gattey on 10/28/20.
//

//
//  Header containing types and enum constants shared between Metal shaders and Swift/ObjC source
//
#ifndef SharedTypes_h
#define SharedTypes_h

#ifdef __METAL_VERSION__
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#define NSInteger metal::int32_t
#else
#import <Foundation/Foundation.h>
#endif

#include <simd/simd.h>
#import "GridShaderTypes.h"
#import "TerrainShaderTypes.h"

/// An index for buffer indices when passing data to Metal from the app
typedef NS_ENUM(NSInteger, ShaderIndex)
{
    /// Data for the vertices themselves
    ShaderIndexVertices = 0,
    
    /// Data for the viewport bounds to use in calculating normaliized positions
    ShaderIndexViewport = 1,
};

#endif /* SharedTypes_h */

