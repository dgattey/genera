// EditableBiomeValue.swift
// Copyright (c) 2020 Dylan Gattey

// TODO: @dgattey try to remove dependency on AppKit
import AppKit
import Engine
import EngineData
import UI

/// Contains all the fields to change the values of a particular biome (not its type!)
class EditableBiomeValue {
    /// The min size of the color well
    private static let colorWellMinSize: CGFloat = 60

    /// To notify with biome changes
    weak var biomeChangeDelegate: BiomeChangeDelegate? {
        didSet {
            // Make sure it gets updated once
            guard !label.isEmpty else {
                return
            }
            biomeChangeDelegate?.biome(withIdentifier: label, didUpdateTo: value)
        }
    }

    /// The immutable biome type
    private let biomeType: BiomeType

    /// The color picker itself, configured
    private lazy var colorWell: NSColorWell = {
        let colorWell = NSColorWell()
        colorWell.isBordered = true
        colorWell.controlSize = .large
        colorWell.widthAnchor.constraint(greaterThanOrEqualToConstant: EditableBiomeValue.colorWellMinSize).isActive = true
        colorWell.heightAnchor.constraint(greaterThanOrEqualToConstant: EditableBiomeValue.colorWellMinSize).isActive = true
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
    private(set) var label: String = ""

    /// Update delegate passthrough
    weak var updateDelegate: ConfigUpdateDelegate?

    /// Creates fields out of the initial values
    init(_ initialValue: Biome) {
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
    func addValues(to stackView: EditableValuesStackView, index: Int) {
        let suffix = index > 1 ? " \(index)" : ""
        label = "\(biomeType.description) \(suffix)"
        LabeledView.addLabel(label, style: .smallSection, toStack: stackView)
        stackView.addView(colorWell, in: .bottom)
        EditableValuesStackView.addValue(stackView)(minElevation)
        EditableValuesStackView.addValue(stackView)(maxElevation)
        EditableValuesStackView.addValue(stackView)(maxMoisture)
        EditableValuesStackView.addValue(stackView)(blendRange)

        biomeChangeDelegate?.biome(withIdentifier: label, didUpdateTo: value)
    }

    /// Constructs a biome out of the fields' current data
    var value: Biome {
        return Biome(
            type: biomeType,
            color: vector_float3(
                Float(colorWell.color.redComponent),
                Float(colorWell.color.greenComponent),
                Float(colorWell.color.blueComponent)
            ),
            minElevation: minElevation.value,
            maxElevation: maxElevation.value,
            maxMoisture: maxMoisture.value,
            blendRange: blendRange.value
        )
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
        biomeChangeDelegate?.biome(withIdentifier: label, didUpdateTo: value)
    }
}
