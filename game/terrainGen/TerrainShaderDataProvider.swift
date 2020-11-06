//
//  TerrainShaderDataProvider.swift
//  Genera
//
//  Created by Dylan Gattey on 11/5/20.
//

import Foundation

/// Fractal Brownian Motion input data for use in shaders
struct FBMData {
    
    /// Octaves of noise to use
    let octaves: Int
    
    /// Amount to multiply amplitude by every iteration
    let persistence: Float
    
    /// Frequency of the noise
    let scale: Float
}

/// Shader config data to pass in the form of a uniform to all shaders
struct TerrainShaderConfigData {
    
    /// How much elevation influences color of any biome (0-1)
    let elevationColorWeight: Float
    
    /// How much moisture influences color of any biome (0-1)
    let moistureColorWeight: Float

    /// Multiplied by the color position to change the scale of anything
    let globalScalar: Float
    
    /// The elevation data for FBM generation
    let elevationGenerator: FBMData
    
    /// The moisture data for FBM generation
    let moistureGenerator: FBMData
    
}

/// This defines something that provides data to the shaders in the form of config data
protocol TerrainShaderDataProvider: class {
    
    /// All possible biomes we support
    var allBiomes: [Biome] { get }
    
    /// Current config data for the shaders (changes often)
    var configData: TerrainShaderConfigData { get }

}
