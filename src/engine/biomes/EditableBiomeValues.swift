// EditableBiomeValues.swift
// Copyright (c) 2020 Dylan Gattey

import Foundation

/// Supports a list of editable biome values
class EditableBiomeValues {
    /// Sorts all biomes by moisture and elevation so they draw right
    private static func sortedBiomes(_ biomes: [Biome]) -> [Biome] {
        biomes.sorted { (a, b) -> Bool in
            a.maxMoisture < b.maxMoisture
                && a.maxElevation - a.minElevation < b.maxElevation - b.minElevation
        }
    }

    /// All editable biome values (list)
    private var biomeValues: [EditableBiomeValue]

    /// Update delegate passthrough
    weak var updateDelegate: ConfigUpdateDelegate? {
        didSet {
            biomeValues.forEach { $0.updateDelegate = updateDelegate }
        }
    }

    /// Biome change delegate passthrough
    weak var biomeChangeDelegate: BiomeChangeDelegate? {
        didSet {
            biomeValues.forEach { $0.biomeChangeDelegate = biomeChangeDelegate }
        }
    }

    /// The list of values, turned into their current values
    var values: [Biome] {
        biomeValues.map(\.value)
    }

    /// Creates a list of biome data using a list of biomes to start
    init(biomes: [Biome] = []) {
        biomeValues = EditableBiomeValues.sortedBiomes(biomes).map { EditableBiomeValue($0) }
    }

    /// Adds all biome edit fields to a stack view and one overview biome view
    func addValues(to stackView: EditableValuesStackView) {
        var counts: [BiomeType: Int] = [:]
        for biomeValue in biomeValues {
            biomeValue.updateDelegate = updateDelegate
            biomeValue.biomeChangeDelegate = biomeChangeDelegate
            counts[biomeValue.value.type] = (counts[biomeValue.value.type] ?? 0) + 1
            biomeValue.addValues(to: stackView, index: counts[biomeValue.value.type] ?? 0)
        }
    }

    /// Modifies all biomes to a new set of values (useful for presets resetting data)
    func changeValues(to biomes: [Biome]) {
        biomeValues = EditableBiomeValues.sortedBiomes(biomes).map { EditableBiomeValue($0) }
    }
}
