//
//  EditableFBMConfigValues.swift
//  Genera
//
//  Created by Dylan Gattey on 11/7/20.
//

import Foundation

/// Creates and holds onto a group of editable config values for FBMData
class EditableFBMConfigValues {
    
    let octaves: EditableConfigValue<Int32>
    let persistence: EditableConfigValue<Float>
    let scale: EditableConfigValue<Float>
    let frequency: EditableConfigValue<Float>
    let compression: EditableConfigValue<Float>
    
    /// Creates a list of config values from a title for the fbm data and default data
    init(defaultData: FBMData) {
        octaves = EditableConfigValue(fallback: defaultData.octaves, label: "Octaves")
        persistence = EditableConfigValue(fallback: defaultData.persistence, label: "Persistence")
        scale = EditableConfigValue(fallback: defaultData.scale, label: "Scale")
        frequency = EditableConfigValue(fallback: defaultData.frequency, label: "Frequency")
        compression = EditableConfigValue(fallback: defaultData.compression, label: "Compression")
    }
}
