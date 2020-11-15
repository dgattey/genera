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
            return "BiomeType total: \(rawValue)"
        @unknown default:
            assertionFailure("New enum type we haven't handled with raw value \(rawValue)")
            return ""
        }
    }
}
