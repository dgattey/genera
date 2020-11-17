// DefaultTerrainData.swift
// Copyright (c) 2020 Dylan Gattey

import EngineData
import Foundation

/// In-memory fallback for default terrain data if it doesn't exist locally
enum DefaultTerrainData {
    /// The name of the preset representing this set of defaults
    static let presetName = "Default Settings"

    /// The identifer of the preset representing this set of defaults
    static let presetID = "defaultSettings"

    /// The value that sets the map gen seed
    static let seed: String = "puppy"

    /// In the shader, this scales all coordinates
    static let globalScalar: Float = 0.03

    /// The offset from 0 the sea level should have
    static let seaLevelOffset: Float = -0.82

    /// How spiky the elevation should be (higher values create higher peaks/flatter valleys)
    static let elevationDistribution: Float = 16

    /// The offset from 0 the moisture level should have
    static let aridness: Float = -0.35

    /// How spiky/distributed the moisture should be (higher values create more extremes)
    static let moistureDistribution: Float = 0.9

    /// Defaults for FBMData for elevation noise generation
    static let elevationFBM = FBMData(
        octaves: 11,
        persistence: 0.55,
        scale: 0.01,
        compression: 0.33,
        seed: 0
    )

    /// Defaults for FBMData for moisture noise generation
    static let moistureFBM = FBMData(
        octaves: 9,
        persistence: 0.6,
        scale: 0.03,
        compression: 2,
        seed: 0
    )

    /// Default amount to weight elevation in color generation [0-1]
    static let elevationColorWeight: Float = 0.0

    /// Default amount to weight moisture in color generation [0-1]
    static let moistureColorWeight: Float = 0.0

    /// So we can save this to disk if we need to
    static var terrainData: TerrainData {
        TerrainData(
            presetName: presetName,
            presetID: presetID,
            seed: seed,
            globalScalar: globalScalar,
            seaLevelOffset: seaLevelOffset,
            elevationDistribution: elevationDistribution,
            aridness: aridness,
            moistureDistribution: moistureDistribution,
            elevationFBM: elevationFBM,
            moistureFBM: moistureFBM,
            elevationColorWeight: elevationColorWeight,
            moistureColorWeight: moistureColorWeight,
            biomes: Biome.defaultBiomes
        )
    }
}
