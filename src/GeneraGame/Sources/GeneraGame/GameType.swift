// GameType.swift
// Copyright (c) 2022 Dylan Gattey

import Foundation

/// The type of game we're currently running - corresponds to a ChunkDataProviderProtocol
public enum GameType: String {
    /// Uses `TerrainChunkDataProvider` to show GPU-heavy chunks of Simplex-noise-generated terrain data
    case terrain = "Terrain"

    /// Titles of all game types - when adding more, add them here too!
    public static let titles: [String] = [GameType.terrain].map(\.rawValue)
}
