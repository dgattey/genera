//
//  EditableBiomeValue.swift
//  Genera
//
//  Created by Dylan Gattey on 11/9/20.
//

import Foundation

/// Contains all the fields to change the values of a particular biome (not its type!)
class EditableBiomeValue {
    
    /// The immutable biome type
    private let biomeType: BiomeType
    
    /// The red portion of the color
    private let colorR: EditableConfigValue<Float>
    
    /// The green portion of the color
    private let colorG: EditableConfigValue<Float>
    
    /// The blue portion of the color
    private let colorB: EditableConfigValue<Float>
    
    /// Minimum elevation this biome exists at
    private let minElevation: EditableConfigValue<Float>
    
    /// Maximum elevation this biome exists at
    private let maxElevation: EditableConfigValue<Float>
    
    /// Maximum amount of moisture this biome supports
    private let maxMoisture: EditableConfigValue<Float>
    
    /// Range of values in which the color is blended
    private let blendRange: EditableConfigValue<Float>
    
    /// Update delegate passthrough
    weak var updateDelegate: ConfigUpdateDelegate? {
        didSet {
            colorR.updateDelegate = updateDelegate
            colorG.updateDelegate = updateDelegate
            colorB.updateDelegate = updateDelegate
            minElevation.updateDelegate = updateDelegate
            maxElevation.updateDelegate = updateDelegate
            maxMoisture.updateDelegate = updateDelegate
            blendRange.updateDelegate = updateDelegate
        }
    }
    
    /// Creates fields out of the initial values
    init(_ initialValue: Biome) {
        biomeType = initialValue.type
        colorR = EditableConfigValue(fallback: initialValue.color.x, label: "Color Red %")
        colorG = EditableConfigValue(fallback: initialValue.color.y, label: "Color Green %")
        colorB = EditableConfigValue(fallback: initialValue.color.z, label: "Color Blue %")
        minElevation = EditableConfigValue(fallback: initialValue.minElevation, label: "Min elevation")
        maxElevation = EditableConfigValue(fallback: initialValue.maxElevation, label: "Max elevation")
        maxMoisture = EditableConfigValue(fallback: initialValue.maxMoisture, label: "Max moisture")
        blendRange = EditableConfigValue(fallback: initialValue.maxMoisture, label: "Range of color blending")
    }
    
    /// Adds the config values saved here to a given stack view
    func addValues(to stackView: EditableValuesStackView, index: Int) {
        let suffix = index > 1 ? " \(index)" : ""
        LabeledView.addLabel("\(biomeType.description) \(suffix)", style: .smallSection, toStack: stackView)
        EditableValuesStackView.addValue(stackView)(colorR)
        EditableValuesStackView.addValue(stackView)(colorG)
        EditableValuesStackView.addValue(stackView)(colorB)
        EditableValuesStackView.addValue(stackView)(minElevation)
        EditableValuesStackView.addValue(stackView)(maxElevation)
        EditableValuesStackView.addValue(stackView)(maxMoisture)
        EditableValuesStackView.addValue(stackView)(blendRange)
    }
    
    /// Constructs a biome out of the fields' current data
    var value: Biome {
        return Biome(
            type: biomeType,
            color: vector_float3(colorR.value, colorG.value, colorB.value),
            minElevation: minElevation.value,
            maxElevation: maxElevation.value,
            maxMoisture: maxMoisture.value,
            blendRange: blendRange.value
        )
    }
    
}
