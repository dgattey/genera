// EditableBiomeValue.swift
// Copyright (c) 2020 Dylan Gattey

import AppKit
import Combine
import EngineCore
import EngineData
import UI

/// Contains all the fields to change the values of a particular biome (not its type!)
class EditableBiomeValue {
    /// The min size of the color well
    private static let colorWellMinSize: CGFloat = 60

    /// The immutable biome type
    private let biomeType: BiomeType

    /// The color picker itself, configured
    private lazy var colorWell: NSColorWell = {
        let colorWell = NSColorWell()
        colorWell.isBordered = true
        colorWell.controlSize = .large
        colorWell.widthAnchor.constraint(greaterThanOrEqualToConstant: EditableBiomeValue.colorWellMinSize)
            .isActive = true
        colorWell.heightAnchor.constraint(greaterThanOrEqualToConstant: EditableBiomeValue.colorWellMinSize)
            .isActive = true
        colorWell.action = #selector(userDidPickColor)
        colorWell.target = self
        return colorWell
    }()

    /// Minimum elevation this biome exists at
    private let minElevation: EditableConfigValue<Float>

    /// Maximum elevation this biome exists at
    private let maxElevation: EditableConfigValue<Float>

    /// Maximum amount of moisture this biome supports
    private let maxMoisture: EditableConfigValue<Float>

    /// Range of values in which the color is blended
    private let blendRange: EditableConfigValue<Float>

    /// The label this value has if it's contained in the view
    let label: String

    /// Sends the latest value of this value + label to anyone listening
    let biome: CurrentValueSubject<Biome, Never>

    /// Constructs a biome out of the fields' current data - used to update `biome`
    private var value: Biome {
        guard let convertedColor = colorWell.color.usingColorSpace(.deviceRGB) else {
            fatalError("Couldn't convert color")
        }
        return Biome(type: biomeType,
                     color: vector_float3(Float(convertedColor.redComponent),
                                          Float(convertedColor.greenComponent),
                                          Float(convertedColor.blueComponent)),
                     minElevation: minElevation.value,
                     maxElevation: maxElevation.value,
                     maxMoisture: maxMoisture.value,
                     blendRange: blendRange.value)
    }

    /// Update delegate passthrough
    weak var updateDelegate: ConfigUpdateDelegate?

    /// Creates fields out of the initial values and the index of where we're at
    init(_ initialValue: Biome, index: Int) {
        let suffix = index > 1 ? " \(index)" : ""
        label = "\(initialValue.type.description) \(suffix)"
        biome = CurrentValueSubject(initialValue)

        biomeType = initialValue.type
        minElevation = EditableConfigValue(fallback: initialValue.minElevation, label: "Min elevation")
        maxElevation = EditableConfigValue(fallback: initialValue.maxElevation, label: "Max elevation")
        maxMoisture = EditableConfigValue(fallback: initialValue.maxMoisture, label: "Max moisture")
        blendRange = EditableConfigValue(fallback: initialValue.maxMoisture, label: "Range of color blending")
        colorWell.color = initialValue.nsColor

        minElevation.updateDelegate = self
        maxElevation.updateDelegate = self
        maxMoisture.updateDelegate = self
        blendRange.updateDelegate = self
    }

    /// Adds the config values saved here to a given stack view
    func addValues(to stackView: EditableValuesStackView) {
        LabeledView.addLabel(label, style: .smallSection, toStack: stackView)
        stackView.addView(colorWell, in: .bottom)
        EditableValuesStackView.addValue(stackView)(minElevation)
        EditableValuesStackView.addValue(stackView)(maxElevation)
        EditableValuesStackView.addValue(stackView)(maxMoisture)
        EditableValuesStackView.addValue(stackView)(blendRange)
    }

    /// Called when the user picks a color
    @objc func userDidPickColor() {
        configDidUpdate(from: nil, to: colorWell.color)
    }
}

// MARK: ConfigUpdateDelegate

extension EditableBiomeValue: ConfigUpdateDelegate {
    /// Notifies both our update delegate and the biome delegate
    func configDidUpdate<T>(from: T?, to: T?) {
        updateDelegate?.configDidUpdate(from: from, to: to)
        biome.send(value)
    }
}
