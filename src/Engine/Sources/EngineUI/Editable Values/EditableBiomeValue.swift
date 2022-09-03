// EditableBiomeValue.swift
// Copyright (c) 2022 Dylan Gattey

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

    /// The current cancellable for listening to all the values
    private var cancellables: Set<AnyCancellable> = []

    /// To (re) publish actions to listeners
    private let editableActionPublisher = PassthroughSubject<EditableConfigAction, Never>()

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

        setupSubscribersAndPublishers()
    }

    /// When the value gets created, sets up internal publishers/subscribers so we
    /// can republish to whoever wants to listen to changes
    private func setupSubscribersAndPublishers() {
        let publishers = [minElevation,
                          maxElevation,
                          maxMoisture,
                          blendRange]
        let combinedPublisher = Publishers.MergeMany(publishers)

        // Any of the values changing should JUST update the biome
        let cancellable1 = combinedPublisher.sink(receiveValue: { [unowned self] action in
            switch action {
            case .changeValue:
                biome.send(value)
            }
        })

        // Sink on the biome and republish to the editable action republisher
        let cancellable2 = biome.sink(receiveValue: { [unowned self] _ in
            editableActionPublisher.send(.changeValue)
        })

        // Update the cancellables so we don't lose a reference
        cancellables.removeAll()
        cancellables.insert(cancellable1)
        cancellables.insert(cancellable2)
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

    /// Called when the user picks a color to update the biome
    @objc func userDidPickColor() {
        biome.send(value)
    }
}

// MARK: - Publisher

extension EditableBiomeValue: Publisher {
    public typealias Output = EditableConfigAction
    public typealias Failure = Never

    /// Connect the re-publisher to the subscriber sent
    public func receive<S>(subscriber: S)
        where S: Subscriber,
        EditableBiomeValue.Failure == S.Failure,
        EditableBiomeValue.Output == S.Input
    {
        editableActionPublisher.receive(subscriber: subscriber)
    }
}
