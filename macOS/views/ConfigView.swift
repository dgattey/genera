//
//  ConfigView.swift
//  Genera
//
//  Created by Dylan Gattey on 11/5/20.
//

import Cocoa

/// A stack view containing text fields for certain configurable data
class ConfigView: NSStackView {
    
    private let elevationOctaves: NSTextField = NSTextField(string: "8")
    private let elevationPersistence: NSTextField = NSTextField(string: "0.23")
    private let elevationScale: NSTextField = NSTextField(string: "0.221")
    private let moistureOctaves: NSTextField = NSTextField(string: "12")
    private let moisturePersistence: NSTextField = NSTextField(string: "0.111")
    private let moistureScale: NSTextField = NSTextField(string: "0.2322")
    
    /// Add our views!
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        orientation = .vertical
        alignment = .leading
        distribution = .fill
        LabeledView.addLabel("Shader Config", style: .section, toStack: self)
        LabeledView.addView(elevationOctaves, labeledWith: "Elevation Octaves", toStack: self)
        LabeledView.addView(elevationPersistence, labeledWith: "Elevation Persistence", toStack: self)
        LabeledView.addView(elevationScale, labeledWith: "Elevation Scale", toStack: self)
        LabeledView.addView(moistureOctaves, labeledWith: "Moisture Octaves", toStack: self)
        LabeledView.addView(moisturePersistence, labeledWith: "Moisture Persistence", toStack: self)
        LabeledView.addView(moistureScale, labeledWith: "Moisture Scale", toStack: self)
    }
    
    /// Returns the value of the field as a casted optional value
    private static func value<T: Hashable>(from field: NSTextField?) -> T? {
        return field?.stringValue as? T
    }

}

// MARK: - TerrainShaderDataProvider

/// Creates a bunch of biomes & offers config support from this view's text fields
extension ConfigView: TerrainShaderDataProvider {
    
    /// Bunch of biomes with different elevation and moistures
    var allBiomes: [Biome] {
        return Biome.defaultBiomes
    }
    
    /// Config data for generation of noise, pulls data from text fields if they exist
    var configData: TerrainShaderConfigData {
        let elevationGenerator = FBMData(
            octaves: ConfigView.value(from: elevationOctaves) ?? 14,
            persistence: ConfigView.value(from: elevationPersistence) ?? 0.71,
            scale: ConfigView.value(from: elevationScale) ?? 0.01)
        let moistureGenerator = FBMData(
            octaves: ConfigView.value(from: moistureOctaves) ?? 6,
            persistence: ConfigView.value(from: moisturePersistence) ?? 0.31,
            scale: ConfigView.value(from: moistureScale) ?? 0.1)
        return TerrainShaderConfigData(
            elevationColorWeight: 0.2,
            moistureColorWeight: 0.1,
            globalScalar: 0.01,
            elevationGenerator: elevationGenerator,
            moistureGenerator: moistureGenerator)
    }
    
}
