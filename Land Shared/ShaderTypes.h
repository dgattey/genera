//
//  ShaderTypes.h
//  Land Shared
//
//  Created by Dylan Gattey on 10/28/20.
//

//
//  Header containing types and enum constants shared between Metal shaders and Swift/ObjC source
//
#ifndef ShaderTypes_h
#define ShaderTypes_h

#ifdef __METAL_VERSION__
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#define NSInteger metal::int32_t
#else
#import <Foundation/Foundation.h>
#endif

#include <simd/simd.h>


typedef NS_ENUM(NSInteger, VertexInputIndex)
{
    VertexInputIndexVertices  = 0,
    VertexInputIndexViewportSize  = 1,
};

#endif /* ShaderTypes_h */

