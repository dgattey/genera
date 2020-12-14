// EditableBiomeValues.swift
// Copyright (c) 2020 Dylan Gattey

import Combine
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

    // MARK: - static helpers

    /// Creates all the editable values from a list of unsorted biomes
    private static func biomeValues(from biomes: [Biome]) -> [EditableBiomeValue] {
        var counts: [BiomeType: Int] = [:]
        return sortedBiomes(biomes).map { biome in
            // Keep track of how many of this type we have so we can index them
            let count = (counts[biome.type] ?? 0) + 1
            counts[biome.type] = count
            return EditableBiomeValue(biome, index: count)
        }
    }

    // MARK: - variables

    /// All editable biome values to keep internally - the useful values are exposed elsewhere
    private let editableValues: [EditableBiomeValue]

    /// Exposes the data captured by this class, for anything that needs it
    public let data: [(label: String, biome: CurrentValueSubject<Biome, Never>)]

    // MARK: - value manipulation

    /// Creates a list of biome data using a list of biomes to start
    public init(biomes: [Biome] = []) {
        editableValues = EditableBiomeValues.biomeValues(from: biomes)
        data = editableValues.map { ($0.label, $0.biome) }
    }

    /// Adds all biome edit fields to a stack view and one overview biome view
    public func addValues(to stackView: EditableValuesStackView) {
        LabeledView.addLabel("Biomes", style: .section, toStack: stackView)
        for biomeValue in editableValues {
            biomeValue.addValues(to: stackView)
        }
    }
}

// MARK: - Publisher

extension EditableBiomeValues: Publisher {
    public typealias Output = EditableConfigAction
    public typealias Failure = Never

    /// Connect the fields' publishers to the subscriber sent
    public func receive<S>(subscriber: S)
        where S: Subscriber,
        EditableBiomeValues.Failure == S.Failure,
        EditableBiomeValues.Output == S.Input
    {
        Publishers.MergeMany(editableValues).subscribe(subscriber)
    }
}
