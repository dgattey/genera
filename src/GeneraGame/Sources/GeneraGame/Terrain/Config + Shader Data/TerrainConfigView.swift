// TerrainConfigView.swift
// Copyright (c) 2022 Dylan Gattey

import AppKit
import Combine
import Debug
import Engine

/// A stack view containing text fields for certain configurable data
class TerrainConfigView: NSStackView {
    // MARK: - constants

    private static let interItemSpacing: CGFloat = 48

    // MARK: - variables

    /// To keep track of saving the preset
    private var savePresetCancellable: AnyCancellable?

    /// To keep track of handling actions
    private var actionCancellable: AnyCancellable?

    /// To (re) publish actions to listeners
    private let editableActionPublisher = PassthroughSubject<EditableConfigAction, Never>()

    /// Seed for generation of the map (string)
    private let seed = EditableConfigValue(fallback: TerrainPresetData.default.seed,
                                           label: "Terrain seed")

    /// Scaling constant for all coordinates on the map
    private let globalScalar = EditableConfigValue(fallback: TerrainPresetData.default.globalScalar,
                                                   label: "Global scalar")

    /// FBM values for elevation noise generation
    private let elevationFBM = EditableFBMConfigValues(defaultData: TerrainPresetData.default.elevationFBM)

    /// As a float, how far off of zero we should make sea level
    private let seaLevelOffset = EditableConfigValue(fallback: TerrainPresetData.default.seaLevelOffset,
                                                     label: "Sea level offset")

    /// The distribution of values (spiky or not) for elevation
    private let elevationDistribution = EditableConfigValue(fallback: TerrainPresetData.default.elevationDistribution,
                                                            label: "Elevation distribution")

    /// How much elevation contributes to color of the biome
    private let elevationColorWeight = EditableConfigValue(fallback: TerrainPresetData.default.elevationColorWeight,
                                                           label: "Color weight")

    /// FBM values for moisture noise generation
    private let moistureFBM = EditableFBMConfigValues(defaultData: TerrainPresetData.default.moistureFBM)

    /// How dry "default" is on the map
    private let aridness = EditableConfigValue(fallback: TerrainPresetData.default.aridness,
                                               label: "Aridness")

    /// The distribution of values (spiky or not) for moisture
    private let moistureDistribution = EditableConfigValue(fallback: TerrainPresetData.default.moistureDistribution,
                                                           label: "Moisture distribution")

    /// How much moisture contributes to color of the biome
    private let moistureColorWeight = EditableConfigValue(fallback: TerrainPresetData.default.moistureColorWeight,
                                                          label: "Color weight")

    /// A grid view for all the biome color data at a glance
    private lazy var biomeOverviewView: BiomeOverview = {
        let view = BiomeOverview()
        view.connect(to: biomes)
        view.heightAnchor.constraint(greaterThanOrEqualToConstant: 200).isActive = true
        return view
    }()

    /// All current biome values, defaulted to all default biomes
    private var biomes = EditableBiomeValues(biomes: Biome.defaultBiomes)

    /// The biome views
    private let biomeView = EditableValuesStackView()

    // MARK: - API

    /// Adds a nested stack view with equal widths
    private func addView(_ view: EditableValuesStackView) {
        addView(view, in: .bottom)
        NSLayoutConstraint.activate([view.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     view.trailingAnchor.constraint(equalTo: trailingAnchor)])
    }

    /// Add our views!
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        orientation = .vertical
        alignment = .leading
        distribution = .fill
        spacing = TerrainConfigView.interItemSpacing

        let presetView = TerrainPresetView(title: "Presets")
        presetView.populatePresets()
        addView(presetView)

        let sharedView = EditableValuesStackView(title: "Global Config")
        sharedView.addValue(seed)
        sharedView.addValue(globalScalar)
        addView(sharedView)

        let elevationView = EditableValuesStackView(title: "Elevation Config")
        elevationFBM.addValues(to: elevationView)
        elevationView.addValue(seaLevelOffset)
        elevationView.addValue(elevationDistribution)
        elevationView.addValue(elevationColorWeight)
        addView(elevationView)

        let moistureView = EditableValuesStackView(title: "Moisture Config")
        moistureFBM.addValues(to: moistureView)
        moistureView.addValue(aridness)
        moistureView.addValue(moistureDistribution)
        moistureView.addValue(moistureColorWeight)
        addView(moistureView)

        addView(biomeView)
        resetBiomesView()

