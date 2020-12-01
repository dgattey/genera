// TerrainConfigView.swift
// Copyright (c) 2020 Dylan Gattey

import AppKit
import Combine
import Debug
import Engine
import EngineUI

/// A stack view containing text fields for certain configurable data
class TerrainConfigView: NSStackView {
    // MARK: - constants

    private static let interItemSpacing: CGFloat = 48

    // MARK: - variables

    /// To keep track of saving the preset
    private var savePresetCancellable: AnyCancellable?

    /// Update delegate, needs to be set for ALLLL the values. This is tedious
    weak var updateDelegate: ConfigUpdateDelegate? {
        didSet {
            seed.updateDelegate = updateDelegate
            globalScalar.updateDelegate = updateDelegate

            elevationFBM.updateDelegate = updateDelegate
            seaLevelOffset.updateDelegate = updateDelegate
            elevationDistribution.updateDelegate = updateDelegate
            elevationColorWeight.updateDelegate = updateDelegate

            moistureFBM.updateDelegate = updateDelegate
            aridness.updateDelegate = updateDelegate
            moistureDistribution.updateDelegate = updateDelegate
            moistureColorWeight.updateDelegate = updateDelegate

            biomes.updateDelegate = updateDelegate
        }
    }

    /// Seed for generation of the map (string)
    private let seed = EditableConfigValue(
        fallback: TerrainPresetData.default.seed,
        label: "Terrain seed"
    )

    /// Scaling constant for all coordinates on the map
    private let globalScalar = EditableConfigValue(
        fallback: TerrainPresetData.default.globalScalar,
        label: "Global scalar"
    )

    /// FBM values for elevation noise generation
    private let elevationFBM = EditableFBMConfigValues(defaultData: TerrainPresetData.default.elevationFBM)

    /// As a float, how far off of zero we should make sea level
    private let seaLevelOffset = EditableConfigValue(
        fallback: TerrainPresetData.default.seaLevelOffset,
        label: "Sea level offset"
    )

    /// The distribution of values (spiky or not) for elevation
    private let elevationDistribution = EditableConfigValue(
        fallback: TerrainPresetData.default.elevationDistribution,
        label: "Elevation distribution"
    )

    /// How much elevation contributes to color of the biome
    private let elevationColorWeight = EditableConfigValue(
        fallback: TerrainPresetData.default.elevationColorWeight,
        label: "Color weight"
    )

    /// FBM values for moisture noise generation
    private let moistureFBM = EditableFBMConfigValues(defaultData: TerrainPresetData.default.moistureFBM)

    /// How dry "default" is on the map
    private let aridness = EditableConfigValue(
        fallback: TerrainPresetData.default.aridness,
        label: "Aridness"
    )

    /// The distribution of values (spiky or not) for moisture
    private let moistureDistribution = EditableConfigValue(
        fallback: TerrainPresetData.default.moistureDistribution,
        label: "Moisture distribution"
    )

    /// How much moisture contributes to color of the biome
    private let moistureColorWeight = EditableConfigValue(
        fallback: TerrainPresetData.default.moistureColorWeight,
        label: "Color weight"
    )

    /// A grid view for all the biome color data at a glance
    private lazy var biomeOverviewView: BiomeOverview = {
        let view = BiomeOverview()
        biomes.biomeChangeDelegate = view
        view.heightAnchor.constraint(greaterThanOrEqualToConstant: 200).isActive = true
        return view
    }()

    /// All current biome values, defaulted to all default biomes
    private let biomes = EditableBiomeValues(biomes: Biome.defaultBiomes)

    /// The biome views
    private let biomeView = EditableValuesStackView()

    // MARK: - API

    /// Adds a nested stack view with equal widths
    private func addView(_ view: EditableValuesStackView) {
        addView(view, in: .bottom)
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    /// Add our views!
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        orientation = .vertical
        alignment = .leading
        distribution = .fill
        spacing = TerrainConfigView.interItemSpacing

        let presetView = TerrainPresetView(title: "Presets")
        presetView.presetDelegate = self
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
    }

    private func resetBiomesView() {
        biomeView.views.forEach { $0.removeFromSuperview() }
        biomeView.addView(biomeOverviewView, in: .bottom)
        biomes.addValues(to: biomeView)
    }
}

// MARK: - ShaderDataProviderProtocol

/// Creates a bunch of biomes & offers config support from this view's text fields
extension TerrainConfigView: ShaderDataProviderProtocol {
    /// Config data for generation of noise, pulls data from text fields if they exist
    var configData: TerrainShaderConfigData {
        return preset().shaderConfigData
    }

    /// Bunch of biomes with different elevation and moistures
    var allBiomes: [Biome] {
        return biomes.values
    }
}

// MARK: - TerrainPresetDelegate

extension TerrainConfigView: TerrainPresetDelegate {
    /// Creates a preset with the current data and a preset name
    private func preset(named name: String = "") -> TerrainPresetData {
        return TerrainPresetData(
            presetName: name,
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
            biomes: allBiomes
        )
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
        biomes.changeValues(to: preset.biomes)
        resetBiomesView()
    }

    /// Called when the user wants to save the current data as a preset
    func saveCurrentDataAsPreset(named name: String, onCompletion completion: @escaping (_ presetName: String) -> Void) {
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
