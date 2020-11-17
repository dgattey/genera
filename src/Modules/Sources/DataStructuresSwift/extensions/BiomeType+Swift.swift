// BiomeType+Swift.swift
// Copyright (c) 2020 Dylan Gattey

import Foundation

/// Conforms BiomeType to string convertible so it can print properly
extension BiomeType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .ocean: return "Ocean"
        case .shallowWater: return "Shallow Water"
        case .shore: return "Shore"
        case .scorched: return "Scorched"
        case .bare: return "Bare"
        case .tundra: return "Tundra"
        case .snow: return "Snow"
        case .temperateDesert: return "Temperate Desert"
        case .shrubland: return "Shrubland"
        case .taiga: return "Taiga"
        case .grassland: return "Grassland"
        case .temperateDeciduousForest: return "Temperate Deciduous Forest"
        case .temperateRainforest: return "Temperate Rainforest"
        case .subtropicalDesert: return "Subtropical Desert"
        case .tropicalSeasonalForest: return "Tropical Seasonal Forest"
        case .tropicalRainforest: return "Tropical Rainforest"
        case .total:
            return "BiomeType total: \(rawValue)"
        @unknown default:
            assertionFailure("New enum type we haven't handled with raw value \(rawValue)")
            return ""
        }
    }
}

// MARK: - Codable

extension BiomeType: Codable {
    /// Creates a value out of the raw value or gives back ocean
    public init(rawValueOrOcean: Int) {
        self = BiomeType(rawValue: rawValueOrOcean) ?? .ocean
    }

    enum CodingKeys: String, CodingKey {
        case rawValue
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(rawValue, forKey: .rawValue)
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let rawValue = try values.decode(Int.self, forKey: .rawValue)
        self.init(rawValueOrOcean: rawValue)
    }
}
