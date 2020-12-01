// GameType.swift
// Copyright (c) 2020 Dylan Gattey

import Foundation

/// The type of game we're currently running - corresponds to a ChunkDataProviderProtocol
public enum GameType: String {
    /// Uses `TerrainChunkDataProvider` to show GPU-heavy chunks of Simplex-noise-generated terrain data
    case terrain = "Terrain"

    /// Uses `GridTileChunkDataProvider` to show CPU-heavy chunks of random tiled data
    case grid = "Random Grid"

    /// Titles of all game types - when adding more, add them here too!
    public static let titles: [String] = [GameType.terrain,
                                          GameType.grid].map(\.rawValue)
}
