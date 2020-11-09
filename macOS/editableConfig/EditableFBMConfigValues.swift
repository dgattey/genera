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
    
    /// Changes current values to new values from the data passed in
    func changeValues(to values: FBMData) {
        octaves.changeValue(to: values.octaves)
        persistence.changeValue(to: values.persistence)
        scale.changeValue(to: values.scale)
        compression.changeValue(to: values.compression)
    }
    
    /// Creates FBMData from all fields with a provided seed
    func value(withSeed seed: uint) -> FBMData {
        return FBMData(
            octaves: octaves.value,
            persistence: persistence.value,
            scale: scale.value,
            compression: compression.value,
            seed: seed)
    }
}