        // Start listening to actions from the preset view
        actionCancellable = presetView.sink { [unowned self] action in
            switch action {
            case let .selectPreset(withData: data):
                selectPreset(data)
                return
            case let .saveCurrentData(asPresetNamed: name, onCompletion: completion):
                saveCurrentDataAsPreset(named: name, onCompletion: completion)
                return
            }
        }
    }

    /// Resets biome view and biome overview view
    private func resetBiomesView() {
        biomeView.views.forEach { $0.removeFromSuperview() }
        biomeView.addView(biomeOverviewView, in: .bottom)
        biomeOverviewView.connect(to: biomes)
        biomes.addValues(to: biomeView)
        resubscribe()
    }

    /// Resubscribes self to all current values
    private func resubscribe() {
        let publishers = [seed.eraseToAnyPublisher(),
                          globalScalar.eraseToAnyPublisher(),
                          elevationFBM.eraseToAnyPublisher(),
                          seaLevelOffset.eraseToAnyPublisher(),
                          elevationDistribution.eraseToAnyPublisher(),
                          elevationColorWeight.eraseToAnyPublisher(),
                          moistureFBM.eraseToAnyPublisher(),
                          aridness.eraseToAnyPublisher(),
                          moistureDistribution.eraseToAnyPublisher(),
                          moistureColorWeight.eraseToAnyPublisher(),
                          biomes.eraseToAnyPublisher()]
        Publishers.MergeMany(publishers).subscribe(self)
    }

    // MARK: - Presets

    /// Creates a preset with the current data and a preset name
    private func preset(named name: String = "") -> TerrainPresetData {
        TerrainPresetData(presetName: name,
                          seed: seed.value,
                          globalScalar: globalScalar.value,
                          seaLevelOffset: seaLevelOffset.value,
                          elevationDistribution: elevationDistribution.value,
                          aridness: aridness.value,
                          moistureDistribution: moistureDistribution.value,
                          elevationFBM: elevationFBM.value(withSeed: Self.seed(from: seed.value)),
                          moistureFBM: moistureFBM.value(withSeed: Self.seed(from: seed.value)),
                          elevationColorWeight: elevationColorWeight.value,
                          moistureColorWeight: moistureColorWeight.value,
                          biomes: allBiomes)
    }

    /// Called when the user selects the given preset to change all values
    func selectPreset(_ preset: TerrainPresetData) {
        seed.changeValue(to: preset.seed)
        globalScalar.changeValue(to: preset.globalScalar)

        elevationFBM.changeValues(to: preset.elevationFBM)
        seaLevelOffset.changeValue(to: preset.seaLevelOffset)
        elevationDistribution.changeValue(to: preset.elevationDistribution)
        elevationColorWeight.changeValue(to: preset.elevationColorWeight)

        moistureFBM.changeValues(to: preset.moistureFBM)
        aridness.changeValue(to: preset.aridness)
        moistureDistribution.changeValue(to: preset.moistureDistribution)
        moistureColorWeight.changeValue(to: preset.moistureColorWeight)

        /// Reset the biome views entirely
        biomes = EditableBiomeValues(biomes: preset.biomes)
        resetBiomesView()
    }

    /// Called when the user wants to save the current data as a preset
    func saveCurrentDataAsPreset(named name: String,
                                 onCompletion completion: @escaping (_ presetName: String) -> Void)
    {
        savePresetCancellable?.cancel()
        savePresetCancellable = TerrainPresetLoader
            .savePreset(preset(named: name))
            .sink(receiveCompletion: { result in
                if case let .failure(error) = result {
                    Logger.log(error)
                }
            }, receiveValue: completion)
    }
}

// MARK: - ShaderDataProviderProtocol

/// Creates a bunch of biomes & offers config support from this view's text fields
extension TerrainConfigView: ShaderDataProviderProtocol {
    /// Converts self to a publisher of the right data
    var asPublisher: AnyPublisher<EditableConfigAction, Never>? {
        eraseToAnyPublisher()
    }

    /// Config data for generation of noise, pulls data from text fields if they exist
    var configData: TerrainShaderConfigData {
        preset().shaderConfigData
    }

    /// Bunch of biomes with different elevation and moistures
    var allBiomes: [Biome] {
        biomes.data.map(\.biome.value)
    }
}

// MARK: - Publisher

extension TerrainConfigView: Publisher {
    public typealias Output = EditableConfigAction
    public typealias Failure = Never

    /// Connect the built-in editable action publisher to the subscriber sent
    public func receive<S>(subscriber: S)
        where S: Subscriber,
        TerrainConfigView.Failure == S.Failure,
        TerrainConfigView.Output == S.Input
    {
        editableActionPublisher.subscribe(subscriber)
    }
}

// MARK: - Subscriber

/// Subscribes this view to just republish to the editable action publisher
extension TerrainConfigView: Subscriber {
    typealias Input = EditableConfigAction

    /// Request unlimited items
    func receive(subscription: Subscription) {
        subscription.request(.unlimited)
    }

    /// Re-send to the never-changing editable action publisher
    func receive(_ action: EditableConfigAction) -> Subscribers.Demand {
        editableActionPublisher.send(action)
        return .none
    }

    /// No-op
    func receive(completion _: Subscribers.Completion<Never>) {}
}
