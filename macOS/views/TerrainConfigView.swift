//
//  TerrainConfigView.swift
//  Genera
//
//  Created by Dylan Gattey on 11/5/20.
//

import AppKit

/// A stack view containing text fields for certain configurable data
class TerrainConfigView: NSStackView {
    
    // MARK: - variables
    
    /// Update delegate, needs to be set for ALLLL the values. This is tedious
    weak var updateDelegate: ConfigUpdateDelegate? {
        didSet {
            moistureValues.updateDelegate = updateDelegate
            seed.updateDelegate = updateDelegate
            globalScalar.updateDelegate = updateDelegate
            elevationValues.updateDelegate = updateDelegate
            seaLevelOffset.updateDelegate = updateDelegate
            elevationDistribution.updateDelegate = updateDelegate
            elevationColorWeight.updateDelegate = updateDelegate
            moistureValues.updateDelegate = updateDelegate
            aridness.updateDelegate = updateDelegate
            moistureDistribution.updateDelegate = updateDelegate
            moistureColorWeight.updateDelegate = updateDelegate
        }
    }
    
    /// Seed for generation of the map (string)
    private let seed = EditableConfigValue(
        fallback: DefaultTerrainData.seed,
        label: "Terrain seed")
    
    /// Scaling constant for all coordinates on the map
    private let globalScalar = EditableConfigValue(
        fallback: DefaultTerrainData.globalScalar,
        label: "Global scalar")
    
    /// FMB values for elevation noise generation
    private let elevationValues = EditableFBMConfigValues(defaultData: DefaultTerrainData.elevationFMB)
    
    /// As a float, how far off of zero we should make sea level
    private let seaLevelOffset = EditableConfigValue(
        fallback: DefaultTerrainData.seaLevelOffset,
        label: "Sea level offset")
    
    /// The distribution of values (spiky or not) for elevation
    private let elevationDistribution = EditableConfigValue(
        fallback: DefaultTerrainData.elevationDistribution,
        label: "Elevation distribution")
    
    /// How much elevation contributes to color of the biome
    private let elevationColorWeight = EditableConfigValue(
        fallback: DefaultTerrainData.elevationColorWeight,
        label: "Color weight")
    
    /// FMB values for moisture noise generation
    private let moistureValues = EditableFBMConfigValues(defaultData: DefaultTerrainData.moistureFMB)
    
    /// How dry "default" is on the map
    private let aridness = EditableConfigValue(
        fallback: DefaultTerrainData.aridness,
        label: "Aridness")
    
    /// The distribution of values (spiky or not) for moisture
    private let moistureDistribution = EditableConfigValue(
        fallback: DefaultTerrainData.moistureDistribution,
        label: "Moisture distribution")
    
    /// How much moisture contributes to color of the biome
    private let moistureColorWeight = EditableConfigValue(
        fallback: DefaultTerrainData.moistureColorWeight,
        label: "Color weight")
    
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
        spacing = SidePanelViewController.interItemSpacing
        
        let sharedView = EditableValuesStackView(title: "Global Config")
        sharedView.addValue(seed)
        sharedView.addValue(globalScalar)
        addView(sharedView)
        
        let elevationView = EditableValuesStackView(title: "Elevation Config")
        elevationValues.addValues(to: elevationView)
        elevationView.addValue(seaLevelOffset)
        elevationView.addValue(elevationDistribution)
        elevationView.addValue(elevationColorWeight)
        addView(elevationView)
        
        let moistureView = EditableValuesStackView(title: "Moisture Config")
        moistureValues.addValues(to: moistureView)
        moistureView.addValue(aridness)
        moistureView.addValue(moistureDistribution)
        moistureView.addValue(moistureColorWeight)
        addView(moistureView)
    }

}

// MARK: - ShaderDataProviderProtocol

/// Creates a bunch of biomes & offers config support from this view's text fields
extension TerrainConfigView: ShaderDataProviderProtocol {
    
    /// Config data for generation of noise, pulls data from text fields if they exist
    var configData: TerrainShaderConfigData {
        let elevationGenerator = FBMData(
            octaves: elevationValues.octaves.value,
            persistence: elevationValues.persistence.value,
            scale: elevationValues.scale.value,
            compression: elevationValues.compression.value,
            seed: Self.seed(from: seed.value))
        let moistureGenerator = FBMData(
            octaves: moistureValues.octaves.value,
            persistence: moistureValues.persistence.value,
            scale: moistureValues.scale.value,
            compression: moistureValues.compression.value,
            seed: Self.seed(from: seed.value))
        return TerrainShaderConfigData(
            numBiomes: Int32(allBiomes.count),
            elevationColorWeight: elevationColorWeight.value,
            moistureColorWeight: moistureColorWeight.value,
            globalScalar: globalScalar.value,
            seaLevelOffset: seaLevelOffset.value,
            elevationDistribution: elevationDistribution.value,
            aridness: aridness.value,
            moistureDistribution: moistureDistribution.value,
            elevationGenerator: elevationGenerator,
            moistureGenerator: moistureGenerator)
    }
    
    /// Bunch of biomes with different elevation and moistures
    var allBiomes: [Biome] {
        return Biome.defaultBiomes
    }
    
}
