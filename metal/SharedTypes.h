//
//  SharedTypes.h
//  Genera
//
//  Created by Dylan Gattey on 10/28/20.
//

#ifndef SharedTypes_h
#define SharedTypes_h

#ifdef __METAL_VERSION__
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#define NSInteger metal::int32_t
#else
#import <Foundation/Foundation.h>
#endif

//  This all gets imported into both Swift/ObjC code & Metal shaders, so it must be safe for both.

#include <simd/simd.h>
#import "GridShaderTypes.h"
#import "TerrainShaderTypes.h"
#import "ShaderIndex.h"
#import "Biome.h"

#endif /* SharedTypes_h */

