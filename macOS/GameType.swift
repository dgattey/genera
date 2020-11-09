//
//  GameType.swift
//  Genera
//
//  Created by Dylan Gattey on 11/8/20.
//

import Foundation

/// The type of game we're currently running - corresponds to a ChunkDataProviderProtocol
enum GameType: String {
    
    /// Uses `TerrainChunkDataProvider` to show GPU-heavy chunks of Simplex-noise-generated terrain data
    case terrain = "Generated Terrain"
    
    /// Uses `GridTileChunkDataProvider` to show CPU-heavy chunks of random tiled data
    case grid = "Random tile grid"
    
    /// Titles of all game types - when adding more, add them here too!
    static let titles: [String] = [
        GameType.terrain,
        GameType.grid,
    ].map({ $0.rawValue })
}