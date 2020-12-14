// Biome+NSColor.swift
// Copyright (c) 2020 Dylan Gattey

import AppKit
import EngineData

/// Adds color support to Biome
extension Biome {
    /// The NSColor representation of this biome's color
    var nsColor: NSColor {
        NSColor(red: CGFloat(color.x),
                green: CGFloat(color.y),
                blue: CGFloat(color.z),
                alpha: 1.0)
    }
}
