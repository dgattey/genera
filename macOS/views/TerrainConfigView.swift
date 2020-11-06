//
//  TerrainConfigView.swift
//  Genera
//
//  Created by Dylan Gattey on 11/5/20.
//

import Cocoa

/// A stack view containing text fields for certain configurable data
class TerrainConfigView: NSStackView, NSTextFieldDelegate {
    
    weak var updateDelegate: TerrainConfigUpdateDelegate?
    
    private let elevationOctaves = EditableConfigValue(
        fallback: DefaultTerrainData.elevationFMB.octaves,
        label: "Elevation Octaves")
    private let elevationPersistence = EditableConfigValue(
        fallback: DefaultTerrainData.elevationFMB.persistence,
        label: "Elevation Persistence")
    private let elevationScale = EditableConfigValue(
        fallback: DefaultTerrainData.elevationFMB.scale,
        label: "Elevation Scale")
    private let moistureOctaves = EditableConfigValue(
        fallback: DefaultTerrainData.moistureFMB.octaves,
        label: "Moisture Octaves")
    private let moisturePersistence = EditableConfigValue(
        fallback: DefaultTerrainData.moistureFMB.persistence,
        label: "Moisture Persistence")
    private let moistureScale = EditableConfigValue(
        fallback: DefaultTerrainData.moistureFMB.scale,
        label: "Moisture Scale")
    
    /// Add our views!
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        orientation = .vertical
        alignment = .leading
        distribution = .fill
        
        /// Adds all the views
        LabeledView.addLabel("Shader Config", style: .section, toStack: self)
        addValue(elevationOctaves)
        addValue(elevationPersistence)
        addValue(elevationScale)
        addValue(moistureOctaves)
        addValue(moisturePersistence)
        addValue(moistureScale)
    }
    
    /// Adds the text field from the value to this stack view
    private func addValue<T>(_ value: EditableConfigValue<T>) {
        value.field.delegate = self
        LabeledView.addView(value.field, labeledWith: value.label, toStack: self)
    }
    
    func controlTextDidChange(_ obj: Notification) {
        guard (obj.object as? NSTextField) != nil else {
            return
        }
        updateDelegate?.configDidUpdate()
    }

}

// MARK: - ShaderDataProvider

/// Creates a bunch of biomes & offers config support from this view's text fields
extension TerrainConfigView: ShaderDataProvider {
    
    /// Config data for generation of noise, pulls data from text fields if they exist
    var configData: TerrainShaderConfigData {
        let elevationGenerator = FBMData(
            octaves: elevationOctaves.value,
            persistence: elevationPersistence.value,
            scale: elevationScale.value)
        let moistureGenerator = FBMData(
            octaves: moistureOctaves.value,
            persistence: moisturePersistence.value,
            scale: moistureScale.value)
        return TerrainShaderConfigData(
            numBiomes: Int32(allBiomes.count),
            elevationColorWeight: 0.2,
            moistureColorWeight: 0.1,
            globalScalar: 0.01,
            elevationGenerator: elevationGenerator,
            moistureGenerator: moistureGenerator)
    }
    
    /// Bunch of biomes with different elevation and moistures
    var allBiomes: [Biome] {
        return Biome.defaultBiomes
    }
    
}
