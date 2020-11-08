//
//  TerrainConfigView.swift
//  Genera
//
//  Created by Dylan Gattey on 11/5/20.
//

import Cocoa

/// A stack view containing text fields for certain configurable data
class TerrainConfigView: NSStackView {
    
    weak var updateDelegate: TerrainConfigUpdateDelegate? {
        didSet {
            sharedView.updateDelegate = updateDelegate
            elevationView.updateDelegate = updateDelegate
            moistureView.updateDelegate = updateDelegate
        }
    }
    
    private lazy var sharedView = EditableValuesStackView(title: "Global Config")
    private let globalScalar = EditableConfigValue(
        fallback: DefaultTerrainData.globalScalar,
        label: "Global scalar")
    
    private lazy var elevationView = EditableValuesStackView(title: "Elevation Config")
    private let elevationValues = EditableFBMConfigValues(defaultData: DefaultTerrainData.elevationFMB)
    private let elevationColorWeight = EditableConfigValue(
        fallback: DefaultTerrainData.elevationColorWeight,
        label: "Color weight")
    
    private lazy var moistureView = EditableValuesStackView(title: "Moisture Config")
    private let moistureValues = EditableFBMConfigValues(defaultData: DefaultTerrainData.moistureFMB)
    private let moistureColorWeight = EditableConfigValue(
        fallback: DefaultTerrainData.moistureColorWeight,
        label: "Color weight")
    
    /// Adds a nested stack view with equal widths
    private func addView(_ view: EditableValuesStackView) {
        view.updateDelegate = updateDelegate
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
        
        sharedView.addValue(globalScalar)
        addView(sharedView)
        
        elevationView.addFBMValues(elevationValues)
        elevationView.addValue(elevationColorWeight)
        addView(elevationView)
        
        moistureView.addFBMValues(moistureValues)
        moistureView.addValue(moistureColorWeight)
        addView(moistureView)
    }

}

// MARK: - ShaderDataProvider

/// Creates a bunch of biomes & offers config support from this view's text fields
extension TerrainConfigView: ShaderDataProvider {
    
    /// Config data for generation of noise, pulls data from text fields if they exist
    var configData: TerrainShaderConfigData {
        let elevationGenerator = FBMData(
            octaves: elevationValues.octaves.value,
            persistence: elevationValues.persistence.value,
            scale: elevationValues.scale.value,
            frequency: elevationValues.frequency.value,
            compression: elevationValues.compression.value)
        let moistureGenerator = FBMData(
            octaves: moistureValues.octaves.value,
            persistence: moistureValues.persistence.value,
            scale: moistureValues.scale.value,
            frequency: moistureValues.frequency.value,
            compression: moistureValues.compression.value)
        return TerrainShaderConfigData(
            numBiomes: Int32(allBiomes.count),
            elevationColorWeight: elevationColorWeight.value,
            moistureColorWeight: moistureColorWeight.value,
            globalScalar: globalScalar.value,
            elevationGenerator: elevationGenerator,
            moistureGenerator: moistureGenerator)
    }
    
    /// Bunch of biomes with different elevation and moistures
    var allBiomes: [Biome] {
        return Biome.defaultBiomes
    }
    
}
