// TerrainData.swift
// Copyright (c) 2020 Dylan Gattey

import EngineData
import Foundation

/// Struct for data for terrain generation used to create presets. Mirrors static properties in DefaultTerrainData
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
