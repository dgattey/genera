// BiomeOverview.swift
// Copyright (c) 2020 Dylan Gattey

import AppKit
import Combine
import EngineCore
import EngineData

/// Shows all biomes in a grid
public class BiomeOverview: NSView {
    // MARK: - variables

    /// Min height of view
    private static let minHeight: CGFloat = 100

    /// Min width of view
    private static let minWidth: CGFloat = 200

    /// Keeps track of label to combo of biome and the layer it appears in
    private var biomes: [String: (biome: Biome, layer: CALayer)] = [:]

    /// Keeps track of subscriptions to changes
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - initialization

    override public func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        translatesAutoresizingMaskIntoConstraints = false
        autoresizesSubviews = false
        wantsLayer = true
        draw(.infinite)
    }

    // MARK: - drawing

    override public func draw(_: NSRect) {
        let width = Float(max(bounds.width, BiomeOverview.minWidth))
        let height = Float(max(bounds.height, BiomeOverview.minHeight))
        let origin = CGPoint(x: 0, y: 0)

        for (biome, sublayer) in biomes.values {
            let moistureUnit = CGFloat(min(max(biome.maxMoisture * width, 0), width))
            let elevationStartUnit = CGFloat(min(max(biome.minElevation * height, 0), height))
            let elevationEndUnit = CGFloat(min(max(biome.maxElevation * height, 0), height))
            let area = CGRect(x: origin.x,
                              y: origin.y + elevationStartUnit,
                              width: moistureUnit,
                              height: elevationEndUnit - elevationStartUnit)
            sublayer.backgroundColor = biome.nsColor.cgColor
            sublayer.frame = area
        }
    }

    /// Sets up subscriptions to update the grid with the new data at the right index
    /// and add a view for it to this subview
    public func connect(to container: EditableBiomeValues) {
        // Reset to original values, removing the layers and subscriptions existing
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll()
        biomes.values.forEach { $0.layer.removeFromSuperlayer() }
        biomes.removeAll()

        // For each editable value, grab the subjects and set them up
        container.data.forEach { datum in
            let (label, biome) = datum
            biome.sink { [unowned self] newBiome in
                // When we have a new value for a biome, make sure we have a layer
                // and it's saved in our datastore
                let existing = biomes[label]
                let sublayer = existing?.layer ?? CALayer()
                if sublayer.superlayer == nil {
                    layer?.insertSublayer(sublayer, at: 0)
                }
                biomes[label] = (newBiome, sublayer)
                draw(.infinite)
            }
            .store(in: &subscriptions)
        }
    }
}
