// ViewportData.h
// Copyright (c) 2020 Dylan Gattey

#ifndef ViewportData_h
#define ViewportData_h

#import <simd/simd.h>

/// A struct of data representing everything we need to represent the viewport
struct ViewportData {
    
    /// Origin of the viewport (x, y)
    vector_float2 origin;
    
    /// Size of the viewport (width, height)
    vector_float2 size;
    
    /// How much to scale the viewport by in xy directions - used as a proxy for pixel density
    vector_float2 scaleFactor;
};

#endif /* ViewportData_h */
