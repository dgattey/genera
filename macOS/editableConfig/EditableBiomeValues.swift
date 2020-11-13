//
//  EditableBiomeValues.swift
//  Genera
//
//  Created by Dylan Gattey on 11/9/20.
//

import Foundation

/// Supports a list of editable biome values
class EditableBiomeValues {
    
    /// All editable biome values (list)
    private var biomeValues: [EditableBiomeValue]
    
    /// Update delegate passthrough
    weak var updateDelegate: ConfigUpdateDelegate? {
        didSet {
            biomeValues.forEach({ $0.updateDelegate = updateDelegate })
        }
    }
    
    /// The list of values, turned into their current values
    var values: [Biome] {
        return biomeValues.map({ $0.value })
    }
    
    /// Creates a list of biome data using a list of biomes to start
    init(biomes: [Biome] = []) {
        self.biomeValues = biomes.map({ EditableBiomeValue($0) })
    }
    
    /// Adds all biome edit fields to a stack view
    func addValues(to stackView: EditableValuesStackView) {
        var counts: [BiomeType: Int] = [:]
        for biomeValue in biomeValues {
            counts[biomeValue.value.type] = (counts[biomeValue.value.type] ?? 0) + 1
            biomeValue.addValues(to: stackView, index: counts[biomeValue.value.type] ?? 0)
        }
    }
    
    /// Modifies all biomes to a new set of values (useful for presets resetting data)
    func changeValues(to biomes: [Biome]) {
        biomeValues = biomes.map({ biome in
            let value = EditableBiomeValue(biome)
            value.updateDelegate = updateDelegate
            return value
        })
    }
    
}
