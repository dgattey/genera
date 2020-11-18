// TerrainPresetData.swift
// Copyright (c) 2020 Dylan Gattey

import EngineData
import Foundation

/// Struct for data for terrain generation used to create presets. Mirrors static properties in DefaultTerrainData
struct TerrainPresetData: Codable {
    /// All default data if there's nothing saved on disk
    static let `default` = TerrainPresetData(
        presetName: "Default Settings",
        seed: "puppy",
        globalScalar: 0.03,
        seaLevelOffset: -0.82,
        elevationDistribution: 16,
        aridness: -0.35,
        moistureDistribution: 0.9,
        elevationFBM: FBMData(
            octaves: 11,
            persistence: 0.55,
            scale: 0.01,
            compression: 0.33,
            seed: 0
        ),
        moistureFBM: FBMData(
            octaves: 9,
            persistence: 0.6,
            scale: 0.03,
            compression: 2,
            seed: 0
        ),
        elevationColorWeight: 0.0,
        moistureColorWeight: 0.0,
        biomes: Biome.defaultBiomes
    )

    /// The name of the preset representing this set of defaults
    let presetName: String

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

    /// Creates shader config data out of this preset
    var shaderConfigData: TerrainShaderConfigData {
        return TerrainShaderConfigData(
            numBiomes: Int32(biomes.count),
            elevationColorWeight: elevationColorWeight,
            moistureColorWeight: moistureColorWeight,
            globalScalar: globalScalar,
            seaLevelOffset: seaLevelOffset,
            elevationDistribution: elevationDistribution,
            aridness: aridness,
            moistureDistribution: moistureDistribution,
            elevationGenerator: elevationFBM,
            moistureGenerator: moistureFBM
        )
    }
}
