//
//  NSEnum.h
//  Genera
//
//  Created by Dylan Gattey on 11/5/20.
//

#ifndef NSEnum_h
#define NSEnum_h

/// Defines either NSEnum to expand to an enum type in Metal, or Foundation to be used in Swift/ObjC

#ifdef __METAL_VERSION__
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#define NSInteger int
#else
#import <Foundation/Foundation.h>
#endif

#endif /* NSEnum_h */
