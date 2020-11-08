//
//  DefaultTerrainData.swift
//  Genera
//
//  Created by Dylan Gattey on 11/5/20.
//

import Foundation

/// Contains a bunch of different default data to use elsewhere
enum DefaultTerrainData {
    
    static let seed: String = "puppy"
    
    /// In the shader, this scales all coordinates
    static let globalScalar: Float = 0.0005
    
    /// The offset from 0 the sea level should have
    static let seaLevelOffset: Float = -0.82
    
    /// How spiky the elevation should be (higher values create higher peaks/flatter valleys)
    static let elevationDistribution: Float = 16
    
    /// The offset from 0 the moisture level should have
    static let aridness: Float = -0.35
    
    /// How spiky/distributed the moisture should be (higher values create more extremes)
    static let moistureDistribution: Float = 0.9
    
    /// Defaults for FBMData for elevation noise generation
    static let elevationFMB = FBMData(
        octaves: 4,
        persistence: 0.75,
        scale: 1,
        compression: 1.7)
        seed: 0)
    
    /// Defaults for FBMData for moisture noise generation
    static let moistureFMB = FBMData(
        octaves: 1,
        persistence: 0,
        scale: 0.0,
        compression: 0)
        seed: 0)
    
    /// Default amount to weight elevation in color generation [0-1]
    static let elevationColorWeight: Float = 0.0
    
    /// Default amount to weight moisture in color generation [0-1]
    static let moistureColorWeight: Float = 0.0

}
