// EditableFBMConfigValues.swift
// Copyright (c) 2020 Dylan Gattey

import EngineCore
import EngineData
import Foundation

/// Creates and holds onto a group of editable config values for FBMData
public class EditableFBMConfigValues {
    /// Update delegate passthrough
    public weak var updateDelegate: ConfigUpdateDelegate? {
        didSet {
            octaves.updateDelegate = updateDelegate
            persistence.updateDelegate = updateDelegate
            scale.updateDelegate = updateDelegate
            compression.updateDelegate = updateDelegate
        }
    }

    public let octaves: EditableConfigValue<Int32>
    public let persistence: EditableConfigValue<Float>
    public let scale: EditableConfigValue<Float>
    public let compression: EditableConfigValue<Float>

    /// Creates a list of config values from a title for the fbm data and default data
    public init(defaultData: FBMData) {
        octaves = EditableConfigValue(fallback: defaultData.octaves, label: "Octaves")
        persistence = EditableConfigValue(fallback: defaultData.persistence, label: "Persistence")
        scale = EditableConfigValue(fallback: defaultData.scale, label: "Scale")
        compression = EditableConfigValue(fallback: defaultData.compression, label: "Compression")
    }

    /// Adds the config values saved here to a given stack view (in reverse!)
    public func addValues(to stackView: EditableValuesStackView) {
        EditableValuesStackView.addValue(stackView)(octaves)
        EditableValuesStackView.addValue(stackView)(persistence)
        EditableValuesStackView.addValue(stackView)(scale)
        EditableValuesStackView.addValue(stackView)(compression)
    }

    /// Changes current values to new values from the data passed in
    public func changeValues(to values: FBMData) {
        octaves.changeValue(to: values.octaves)
        persistence.changeValue(to: values.persistence)
        scale.changeValue(to: values.scale)
        compression.changeValue(to: values.compression)
    }

    /// Creates FBMData from all fields with a provided seed
    public func value(withSeed seed: uint) -> FBMData {
        FBMData(octaves: octaves.value,
                persistence: persistence.value,
                scale: scale.value,
                compression: compression.value,
                seed: seed)
    }
}
