//
//  BiomeType+Swift.swift
//  Genera
//
//  Created by Dylan Gattey on 11/5/20.
//

import Foundation

/// Conforms BiomeType to string convertible so it can print properly
extension BiomeType: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .ocean: return ".ocean"
        case .shallowWater: return ".shallowWater"
        case .shore: return ".shore"
        case .scorched: return ".scorched"
        case .bare: return ".bare"
        case .tundra: return ".tundra"
        case .snow: return ".snow"
        case .temperateDesert: return ".temperateDesert"
        case .shrubland: return ".shrubland"
        case .taiga: return ".taiga"
        case .grassland: return ".grassland"
        case .temperateDeciduousForest: return ".temperateDeciduousForest"
        case .temperateRainforest: return ".temperateRainforest"
        case .subtropicalDesert: return ".subtropicalDesert"
        case .tropicalSeasonalForest: return ".tropicalSeasonalForest"
        case .tropicalRainforest: return ".tropicalRainforest"
        case .total:
            return "BiomeType total: \(self.rawValue)"
        @unknown default:
            assertionFailure("New enum type we haven't handled with raw value \(self.rawValue)")
            return ""
        }
    }
}

// MARK: - BiomeType Codable

extension BiomeType: Codable {
    
    init(rawValueOrOcean: Int) {
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
