//
//  DefaultTerrainData.swift
//  Genera
//
//  Created by Dylan Gattey on 11/5/20.
//

import Foundation

/// Contains a bunch of different default data to use elsewhere
enum DefaultTerrainData {
    
    /// In the shader, this scales all coordinates
    static let globalScalar: Float = 0.0005
    
    /// Defaults for FBMData for elevation noise generation
    static let elevationFMB = FBMData(
        octaves: 4,
        persistence: 0.75,
        scale: 1,
        frequency: 2,
        compression: 1.7)
    
    /// Defaults for FBMData for moisture noise generation
    static let moistureFMB = FBMData(
        octaves: 1,
        persistence: 0,
        scale: 0.0,
        frequency: 0.0,
        compression: 0)
    
    /// Default amount to weight elevation in color generation [0-1]
    static let elevationColorWeight: Float = 0.0
    
    /// Default amount to weight moisture in color generation [0-1]
    static let moistureColorWeight: Float = 0.0

}
