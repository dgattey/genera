// EditableBiomeValues.swift
// Copyright (c) 2020 Dylan Gattey

import EngineCore
import EngineData
import Foundation
import UI

/// Supports a list of editable biome values
public class EditableBiomeValues {
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
    public weak var updateDelegate: ConfigUpdateDelegate? {
        didSet {
            biomeValues.forEach { $0.updateDelegate = updateDelegate }
        }
    }

    /// Biome change delegate passthrough
    public weak var biomeChangeDelegate: BiomeChangeDelegate? {
        didSet {
            biomeValues.forEach { $0.biomeChangeDelegate = biomeChangeDelegate }
        }
    }

    /// The list of values, turned into their current values
    public var values: [Biome] {
        biomeValues.map(\.value)
    }

    /// Creates a list of biome data using a list of biomes to start
    public init(biomes: [Biome] = []) {
        biomeValues = EditableBiomeValues.sortedBiomes(biomes).map { EditableBiomeValue($0) }
    }

    /// Adds all biome edit fields to a stack view and one overview biome view
    public func addValues(to stackView: EditableValuesStackView) {
        LabeledView.addLabel("Biomes", style: .section, toStack: stackView)
        var counts: [BiomeType: Int] = [:]
        for biomeValue in biomeValues {
            biomeValue.updateDelegate = updateDelegate
            biomeValue.biomeChangeDelegate = biomeChangeDelegate
            counts[biomeValue.value.type] = (counts[biomeValue.value.type] ?? 0) + 1
            biomeValue.addValues(to: stackView, index: counts[biomeValue.value.type] ?? 0)
        }
    }

    /// Modifies all biomes to a new set of values (useful for presets resetting data)
    public func changeValues(to biomes: [Biome]) {
        biomeValues = EditableBiomeValues.sortedBiomes(biomes).map { EditableBiomeValue($0) }
    }
}
