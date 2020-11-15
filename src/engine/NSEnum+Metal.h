// NSEnum+Metal.h
// Copyright (c) 2020 Dylan Gattey

#ifndef NSEnum_Metal_h
#define NSEnum_Metal_h

/// Defines NS_ENUM to either expand to an enum type in Metal, or Foundation to be used in Swift/ObjC
#ifdef __METAL_VERSION__
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#define NSInteger int
#else
#import <Foundation/Foundation.h>
#endif

#endif /* NSEnum_Metal_h */
