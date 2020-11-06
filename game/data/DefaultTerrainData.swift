//
//  DefaultTerrainData.swift
//  Genera
//
//  Created by Dylan Gattey on 11/5/20.
//

import Foundation

/// Contains a bunch of different default data to use elsewhere
enum DefaultTerrainData {
    
    /// Defaults for FBMData for elevation noise generation
    static let elevationFMB = FBMData(octaves: 16, persistence: 0.75, scale: 0.0001)
    
    /// Defaults for FBMData for moisture noise generation
    static let moistureFMB = FBMData(octaves: 12, persistence: 0.6, scale: 0.00008)
    
    /// Default amount to weight elevation in color generation [0-1]
    static let elevationColorWeight: Float = 0.2
    
    /// Default amount to weight moisture in color generation [0-1]
    static let moistureColorWeight: Float = 0.1
    
    /// In the shader, this scales
    static let globalCoordinateScalar: Float = 0.01
}
