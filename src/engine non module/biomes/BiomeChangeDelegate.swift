// BiomeChangeDelegate.swift
// Copyright (c) 2020 Dylan Gattey

import EngineData
import Foundation

/// Called when changes to biomes happen
protocol BiomeChangeDelegate: AnyObject {
    /// Called when data for a biome changes for an identifier
    func biome(withIdentifier id: String, didUpdateTo biome: Biome)
}
