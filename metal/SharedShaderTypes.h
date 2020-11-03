//
//  SharedShaderTypes.h
//  Genera
//
//  Created by Dylan Gattey on 10/28/20.
//

//
//  Header containing types and enum constants shared between Metal shaders and Swift/ObjC source
//
#ifndef SharedShaderTypes_h
#define SharedShaderTypes_h

#ifdef __METAL_VERSION__
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#define NSInteger metal::int32_t
#else
#import <Foundation/Foundation.h>
#endif

#include <simd/simd.h>

typedef NS_ENUM(NSInteger, ShaderIndex)
{
    ShaderIndexPositions  = 0,
    ShaderIndexColors  = 1,
    ShaderIndexViewport  = 2,
};

#endif /* SharedShaderTypes_h */

