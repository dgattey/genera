// FBMData.h
// Copyright (c) 2020 Dylan Gattey

#ifndef FBMData_h
#define FBMData_h

/// Fractal Brownian Motion input data for use in shaders (will always output 0-1 range
/// but changing `compression` will change how closely those values are distributed within
/// that range.
struct FBMData {
    
    /// Octaves of noise to use
    int octaves;
    
    /// Amount to multiply amplitude by every iteration
    float persistence;
    
    /// Frequency of the noise at the beginning
    float scale;
    
    /// How closely the values are distributed around 0-1
    float compression;
    
    /// A seed to use in generating random offset
    uint seed;
};

#endif /* FBMData_h */
