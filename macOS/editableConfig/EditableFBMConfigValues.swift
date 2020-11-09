//
//  EditableFBMConfigValues.swift
//  Genera
//
//  Created by Dylan Gattey on 11/7/20.
//

import Foundation

/// Creates and holds onto a group of editable config values for FBMData
class EditableFBMConfigValues {
    
    /// Update delegate passthrough
    weak var updateDelegate: ConfigUpdateDelegate? {
        didSet {
            octaves.updateDelegate = updateDelegate
            persistence.updateDelegate = updateDelegate
            scale.updateDelegate = updateDelegate
            compression.updateDelegate = updateDelegate
        }
    }
    
    let octaves: EditableConfigValue<Int32>
    let persistence: EditableConfigValue<Float>
    let scale: EditableConfigValue<Float>
    let compression: EditableConfigValue<Float>
    
    /// Creates a list of config values from a title for the fbm data and default data
    init(defaultData: FBMData) {
        octaves = EditableConfigValue(fallback: defaultData.octaves, label: "Octaves")
        persistence = EditableConfigValue(fallback: defaultData.persistence, label: "Persistence")
        scale = EditableConfigValue(fallback: defaultData.scale, label: "Scale")
        compression = EditableConfigValue(fallback: defaultData.compression, label: "Compression")
    }
    
    /// Adds the config values saved here to a given stack view (in reverse!)
    func addValues(to stackView: EditableValuesStackView) {
        EditableValuesStackView.addValue(stackView)(octaves)
        EditableValuesStackView.addValue(stackView)(persistence)
        EditableValuesStackView.addValue(stackView)(scale)
        EditableValuesStackView.addValue(stackView)(compression)
    }
}
