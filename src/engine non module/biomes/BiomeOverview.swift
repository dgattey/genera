// BiomeOverview.swift
// Copyright (c) 2020 Dylan Gattey

import AppKit
import DataStructures

/// Shows all biomes in a grid
class BiomeOverview: NSView {
    /// Min height of view
    private static let minHeight: CGFloat = 100

    /// Min width of view
    private static let minWidth: CGFloat = 200

    /// Keeps track of string to value
    private var biomes: [String: (biome: Biome, layer: CALayer)] = [:]

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        translatesAutoresizingMaskIntoConstraints = false
        autoresizesSubviews = false
        wantsLayer = true
        draw(.infinite)
    }

    override func draw(_: NSRect) {
        let width = Float(max(bounds.width, BiomeOverview.minWidth))
        let height = Float(max(bounds.height, BiomeOverview.minHeight))
        let origin = CGPoint(x: 0, y: 0)

        for (biome, sublayer) in biomes.values {
            let moistureUnit = CGFloat(min(max(biome.maxMoisture * width, 0), width))
            let elevationStartUnit = CGFloat(min(max(biome.minElevation * height, 0), height))
            let elevationEndUnit = CGFloat(min(max(biome.maxElevation * height, 0), height))
            let area = CGRect(
                x: origin.x,
                y: origin.y + elevationStartUnit,
                width: moistureUnit,
                height: elevationEndUnit - elevationStartUnit
            )
            sublayer.backgroundColor = biome.nsColor.cgColor
            sublayer.frame = area
        }
    }
}

// MARK: - BiomeChangeDelegate

extension BiomeOverview: BiomeChangeDelegate {
    /// Updates the grid with the new data at the right index and adds a view for it to this subview
    func biome(withIdentifier id: String, didUpdateTo biome: Biome) {
        wantsLayer = true
        if let (_, existingLayer) = biomes[id] {
            biomes[id] = (biome, existingLayer)
        } else {
            let sublayer = CALayer()
            layer?.insertSublayer(sublayer, at: 0)
            biomes[id] = (biome, sublayer)
        }
        draw(.infinite)
    }
}
