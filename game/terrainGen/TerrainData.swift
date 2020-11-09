//
//  TerrainData.swift
//  Genera
//
//  Created by Dylan Gattey on 11/8/20.
//

import Foundation

/// Class for data for terrain generation used to create presets. Mirrors static properties in DefaultTerrainData
struct TerrainData: Codable {
    
    /// The name of the preset representing this set of defaults
    let presetName: String
    
    /// The identifer of the preset representing this set of defaults
    let presetID: String
    
    /// The value that sets the map gen seed
    let seed: String
    
    /// In the shader, this scales all coordinates
    let globalScalar: Float
    
    /// The offset from 0 the sea level should have
    let seaLevelOffset: Float
    
    /// How spiky the elevation should be (higher values create higher peaks/flatter valleys)
    let elevationDistribution: Float
    
    /// The offset from 0 the moisture level should have
    let aridness: Float
    
    /// How spiky/distributed the moisture should be (higher values create more extremes)
    let moistureDistribution: Float
    
    /// Defaults for FBMData for elevation noise generation
    let elevationFBM: FBMData
    
    /// Defaults for FBMData for moisture noise generation
    let moistureFBM: FBMData
    
    /// Default amount to weight elevation in color generation [0-1]
    let elevationColorWeight: Float
    
    /// Default amount to weight moisture in color generation [0-1]
    let moistureColorWeight: Float
    
    /// The current configuration of biomes
    let biomes: [Biome]

}

// MARK: - Biome Codable

/// This is defined in .h file so putting it here for conformance
extension Biome: Codable {
    
    enum CodingKeys: String, CodingKey {
        case type
        case color
        case minElevation
        case maxElevation
        case maxMoisture
        case blendRange
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(color, forKey: .color)
        try container.encode(minElevation, forKey: .minElevation)
        try container.encode(maxElevation, forKey: .maxElevation)
        try container.encode(maxMoisture, forKey: .maxMoisture)
        try container.encode(blendRange, forKey: .blendRange)
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let type = try values.decode(BiomeType.self, forKey: .type)
        let color = try values.decode(vector_float3.self, forKey: .color)
        let minElevation = try values.decode(Float.self, forKey: .minElevation)
        let maxElevation = try values.decode(Float.self, forKey: .maxElevation)
        let maxMoisture = try values.decode(Float.self, forKey: .maxMoisture)
        let blendRange = try values.decode(Float.self, forKey: .blendRange)
        self.init(
            type: type,
            color: color,
            minElevation:minElevation,
            maxElevation:maxElevation,
            maxMoisture:maxMoisture,
            blendRange:blendRange
        )
    }
}

// MARK: - FBMData Codable

/// This is defined in .h file so putting it here for conformance
extension FBMData: Codable {
    
    enum CodingKeys: String, CodingKey {
        case octaves
        case persistence
        case scale
        case compression
        case seed
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(octaves, forKey: .octaves)
        try container.encode(persistence, forKey: .persistence)
        try container.encode(scale, forKey: .scale)
        try container.encode(compression, forKey: .compression)
        try container.encode(seed, forKey: .seed)
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let octaves = try values.decode(Int32.self, forKey: .octaves)
        let persistence = try values.decode(Float.self, forKey: .persistence)
        let scale = try values.decode(Float.self, forKey: .scale)
        let compression = try values.decode(Float.self, forKey: .compression)
        let seed = try values.decode(UInt32.self, forKey: .seed)
        self.init(octaves: octaves, persistence: persistence, scale: scale, compression: compression, seed: seed)
    }
}
