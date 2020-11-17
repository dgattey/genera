// Biome+Swift.swift
// Copyright (c) 2020 Dylan Gattey

import AppKit

/// Adds color support to Biome
public extension Biome {
    /// The NSColor representation of this biome's color
    var nsColor: NSColor {
        return NSColor(
            red: CGFloat(color.x),
            green: CGFloat(color.y),
            blue: CGFloat(color.z),
            alpha: 1.0
        )
    }
}

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
            minElevation: minElevation,
            maxElevation: maxElevation,
            maxMoisture: maxMoisture,
            blendRange: blendRange
        )
    }
}
